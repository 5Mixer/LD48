package level;

typedef TileData = {
	var name:String;
	var baseTexture:Int;
	var solid:Bool;
	var value:Int;
	var health:Int;
}

class Tiles {
	public static final data:Array<TileData> = [
		{
			name: 'stone',
			baseTexture: 0,
			solid: true,
			value: 5,
			health: 10
		},
		{
			name: 'stoneDark',
			baseTexture: 1,
			solid: true,
			value: 10,
			health: 10
		},
		{
			name: 'iron',
			baseTexture: 2,
			solid: true,
			value: 30,
			health: 20
		},
		{
			name: 'gold',
			baseTexture: 3,
			solid: true,
			value: 50,
			health: 40
		},
		{
			name: 'copper',
			baseTexture: 4,
			solid: true,
			value: 60,
			health: 60
		},
		{
			name: 'dirt',
			baseTexture: 5,
			solid: true,
			value: 1,
			health: 1
		},
		{
			name: 'grass',
			baseTexture: 6,
			solid: true,
			value: 1,
			health: 1
		},
		{
			name: 'dirtDark',
			baseTexture: 7,
			solid: true,
			value: 1,
			health: 1
		},
		{
			name: 'plant',
			baseTexture: 8,
			solid: false,
			value: 1,
			health: 1
		}
	];
}
