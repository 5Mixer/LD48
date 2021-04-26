package ;

import nape.shape.Polygon;
import nape.phys.BodyType;
import nape.phys.Body;
import kha.audio1.AudioChannel;
import nape.geom.Ray;
import kha.math.Vector2;
import kha.audio1.Audio;
import nape.geom.Vec2;
import nape.space.Space;

class Simulation {
    var space:Space;
    var grid:Grid;
    
    var player:Player;
    
    var dynamite:Array<Dynamite> = [];
    var launchers:Array<Launcher> = [];
    var explosions = new ParticleSystem();
    
    public var camera:Camera;
    public var input:Input;
    
    public var money = 0;
    public var mineralValues = [0, 5, 10, 30, 50, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150]; // Yes, the tiles are out of order. Yes, this is probably the worst code I've ever written.
    
    var audioChannels:Array<AudioChannel> = [];
    var laserSound:AudioChannel;
    
    var reload = 0.;
    var rayDistance = 0.;

    public var dynamiteForce = 1;
    public var dynamiteSpeed = 1;
    public var laserLevel = 0;
    
    public function new() {
        var gravity = Vec2.weak(0, 600);
        space = new Space(gravity);
        
        camera = new Camera();
        input = new Input(camera);
        
        input.onScroll = function(delta) {
            camera.zoomOn(camera.worldToView(new Vector2(player.body.position.x,player.body.position.y)), delta);
        }
        
        laserSound = Audio.play(kha.Assets.sounds.laser, true);
        laserSound.volume = 0;
        
        initialise();
    }
    
    public function initialise() {
        var w = 6000;
        var h = 900;
        
        dynamite = [];
        space.clear();

        var walls = new Body(BodyType.STATIC);
        walls.shapes.add(new Polygon(Polygon.rect(-100,-10000, 100, 1000000)));
        walls.shapes.add(new Polygon(Polygon.rect(3000,-10000, 100, 1000000)));
        walls.space = space;
        
        grid = new Grid(space);

        grid.tileRemovalCallback = function(tile) {
            money += mineralValues[tile];
        }
        
        player = new Player(600, 540, space);
    }
    
    function explosion(x,y,force:Float, vx=0., vy=0.) {
        var explosionOrigin = Vec2.get(x*20, 600 + y*20);
        
        explosions.explode(explosionOrigin.x,explosionOrigin.y, 90, vx,vy);
        
        var forceSquared = force*force/4;
        
        for (localx in Math.floor(-force/2)...Math.ceil(force/2)) {
            for (localy in Math.floor(-force/2)...Math.ceil(force/2)) {
                var distanceSquared = Math.pow(localx,2)+Math.pow(localy,2);
                if (distanceSquared < forceSquared) {
                    grid.damage(x + localx,y + localy, Math.ceil(50 * (1-distanceSquared/forceSquared)));
                }
            }
        }
        
        var explosionForceEffect = 40;
        
        for (body in space.bodiesInCircle(explosionOrigin, force * 20)) {
            var deltaVector = body.position.sub(explosionOrigin);
            deltaVector.length = explosionForceEffect * force*20/deltaVector.length;
            body.applyImpulse(deltaVector);
        }
    }

    public function stop() {
        laserSound.stop();
        player.flyingSound.stop();
        for (channel in audioChannels)
            channel.stop();
    }

    public function laserPurchase() {
        laserLevel++;
    }
    public function dynamiteSpeedPurchase() {
        dynamiteSpeed++;
    }
    public function dynamiteForcePurchase() {
        dynamiteForce++;
    }
    
    function launcherCallback(launcher:Launcher) {
        var newDynamite = new Dynamite(launcher.position.x, launcher.position.y, space, dynamiteExplosion);
        newDynamite.body.applyImpulse(Vec2.weak(300,-200));
        dynamite.push(newDynamite);
    }
    
