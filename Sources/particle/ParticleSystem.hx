package particle;

import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.BlendingFactor;
import kha.graphics4.VertexData;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class ParticleSystem {
	var particles:Array<Particle> = [];
	var pipeline:PipelineState;

	public function new() {
		pipeline = createAdditivePipeline();
	}

	function getParticle() {
		var newParticle = new Particle();
		particles.push(newParticle);
		return newParticle;
	}

	public function explode(x, y, particleCount, vx, vy) {
		for (i in 0...Math.round(particleCount / 7)) {
			var angle = Math.PI * 2 * Math.random();
			var speed = 20 + Math.random() * 70;
			var p = getParticle();
			p.position.x = x;
			p.position.y = y;
			p.gradient = kha.Assets.images.explosion_gradient;
			p.size = 5 + Math.floor(Math.random() * 40);
			p.velocity.x = Math.cos(angle) * speed / p.size + vx;
			p.velocity.y = Math.sin(angle) * speed / p.size + vy;
			p.life = 0;
			p.lifetime = .4 + Math.random() * .5;
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
		g.pipeline = pipeline;
		for (particle in particles) {
			var life = particle.life / particle.lifetime;
			// g.color = particle.gradient.at(Math.floor(life * 100), 0);
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
