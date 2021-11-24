package entity;

import entity.util.DamageColour;
import nape.geom.Vec2;
import kha.math.Vector2;
import nape.phys.Material;
import physics.CollisionLayers;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import kha.graphics2.Graphics;
import nape.shape.Circle;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.space.Space;

class Spikey {
	public var body:Body;

	public static var callbackType = new CbType();

	public var target:Vector2;

	public var health = 3000;

	public var damage = 5;

	var damageColour = new DamageColour();

	final radius = 50;
	var maxVelocity = 700 + Math.random() * 400;

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);
		body.position.setxy(x, y);

		body.shapes.add(new Circle(20));
		var material = Material.steel();
		material.density = .2;
		body.setShapeMaterials(material);
		body.setShapeFilters(new InteractionFilter(CollisionLayers.ENEMY));
		body.space = space;

		body.userData.spikey = this;

		body.cbTypes.add(callbackType);
	}

	public function render(g:Graphics) {
		g.color = damageColour.getColour();
		GraphicsHelper.drawImage(g, kha.Assets.images.spikey, body.position.x - radius / 2, body.position.y - radius / 2, radius, radius, body.rotation);
		g.color = kha.Color.White;
	}

	public function receiveDamage(damage:Int) {
		health -= damage;
		damageColour.damage();
	}

	public function update(delta:Float) {
		damageColour.update(delta);

		if (target != null) {
			var impulse = target.sub(new Vector2(body.position.x, body.position.y));
			impulse.length = Math.max(2, Math.min(impulse.length / 30, 10));
			impulse.length = 4;
			body.applyImpulse(Vec2.weak(impulse.x, impulse.y));
		}
		if (body.velocity.length > maxVelocity) {
			body.velocity.length = maxVelocity;
		}
	}
}