    public function dynamiteExplosion(explodedDynamite:Dynamite) {
        var movementVector = explodedDynamite.body.velocity.copy();
        if (movementVector.length > 0) {
            movementVector.length = Math.min(5, 2 + movementVector.length/50);
        }
        
        if (audioChannels.length > 5) {
            audioChannels.shift().stop();
        }
        audioChannels.push(Audio.play(kha.Assets.sounds.get('explosion'+(1+Math.floor(Math.random()*6)))));
        
        explosion(Math.round(explodedDynamite.getPosition().x/20), Math.round((explodedDynamite.getPosition().y-600)/20), 4+dynamiteForce * (2 +Math.random() * .4), movementVector.x, movementVector.y);
        dynamite.remove(explodedDynamite);
    }
    
    public function update(delta:Float) {
        camera.follow(player.getPosition().x,player.getPosition().y);

        space.step(1/60);
        
        reload -= delta;
        
        var directionVector = Vec2.get(input.getMouseWorldPosition().x, input.getMouseWorldPosition().y).sub(player.body.position).muleq(1000);
        var ray = space.rayCast(Ray.fromSegment(player.body.position, player.body.position.add(directionVector, true)));
        if (ray != null) {
            rayDistance = ray.distance;
        }else{
            rayDistance = 6000;
        }
        
        for (audioChannel in audioChannels) {
            if (audioChannel.finished) {
                audioChannels.remove(audioChannel);
            }
        }
        
        for (dynamite in dynamite) {
            dynamite.update(delta);
        }
        for (launcher in launchers) {
            launcher.update(delta);
        }
        
        if (input.right() && reload <= 0.) {
            var vector = input.getMouseWorldPosition().sub(new Vector2(player.body.position.x, player.body.position.y)).normalized();
            var d = new Dynamite(player.body.position.x + vector.x * 25, player.body.position.y + vector.y * 25, space, dynamiteExplosion);
            var speed = 600;
            d.body.velocity.x = vector.x * speed;
            d.body.velocity.y = vector.y * speed;
            dynamite.push(d);
            
            var fireSound = kha.audio1.Audio.play(kha.Assets.sounds.fire);
            fireSound.volume = .3 + Math.random() * .1;
            
            reload = 1.3 / dynamiteSpeed;
        }
        
        if (input.middle() && laserLevel > 0) {
            laserSound.volume = 1;
            
            if (ray != null) {
                if (ray.shape != null && ray.shape.body != null && ray.shape.body.userData != null && ray.shape.body.userData.data != null) {
                    switch (cast(ray.shape.body.userData.data, BodyData)) {
                        case Tile(x,y): {
                            grid.damage(x,y, 1 + 2 * laserLevel);
                        }
                        case Dynamite(laserDynamite): {
                            laserDynamite.explode();
                        }
                    }
                }
            }
        }else{
            laserSound.volume *= .6;
        }
        
        player.update(delta, input);
        grid.update();
        explosions.update(delta);
    }
    public function render(g:Graphics) {
        g.g.color = kha.Color.fromValue(0xffb4d8f5);
        g.g.fillRect(0, -10000, 3000, 10100);
        g.g.color = kha.Color.White;
        
        g.drawImage(kha.Assets.images.background, 0, 600-594, 3000, 594);
        explosions.render(g);
        grid.render(g);
        
        if (input.middle() && laserLevel > 0) {
            g.drawLaser(player.body.position.x, player.body.position.y, Math.atan2(input.getMouseWorldPosition().y-player.body.position.y, input.getMouseWorldPosition().x-player.body.position.x), rayDistance);
        }
        
        player.render(g);
        
        var turretVector = input.getMouseWorldPosition().sub(new Vector2(player.body.position.x, player.body.position.y)).normalized();
        if (laserLevel > 0)
            g.drawImage(kha.Assets.images.laser_attachment, player.body.position.x-40, player.body.position.y-40, 80, 80, Math.atan2(turretVector.y, turretVector.x));
        
        if (input.left())
            g.drawImage(kha.Assets.images.jet_attachment, player.body.position.x-40, player.body.position.y-40, 80, 80, Math.PI+Math.atan2(turretVector.y, turretVector.x));
        
        if (input.left() && player.body.velocity.length > 1) {
            var jetVector = turretVector.mult(-20);
            explosions.explode(player.body.position.x,player.body.position.y, 10, jetVector.x, jetVector.y);
        }
        
        for (dynamite in dynamite) {
            dynamite.render(g);
        }
        for (launcher in launchers) {
            launcher.render(g);
        }
    }
}