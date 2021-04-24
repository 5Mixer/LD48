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

    public function new(space) {
        for (x in 0...width) {
            for (y in 0...height) {
                tiles.push(1);
                bodies.push(null);
            }
        }
        this.space = space;

        constructShapes();
    }
    public function update() {
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
    function makeBody(x, y) {
        var body = new Body(BodyType.STATIC);
        body.shapes.add(new Polygon(Polygon.rect(x*20, 600+y*20, 20, 20)));
        body.space = space;

        bodies[x*height+y] = body;
    }
    public function remove(x,y) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return;
        tiles[x*height+y] = 0;

        if (bodies[x*height+y] != null) {
            bodies[x*height+y].space = null;
            bodies[x*height+y] = null;
        }

        if (x > 0 && unsafeGetTile(x-1,y) == 1 && getBody(x-1,y) == null) {
            makeBody(x-1,y);
        }
        if (x < width-1 && unsafeGetTile(x+1,y) == 1 && getBody(x+1,y) == null) {
            makeBody(x+1,y);
        }
        if (y > 0 && unsafeGetTile(x,y-1) == 1 && getBody(x,y-1) == null) {
            makeBody(x,y-1);
        }
        if (y < height-1 && unsafeGetTile(x,y+1) == 1 && getBody(x,y+1) == null) {
            makeBody(x,y+1);
        }
    }
    public inline function unsafeGetTile(x,y) {
        return tiles[x*height+y];
    }
    public function getTile(x,y) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return 0;
        return tiles[x*height+y];
    }
    public inline function getBody(x,y) {
        // if (x < 0 || y < 0 || x >= width || y >= height)
        //     return null;
        return bodies[x*height+y];
    }

    public function constructShapes() {
        for (x in 0...width) {
            for (y in 0...height) {
                if (getTile(x,y) == 1 && (getTile(x-1,y) == 0 || getTile(x+1,y) == 0 || getTile(x,y-1) == 0 || getTile(x,y+1) == 0)) {
                    makeBody(x,y);
                }
            }
        }
    }
}