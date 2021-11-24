package;

import entity.Spikey;
import level.Tiles;
import entity.Dynamite;
import entity.Bullet;
import physics.CollisionLayers;
import entity.TileDrop;
import entity.Player;
import particle.ParticleSystem;
import level.Grid;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import nape.dynamics.InteractionFilter;
import kha.graphics2.Graphics;
import nape.shape.Polygon;
import nape.phys.BodyType;
import nape.phys.Body;
import kha.audio1.AudioChannel;
import nape.geom.Ray;
import kha.math.Vector2;
import kha.audio1.Audio;
import nape.geom.Vec2;
import nape.space.Space;

class Simulation {
	var space:Space;
	var grid:Grid;

	public var player:Player;

	var dynamite:Array<Dynamite> = [];
	var drops:Array<TileDrop> = [];
	var bullets:Array<Bullet> = [];

	var spikeys:Array<Spikey> = [];

	var explosions = new ParticleSystem();

	public var camera:Camera;
	public var input:Input;

	public var money = 0;

	var audioChannels:Array<AudioChannel> = [];
	var laserSound:AudioChannel;

	var reload = 0.;
	var rayDistance = 0.;

	public var dynamiteForce = 1;
	public var dynamiteSpeed = 1;
	public var laserLevel = 0;

	public function new() {
		var gravity = Vec2.weak(0, 600);
		space = new Space(gravity);

		camera = new Camera(Grid.width * Grid.tileSize);
		input = new Input(camera);

		input.onScroll = function(delta) {
			camera.zoomOn(camera.worldToView(new Vector2(player.body.position.x, player.body.position.y)), delta);
		}

		laserSound = Audio.play(kha.Assets.sounds.laser, true);
		laserSound.volume = 0;

		initialise();
	}

	public function initialise() {
		dynamite = [];
		drops = [];
		bullets = [];
		explosions = new ParticleSystem();

		space.clear();

		createSpaceListeners();
		createWalls();
		initialiseGrid();
		player = new Player(600, -100, space);

		spikeys = [];
		for (_ in 0...40) {
			spikeys.push(new Spikey(Math.random() * 500, Math.random() * 200 - 200, space));
		}
	}

	function initialiseGrid() {
		grid = new Grid(space);
		grid.tileRemovalCallback = onGridTileRemoval;
	}

	function onGridTileRemoval(tile, x, y) {
		money += Tiles.data[tile - 1].value;

		if (tile == 0 || Math.random() > .4)
			return;

		drops.push(new TileDrop((x + .5) * Grid.tileSize, (y + .5) * Grid.tileSize, tile, space));
	}

	function createSpaceListeners() {
		space.listeners.add(createBulletTileInteractionListener());
		space.listeners.add(createPlayerTileDropInteractionListener());
		space.listeners.add(createPlayerEnemyInteractionListener());
	}

	function createWalls() {
		var walls = new Body(BodyType.STATIC);
		walls.shapes.add(new Polygon(Polygon.rect(-100, -10000, 100, 1000000)));
		walls.shapes.add(new Polygon(Polygon.rect(Grid.width * Grid.tileSize, -10000, 100, 1000000)));
		walls.setShapeFilters(new InteractionFilter(CollisionLayers.LEVEL));
		walls.cbTypes.add(Grid.levelCallbackType);
		walls.space = space;
	}

