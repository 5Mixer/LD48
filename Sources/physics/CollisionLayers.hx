package physics;

class CollisionLayers {
	public static final PLAYER = 1 << 0;
	public static final ENEMY = 1 << 1;
	public static final TILE = 1 << 2;
	public static final TILE_DROP = 1 << 3;
	public static final LEVEL = 1 << 4;
	public static final DYNAMITE = 1 << 5;
	public static final BULLET = 1 << 6;
	public static final EXPLOSION_FORCE = 1 << 6;
}
