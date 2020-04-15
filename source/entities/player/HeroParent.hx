package entities.player;

import flixel.animation.FlxAnimation;
import haxe.CallStack.StackItem;
import flixel.system.debug.watch.Watch;
import flixel.system.FlxSplash;
import haxe.macro.Expr.Case;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;

private enum ActionState 
{
	Null;
	Normal;
	Jumping;
	Crouching;
	Sliding;
}

private class Action
{
	var lastState:ActionState = ActionState.Null;
	var currentState:ActionState = ActionState.Null;
	var changed:Bool = false;

	private function checkChanged():Bool
	{
		return !(lastState == currentState);
	}

	private function setState(newState:ActionState = ActionState.Null):ActionState
	{
		lastState = currentState;
		currentState = newState;

		return currentState;
	}

	private function getState():ActionState
	{
		return currentState;
	}

}



class Hero extends FlxSprite 
{
	// Graphics
	private var playerWidth:Float = 0;
	private var playerHeight:Float = 0;
	private var targetWidth:Float = 0;
	private var targetHeight:Float = 0;

	private static var THICKNESS_NORMAL(default, never):Float = 16;
	private static var HEIGHT_NORMAL(default, never):Float = 32;
	private static var HEIGHT_JUMPING(default, never):Float = 36;
	private static var HEIGHT_CROUCHING(default, never):Float = 16;

	// Input
	private static var DEAD_ZONE(default, never):Float = 0.1;
	private static var MOVEMENT_INTERP(default, never):Float = 1/16;

	private var leftInput:Int = 0;
	private var rightInput:Int = 0;
	private var jumpInput:Int = 0;
	private var crouchInput:Int = 0;

	private var horizontalMovementAxis:Float = 0;
	
	// Movement
	private static var GRAVITY(default, never):Float = 981;
	private static var TERMINAL_VELOCITY(default, never):Float = 1500;
	private static var X_TARGET_SPEED(default, never):Float = 200;
	private static var JUMP_SPEED(default, never):Float = -350;

	private var xSpeed:Float = 0;
	private var ySpeed:Float = 0;
	
	// Jumping
	private var currentJumpCount:Int = 0;
	private var maxJumpCount:Int = 1;

	// Player States
	private var animCycle:Int = 0;
	private var playerState:ActionState;
	private var facingDirection:Int = 1;
	private var grounded:Bool = false;
	

	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		actionState(ActionState.Normal);
		//

		targetWidth = THICKNESS_NORMAL;
		targetHeight = HEIGHT_NORMAL;
		loadGraphic("assets/images/sprPlayer.png", true, 32, 32);
		animation.add("idle", [0], 30, false);
		animation.add("crouching", [1, 2, 3, 4, 5, 6], 4, false);
		animation.add("uncrouching", [6, 5, 4, 3, 2, 1], 4, false);

		//updateAnimationAndHitbox("crouching");

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;

