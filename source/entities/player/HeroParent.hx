package entities.player;

import flixel.animation.FlxAnimation;
import haxe.CallStack.StackItem;
import flixel.system.debug.watch.Watch;
import flixel.system.FlxSplash;
import haxe.macro.Expr.Case;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;
import systems.Animation;
import systems.Action;

enum PlayerStates 
{
	Null;
	Normal;
	Jumping;
	Crouching;
	Sliding;
}

class Hero extends FlxSprite 
{
	// Input
	private static var DEAD_ZONE(default, never):Float = 0.1;
	private static var MOVEMENT_INTERP_RATIO(default, never):Float = 1/16;

	private var leftInput:Int = 0;
	private var rightInput:Int = 0;
	private var jumpInput:Int = 0;
	private var crouchInput:Int = 0;

	private var horizontalMovementAxis:Float = 0;
	
	// Movement
	private static var GRAVITY(default, never):Float = 981;
	private static var TERMINAL_VELOCITY(default, never):Float = 1500;

	private static var X_MAX_NORMAL_SPEED(default, never):Float = 200;
	private static var X_MAX_AIR_SPEED(default, never):Float = 250;
	private static var X_MAX_CROUCH_SPEED(default, never):Float = 0;

	private static var JUMP_SPEED(default, never):Float = -350;

	private var xSpeed:Float = 0;
	private var ySpeed:Float = 0;
	private var targetXSpeed:Float = 200;
	
	// Jumping
	private var currentJumpCount:Int = 0;
	private var maxJumpCount:Int = 1;

	// Player Systems
	private var playerState:ActionSystem;
	private var facingDirection:Int = 1;
	private var grounded:Bool = false;

	private var playerAnimation:AnimationSystem;
	


	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		// Set up the needed custom systems
		playerState = new ActionSystem(Normal);
		playerAnimation = new AnimationSystem(this);

		targetXSpeed = X_MAX_NORMAL_SPEED;

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;

		// Set up graphics and animations
		loadGraphic("assets/images/sprPlayer.png", true, 32, 32);

		setSize(20, 32);
		offset.set(6, 0);
		centerOrigin(); 

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		animation.add("idle", [0], 45, false);
		animation.add("crouching", [1, 2, 3, 4, 5, 6], 45, false);
		animation.add("uncrouching", [6, 5, 4, 3, 2, 1], 45, false);
	}

	override function update(elapsed:Float) 
	{

		// Check and update the grounded state of the player
		updateGrounded();

		// Set up nicer input-handling for movement.
		gatherInputs();

		// Update facing direction
		var facingDirection:Int = getMoveDirectionCoefficient(horizontalMovementAxis);
		if (facingDirection != 0)
			facing = (facingDirection == -1)? FlxObject.LEFT : FlxObject.RIGHT;

		// Smooth out horizontal movement
		velocity.x = FlxMath.lerp(velocity.x, targetXSpeed * facingDirection, MOVEMENT_INTERP_RATIO);
	   
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

		handleStates();

		

		super.update(elapsed);
	}

	/**
		Function that simply returns an *axis* as a **Float** from two input values.
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
		@return Returns **1**, **0**, or **-1**. Multiply movement speed by this to set movement direction.
	**/
	private function getMoveDirectionCoefficient(axis:Float):Int 
	{      
		return (Math.abs(axis) <= DEAD_ZONE)? 0 : FlxMath.signOf(axis);
	}

	/**
		Function to update `grounded` via `newBool` or `FlxSprite.isTouching()`
		@param newBool Boolean to update `grounded` with. Will be ignored if *False*.
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
		@return Returns `grounded`.
	**/
	public function isOnGround():Bool 
	{ 
		return grounded; 
	}

	/**
		Returns if the player is allowed to jump
		@return Returns **True** only if `grounded` is **True** *or* `currentJumpCount` <= `maxJumpCount`.
	**/
	public function canJump() 
	{
		return  (isOnGround() || (currentJumpCount <= maxJumpCount)) &&
				(playerState.getState() != Crouching);
	}

	/**
		Simple function for handling jump logic.
		@param jumpCount Number of jumps allowed.
		@return Returns **True** if jumping.
	**/
	private function jump(jumpCount:Int):Bool 
	{
		trace(playerState.getState());
		if (canJump()) 
		{
			velocity.y = JUMP_SPEED;
			currentJumpCount++;
			updateGrounded(false);

			playerState.setState(Jumping);

			return true;
		}
		else 
		{
			return false;
		}
	}

	/**
		Returns if the player is allowed to jump
		@return Returns **True** only if `grounded` is **True** *or* `currentJumpCount` <= `maxJumpCount`.
	**/
	public function canCrouch():Bool
	{
		return (isOnGround());
	}

	/**
		Function just set instructions for crouching
	**/
	private function crouch():Void 
	{
		if (canCrouch())
		{
			playerState.setState(PlayerStates.Crouching);
		}	
	}

	/**
		Function that's called to resolve collision overlaping with solid objects when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onWallCollision(player:FlxSprite, other:FlxSprite):Void
	{
		if (isOnGround())
		{
			currentJumpCount = 0;

			playerState.setState(Normal);
		}
	}

	/**
		Function that's called to resolve collision overlaping with damage inducing objects when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onDamageCollision(player:FlxSprite, other:FlxSprite):Void
	{
		// We ONLY do a pixel perfect check if the object in question has collided with our simplified hitbox.
		//
		// Checking perfectly since we have a character that can crouch
		// WAY easier than calculating and updating the hitbox. 
		// It really is, since HaxeFlixel doesn't do a good job scaling with the set origin
		//	which was resulting in glitchy floor detection
		if (FlxG.pixelPerfectOverlap(player, other))
		{
			trace("We have really collided with the object");

			other.kill();
		}
	}

	/**
		Function to handle what happens with each action state
	**/
	public function handleStates():Void
	{
		
		switch (playerState.getState())
		{
			case (PlayerStates.Normal):
				targetXSpeed = X_MAX_NORMAL_SPEED;

				// Only allow an animation change if there has been a state change
				if (playerState.hasChanged())
				{
					// To uncrouching animation if previously crouching
					if (playerAnimation.getPreviousAnimation() == "crouching")
						playerAnimation.setAnimation("uncrouching");
				}

				// Only allow an animation change once the previous animation has finished
				if (playerAnimation.isFinished())
				{
					// To idle animation if previously uncrouching
					if (playerAnimation.getPreviousAnimation() == "uncrouching")
						playerAnimation.setAnimation("idle");
				}

			case (PlayerStates.Crouching):
				targetXSpeed = X_MAX_CROUCH_SPEED;

				if (playerState.hasChanged())
					playerAnimation.setAnimation("crouching", false, false, 0, true);

			case (PlayerStates.Jumping):
				targetXSpeed = X_MAX_AIR_SPEED;

				if (playerState.hasChanged())
					playerAnimation.setAnimation("idle");

			case (PlayerStates.Sliding):
				targetXSpeed = X_MAX_NORMAL_SPEED;

				if (playerState.hasChanged())
					playerAnimation.setAnimation("crouching");

			case (PlayerStates.Null):
		}
	}

}