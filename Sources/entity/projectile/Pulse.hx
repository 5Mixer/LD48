package entity.projectile;

import nape.geom.Vec2;
import physics.CollisionLayers;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import kha.graphics2.Graphics;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.space.Space;
import nape.phys.Body;

class Pulse {
	public var body:Body;

	public static var callbackType = new CbType();

	public var life:Float = 0;

	var invisibleFrames = 1;
	var frame = 0;

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);

		body.position.setxy(x, y);
		body.isBullet = true;
		body.mass = 0.001;
		body.allowRotation = false;

		body.shapes.add(new Circle(5));
		body.setShapeMaterials(nape.phys.Material.glass());
		body.setShapeFilters(new InteractionFilter(CollisionLayers.BULLET, CollisionLayers.TILE | CollisionLayers.ENEMY));

		body.userData.pulse = this;
		body.cbTypes.add(callbackType);

		body.space = space;
	}

	public function update(delta:Float) {
		life += delta;
	}

	public function render(g:Graphics) {
		if (frame++ < invisibleFrames)
			return;

		g.color = kha.Color.fromFloats(.8, .8, .3, 1);
		var width = kha.Assets.images.beam.width;
		var height = kha.Assets.images.beam.height;
		GraphicsHelper.drawImage(g, kha.Assets.images.beam, body.position.x - width / 2, body.position.y - height / 2, width, height,
			Math.atan2(body.velocity.y, body.velocity.x));
		g.color = kha.Color.fromFloats(1, 1, .9, .7);
		g.drawScaledImage(kha.Assets.images.glow_particle, body.position.x - 300, body.position.y - 300, 600, 600);
	}
}
