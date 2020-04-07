package;

import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;

class PlayState extends FlxState
{
	var text = new FlxText();
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
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		dt += elapsed;
		dy = FlxMath.fastSin(dt * 2.5) * 4.0;
		text.setPosition(text.x, text.y + dy);
	}
}
