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
		// Mouse.get().notify(function(b,x,y){
		// 	if (b == 0)
		// 		simulation.initialise();
		// },null,null);

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
		g.drawString("$"+simulation.money, 100, 100);

		g.end();
	}

	public static function main() {
		new Main();
	}
}
