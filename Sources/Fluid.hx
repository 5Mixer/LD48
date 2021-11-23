package;

import nape.phys.Material;
import nape.phys.BodyType;
import kha.graphics2.Graphics;
import nape.shape.Circle;
import nape.space.Space;
import nape.phys.Body;

class FluidGlob {
	public var body:Body;

	public function new(x:Float, y:Float, space:Space) {
		body = new Body(BodyType.DYNAMIC);
		body.position.setxy(x, y);
		var circleShape = new Circle(10);
		circleShape.material = Material.rubber();
		circleShape.material.rollingFriction = 0;
		circleShape.material.dynamicFriction = 0;
		circleShape.material.staticFriction = 0;
		body.shapes.add(circleShape);
		body.allowRotation = false;
		body.space = space;
	}

	public function render(g:Graphics) {
		g.color = kha.Color.fromFloats(1, 1, 1, .3);
		g.fillRect(body.position.x - 5, body.position.y - 5, 10, 10);
		g.color = kha.Color.White;
	}
}

class Fluid {
	public var globs:Array<FluidGlob> = [];

	public function new(space:Space) {
		for (_ in 0...1000) {
			globs.push(new FluidGlob(100 + Math.random() * 200, Math.random() * 10 - 300, space));
		}
	}

	public function render(g:Graphics) {
		for (glob in globs) {
			glob.render(g);
		}
	}
}