		//FlxG.watch.add(this, "targetHeight", "Target Height");
		//FlxG.watch.add(this, "playerHeight", "Player Height");
		//FlxG.watch.add(this, "origin", "Origin");
		FlxG.watch.add(this, "animCycle", "Anim Cycle");
		
	}

	override function update(elapsed:Float) 
	{
		// Check and update the grounded state of the player
		updateGrounded();

		// Set up nicer input-handling for movement.
		gatherInputs();

		// Update facing direction
		var facingDirection:Int = getMoveDirectionCoefficient(horizontalMovementAxis);

		// Smooth out horizontal movement
		velocity.x = FlxMath.lerp(velocity.x, X_TARGET_SPEED * facingDirection, MOVEMENT_INTERP);
	   
		// Jump
		if (jumpInput == 1)
		{
			jump(maxJumpCount);
		}

		// Crouch
		if (crouchInput == 1)
		{
			crouch();
		}

		handleActionStates();

		super.update(elapsed);
	}

	private function actionState(newState:ActionState = ActionState.Null):ActionState
	{
		if (newState != ActionState.Null)
		{
			playerState = newState;
			return newState;
		}
		else
		{
			return playerState;
		}
	}

	/**
		Function that simply returns an "axis" as a **Float** from two input values.
	**/
	private function inputAxis(negativeInput:Float, positiveInput:Float):Float 
	{
		return (positiveInput - negativeInput);
	}

	/**
		Helper function responsible for interacting with HaxeFlixel systems to gather inputs 
		relevant to the Hero. Helps keep code clean by restricting FlxG.keys input to a single spot,
		which makes it much easier to change inputs, implement rebinding, etc. in the future.
	**/
	private function gatherInputs():Void 
	{
		leftInput = (FlxG.keys.pressed.LEFT)? 1:0;
		rightInput = (FlxG.keys.pressed.RIGHT)? 1:0;
		horizontalMovementAxis = inputAxis(leftInput, rightInput);
		
		jumpInput = (FlxG.keys.justPressed.Z)? 1:0;
		crouchInput = (FlxG.keys.pressed.DOWN)? 1:0;
	}

	/**
		Uses player input to determine if movement should occur in a positive or negative X 
		direction. If no movement inputs are detected, 0 is returned instead.
		@param axis Float representing an axis of input.
		@return Returns 1, 0, or -1. Multiply movement speed by this to set movement direction.
	**/
	private function getMoveDirectionCoefficient(axis:Float):Int 
	{      
		return (Math.abs(axis) <= DEAD_ZONE)? 0 : FlxMath.signOf(axis);
	}

	/**
		Function to update the ***grounded*** variable via ***newBool*** or **FlxSprite.isTouching()**
		@param newBool Boolean to update the ***grounded*** variable with. Will be ignored if *False*.
	**/
	public function updateGrounded(newGround:Bool = false):Void
	{
		if (newGround)
			grounded = newGround;
		else
			grounded = this.isTouching(FlxObject.DOWN);
	}

	/**
		Returns if the player is on the ground or not
		@return Returns the ***grounded*** variable.
	**/
	public function isOnGround():Bool 
	{ 
		return grounded; 
	}

	/**
		Returns if the player is allowed to jump. Does NOT check if the player is grounded to allow for multi-jumping
		@return Returns *True* only if *`currentJumpCount` < `maxJumpCount`*.
	**/
	public function canJump() 
	{
		return  (isOnGround() || (currentJumpCount <= maxJumpCount));
	}

	/**
		Simple function for handling jump logic.
		@param jumpCount Number of jumps allowed.
	**/
	private function jump(jumpCount:Int):Void 
	{
		if (canJump()) 
		{
			velocity.y = JUMP_SPEED;
			currentJumpCount++;
			updateGrounded(false);
			actionState(ActionState.Jumping);
		}
	}

	private function crouch():Void 
	{
		actionState(ActionState.Crouching);
	}

	/**
		Function that's called to resolve collision overlaps when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onCollision(player:FlxSprite, other:FlxSprite)
	{
		if (isOnGround())
		{
			currentJumpCount = 0;
			actionState(ActionState.Normal);
		}

		unstick(player, other);
	}

	private function unstick(player:FlxSprite, other:FlxSprite) 
	{

		//Horizontal Collision
		if (overlapsAt(x + velocity.x, y, other))
		{
			while(!overlapsAt(x + FlxMath.signOf(velocity.x), y, other))
			{
				x += FlxMath.signOf(velocity.x);
			}
			//xSpeed = 0;
		}

		//vertical Collision
		if (overlapsAt(x, y + velocity.y, other))
		{
			while(!overlapsAt(x, y + FlxMath.signOf(velocity.y), other))
			{
				y += FlxMath.signOf(velocity.y);
			}
			//ySpeed = 0;
		}	
	}

	public function isOnLastFrame():Bool
	{
		if (animation.curAnim != null)
		{
			var l = animation.curAnim.frames.length - 1;
			trace(animation.frameIndex, animation.curAnim.frames, animation.curAnim.frames[l]);
			return (animation.frameIndex == animation.curAnim.frames[l]);
		}

		return false;
	}

	public function isOnFirstFrame():Bool
	{
		if (animation.curAnim != null)
		{
			return (animation.frameIndex == animation.curAnim.frames[0]);
		}

		return false;
	}

	public function updateAnimationAndHitbox(?animations:Array<String>, ?loopLastAnimation:Bool = true, ?holdLastFrame:Bool = false, ?forcePlay:Bool = false, ?reversed:Bool = false) 
	{
		var rev:Array<String> = animations;
		rev.reverse();
		

		if (animations.length == 1)
		{
			animation.play(animations[0], forcePlay, reversed);

			if (holdLastFrame == true && isOnLastFrame())
				animation.curAnim.pause();
		}
		else if (animations.length > 1)
		{
			if (animation.curAnim != null)
			{

				if (animCycle != 0)
				{
					animation.play(animations[animCycle], forcePlay, reversed);

					if (isOnLastFrame())
					{
						animCycle--;
					}
				}
				else if (animCycle == 0)
				{
					if (holdLastFrame == true && isOnLastFrame())
					{
						animation.curAnim.pause();
					}
				}
			}
		}
		
		

		updateHitbox();
	}

	public function handleActionStates():Void
	{
		switch (actionState())
		{
			case (ActionState.Normal):
				updateAnimationAndHitbox(["uncrouching", "idle"], false, true, false);
			case (ActionState.Crouching):
				updateAnimationAndHitbox(["crouching"], false, true);
			case (ActionState.Jumping):
				updateAnimationAndHitbox(["idle"]);
			case (ActionState.Sliding):
				updateAnimationAndHitbox(["crouching"]);
			case (ActionState.Null):
		}
	}
}