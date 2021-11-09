package;

import kha.graphics2.Graphics;
import kha.math.Vector2;

class Button {
	public var position:Vector2;
	public var text = "";
	public var mouseOverText = "";

	var callback:Void->Void;
	var width = 300;
	var height = 60;
	var input:Input;

	public function new(x, y, text, input:Input, callback) {
		position = new Vector2(x, y);
		this.text = text;
		this.callback = callback;
		this.input = input;
		input.onLeftDown.push(function() {
			var mousePos = input.getMouseScreenPosition();
			if (mousePos.x > position.x && mousePos.y > position.y && mousePos.x < position.x + width && mousePos.y < position.y + height) {
				callback();
			}
		});
	}

	public function render(g:Graphics) {
		var fontSize = 30;
		var mousePos = input.getMouseScreenPosition();
		var mouseOver = mousePos.x > position.x && mousePos.y > position.y && mousePos.x < position.x + width && mousePos.y < position.y + height;
		GraphicsHelper.drawImage(g, kha.Assets.images.button, position.x, position.y, width, height);
		g.fontSize = fontSize;
		var shownText = mouseOver ? mouseOverText : text;
		GraphicsHelper.drawText(g, position.x + width / 2 - g.font.width(g.fontSize, shownText) / 2, position.y + height / 2 - fontSize / 2, shownText);
	}
}
