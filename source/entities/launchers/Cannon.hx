package entities.launchers;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import systems.Action;

enum CannonStates 
{
	Null;
	Idle;
	Detected;
	Charging;
    Firing;
    Cooldown;
}

class Cannon extends FlxSprite
{
    private var cannonState:ActionSystem;

    public function new(?X:Float = 0, ?Y:Float = 0, ?facingDirection:Int = 0) 
    {
        super(X, Y);

        cannonState = new ActionSystem(CannonStates.Idle);

        loadGraphic("assets/images/sprCannon_1.png", false, 32, 32);

        setFacingFlip(FlxObject.LEFT, true, false);
        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.UP, false, false);
        setFacingFlip(FlxObject.DOWN, false, true);

        switch (facingDirection)
        {
            case 4:
                trace("LEFT");
                facing = FlxObject.LEFT;
            case 6:
                trace("RIGHT");
                facing = FlxObject.RIGHT;
            case 8:
                trace("UP");
                angle = -90;
                facing = FlxObject.UP;
            case 2:
                trace("DOWN");
                angle = 90;
                facing = FlxObject.DOWN;
        }

        immovable = true;
    }

    public function playerIsNear():Bool
    {
        if (this.isOnScreen())
        {
            if (FlxMath.distanceToPoint(this, FlxG.cameras.list[0].target.getPosition()) < 280)
            {
                //trace("Near Cannon");
            }
        }
        
        return true;
    }

}
