package;

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

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);

		body.shapes.add(new Circle(30));
		body.position.setxy(x, y);
		body.setShapeMaterials(nape.phys.Material.steel());
		body.space = space;

		flyingSound = kha.audio1.Audio.play(kha.Assets.sounds.flying, true);
		flyingSound.volume = 0;
	}

	public function render(g:Graphics) {
		visualRotation -= (lastBodyRotation - body.rotation) * .3;
		visualRotation *= .9;
		GraphicsHelper.drawImage(g, kha.Assets.images.player_bg, body.position.x - 30, body.position.y - 30, 60, 60, body.rotation);
		GraphicsHelper.drawImage(g, kha.Assets.images.player_fg, body.position.x - 30, body.position.y - 30, 60, 60, visualRotation);

		lastBodyRotation = body.rotation;
	}

	public function getPosition() {
		return body.position;
	}

	public function update(delta:Float, input:Input) {
		if (input.left()) {
			var impulse = input.getMouseWorldPosition().sub(new Vector2(body.position.x, body.position.y));
			impulse.length = Math.max(500, Math.min(impulse.length / 2, 800));
			body.applyImpulse(Vec2.weak(impulse.x, impulse.y));
		}

		flyingSound.volume = (9 * flyingSound.volume + (input.left() ? flyingVolume : 0)) / 10;
	}
}
