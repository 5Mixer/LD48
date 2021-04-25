package ;

import kha.audio1.Audio;
import kha.math.Vector2;


class Button {
    public var position:Vector2;
    public var text = "";
    public var mouseOverText = "";
    var callback:Void->Void;
    var width = 400;
    var height = 100;
    var input:Input;
    public function new(x,y,text,input:Input,callback) {
        position = new Vector2(x,y);
        this.text = text;
        this.callback = callback;
        this.input = input;
        input.onLeftDown.push(function () {
            var mousePos = input.getMouseScreenPosition();
            if (mousePos.x > position.x && mousePos.y > position.y && mousePos.x < position.x + width && mousePos.y < position.y + height) {
                callback();
            }
        });
        
    }
    public function render(g:Graphics) {
        var fontSize = 50;
        var mousePos = input.getMouseScreenPosition();
        var mouseOver = mousePos.x > position.x && mousePos.y > position.y && mousePos.x < position.x + width && mousePos.y < position.y + height;
        g.drawImage(kha.Assets.images.button, position.x, position.y, width, height);
        g.drawText(position.x+width/2-g.g.font.width(g.g.fontSize, text)/2,position.y+height/2-fontSize/2,mouseOver ? mouseOverText : text);
    }
}