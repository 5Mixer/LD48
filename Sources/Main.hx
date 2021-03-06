package;

import kha.graphics4.BlendingFactor;
import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.Window;
import ui.Touchpad;
import ui.Button;
import kha.audio1.Audio;
import kha.graphics2.ImageScaleQuality;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var simulation:Simulation;
	var lastTime = Scheduler.time();
	var buttons = [];
	var buttony = 60;
	var upgradeCosts = [1000, 100, 100];
	var mineNumber = 1;

	var laserButton:Button;
	var speedButton:Button;
	var forceButton:Button;
	var mineButton:Button;

	var movementTouchpad:Touchpad;
	var actionTouchpad:Touchpad;

	public static var additivePipeline:PipelineState;

	function new() {
		System.start({title: "Orbdig", width: 800, height: 600}, function(_) {
			#if js
			var canvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
			canvas.width = js.Browser.window.innerWidth;
			canvas.height = js.Browser.window.innerHeight;
			canvas.addEventListener('contextmenu', function(event) {
				event.preventDefault();
			});
			#end

			Assets.loadEverything(function() {
				for (asset in kha.Assets.images.names) {
					kha.Assets.images.get(asset).generateMipmaps(8);
				}

				preparePipelines();

				lastTime = Scheduler.time();

				init();
				Scheduler.addTimeTask(function() {
					update();
				}, 0, 1 / 60);
				System.notifyOnFrames(function(framebuffers) {
					render(framebuffers[0]);
				});
			});
		});
	}

	function preparePipelines() {
		additivePipeline = createAdditivePipeline();
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

	function init() {
		simulation = new Simulation();

		movementTouchpad = new Touchpad();
		actionTouchpad = new Touchpad();

		simulation.input.movementTouchpad = movementTouchpad;
		simulation.input.actionTouchpad = actionTouchpad;

		buttons = [];

		laserButton = new Button(200, buttony, "Buy Laser", simulation.input, onLaserButtonClick);
		buttons.push(laserButton);
		laserButton.mouseOverText = "$" + upgradeCosts[0];

		speedButton = new Button(550, buttony, "Upgrade Dynamite Speed", simulation.input, onSpeedButtonClick);
		buttons.push(speedButton);
		speedButton.mouseOverText = "$" + upgradeCosts[1];

		forceButton = new Button(900, buttony, "Upgrade Dynamite Force", simulation.input, onForceButtonClick);
		buttons.push(forceButton);
		forceButton.mouseOverText = "$" + upgradeCosts[2];

		mineButton = new Button(1250, buttony, "Go to new mine", simulation.input, onMineButtonClick);

		buttons.push(mineButton);
		mineButton.mouseOverText = "$20,000";
	}

	function positionTouchpads() {
		movementTouchpad.screenPosition.y = actionTouchpad.screenPosition.y = Window.get(0).height - 160;
		movementTouchpad.screenPosition.x = 160;
		actionTouchpad.screenPosition.x = Window.get(0).width - 160;
	}

	function onLaserButtonClick() {
		if (simulation.money > upgradeCosts[0]) {
			simulation.laserPurchase();
			simulation.money -= upgradeCosts[0];
			upgradeCosts[0] *= 2;
			Audio.play(kha.Assets.sounds.button);
		}
		laserButton.mouseOverText = "$" + upgradeCosts[0];
	}

	function onSpeedButtonClick() {
		if (simulation.money > upgradeCosts[1]) {
			simulation.dynamiteSpeedPurchase();
			simulation.money -= upgradeCosts[1];
			upgradeCosts[1] *= 2;
			Audio.play(kha.Assets.sounds.button);
		}
		speedButton.mouseOverText = "$" + upgradeCosts[1];
	}

	function onForceButtonClick() {
		if (simulation.money > upgradeCosts[2]) {
			simulation.dynamiteForcePurchase();
			simulation.money -= upgradeCosts[2];
			upgradeCosts[2] *= 2;
			Audio.play(kha.Assets.sounds.button);
		}
		forceButton.mouseOverText = "$" + upgradeCosts[2];
	}

	function onMineButtonClick() {
		if (simulation.money > mineNumber * 20000) {
			simulation.money -= mineNumber * 20000;
			mineNumber++;
			mineButton.mouseOverText = "$" + (mineNumber * 20) + ",000";
			Audio.play(kha.Assets.sounds.button);
			var newSimulation = new Simulation();
			newSimulation.money = simulation.money;
			newSimulation.laserLevel = simulation.laserLevel;
			newSimulation.dynamiteForce = simulation.dynamiteForce;
			newSimulation.dynamiteSpeed = simulation.dynamiteSpeed;
			simulation.stop();
			simulation = newSimulation;
		}
	}

	function update() {
		#if js
		var canvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
		canvas.width = js.Browser.window.innerWidth;
		canvas.height = js.Browser.window.innerHeight;
		#end

		positionTouchpads();

		simulation.update(Scheduler.time() - lastTime);
		lastTime = Scheduler.time();
	}

	function render(framebuffer:Framebuffer) {
		var g = framebuffer.g2;
		g.imageScaleQuality = ImageScaleQuality.High;
		g.mipmapScaleQuality = ImageScaleQuality.High;

		g.begin(true, kha.Color.fromValue(0x0d1219));
		simulation.render(g);
		g.fontSize = 50;
		g.font = kha.Assets.fonts.BebasNeue_Regular;
		g.drawString("$" + simulation.money, buttony, 100);

		for (button in buttons) {
			// button.render(g);
		}

		final healthBarWidth = 400;
		final healthBarHeight = 30;
		g.color = kha.Color.fromBytes(226, 229, 234);
		g.fillRect(10, 10, healthBarWidth, healthBarHeight);
		g.color = kha.Color.fromBytes(170, 61, 61);
		g.fillRect(10, 10, healthBarWidth * (simulation.player.health / simulation.player.maxHealth), healthBarHeight);

		movementTouchpad.render(g);
		actionTouchpad.render(g);

		g.end();
	}

	public static function main() {
		new Main();
	}
}