	function createPlayerTileDropInteractionListener() {
		return new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, Player.callbackType, TileDrop.callbackType, function(callback:InteractionCallback) {
			var drop:TileDrop = cast callback.int2.userData.drop;

			drop.body.space = null;
			drops.remove(drop);
		});
	}

	function createBulletTileInteractionListener() {
		return new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, Bullet.callbackType, [Grid.tileCallbackType, Spikey.callbackType],
			function(callback:InteractionCallback) {
				var bullet:Bullet = cast callback.int1.userData.bullet;

				var position = new Vector2(bullet.body.position.x, bullet.body.position.y);
				var velocity = bullet.body.velocity.copy().normalise().muleq(2);

				bullet.body.space = null;
				bullets.remove(bullet);

				explosion(position, 3, velocity.x, velocity.y);
			});
	}

	function createPlayerEnemyInteractionListener() {
		return new InteractionListener(CbEvent.ONGOING, InteractionType.ANY, Player.callbackType, Spikey.callbackType, function(callback:InteractionCallback) {
			if (callback.int2.userData.spikey == null)
				return;

			var player:Player = cast callback.int1.userData.player;
			var spikey:Spikey = cast callback.int2.userData.spikey;

			player.damage(spikey.damage);
		});
	}

	function explosion(position:Vector2, force:Float, vx = 0., vy = 0.) {
		explosions.explode(position.x, position.y, Math.round(90 * force), vx, vy);

		var forceSquared = force * force / 4;

		var tileCoordinate = grid.worldPositionToTilePosition(position);
		var x = tileCoordinate.x;
		var y = tileCoordinate.y;

		for (localx in Math.floor(-force / 2)...Math.ceil(force / 2)) {
			for (localy in Math.floor(-force / 2)...Math.ceil(force / 2)) {
				var distanceSquared = Math.pow(localx, 2) + Math.pow(localy, 2);
				if (distanceSquared < forceSquared) {
					grid.damage(x + localx, y + localy, Math.ceil(50 * (1 - distanceSquared / forceSquared)));
				}
			}
		}

		var explosionForceEffect = 40;

		var napePosition = Vec2.get(position.x, position.y);
		var explosionForceRadius = force * 20;

		for (body in space.bodiesInCircle(napePosition, explosionForceRadius, false,
			new InteractionFilter(CollisionLayers.DYNAMITE | CollisionLayers.PLAYER | CollisionLayers.TILE_DROP | CollisionLayers.ENEMY))) {
			var deltaVector = body.position.sub(napePosition);
			if (deltaVector.length == 0)
				continue; // Same object - delta to object is zero, applying force is illogical

			deltaVector.length = explosionForceEffect * explosionForceRadius / deltaVector.length;
			body.applyImpulse(deltaVector);
			if (body.userData.spikey != null) {
				var spikey = cast(body.userData.spikey, entity.Spikey);
				spikey.receiveDamage(Math.round(deltaVector.length));
				if (spikey.health <= 0) {
					spikey.body.space = null;
					spikeys.remove(spikey);
				}
			}
		}
		napePosition.dispose();
	}

	public function stop() {
		laserSound.stop();
		player.flyingSound.stop();
		for (channel in audioChannels)
			channel.stop();
	}

	public function laserPurchase() {
		laserLevel++;
	}

	public function dynamiteSpeedPurchase() {
		dynamiteSpeed++;
	}

	public function dynamiteForcePurchase() {
		dynamiteForce++;
	}

	public function dynamiteExplosion(explodedDynamite:Dynamite) {
		var movementVector = explodedDynamite.body.velocity.copy();
		if (movementVector.length > 0) {
			movementVector.length = Math.min(5, 2 + movementVector.length / 50);
		}

		if (audioChannels.length > 5) {
			audioChannels.shift().stop();
		}
		audioChannels.push(Audio.play(kha.Assets.sounds.get('explosion' + (1 + Math.floor(Math.random() * 6)))));

		var explodedDynamitePosition = explodedDynamite.getPosition();
		explosion(new Vector2(explodedDynamitePosition.x, explodedDynamitePosition.y), 4 + dynamiteForce * (2 + Math.random() * .4), movementVector.x,
			movementVector.y);
		dynamite.remove(explodedDynamite);
	}

	public function update(delta:Float) {
		camera.follow(player.getPosition().x, player.getPosition().y);

		space.step(1 / 60);

		reload -= delta;

		for (drop in drops) {
			drop.age += delta;
			if (drop.age >= drop.deathAge) {
				drops.remove(drop);
				drop.body.space = null;
			}
		}

		for (bullet in bullets) {
			bullet.update(delta);

			if (bullet.life > 2) {
				bullet.body.space = null;
				bullets.remove(bullet);
			}
		}

		var directionVector = Vec2.get(input.getMouseWorldPosition().x, input.getMouseWorldPosition().y).sub(player.body.position);
		directionVector.normalise(); // So that rayHitPosition can be found easily later
		var ray = space.rayCast(new Ray(player.body.position, directionVector), false, new InteractionFilter(null, ~CollisionLayers.TILE_DROP));
		var rayHitPosition = null;

		if (ray != null) {
			rayDistance = ray.distance;
			rayHitPosition = player.body.position.add(directionVector.mul(ray.distance, true));
		} else {
			rayDistance = 6000;
		}

		for (audioChannel in audioChannels) {
			if (audioChannel.finished) {
				audioChannels.remove(audioChannel);
			}
		}

		for (dynamite in dynamite) {
			dynamite.update(delta);
		}

		if (input.right() && reload <= 0.) {
			var vector = input.getMouseWorldPosition().sub(new Vector2(player.body.position.x, player.body.position.y)).normalized();
			var angle = Math.atan2(vector.y, vector.x);

			for (_ in 0...5) {
				var variation = Math.PI / 10;
				angle += (-.5 + Math.random()) * variation;
				vector = new Vector2(Math.cos(angle), Math.sin(angle));

				var bullet = new Bullet(player.body.position.x + vector.x * 25, player.body.position.y + vector.y * 25, space);
				var speed = 4000 * (.9 + Math.random() * .2);
				bullet.setVelocity(vector.x * speed, vector.y * speed);
				bullets.push(bullet);
			}

			var d = new Dynamite(player.body.position.x + vector.x * 25, player.body.position.y + vector.y * 25, space, dynamiteExplosion);
			var speed = 600;
			d.setVelocity(vector.x * speed, vector.y * speed);
			dynamite.push(d);

			var fireSound = kha.audio1.Audio.play(kha.Assets.sounds.fire);
			fireSound.volume = .3 + Math.random() * .1;

			reload = 1.3 / dynamiteSpeed;
			reload = .1;
		}

		if (input.middle() && laserLevel > 0) {
			laserSound.volume = 1;

			if (ray != null) {
				if (ray.shape != null && ray.shape.body != null && ray.shape.body.userData != null) {
					explosion(new Vector2(rayHitPosition.x, rayHitPosition.y), 3, ray.normal.x, ray.normal.y);

					if (ray.shape.body.userData.tile != null) {
						grid.damage(ray.shape.body.userData.tile.x, ray.shape.body.userData.tile.y, 1 + 2 * laserLevel);
					}
					if (ray.shape.body.userData.dynamite != null) {
						ray.shape.body.userData.dynamite.explode();
					}
				}
			}
		} else {
			laserSound.volume *= .6;
		}

		player.update(delta, input);

		var target = new Vector2(player.body.position.x, player.body.position.y);
		for (spikey in spikeys) {
			spikey.target = target;
			spikey.update(delta);
		}

		grid.update();
		explosions.update(delta);
	}

	public function render(g:Graphics) {
		g.color = kha.Color.fromValue(0xffb4d8f5);
		g.fillRect(0, -10000, Grid.width * Grid.tileSize, 10000);
		g.color = kha.Color.White;

		GraphicsHelper.drawImage(g, kha.Assets.images.background, 0, -594, Grid.width * Grid.tileSize, 594);
		explosions.render(g);
		grid.render(g);

		if (input.middle() && laserLevel > 0) {
			GraphicsHelper.drawLaser(g, player.body.position.x, player.body.position.y,
				Math.atan2(input.getMouseWorldPosition().y - player.body.position.y, input.getMouseWorldPosition().x - player.body.position.x), rayDistance);
		}

		for (spikey in spikeys) {
			spikey.render(g);
		}

		player.render(g);

		var turretVector = input.getMouseWorldPosition().sub(new Vector2(player.body.position.x, player.body.position.y)).normalized();
		if (laserLevel > 0) {
			GraphicsHelper.drawImage(g, kha.Assets.images.laser_attachment, player.body.position.x - 40, player.body.position.y - 40, 80, 80,
				Math.atan2(turretVector.y, turretVector.x));
		}

		if (input.left())
			GraphicsHelper.drawImage(g, kha.Assets.images.jet_attachment, player.body.position.x
				- 40, player.body.position.y
				- 40, 80, 80,
				Math.PI
				+ Math.atan2(turretVector.y, turretVector.x));

		if (input.left() && player.body.velocity.length > 1) {
			var jetVector = turretVector.mult(-20 * (.8 + .4 * Math.random()));
			explosions.explode(player.body.position.x, player.body.position.y, 10, jetVector.x, jetVector.y);
		}

		for (drop in drops) {
			drop.render(g);
		}
		for (dynamite in dynamite) {
			dynamite.render(g);
		}
		for (bullet in bullets) {
			bullet.render(g);
		}
	}
}
