package ;

import nape.geom.Vec2;
import nape.space.Space;

class Simulation {
    var space:Space;
    var grid:Grid;
    var dynamite:Array<Dynamite> = [];
 
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

        for (i in 0...400) {
            dynamite.push(new Dynamite(i%70*20,Math.floor(i/70)*20, space, dynamiteExplosion));
        }
    }

    function explosion(x,y,force) {
        var explosionOrigin = Vec2.get(x*20, 600 + y*20);
        
        for (localx in Math.floor(-force/2)...Math.ceil(force/2)) {
            for (localy in Math.floor(-force/2)...Math.ceil(force/2)) {
                if (Math.abs(localx)+Math.abs(localy) < force)
                    grid.remove(x + localx,y + localy);
            }
        }

        var explosionForceEffect = 20;

        for (body in space.bodiesInCircle(explosionOrigin, force * 20)) {
            var deltaVector = body.position.sub(explosionOrigin);
            deltaVector.length = explosionForceEffect * force*20/deltaVector.length;
            body.applyImpulse(deltaVector);
        }
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
        grid.update();
    }
    public function render(g:Graphics) {
        grid.render(g);
        for (dynamite in dynamite) {
            dynamite.render(g);
        }
    }
}