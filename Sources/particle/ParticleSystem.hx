package particle;

import haxe.ds.Vector;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.BlendingFactor;
import kha.graphics4.VertexData;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class ParticleSystem {
	var allocatedParticles = 4000;
	var particles:Vector<Particle>;

	var particleAllocationIndex = 0;

	public function new() {
		particles = new Vector(allocatedParticles);

		for (i in 0...allocatedParticles) {
			particles[i] = new Particle();
		}
	}

	function getParticle() {
		particleAllocationIndex++;

		if (particleAllocationIndex == allocatedParticles) {
			particleAllocationIndex = 0;
		}
		return particles[particleAllocationIndex];
	}

	public function explode(x, y, particleCount, vx, vy, speed, scatter) {
		for (_ in 0...particleCount) {
			var angle = Math.PI * 2 * Math.random();
			var speed = 20 + Math.random() * 10 * speed;
			var p = getParticle();
			p.position.x = x + Math.cos(angle) * scatter;
			p.position.y = y + Math.sin(angle) * scatter;
			p.gradient = kha.Assets.images.explosion_gradient;
			p.size = 5 + Math.floor(Math.random() * 40);
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
		p.size = 15;
		p.velocity.x = 0;
		p.velocity.y = 0;
		p.life = 0;
		p.lifetime = .1;
	}

	public function update(delta:Float) {
		for (particle in particles) {
			if (particle.life > particle.lifetime) {
				continue;
			}
			particle.position.x += particle.velocity.x;
			particle.position.y += particle.velocity.y;

			particle.velocity.x *= .95;
			particle.velocity.y *= .95;

			particle.life += delta;
		}
	}

	public function render(g:Graphics) {
		g.pipeline = Main.additivePipeline;
		for (particle in particles) {
			if (particle.life > particle.lifetime) {
				continue;
			}

			var life = particle.life / particle.lifetime;
			g.color = kha.Color.fromFloats(.9, .5, .1);
			var size = particle.size * Math.abs(1.1 - life);
			g.drawScaledImage(kha.Assets.images.explosion_particle, particle.position.x - size, particle.position.y - size, size * 2, size * 2);
			size *= 4;
			g.color = kha.Color.fromFloats(g.color.R, g.color.G, g.color.B, .1);
			g.drawScaledImage(kha.Assets.images.glow_particle, particle.position.x - size, particle.position.y - size, size * 2, size * 2);
			g.color = kha.Color.White;
		}
		g.pipeline = null;
	}
}
