package ;

import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

class Grid {
    var width = 150;
    var height = 60;

    var tiles:Array<Int> = [];
    var bodies:Array<Body> = [];
    var space:Space;
    var dirty = false;

    public function new(space) {
        for (x in 0...width) {
            for (y in 0...height) {
                tiles.push(1);
            }
        }
        this.space = space;
        constructShapes();
    }
    public function update() {
        if (dirty)
            constructShapes();
    }
    public function render(g:Graphics){
        for (x in 0...width) {
            for (y in 0...height) {
                if (tiles[x*height+y] == 1) {
                    g.drawImage(kha.Assets.images.tile, x*20, y*20+600, 20, 20);
                }
            }
        }
    }
    public function remove(x,y) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return;
        tiles[x*height+y] = 0;
        dirty = true;
    }
    public function getTile(x,y) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return 0;
        return tiles[x*height+y];
    }
    public function constructShapes() {
        for (body in bodies) {
            body.space = null;
        }
        bodies = [];

        for (x in 0...width) {
            for (y in 0...height) {
                if (getTile(x,y) == 1 && (getTile(x-1,y) == 0 || getTile(x+1,y) == 0 || getTile(x,y-1) == 0 || getTile(x,y+1) == 0)) {
                    var body = new Body(BodyType.STATIC);
                    body.shapes.add(new Polygon(Polygon.rect(x*20, 600+y*20, 20, 20)));
                    body.space = space;
                    bodies.push(body);
                }
            }
        }
        // body.space = space;
    }
}