package ;

import kha.math.FastMatrix3;
using kha.graphics2.GraphicsExtension;

class Graphics {
    var g:kha.graphics2.Graphics;
    public function new() {

    }
    public function setG2(g:kha.graphics2.Graphics) {
        this.g = g;
    }
    public function drawImage(image, x:Float,y:Float, width, height, angle=0.) {
        if (angle != 0) g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + width/2, y + height/2)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-x - width/2, -y - height/2)));
        g.drawScaledImage(image, x, y, width, height);
        if (angle != 0) g.popTransformation();
    }
    public function drawTile(x:Float,y:Float, tile) {
        g.drawScaledSubImage(kha.Assets.images.tile, tile*100, 0, 100, 100, Math.round(x), Math.round(y), 20, 20);
    }
    public function drawParticle(x:Float, y:Float, life:Float,size:Float) {
        g.color = kha.Assets.images.explosion_gradient.at(Math.floor(life*100),0);
        g.fillCircle(x, y, size*Math.abs(1.1-life));
        g.color = kha.Color.White;
    }
    public function startTiles() {
        g.mipmapScaleQuality = Low;
        g.imageScaleQuality = Low;
    }
    public function endTiles() {
        g.mipmapScaleQuality = High;
        g.imageScaleQuality = High;
    }
}