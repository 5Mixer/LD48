package level;

import kha.graphics4.PipelineState;
import kha.graphics4.BlendingFactor;
import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.Image;
import kha.Scheduler;
import physics.CollisionLayers;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import kha.math.FastVector2;
import kha.math.Vector2i;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import hxnoise.Perlin;
import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

class TileBodyData {
	public var x:Int;
	public var y:Int;

	public function new(x, y) {
		this.x = x;
		this.y = y;
	}
}

class Grid {
	public static final width = 1000;
	public static final height = 1000;

	var lightImage:kha.Image;
	var lightingPipeline:PipelineState;

	var tiles:Array<Int> = [];
	var light:Array<Float> = [];
	var tileHealth:Array<Int> = [];
	var bodies:Array<Body> = [];
	var space:Space;

	var removedTiles:Array<Vector2i> = []; // Reprocess removed tile bodies once on update(), as otherwise large removals cause many unneeded [create -> delete]

	public static var tileCallbackType = new CbType();
	public static var levelCallbackType = new CbType();

	var tileShapeFilter = new InteractionFilter(CollisionLayers.TILE);

	public static final tileSize = 20;

	public var tileRemovalCallback:(tile:Int, x:Int, y:Int) -> Void;

	var tileTextures:TileTextureGenerator;

	public function new(space) {
		var start = Scheduler.realTime();
		lightImage = Image.createRenderTarget(width, height);

		var m_diamondSquare = new Perlin();
		var seed = Math.random() * 100000;

		lightingPipeline = createLightingPipeline();

		tileTextures = new TileTextureGenerator();
		var gpuGenerator = new GpuGenerator(width, height);
		var generationData = gpuGenerator.generate();

		for (x in 0...width) {
			for (y in 0...height) {
				var tile = 1;

				/*var air = kha.Assets.images.noise.at(x, y).R;
					var mineralA = kha.Assets.images.noise.at(x, y).G;
					var mineralC = kha.Assets.images.noise.at(x, y).B;
					var dirtVariant = kha.Assets.images.noise.at(x, y).A;

					var land = kha.Assets.images.noise.at(x, 0).A;
					var dirt = kha.Assets.images.noise.at(x, 1).A;

					// var air = m_diamondSquare.OctavePerlin(x / 20, y / 20, seed, 2, 0.5, 0.6);
					// 	var mineralA = m_diamondSquare.OctavePerlin(x / 10, y / 3, seed + 1000, 2, 0.5, 0.25);
					// 	var mineralC = m_diamondSquare.OctavePerlin(x / 2, y / 2, seed + 3000, 2, 0.5, 0.25);
					// 	var dirtVariant = m_diamondSquare.OctavePerlin(x / 3, y / 3, seed + 4000, 2, 0.5, 0.25);

					// 	var land = m_diamondSquare.OctavePerlin(x / 10, 0, seed, 1, 0.5, 0.25);
					// 	var dirt = m_diamondSquare.OctavePerlin(x / 10, 1, seed, 1, 0.5, 0.25);

					tile = dirtVariant < .5 ? 1 : 9;

					if (mineralA < .3) {
						tile = 2;
					}
					if (mineralA > .7) {
						tile = 3;
					}
					if (mineralC < .3) {
						tile = 4;
					}
					if (air < .45) {
						tile = 0;
					}

					var landy:Int = 10 + Math.floor(land * 30);
					var dirty:Int = 10 + Math.floor(dirt * 30);
					if (y < landy + 20) {
						tile = dirtVariant < .5 ? 5 : 7;
					}
					if (y < dirty + 6) {
						tile = 6;
					}
					if (y < landy) {
						tile = 0;
					}
					if (y == landy - 1 && Math.random() < .1) {
						tile = 8;
				}*/

				tile = generationData.get((x * width + y) * 4);

				tileHealth.push(tile == 0 ? 0 : Tiles.data[tile - 1].health);

				tiles.push(tile);
				bodies.push(null);
			}
		}

		var tileTime = Scheduler.realTime();

		updateLight();

		var lightTime = Scheduler.realTime();

		this.space = space;

		constructShapes();

		var shapeTime = Scheduler.realTime();

		trace("Level generation timing");
		trace('tiles: ${tileTime - start}, lights: ${lightTime - tileTime}, shapes: ${shapeTime - lightTime}. Total: ${shapeTime - start}');
	}

	var lightRadius = 12;
	var lightChange = .004;

	public function updateLight() {
		lightImage.g2.begin(true, kha.Color.Black);
		for (x in 0...width) {
			for (y in 0...height) {
				if (getTile(x, y) == 0) {
					lightImage.g2.drawImage(kha.Assets.images.light, x - 8, y - 8);
				}
			}
		}
		lightImage.g2.end();
		lightImage.generateMipmaps(1);
	}

	public function updateLightAroundPoint(x, y) {
		lightImage.g2.begin(false);
		if (getTile(x, y) == 0) {
			lightImage.g2.drawImage(kha.Assets.images.light, x - 8, y - 8);
		}
		lightImage.g2.end();
	}

	public function worldPositionToTilePosition(worldPosition:Vector2) {
		return new Vector2i(Math.floor(worldPosition.x / tileSize), Math.floor(worldPosition.y / tileSize));
	}

	public function update() {
		// updateLight();
	}

