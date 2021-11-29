package inventory;

class Inventory {
	var contents:Map<Item, Int> = [];

	public function new() {}

	public function addItem(item:Item, quantity = 1) {
		if (!contents.exists(item)) {
			contents.set(item, quantity);
		} else {
			contents.set(item, contents.get(item) + quantity);
		}
	}

	public function removeItem(item:Item, quantity = 1) {
		if (contents.exists(item)) {
			var removedQuantity = contents.get(item) - quantity;
			contents.set(item, removedQuantity < 0 ? 0 : removedQuantity);
		}
	}

	public function getContents() {
		return contents;
	}
}
