package ;

import kha.math.Vector2;

class Launcher {
    var timer:Float = 0;
    var period:Float = 5;
    public var position:Vector2;
    public var launchCallback:(Launcher)->Void;

    public function new(x, y, callback:(Launcher)->Void) {
        position = new Vector2(x,y);
        launchCallback = callback;
    }
    public function update(delta:Float) {
        timer -= delta;
        if (timer < 0) {
            timer = period;
            launchCallback(this);
        }
    }
    public function render(g:Graphics) {
        g.drawImage(kha.Assets.images.launcher, position.x, position.y, 20, 20);
    }
}