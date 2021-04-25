package ;

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
    var input:Input;

    public var money = 0;
    public var mineralValues = [0, 5, 10, 30, 50];

    var audioChannels = [];

    var reload = 0.;
 
    public function new() {
        var gravity = Vec2.weak(0, 600);
        space = new Space(gravity);

        camera = new Camera();
        input = new Input(camera);

        input.onMouseMove = function(dx,dy) {
			if (input.middleMouseButtonDown) {
				camera.position.x -= dx;
				camera.position.y -= dy;
			}
		};
		input.onScroll = function(delta) {
            // camera.position.y += delta * 60;
			// if (mouseInUI()) {
			// 	ui.scroll(delta);
			// }else{
				camera.zoomOn(input.getMouseScreenPosition(), delta);
			// }
		}

        input.onLeftDown = function() {
            // Audio.play(kha.Assets.sounds.takeoff);
        }

        initialise();
    }
 
    public function initialise() {
        var w = 6000;
        var h = 900;

        dynamite = [];
        space.clear();
        
        grid = new Grid(space);

        for (i in 0...100) {
            // dynamite.push(new Dynamite(i%70*20,Math.floor(i/70)*20, space, dynamiteExplosion));
        }
        for (i in 0...5) {
            launchers.push(new Launcher(100+i*40, 600, launcherCallback));
        }

        player = new Player(600, 540, space);
    }

    function explosion(x,y,force:Float, vx=0., vy=0.) {
        var explosionOrigin = Vec2.get(x*20, 600 + y*20);

        explosions.explode(explosionOrigin.x,explosionOrigin.y,force,vx,vy);

        var forceSquared = force*force/4;
        
        for (localx in Math.floor(-force/2)...Math.ceil(force/2)) {
            for (localy in Math.floor(-force/2)...Math.ceil(force/2)) {
                var distanceSquared = Math.pow(localx,2)+Math.pow(localy,2);
                if (distanceSquared < forceSquared) {
                    
                    var tile = grid.getTile(x+localx, y+localy);
                    money += mineralValues[tile];
                    
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

        var force = 4+Math.random()*4;

        if (audioChannels.length > 5) {
            audioChannels.shift().stop();
        }
        audioChannels.push(Audio.play(kha.Assets.sounds.get('explosion'+(1+Math.floor(Math.random()*6)))));

        explosion(Math.round(explodedDynamite.getPosition().x/20), Math.round((explodedDynamite.getPosition().y-600)/20), force, movementVector.x, movementVector.y);
        dynamite.remove(explodedDynamite);
    }

    public function update(delta:Float) {
        space.step(1/60);

        reload -= delta;

        camera.position.y = player.getPosition().y - kha.Window.get(0).height/2;

        for (audioChannel in audioChannels) {
            if (audioChannel.finished)
                audioChannels.remove(audioChannel);
        }

        for (dynamite in dynamite) {
            dynamite.update(delta);
        }
        for (launcher in launchers) {
            launcher.update(delta);
        }

        if (input.rightMouseButtonDown && reload <= 0.) {
            var vector = input.getMouseWorldPosition().sub(new Vector2(player.body.position.x, player.body.position.y)).normalized();
            var d = new Dynamite(player.body.position.x + vector.x * 25, player.body.position.y + vector.y * 25, space, dynamiteExplosion);
            var speed = 600;
            d.body.velocity.x = vector.x * speed;
            d.body.velocity.y = vector.y * speed;
            dynamite.push(d);

            var fireSound = kha.audio1.Audio.play(kha.Assets.sounds.fire);
            fireSound.volume = .3 + Math.random() * .1;

            reload = .1;
        }

        player.update(delta, input);
        grid.update();
        explosions.update(delta);
    }
    public function render(g:Graphics) {
        explosions.render(g);
        grid.render(g);
        player.render(g);
        for (dynamite in dynamite) {
            dynamite.render(g);
        }
        for (launcher in launchers) {
            launcher.render(g);
        }
    }
}