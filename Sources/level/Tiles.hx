package level;

import inventory.Item;

typedef TileData = {
	var name:String;
	var baseTexture:Int;
	var solid:Bool;
	var value:Int;
	var health:Int;
	var drops:Item;
}

class Tiles {
	public static final data:Array<TileData> = [
		{
			name: 'stone',
			baseTexture: 0,
			solid: true,
			value: 5,
			health: 10,
			drops: Stone
		},
		{
			name: 'stoneDark',
			baseTexture: 1,
			solid: true,
			value: 10,
			health: 10,
			drops: Stone
		},
		{
			name: 'iron',
			baseTexture: 2,
			solid: true,
			value: 30,
			health: 20,
			drops: Iron
		},
		{
			name: 'gold',
			baseTexture: 3,
			solid: true,
			value: 50,
			health: 40,
			drops: Gold
		},
		{
			name: 'copper',
			baseTexture: 4,
			solid: true,
			value: 60,
			health: 60,
			drops: Copper
		},
		{
			name: 'dirt',
			baseTexture: 5,
			solid: true,
			value: 1,
			health: 1,
			drops: Dirt
		},
		{
			name: 'grass',
			baseTexture: 6,
			solid: true,
			value: 1,
			health: 1,
			drops: Grass
		},
		{
			name: 'dirtDark',
			baseTexture: 7,
			solid: true,
			value: 1,
			health: 1,
			drops: Dirt
		},
		{
			name: 'plant',
			baseTexture: 8,
			solid: false,
			value: 1,
			health: 1,
			drops: Grass
		}
	];
}
