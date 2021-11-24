package level;

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

class Grid {
	public static final width = 400;
	public static final height = 1000;

	var tiles:Array<Int> = [];
	var tileHealth:Array<Int> = [];
	var bodies:Array<Body> = [];
	var space:Space;

	public static var tileCallbackType = new CbType();
	public static var levelCallbackType = new CbType();

	public static final tileSize = 20;

	public var tileRemovalCallback:(tile:Int, x:Int, y:Int) -> Void;

	var tileTextures:TileTextureGenerator;

	public function new(space) {
		var m_diamondSquare = new Perlin();
		var seed = Math.random() * 100000;

		tileTextures = new TileTextureGenerator();

		for (x in 0...width) {
			for (y in 0...height) {
				var tile = 1;
				var health = 10;

				var air = m_diamondSquare.OctavePerlin(x / tileSize, y / tileSize, seed, 4, 0.5, 0.6);
				var mineralA = m_diamondSquare.OctavePerlin(x / 10, y / 3, seed + 1000, 3, 0.5, 0.25);
				var mineralB = m_diamondSquare.OctavePerlin(x / 4, y / 4, seed + 2000, 3, 0.5, 0.25);
				var mineralC = m_diamondSquare.OctavePerlin(x / 2, y / 2, seed + 3000, 3, 0.5, 0.25);
				var dirtVariant = m_diamondSquare.OctavePerlin(x / 3, y / 3, seed + 4000, 3, 0.5, 0.25);

				var land = m_diamondSquare.OctavePerlin(x / 10, 0, seed, 3, 0.5, 0.25);
				var dirt = m_diamondSquare.OctavePerlin(x / 10, 1, seed, 3, 0.5, 0.25);

				tile = dirtVariant < .5 ? 1 : 9;

				if (mineralA < .3) {
					tile = 2;
					health = 20;
				}
				if (mineralB < .3) {
					tile = 3;
					health = 50;
				}
				if (mineralC < .3) {
					tile = 4;
					health = 80;
				}
				if (air < .45) {
					tile = 0;
					health = 0;
				}

				var landy:Int = 10 + Math.floor(land * 30);
				var dirty:Int = 10 + Math.floor(dirt * 30);
				if (y < landy + 20) {
					tile = dirtVariant < .5 ? 5 : 7;
					health = 10;
				}
				if (y < dirty + 6) {
					tile = 6;
					health = 5;
				}
				if (y < landy) {
					tile = 0;
					health = 0;
				}
				if (y == landy - 1 && Math.random() < .1) {
					tile = 8;
					health = 1;
				}

				tileHealth.push(health);
				tiles.push(tile);
				bodies.push(null);
			}
		}
		this.space = space;

		constructShapes();
	}

	public function worldPositionToTilePosition(worldPosition:Vector2) {
		return new Vector2i(Math.floor(worldPosition.x / tileSize), Math.floor(worldPosition.y / tileSize));
	}

	public function update() {}

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
		g.mipmapScaleQuality = High;
		g.imageScaleQuality = High;
	}

	public function drawTile(g:Graphics, x:Int, y:Int, tile:Int, variant:Int) {
		g.drawScaledSubImage(tileTextures.renderTexture, tile * 100, variant * 100, 100, 100, x * tileSize, y * tileSize, tileSize, tileSize);
	}

	function makeBody(x, y) {
		var body = new Body(BodyType.STATIC);
		body.userData.tile = {x: x, y: y};

		body.cbTypes.add(tileCallbackType);
		body.shapes.add(new Polygon(Polygon.rect(x * tileSize, y * tileSize, tileSize, tileSize)));
		body.setShapeFilters(new InteractionFilter(CollisionLayers.TILE));
		body.space = space;

		bodies[x * height + y] = body;
	}

	public function damage(x, y, damage) {
		tileHealth[x * height + y] -= damage;
		if (tileHealth[x * height + y] <= 0) {
			remove(x, y);
		}
	}

	public function remove(x, y) {
		if (x < 0 || y < 0 || x >= width || y >= height || tiles[x * height + y] == 0)
			return;

		tileRemovalCallback(tiles[x * height + y], x, y);
		tiles[x * height + y] = 0;

		if (bodies[x * height + y] != null) {
			bodies[x * height + y].space = null;
			bodies[x * height + y] = null;
		}

		if (x > 0 && unsafeGetTile(x - 1, y) != 0 && unsafeGetBody(x - 1, y) == null) {
			makeBody(x - 1, y);
		}
		if (x < width - 1 && unsafeGetTile(x + 1, y) != 0 && unsafeGetBody(x + 1, y) == null) {
			makeBody(x + 1, y);
		}
		if (y > 0 && unsafeGetTile(x, y - 1) != 0 && unsafeGetBody(x, y - 1) == null) {
			makeBody(x, y - 1);
		}
		if (y < height - 1 && unsafeGetTile(x, y + 1) != 0 && unsafeGetBody(x, y + 1) == null) {
			makeBody(x, y + 1);
		}
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
}
