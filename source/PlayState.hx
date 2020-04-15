package;

import entities.projectiles.Fireball;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import entities.player.HeroParent;
import entities.launchers.Cannon;
import entities.terrain.Wall;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class PlayState extends FlxState
{
	private static var WALL_COUNT(default, never) = 10;
	private static var WALL_START_X(default, never) = 150;
	private static var WALL_START_Y(default, never) = 200;

	private static var FIREBALL_COUNT(default, never) = 20;
	private static var FIREBALL_SPAWN_BORDER(default, never) = 50;

	private var hero:Hero;
	private var walls:FlxTypedGroup<Wall>;
	private var fireballs:FlxTypedGroup<Fireball>;
	//private var map:FlxOgmo3Loader;

	override public function create():Void
	{
		super.create();

		

		hero = new Hero();
		add(hero);

		FlxG.camera.follow(hero, PLATFORMER, 1/32);

		initializeWalls();
		initializeFireballs();

		var cann = new Cannon(150, 200);
		add(cann);
	}

	private function initializeWalls() {
		walls = new FlxTypedGroup<Wall>();

		for (i in 0...WALL_COUNT) {
			var x:Float = WALL_START_X + (i * Wall.WIDTH);
			var y:Float = WALL_START_Y;
			var wall:Wall = new Wall(x, y);
			walls.add(wall);
		}
		add(walls);
	}

	private function initializeFireballs() {
		fireballs = new FlxTypedGroup<Fireball>();

		for (i in 0...FIREBALL_COUNT) {
			var x:Float = FlxG.random.int(FIREBALL_SPAWN_BORDER, 
				FlxG.width - FIREBALL_SPAWN_BORDER);
			var y:Float = FlxG.random.int(FIREBALL_SPAWN_BORDER, 
				FlxG.height - FIREBALL_SPAWN_BORDER);
			var fireball = new Fireball(x, y);
			fireballs.add(fireball);
		}
		add(fireballs);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Uncomment to collide hero against all wall objects.
		FlxG.collide(hero, walls, hero.onWallCollision);

		// Uncomment to trigger custom logic when a player overlaps with a fireball.
		FlxG.overlap(hero, fireballs, hero.onDamageCollision);

		// Wrap various objects if gone offscreen.
		screenWrapObject(hero);
		for (fireball in fireballs) {
			screenWrapObject(fireball);
		}
	}

	private function screenWrapObject(wrappingObject:FlxObject) {
		if (wrappingObject.x > FlxG.width) {
			wrappingObject.x = 0 - wrappingObject.width;
		} else if (wrappingObject.x + wrappingObject.width < 0) {
			wrappingObject.x = FlxG.width;
		}

		if (wrappingObject.y > FlxG.height) {
			wrappingObject.y = 0 - wrappingObject.height;
		} else if (wrappingObject.y + wrappingObject.height < 0) {
			wrappingObject.y = FlxG.height;
		}
	}

}
