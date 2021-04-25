package ;

import kha.math.FastMatrix3;
import kha.math.Vector2;
import kha.graphics2.Graphics;

class Camera {
	public var position:Vector2;
	public var scale:Float;
	var zoomSpeed = 1.09;
	var worldWidth = 3000;

	public function new () {
		position = new Vector2();
		scale = 1;
	}
	public function zoomOn(screenPoint:Vector2, amount:Float) {
		var oldWorldPos = viewToWorld(screenPoint);
		if (amount < 0) {
			scale *= -amount * zoomSpeed;
		} else {
			scale /= amount * zoomSpeed;
		} 
		scale = Math.max(0.5, scale);
		scale = Math.min(2, scale);
		// scale = Math.max(scale, kha.Window.get(0).width/worldWidth);
		var newWorldPos = viewToWorld(screenPoint);
		position = position.add(worldToView(oldWorldPos).sub(worldToView(newWorldPos)));
	}
	public function follow(x:Float,y:Float) {
		scale = Math.max(scale, kha.Window.get(0).width/worldWidth);
		position.x = scale*x-kha.Window.get(0).width/2;
		position.y = scale*y-kha.Window.get(0).height/2;
		position.x = Math.max(0, Math.min(position.x, scale*worldWidth - kha.Window.get(0).width));
	}
	public function worldToView(point:Vector2) {
		return point.mult(scale).sub(position);
	}
	public function viewToWorld(point:Vector2) {
		return point.add(position).mult(1/scale);
	}
	public function getTransformation() {
		return FastMatrix3.translation(-(position.x), -(position.y)).multmat(FastMatrix3.scale(scale, scale));
	}
	public function transform (g:Graphics) {
		g.pushTransformation(getTransformation());
	}
	public function reset (g:Graphics) {
		g.popTransformation();
	}
}