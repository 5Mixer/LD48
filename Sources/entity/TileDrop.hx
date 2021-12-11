package entity;

import physics.CollisionLayers;
import kha.math.FastMatrix3;
import nape.shape.Polygon;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import kha.graphics2.Graphics;
import nape.phys.BodyType;
import nape.space.Space;
import nape.phys.Body;

class TileDrop {
	public var body:Body;

	public static var callbackType = new CbType();

	public var tile:Int;

	public var deathAge:Float = .4 + Math.random() * .4;

	public var age:Float = 0;

	public function new(x:Float, y:Float, tile:Int, space:Space) {
		body = new Body(BodyType.DYNAMIC);

		body.position.setxy(x, y);

		body.shapes.add(new Polygon(Polygon.box(10, 10)));
		body.setShapeMaterials(nape.phys.Material.glass());
		body.setShapeFilters(new InteractionFilter(CollisionLayers.TILE_DROP, CollisionLayers.TILE | CollisionLayers.LEVEL | CollisionLayers.EXPLOSION_FORCE));

		body.userData.bullet = this;
		body.cbTypes.add(callbackType);

		body.userData.drop = this;

		body.space = space;

		this.tile = tile;
	}

	inline public function setVelocity(x:Float, y:Float) {
		body.velocity.x = x;
		body.velocity.y = y;
	}

	public function render(g:Graphics) {
		var size = 30 - (age / deathAge) * 30;

		g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(body.position.x, body.position.y))
			.multmat(FastMatrix3.rotation(body.rotation))
			.multmat(FastMatrix3.translation(-body.position.x, -body.position.y)));

		g.drawScaledSubImage(kha.Assets.images.tile, (tile - 1) * 125, 125, 100, 100, body.position.x - size / 2, body.position.y - size / 2, size, size);
		g.popTransformation();
	}
}
