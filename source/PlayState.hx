package;

import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	var text:FlxText;
	var player:Hero;
	
	var totalTime:Float = 0;
	var dy:Float = 0;

	override public function create():Void
	{
		super.create();

		player = new Hero(25.0, 25.0);
		add(player);

		text = new FlxText();
		text.text = "Hello World!!";
		text.size = 64;
		text.screenCenter();
		text.moves = true;
		add(text);
	}

	override public function update(elapsed:Float):Void
	{
		// elapsed IS deltaTime
		super.update(elapsed);
		
		totalTime += elapsed;
		dy = FlxMath.fastSin(totalTime * 2.5) * 256.0;
		text.velocity.set(0, dy);
	}
}
