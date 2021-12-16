package;

import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class GraphicsHelper {
	public static function drawImage(g:Graphics, image:kha.Image, x:Float, y:Float, width, height, angle = 0.) {
		if (angle != 0)
			g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + width / 2, y + height / 2))
				.multmat(FastMatrix3.rotation(angle))
				.multmat(FastMatrix3.translation(-x - width / 2, -y - height / 2)));

		g.drawScaledImage(image, x, y, width, height);
		if (angle != 0)
			g.popTransformation();
	}

	public static function drawText(g:Graphics, x, y, text) {
		g.font = kha.Assets.fonts.BebasNeue_Regular;
		g.color = kha.Color.Black;
		g.drawString(text, x, y);
		g.color = kha.Color.White;
	}

	public static function drawLaser(g:Graphics, x, y, angle, distance:Float) {
		g.drawLine(x, y, x + Math.cos(angle) * distance, y + Math.sin(angle) * distance);
		var width = 300;

		g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x, y))
			.multmat(FastMatrix3.rotation(angle))
			.multmat(FastMatrix3.translation(-x, -y)));
		g.drawScaledImage(kha.Assets.images.laser, x, y - width / 2, distance, width);
		g.popTransformation();
	}
}
