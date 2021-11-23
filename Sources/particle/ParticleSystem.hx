package particle;

import kha.graphics2.Graphics;

class ParticleSystem {
	var particles:Array<Particle> = [];
	var deadParticles:Array<Particle> = [];

	public function new() {}

	function getParticle() {
		if (deadParticles.length > 0) {
			return deadParticles.pop();
		}
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
			p.size = 1 + Math.floor(Math.random() * 6);
			p.velocity.x = Math.cos(angle) * speed / p.size + vx;
			p.velocity.y = Math.sin(angle) * speed / p.size + vy;
			p.life = 0;
			p.lifetime = .2 + Math.random() * .4;
		}
	}

	public function update(delta:Float) {
		for (particle in particles) {
			if (particle.life > particle.lifetime) {
				particles.remove(particle);
				deadParticles.push(particle);
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
			GraphicsHelper.drawParticle(g, particle.position.x, particle.position.y, particle.life / particle.lifetime, particle.size);
		}
	}
}
