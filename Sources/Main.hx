package;

import kha.graphics5_.MipMapFilter;
import kha.graphics4.MipMapFilter;
import kha.graphics2.ImageScaleQuality;
import kha.input.Mouse;
import kha.input.Keyboard;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var simulation:Simulation;
	var graphics:Graphics;
	var lastTime = Scheduler.time();
    var buttons = [];
	var buttony = 60;
	function new() {

		System.start({title: "LD48", width: 800, height: 600}, function (_) {
			Assets.loadEverything(function () {
				for (asset in kha.Assets.images.names) {
					kha.Assets.images.get(asset).generateMipmaps(8);
				}

				graphics = new Graphics();

				lastTime = Scheduler.time();

				init();
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
			});
		});
	}
	function init() {
		simulation = new Simulation();
		buttons = [];

		buttons.push(new Button(200, buttony, "Buy Laser", simulation.input, function() {
			simulation.laserPurchase();
		}));
		buttons.push(new Button(650, buttony, "Upgrade Dynamite Speed", simulation.input, function() {
			simulation.dynamiteSpeedPurchase();
		}));
		buttons.push(new Button(1100, buttony, "Upgrade Dynamite Force", simulation.input, function() {
			simulation.dynamiteForcePurchase();
		}));
	}

	function update() {
		simulation.update(Scheduler.time() - lastTime);
		lastTime = Scheduler.time();
	}

	function render(framebuffer: Framebuffer) {
		var g = framebuffer.g2;
		g.imageScaleQuality = ImageScaleQuality.High;
		g.mipmapScaleQuality = ImageScaleQuality.High;

		g.begin(true,kha.Color.fromValue(0x0d1219));
		graphics.setG2(g);
        simulation.camera.transform(g);
		simulation.render(graphics);
		simulation.camera.reset(g);
		g.fontSize = 50;
		g.font = kha.Assets.fonts.BebasNeue_Regular;
		g.drawString("$"+simulation.money, buttony, 100);

        for (button in buttons) {
            button.render(graphics);
        }

		g.end();
	}

	public static function main() {
		new Main();
	}
}
