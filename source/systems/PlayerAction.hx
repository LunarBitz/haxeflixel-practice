package systems;

enum ActionState 
{
	Null;
	Normal;
	Jumping;
	Crouching;
	Sliding;
}

class Action
{
	var lastState:ActionState = ActionState.Null;
	var currentState:ActionState = ActionState.Null;
	var changed:Bool = false;

	public function new(defaultAction:ActionState = ActionState.Null) 
	{
		this.currentState = defaultAction;
		this.lastState = currentState;
    }

	public function hasChanged():Bool
	{
		return !(lastState == currentState);
	}

	public function setState(newState:ActionState = ActionState.Null):ActionState
	{
		lastState = currentState;
		currentState = newState;

		return currentState;
	}

	public function getState():ActionState
	{
		return currentState;
	}

}