	public function render(g:Graphics) {
		g.mipmapScaleQuality = Low;
		g.imageScaleQuality = Low;

		var transformInverse = g.transformation.inverse();
		var topLeftFrustrum = transformInverse.multvec(new FastVector2());
		var bottomRightFrustrum = transformInverse.multvec(new FastVector2(kha.Window.get(0).width, kha.Window.get(0).height));

		var topLeftTileFrustrum = new Vector2i(Math.floor(topLeftFrustrum.x / tileSize), Math.floor(topLeftFrustrum.y / tileSize));
		var bottomRightTileFrustrum = new Vector2i(Math.ceil(bottomRightFrustrum.x / tileSize), Math.ceil(bottomRightFrustrum.y / tileSize));

		for (x in topLeftTileFrustrum.x...bottomRightTileFrustrum.x) {
			for (y in topLeftTileFrustrum.y...bottomRightTileFrustrum.y) {
				var tile = getTile(x, y);
				if (tile != 0) {
					var leftEmpty = getTile(x - 1, y) == 0;
					var rightEmpty = getTile(x + 1, y) == 0;
					var aboveEmpty = getTile(x, y - 1) == 0;
					var belowEmpty = getTile(x, y + 1) == 0;

					var removeTopLeft = leftEmpty && aboveEmpty;
					var removeBottomLeft = leftEmpty && belowEmpty;
					var removeTopRight = rightEmpty && aboveEmpty;
					var removeBottomRight = rightEmpty && belowEmpty;
					var variant = (removeTopLeft ? 1 << 0 : 0) | (removeTopRight ? 1 << 1 : 0) | (removeBottomRight ? 1 << 2 : 0) | (removeBottomLeft ? 1 << 3 : 0);

					drawTile(g, x, y, tile - 1, variant);
				}
			}
		}
		g.color = kha.Color.White;
		g.mipmapScaleQuality = High;
		g.imageScaleQuality = High;
		g.pipeline = lightingPipeline;
		g.drawScaledImage(lightImage, 0, 0, width * tileSize, height * tileSize);
		g.pipeline = null;
	}

	public function drawTile(g:Graphics, x:Int, y:Int, tile:Int, variant:Int) {
		g.drawScaledSubImage(tileTextures.renderTexture, tile * 100, variant * 100, 100, 100, x * tileSize, y * tileSize, tileSize, tileSize);
	}

	function makeBody(x, y) {
		var body = new Body(BodyType.STATIC);
		body.userData.tile = new TileBodyData(x, y);

		body.cbTypes.add(tileCallbackType);
		body.shapes.add(new Polygon(Polygon.rect(x * tileSize, y * tileSize, tileSize, tileSize)));
		body.setShapeFilters(tileShapeFilter);
		body.space = space;

		bodies[x * height + y] = body;
	}

	public function damage(x, y, damage) {
		tileHealth[x * height + y] -= damage;
		if (tileHealth[x * height + y] <= 0) {
			removeWithoutPhysicsLightUpdate(x, y);
		}
	}

	public function removeWithoutPhysicsLightUpdate(x, y) {
		if (x < 0 || y < 0 || x >= width || y >= height || tiles[x * height + y] == 0)
			return;

		tileRemovalCallback(tiles[x * height + y], x, y);
		tiles[x * height + y] = 0;

		if (bodies[x * height + y] != null) {
			// bodies[x * height + y].space = null;
			// bodies[x * height + y] = null;
			bodies[x * height + y].setShapeFilters(new InteractionFilter(0)); // Interesting possible optimisation avenue
		}
	}

	public function processChangedRegion(minX:Int, minY:Int, maxX:Int, maxY:Int) {
		lightImage.g2.begin(false);
		for (x in minX - 1...maxX + 1) {
			for (y in minY - 1...maxY + 1) {
				if (getTile(x, y) == 0) {
					lightImage.g2.drawImage(kha.Assets.images.light, x - 8, y - 8);
				} else if (unsafeGetBody(x, y) == null
					&& (getTile(x - 1, y) == 0 || getTile(x + 1, y) == 0 || getTile(x, y - 1) == 0 || getTile(x, y + 1) == 0)) {
					makeBody(x, y);
				}
			}
		}
		lightImage.g2.end();
	}

	public inline function unsafeGetTile(x, y) {
		return tiles[x * height + y];
	}

	public inline function unsafeGetBody(x, y) {
		return bodies[x * height + y];
	}

	public function constructShapes() {
		for (x in 0...width) {
			for (y in 0...height) {
				if (getTile(x, y) != 0
					&& (getTile(x - 1, y) == 0 || getTile(x + 1, y) == 0 || getTile(x, y - 1) == 0 || getTile(x, y + 1) == 0)) {
					makeBody(x, y);
				}
			}
		}
	}

	public function getTile(x, y) {
		if (x < 0 || y < 0 || x >= width || y >= height)
			return 0;
		return tiles[x * height + y];
	}

	function createLightingPipeline() {
		var pipeline = new PipelineState();
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexUV", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.painter_image_vert;
		pipeline.fragmentShader = Shaders.painter_image_frag;

		pipeline.blendSource = BlendingFactor.DestinationColor;
		pipeline.blendDestination = BlendingFactor.BlendZero;

		pipeline.alphaBlendSource = BlendingFactor.BlendOne;
		pipeline.alphaBlendDestination = BlendingFactor.BlendZero;

		pipeline.compile();
		return pipeline;
	}
}
