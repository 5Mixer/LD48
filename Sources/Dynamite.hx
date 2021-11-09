package;

import kha.graphics2.Graphics;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;

class Dynamite {
	public var body:Body;

	var timer:Float;
	var explodeCallback:(Dynamite) -> Void;

	public function new(x:Float, y:Float, space:Space, explodeCallback:(Dynamite) -> Void) {
		body = new Body(BodyType.DYNAMIC);

		timer = 2 + Math.random() * .5;
		this.explodeCallback = explodeCallback;

		body.shapes.add(new Polygon(Polygon.box(10, 20)));
		body.position.setxy(x, y);
		body.setShapeMaterials(nape.phys.Material.glass());
		body.angularVel = Math.random() * 2 - 1;
		body.rotation = Math.PI * 2 * Math.random();
		body.userData.data = BodyData.Dynamite(this);
		body.space = space;
	}

	public function render(g:Graphics) {
		GraphicsHelper.drawImage(g, kha.Assets.images.dynamite, body.position.x - 5, body.position.y - 10, 10, 20, body.rotation);
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

	public function explode() {
		body.space = null;
		explodeCallback(this);
	}
}
