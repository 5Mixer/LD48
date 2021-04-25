package ;

import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

class Grid {
    var width = 150;
    var height = 400;

    var tiles:Array<Int> = [];
    var bodies:Array<Body> = [];
    var space:Space;

    public function new(space) {
        for (x in 0...width) {
            for (y in 0...height) {
                var tile = 1;
                var r = Math.random();
                if (r < .01) {
                    tile = 2;
                }else if (r < .02) {
                    tile = 3;
                }else if (r < .03) {
                    tile = 4;
                }
                tiles.push(tile);
                bodies.push(null);
            }
        }
        this.space = space;

        constructShapes();
    }
    public function update() {
    }
    public function render(g:Graphics){
        g.startTiles();
        for (x in 0...width) {
            for (y in 0...height) {
                if (getTile(x,y) != 0) {
                    g.drawTile(x*20, y*20+600, getTile(x,y)-1);

                    if (getTile(x,y-1) == 0) {
                        g.drawTile(x*20, y*20+600, 8);
                    }
                    if (getTile(x,y+1) == 0) {
                        g.drawTile(x*20, y*20+600, 9);
                    }

                    if (getTile(x,y+1) == 0 && getTile(x-1,y) == 0) {
                        g.drawTile(x*20, y*20+600, 4);
                    }
                    if (getTile(x,y-1) == 0 && getTile(x-1,y) == 0) {
                        g.drawTile(x*20, y*20+600, 5);
                    }
                    if (getTile(x,y-1) == 0 && getTile(x+1,y) == 0) {
                        g.drawTile(x*20, y*20+600, 6);
                    }
                    if (getTile(x,y+1) == 0 && getTile(x+1,y) == 0) {
                        g.drawTile(x*20, y*20+600, 7);
                    }
                }
            }
        }
        g.endTiles();
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

        if (x > 0 && unsafeGetTile(x-1,y) != 0 && unsafeGetBody(x-1,y) == null) {
            makeBody(x-1,y);
        }
        if (x < width-1 && unsafeGetTile(x+1,y) != 0 && unsafeGetBody(x+1,y) == null) {
            makeBody(x+1,y);
        }
        if (y > 0 && unsafeGetTile(x,y-1) != 0 && unsafeGetBody(x,y-1) == null) {
            makeBody(x,y-1);
        }
        if (y < height-1 && unsafeGetTile(x,y+1) != 0 && unsafeGetBody(x,y+1) == null) {
            makeBody(x,y+1);
        }
    }
    public inline function unsafeGetTile(x,y) {
        return tiles[x*height+y];
    }
    public inline function unsafeGetBody(x,y) {
        return bodies[x*height+y];
    }

    public function constructShapes() {
        for (x in 0...width) {
            for (y in 0...height) {
                if (getTile(x,y) != 0 && (getTile(x-1,y) == 0 || getTile(x+1,y) == 0 || getTile(x,y-1) == 0 || getTile(x,y+1) == 0)) {
                    makeBody(x,y);
                }
            }
        }
    }
    public function getTile(x,y) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return 0;
        return tiles[x*height+y];
    }
}