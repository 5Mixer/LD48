package entity;

import entity.util.DamageColour;
import physics.CollisionLayers;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import kha.graphics2.Graphics;
import kha.audio1.AudioChannel;
import nape.geom.Vec2;
import kha.math.Vector2;
import nape.shape.Circle;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.space.Space;

class Player {
	public var body:Body;

	var visualRotation = 0.;
	var lastBodyRotation = 0.;

	public var flyingSound:AudioChannel;

	var flyingVolume = .3;

	public var health = 10000;
	public var maxHealth = 10000;

	public static var callbackType = new CbType();

	var damageColour = new DamageColour();

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);
		body.position.setxy(x, y);

		body.shapes.add(new Circle(30));
		body.setShapeMaterials(nape.phys.Material.steel());
		body.setShapeFilters(new InteractionFilter(CollisionLayers.PLAYER));
		body.space = space;

		body.userData.player = this;

		body.cbTypes.add(callbackType);

		flyingSound = kha.audio1.Audio.play(kha.Assets.sounds.flying, true);
		flyingSound.volume = 0;
	}

	public function render(g:Graphics) {
		visualRotation -= (lastBodyRotation - body.rotation) * .3;
		visualRotation *= .9;
		g.color = damageColour.getColour();
		GraphicsHelper.drawImage(g, kha.Assets.images.player_bg, body.position.x - 30, body.position.y - 30, 60, 60, body.rotation);
		GraphicsHelper.drawImage(g, kha.Assets.images.player_fg, body.position.x - 30, body.position.y - 30, 60, 60, visualRotation);
		g.color = kha.Color.White;

		lastBodyRotation = body.rotation;
	}

	public function damage(damage:Int) {
		health -= damage;
		damageColour.damage();
	}

	public function getPosition() {
		return body.position;
	}

	public function update(delta:Float, input:Input) {
		if (input.shouldMove()) {
			#if kha_android_native
			var impulse = input.getMovementVector();
			#else
			var impulse = input.getMouseWorldPosition().sub(new Vector2(body.position.x, body.position.y));
			impulse = impulse.normalized();
			#end
			impulse.length *= 500;
			body.applyImpulse(Vec2.weak(impulse.x, impulse.y));
		}
		damageColour.update(delta);

		flyingSound.volume = (9 * flyingSound.volume + (input.shouldMove() ? flyingVolume : 0)) / 10;
	}
}
