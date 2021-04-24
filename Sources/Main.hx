package;

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

		graphics = new Graphics();

		System.start({title: "LD48", width: 800, height: 600}, function (_) {
			Assets.loadEverything(function () {

				lastTime = Scheduler.time();

				init();
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
			});
		});
	}
	function init() {
		simulation = new Simulation();
		Mouse.get().notify(function(b,x,y){
			simulation.initialise();
		},null,null);

	}

	function update() {
		simulation.update(Scheduler.time() - lastTime);
		lastTime = Scheduler.time();
	}

	function render(framebuffer: Framebuffer) {
		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromValue(0x0d1219));
		graphics.setG2(g);
		simulation.render(graphics);

		g.end();
	}

	public static function main() {
		new Main();
	}
}
