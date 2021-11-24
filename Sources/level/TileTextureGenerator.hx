package level;

import kha.graphics4.BlendingFactor;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.Shaders;
import kha.Assets;

class TileTextureGenerator {
	public var renderTexture:kha.Image;

	public function new() {
		var tiles = [
			{
				name: 'stone',
				baseTexture: 0
			},
			{
				name: 'stoneDark',
				baseTexture: 1
			},
			{
				name: 'iron',
				baseTexture: 2
			},
			{
				name: 'gold',
				baseTexture: 3
			},
			{
				name: 'copper',
				baseTexture: 4
			},
			{
				name: 'dirt',
				baseTexture: 5
			},
			{
				name: 'grass',
				baseTexture: 6
			},
			{
				name: 'dirtDark',
				baseTexture: 7
			},
			{
				name: 'plant',
				baseTexture: 8
			}
		];
		var width = tiles.length;
		var tileSize = 100;
		var variants = 1 << 4;
		renderTexture = kha.Image.createRenderTarget(width * tileSize, variants * tileSize);

		renderTexture.g2.begin(true, kha.Color.Transparent);
		renderTexture.g2.imageScaleQuality = Low;
		renderTexture.g2.mipmapScaleQuality = Low;

		var tileIndex = 0;
		for (tile in tiles) {
			for (variant in 0...variants) {
				// Draw base texture
				renderTexture.g2.drawSubImage(Assets.images.tile, tileIndex * tileSize, variant * tileSize, tile.baseTexture * 125, 0, 100, 100);
			}
			tileIndex++;
		}

		renderTexture.g2.pipeline = createMaskPipeline();

		var tileIndex = 0;
		for (tile in tiles) {
			for (variant in 0...variants) {
				var removeTopLeft = (variant & 1 << 0) != 0;
				var removeTopRight = (variant & 1 << 1) != 0;
				var removeBottomRight = (variant & 1 << 2) != 0;
				var removeBottomLeft = (variant & 1 << 3) != 0;

				if (removeTopLeft)
					renderTexture.g2.drawSubImage(Assets.images.tileMasks, tileIndex * tileSize, variant * tileSize, 0, 0, 50, 50);
				if (removeTopRight)
					renderTexture.g2.drawSubImage(Assets.images.tileMasks, tileIndex * tileSize + 50, variant * tileSize, 50, 0, 50, 50);
				if (removeBottomRight)
					renderTexture.g2.drawSubImage(Assets.images.tileMasks, tileIndex * tileSize + 50, variant * tileSize + 50, 50, 50, 50, 50);
				if (removeBottomLeft)
					renderTexture.g2.drawSubImage(Assets.images.tileMasks, tileIndex * tileSize, variant * tileSize + 50, 0, 50, 50, 50);
			}

			tileIndex++;
		}

		renderTexture.g2.end();
	}

	function createMaskPipeline() {
		var pipeline = new PipelineState();
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexUV", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.painter_image_vert;
		pipeline.fragmentShader = Shaders.painter_image_frag;

		pipeline.blendSource = BlendingFactor.BlendZero;
		pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;

		pipeline.alphaBlendSource = BlendingFactor.SourceAlpha;
		pipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		pipeline.alphaBlendOperation = ReverseSubtract;

		pipeline.compile();
		return pipeline;
	}
}
