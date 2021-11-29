package ui;

import kha.math.Vector2i;
import kha.Assets;
import inventory.Item;
import kha.graphics2.Graphics;
import inventory.Inventory;

class Hotbar {
	var inventory:Inventory;
	var position:Vector2i; // Top left of hotbar
	var itemStackSize = 40;
	var itemStackPadding = 5;

	public function new(inventory:Inventory) {
		this.inventory = inventory;
		position = new Vector2i(450, 10); // Magic values based on offset from health bar
	}

	public function render(g:Graphics) {
		var itemIndex = 0;
		for (item => quantity in inventory.getContents()) {
			if (quantity < 1)
				continue;

			drawItemStack(g, item, quantity, position.x + (itemStackSize + itemStackPadding) * itemIndex, position.y);
			itemIndex++;
		}
	}

	function drawItemStack(g:Graphics, item:Item, quantity:Int, x:Int, y:Int) {
		g.drawScaledImage(Assets.images.itemStack, x, y, itemStackSize, itemStackSize);
		g.drawScaledSubImage(Assets.images.items, getItemTextureOffset(item) * 100, 0, 100, 100, x, y, itemStackSize, itemStackSize);
	}

	static function getItemTextureOffset(item:Item) {
		return switch (item) {
			case Stone: 0;
			case Iron: 1;
			case Gold: 2;
			case Copper: 3;
			case Dirt: 4;
			case Grass: 5;
		}
	}
}
