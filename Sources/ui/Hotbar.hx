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
		var quantityLabelVerticalPadding = 20;
		g.fontSize = 22;
		g.font = kha.Assets.fonts.Poppins_Light;
		g.drawScaledImage(Assets.images.itemStack, x, y, itemStackSize, itemStackSize);
		g.drawScaledImage(Assets.images.itemStack, x, y + itemStackSize + quantityLabelVerticalPadding - 3, itemStackSize, g.fontSize + 6);
		g.drawScaledSubImage(Assets.images.items, getItemTextureOffset(item) * 100, 0, 100, 100, x, y, itemStackSize, itemStackSize);
		g.font = kha.Assets.fonts.BebasNeue_Regular;
		var string = getQuantityAsApproximateString(quantity);
		g.drawString(string, x + 3, y + itemStackSize + quantityLabelVerticalPadding);
	}

	function getQuantityAsApproximateString(quantity:Int) {
		if (quantity < 1000) {
			return '$quantity';
		} else if (quantity < 10000) {
			return Math.round(quantity / 10) * 10 / 1000 + "k";
		} else if (quantity < 1000000) {
			return Math.round(quantity / 1000 * 10) / 10 + "k";
		} else if (quantity < 1000000000) {
			return Math.round(quantity / 1000000 * 10) / 10 + "m";
		}
		return '$quantity';
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
