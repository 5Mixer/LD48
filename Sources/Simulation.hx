package ;

import nape.geom.Vec2;
import nape.space.Space;

class Simulation {
    var space:Space;
    var grid:Grid;
    var dynamite:Array<Dynamite> = [];
    var launchers:Array<Launcher> = [];
    var explosions = new ParticleSystem();

    public var money = 0;
    public var mineralValues = [0, 5, 10, 30, 50];
 
    public function new() {
        var gravity = Vec2.weak(0, 600);
        space = new Space(gravity);
 
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
    }

    function explosion(x,y,force) {
        var explosionOrigin = Vec2.get(x*20, 600 + y*20);

        explosions.explode(explosionOrigin.x,explosionOrigin.y,force);
        
        for (localx in Math.floor(-force/2)...Math.ceil(force/2)) {
            for (localy in Math.floor(-force/2)...Math.ceil(force/2)) {
                if (Math.abs(localx)+Math.abs(localy) < force) {
                    
                    var tile = grid.getTile(x+localx, y+localy);
                    money += mineralValues[tile];
                    
                    grid.remove(x + localx,y + localy);
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
        explosion(Math.round(explodedDynamite.getPosition().x/20), Math.round((explodedDynamite.getPosition().y-600)/20), 5);
        dynamite.remove(explodedDynamite);
    }

    public function update(delta:Float) {
        space.step(1/60);

        for (dynamite in dynamite) {
            dynamite.update(delta);
        }
        for (launcher in launchers) {
            launcher.update(delta);
        }
        grid.update();
        explosions.update(delta);
    }
    public function render(g:Graphics) {
        grid.render(g);
        for (dynamite in dynamite) {
            dynamite.render(g);
        }
        for (launcher in launchers) {
            launcher.render(g);
        }
        explosions.render(g);
    }
}