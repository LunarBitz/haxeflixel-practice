package;

import entities.projectiles.Fireball;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import entities.player.HeroParent;
import entities.launchers.Cannon;
import entities.terrain.Wall;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	private var hero:Hero;

	private var map:FlxOgmo3Loader;
	private var graphicTiles:FlxTilemap;
	private var solidTiles:FlxTypedGroup<Wall>;
	private var cannons:FlxTypedGroup<Cannon>;

	override public function create():Void
	{
		hero = new Hero();
		add(hero);

		FlxG.camera.follow(hero, PLATFORMER, 1/16);

		initOgmo3Map(AssetPaths.TestMap__ogmo, AssetPaths.TestMap__json);



		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (solidTiles != null)
		{
			// Must handle x collisions before the y collisions or 
			// else the player will get stuck in the seams of solid object sprites
			FlxG.overlap(hero, solidTiles, hero.onWallCollision, FlxObject.separateX);
			FlxG.overlap(hero, solidTiles, hero.onWallCollision, FlxObject.separateY);	
		}

	}

	private function initOgmo3Map(projectPath:String, projectJson:String):Void 
	{
		map = new FlxOgmo3Loader(AssetPaths.TestMap__ogmo, AssetPaths.TestMap__json);	

		// Get the solid objects for collission
		var grid:Map<String, Array<flixel.math.FlxPoint>> = map.loadGridMap("solid");
		solidTiles = new FlxTypedGroup<Wall>();
		for (point in grid['1'])
		{
			solidTiles.add(new Wall(point.x, point.y, 48, 48));
		}

		// Get the graphical tilemaps
		// Note: When creating a tileset in a sprite editor, ALWAYS leave the first tile 
		//		 blank (0 alpha)! Will save you a lot of time and spared of the headache 
		// 		 trying to figure out why the tiles aren't rendering.
		graphicTiles = map.loadTilemap(AssetPaths.sprStationTileset__png, "graphics");
		graphicTiles.follow();
		// Disable collision for tiles 1-4 since we already established a collision grid
		graphicTiles.setTileProperties(1, FlxObject.NONE, null, null, 4);

		// Get all entities
		cannons = new FlxTypedGroup<Cannon>();
		map.loadEntities(placeEntities, "entities");

		// Add groups for building
		add(solidTiles);
		add(graphicTiles);
		add(cannons);
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "player":
				hero.setPosition(entity.x, entity.y);
			case "cannon":
				cannons.add(new Cannon(entity.x, entity.y, entity.values.facing_direction));
		}
	}

}
