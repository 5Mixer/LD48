package entity;

import physics.CollisionLayers;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import kha.graphics2.Graphics;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.space.Space;
import nape.phys.Body;

class Bullet {
	public var body:Body;

	public static var callbackType = new CbType();

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);

		body.position.setxy(x, y);
		body.isBullet = true;
		body.mass = 0.00001;
		body.allowRotation = false;

		body.shapes.add(new Circle(5));
		body.setShapeMaterials(nape.phys.Material.glass());
		body.setShapeFilters(new InteractionFilter(CollisionLayers.BULLET, CollisionLayers.TILE));

		body.userData.bullet = this;
		body.cbTypes.add(callbackType);

		body.space = space;
	}

	inline public function setVelocity(x:Float, y:Float) {
		body.velocity.x = x;
		body.velocity.y = y;
	}

	public function render(g:Graphics) {
		GraphicsHelper.drawImage(g, kha.Assets.images.bullet, body.position.x - 5, body.position.y - 5, 10, 10, body.rotation);
	}
}
