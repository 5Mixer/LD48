package particle;

import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class ParticleSystem {
	var particles:Array<Particle> = [];

	public function new() {}

	function getParticle() {
		var newParticle = new Particle();
		particles.push(newParticle);
		return newParticle;
	}

	public function explode(x, y, particleCount, vx, vy) {
		for (i in 0...particleCount) {
			var angle = Math.PI * 2 * Math.random();
			var speed = 4 + Math.random() * 16;
			var p = getParticle();
			p.position.x = x;
			p.position.y = y;
			p.gradient = kha.Assets.images.explosion_gradient;
			p.size = 1 + Math.floor(Math.random() * 6);
			p.velocity.x = Math.cos(angle) * speed / p.size + vx;
			p.velocity.y = Math.sin(angle) * speed / p.size + vy;
			p.life = 0;
			p.lifetime = .2 + Math.random() * .4;
		}
	}

	public function trail(x, y) {
		var p = getParticle();
		p.position.x = x;
		p.position.y = y;
		p.gradient = kha.Assets.images.trail_gradient;
		p.size = 6;
		p.velocity.x = 0;
		p.velocity.y = 0;
		p.life = 0;
		p.lifetime = .1;
	}

	public function update(delta:Float) {
		for (particle in particles) {
			if (particle.life > particle.lifetime) {
				particles.remove(particle);
				continue;
			}
			particle.position.x += particle.velocity.x;
			particle.position.y += particle.velocity.y;

			particle.velocity.x *= .9;
			particle.velocity.y *= .9;

			particle.life += delta;
		}
	}

	public function render(g:Graphics) {
		for (particle in particles) {
			var life = particle.life / particle.lifetime;
			g.color = particle.gradient.at(Math.floor(life * 100), 0);
			g.fillCircle(particle.position.x, particle.position.y, particle.size * Math.abs(1.1 - life));
			g.color = kha.Color.White;
		}
	}
}
