package level;

import kha.Assets;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.Shaders;
import kha.graphics4.BlendingFactor;

class GpuGenerator {
	var texture:kha.Image;

	public function new(width, height) {
		texture = kha.Image.createRenderTarget(width, height);
	}

	public function generate() {
		// texture.g2.begin(true, kha.Color.Transparent);
		Assets.images.noise.generateMipmaps(4);
		var pipeline = createGenerationPipeline();
		texture.g2.begin(true, kha.Color.fromBytes(3, 0, 0));
		texture.g2.imageScaleQuality = High;
		texture.g2.mipmapScaleQuality = High;
		texture.g2.pipeline = pipeline;
		texture.g2.drawScaledImage(kha.Assets.images.noise, 0, 0, Math.ceil(texture.width), Math.ceil(texture.height));
		texture.g2.end();
		// texture.g2.flush();
		return texture.getPixels();
	}

	function createGenerationPipeline() {
		var pipeline = new PipelineState();
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexUV", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.painter_image_vert;
		pipeline.fragmentShader = Shaders.generation_frag;

		pipeline.blendSource = BlendingFactor.BlendOne;
		pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		pipeline.alphaBlendSource = BlendingFactor.BlendOne;
		pipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;

		pipeline.compile();
		return pipeline;
	}
}
