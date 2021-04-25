package ;

import hxnoise.Perlin;
import hxnoise.DiamondSquare;
import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

class Grid {
    var width = 150;
    var height = 400;

    var tiles:Array<Int> = [];
    var tileHealth:Array<Int> = [];
    var bodies:Array<Body> = [];
    var space:Space;
    public var tileRemovalCallback:Int->Void;

    public function new(space) {
        var m_diamondSquare = new Perlin();//width, height, 64, 2, function() { return Math.random() - .5; });
        var seed = Math.random() * 100000;

        for (x in 0...width) {
            for (y in 0...height) {
                var tile = 1;
                var health = 10;

                var air = m_diamondSquare.OctavePerlin(x/20, y/20 , seed, 4, 0.5, 0.6);
                var mineralA = m_diamondSquare.OctavePerlin(x/12 + 1000, y/3 , seed, 3, 0.5, 0.25);
                var mineralB = m_diamondSquare.OctavePerlin(x/5  + 2000,  y/4 , seed, 3, 0.5, 0.25);
                var mineralC = m_diamondSquare.OctavePerlin(x/2  + 3000,  y/2 , seed, 3, 0.5, 0.25);
                var mineralD = m_diamondSquare.OctavePerlin(x  + 8000,  y , seed, 3, 0.5, 0.25);
                if (mineralA < .4) {
                    tile = 2;
                    health = 20; 
                }
                if (mineralB < .4) {
                    tile = 3;
                    health = 50; 
                }
                if (mineralC < .4) {
                    tile = 4;
                    health = 80; 
                }
                if (mineralD < .25) {
                    tile = 11;
                    health = 300; 
                }
                if (air < .45) {
                    tile = 0;
                    health = 0;
                }

                health = Math.round(health * .5 + Math.random() * health * .5);

                tileHealth.push(health);
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
        body.userData.data = BodyData.Tile(x,y);
        body.shapes.add(new Polygon(Polygon.rect(x*20, 600+y*20, 20, 20)));
        body.space = space;

        bodies[x*height+y] = body;
    }
    public function damage(x,y,damage) {
        tileHealth[x*height+y] -= damage;
        if (tileHealth[x*height+y] <= 0)
            remove(x,y);
    }
    public function remove(x,y) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return;

        tileRemovalCallback(tiles[x*height+y]);
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