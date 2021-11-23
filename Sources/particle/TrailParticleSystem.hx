package particle;

import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class TrailParticle {
	public var startx:Float;
	public var starty:Float;
	public var endx:Float;
	public var endy:Float;
	public var size:Float = 1;
	public var life:Float = 0;
	public var lifetime:Float = 0;
	public var colour:kha.Color = kha.Color.White;

	public function new() {}
}

class TrailParticleSystem {
	var particles:Array<TrailParticle> = [];

	public function new() {}

	function getParticle() {
		var newParticle = new TrailParticle();
		particles.push(newParticle);
		return newParticle;
	}

	public function trail(startx:Float, starty:Float, endx:Float, endy:Float, life = 0.) {
		var p = getParticle();
		p.startx = startx;
		p.starty = starty;
		p.endx = endx;
		p.endy = endy;
		p.size = 6;
		p.life = life;
		p.lifetime = .03;
	}

	public function update(delta:Float) {
		for (particle in particles) {
			if (particle.life > particle.lifetime) {
				particles.remove(particle);
				continue;
			}
			particle.life += delta;
		}
	}

	public function render(g:Graphics) {
		for (particle in particles) {
			var life = Math.min(1, particle.life / particle.lifetime);
			// Experimented with tweaking colour/alpha, but alpha blending looks gross
			g.drawLine(particle.startx, particle.starty, particle.endx, particle.endy, (1 - life) * 10);
		}
	}
}
