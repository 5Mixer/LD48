package particle;

import kha.math.Vector2;

class Particle {
	public var position:Vector2 = new Vector2();
	public var velocity:Vector2 = new Vector2();
	public var size:Float = 1;
	public var life:Float = 0;
	public var lifetime:Float = 0;
	public var colour:kha.Color = kha.Color.White;
	public var gradient:kha.Image;

	public function new() {}
}
