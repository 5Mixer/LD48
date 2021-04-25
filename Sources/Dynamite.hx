package ;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;

class Dynamite {
    public var body:Body;
    var timer:Float;
    var explodeCallback:(Dynamite)->Void;
    public function new(x:Float, y:Float, space:Space, explodeCallback:(Dynamite)->Void) {
        body = new Body(BodyType.DYNAMIC);

        timer = 2 + Math.random() * .05;
        this.explodeCallback = explodeCallback;

        body.shapes.add(new Polygon(Polygon.box(10,20)));
        body.position.setxy(x, y);
        body.setShapeMaterials(nape.phys.Material.glass());
        body.angularVel = Math.random()*2-1;
        body.rotation = Math.PI * 2 * Math.random();
        body.space = space;
    }
    public function render(g:Graphics) {
        g.drawImage(kha.Assets.images.dynamite, body.position.x-5, body.position.y-10, 10, 20, body.rotation);
    }
    public function getPosition() {
        return body.position;
    }
    public function update(delta:Float) {
        timer -= delta;
        if (timer <= 0) {
            explode();
        }
    }

    function explode() {
        body.space = null;
        explodeCallback(this);
    }
}