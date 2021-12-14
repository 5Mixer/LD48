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
	var pipeline:PipelineState;

	var particleAllocationIndex = 0;

	public function new() {
		particles = new Vector(allocatedParticles);

		pipeline = createAdditivePipeline();
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

	public function explode(x, y, particleCount, vx, vy, speed) {
		for (i in 0...particleCount) {
			var angle = Math.PI * 2 * Math.random();
			var speed = 20 + Math.random() * 10 * speed;
			var p = getParticle();
			p.position.x = x;
			p.position.y = y;
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
		g.pipeline = pipeline;
		for (particle in particles) {
			if (particle.life > particle.lifetime) {
				continue;
			}

			var life = particle.life / particle.lifetime;
			g.color = kha.Color.fromFloats(.9, .5, .1);
			var size = particle.size * Math.abs(1.1 - life);
			g.drawScaledImage(kha.Assets.images.explosion_particle, particle.position.x - size, particle.position.y - size, size * 2, size * 2);
			g.color = kha.Color.White;
		}
		g.pipeline = null;
	}

	function createAdditivePipeline() {
		var pipeline = new PipelineState();
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexUV", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.painter_image_vert;
		pipeline.fragmentShader = Shaders.painter_image_frag;

		pipeline.blendSource = BlendingFactor.SourceAlpha;
		pipeline.blendDestination = BlendingFactor.BlendOne;
		pipeline.alphaBlendSource = BlendingFactor.BlendOne;
		pipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;

		pipeline.compile();
		return pipeline;
	}
}
