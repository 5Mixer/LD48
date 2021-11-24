package entity.util;

class DamageColour {
	var damageTime = 0.;

	public function new() {}

	public function damage() {
		damageTime = Math.min(damageTime + .1, 1);
	}

	public function getColour() {
		var damageColour = Math.min(1, 1 - damageTime);
		return kha.Color.fromFloats(1, damageColour, damageColour);
	}

	public function update(delta:Float) {
		damageTime *= .9;
	}
}
