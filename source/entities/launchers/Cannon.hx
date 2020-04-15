package entities.launchers;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;

class Cannon extends FlxSprite
{
    public function new(?X:Float = 0, ?Y:Float = 0) 
    {
        super(X, Y);

        loadGraphic("assets/images/sprCannon_1.png", true, 14, 30);

        immovable = true;
    }

    public function playerIsNear():Bool
    {
        if (this.isOnScreen())
        {
            if (FlxMath.distanceToPoint(this, FlxG.cameras.list[0].target.getPosition()) < 300)
            {
                trace("Near Cannon");
            }
        }
        
        return true;
    }

    override function update(elapsed:Float) 
    {
        playerIsNear();

        super.update(elapsed);
    }
}
