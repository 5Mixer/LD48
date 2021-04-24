package ;

import nape.space.Space;

class Tile {
    public function new(x:Float, y:Float, space:Space) {
        body.position.setxy(x, y);
    }
    public function render(g:Graphics) {
        if (!air)
            g.drawImage(kha.Assets.images.tile, body.position.x-10, body.position.y-10, 20, 20);
    }
    public function remove() {
        body.space = null;
        air = true;
    }
}