package;

import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	var text = new FlxText();
	var player:Hero = new Hero();
	var dy:Float = 0;
	var dt:Float = 0;

	override public function create():Void
	{
		super.create();

		text.text = "Hello World!!";
		text.size = 64;
		text.screenCenter();
		text.moves = true;
		add(text);

		player = new Hero(25.0, 25.0);
		//add(player);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		dt += elapsed;
		dy = FlxMath.fastSin(dt * 2.5) * 256.0;
		//text.setPosition(text.x, text.y + dy);
		text.velocity.set(0, dy);
	}
}
