package;

import ui.Touchpad;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.math.Vector2;

class Input {
	var camera:Camera;

	var mousePosition:Vector2;

	public var leftMouseButtonDown = false;
	public var middleMouseButtonDown = false;
	public var rightMouseButtonDown = false;
	public var onRightDown:() -> Void;
	public var onRightUp:() -> Void;
	public var onLeftDown:Array<() -> Void> = [];
	public var onMouseMove:(Int, Int) -> Void;
	public var onScroll:(Int) -> Void;
	public var downKeys:Array<KeyCode> = [];

	public var movementTouchpad:Touchpad;
	public var actionTouchpad:Touchpad;

	public function new(camera) {
		this.camera = camera;

		Mouse.get().notify(onMouseDown, onMouseUp, mouseMoveHandler, onMouseWheel);
		Keyboard.get().notify(function(key) {
			downKeys.push(key);
		}, function(key) {
			while (downKeys.contains(key))
				downKeys.remove(key);
		}, null);

		mousePosition = new Vector2();
	}

	public function shouldMove() {
		#if kha_android_native
		return movementTouchpad.isDown();
		#else
		return leftMouseButtonDown || downKeys.contains(KeyCode.Q);
		#end
	}

	public function middle() {
		return middleMouseButtonDown || downKeys.contains(KeyCode.W);
	}

	public function shouldDoAction() {
		#if kha_android_native
		return actionTouchpad.isDown();
		#else
		return rightMouseButtonDown || downKeys.contains(KeyCode.E);
		#end
	}

	function onMouseDown(button:Int, x:Int, y:Int) {
		mousePosition.x = x;
		mousePosition.y = y;

		if (button == 0) {
			leftMouseButtonDown = true;
			if (onLeftDown != null)
				for (callback in onLeftDown)
					callback();
		}
		if (button == 1) {
			rightMouseButtonDown = true;
			if (onRightDown != null)
				onRightDown();
		}
		if (button == 2)
			middleMouseButtonDown = true;
	}

	function onMouseUp(button:Int, x:Int, y:Int) {
		mousePosition.x = x;
		mousePosition.y = y;

		if (button == 0) {
			leftMouseButtonDown = false;
		}
		if (button == 1) {
			rightMouseButtonDown = false;
			if (onRightUp != null)
				onRightUp();
		}
		if (button == 2)
			middleMouseButtonDown = false;
	}

	function mouseMoveHandler(x:Int, y:Int, dx:Int, dy:Int) {
		mousePosition.x = x;
		mousePosition.y = y;
		if (onMouseMove != null)
			onMouseMove(dx, dy);
	}

	function onMouseWheel(delta:Int) {
		onScroll(delta);
	}

	public function getMovementVector() {
		return movementTouchpad.getVector();
	}

	public function getActionVector() {
		return actionTouchpad.getVector();
	}

	public function getMouseWorldPosition():kha.math.Vector2 {
		return camera.viewToWorld(mousePosition);
	}

	public function getMouseScreenPosition():kha.math.Vector2 {
		return mousePosition;
	}
}
