package entity;

import nape.geom.Vec2;
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

	public var life:Float = 0;

	public var lastBodyPosition:Vec2; // An optimisation for trails that caches the physics work (rather than reintegrating)

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);

		body.position.setxy(x, y);
		lastBodyPosition = Vec2.get(x, y);
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

	var movementAngle = 0.;

	public function update(delta:Float) {
		life += delta;
		movementAngle = body.position.sub(lastBodyPosition).angle;
	}

	public function render(g:Graphics) {
		var tangentx = Math.cos(movementAngle + Math.PI / 2) * 5;
		var tangenty = Math.sin(movementAngle + Math.PI / 2) * 5;
		g.fillTriangle(body.position.x + tangentx, body.position.y + tangenty, body.position.x - tangentx, body.position.y - tangenty, lastBodyPosition.x,
			lastBodyPosition.y);

		g.drawScaledImage(kha.Assets.images.bullet, body.position.x - 5, body.position.y - 5, 10, 10);
		lastBodyPosition.x = body.position.x;
		lastBodyPosition.y = body.position.y;
	}
}
