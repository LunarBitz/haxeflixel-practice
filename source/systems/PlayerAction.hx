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
	var previousState:ActionState = ActionState.Null;
	var currentState:ActionState = ActionState.Null;

	public function new(defaultAction:ActionState = ActionState.Null) 
	{
		currentState = defaultAction;
		previousState = currentState;
    }

	public function hasChanged():Bool
	{
		return !(previousState == currentState);
	}

	public function setState(newState:ActionState):ActionState
	{
		previousState = currentState;
		currentState = newState;

		return currentState;
	}

	public function getState():ActionState
	{
		return currentState;
    }
    
    public function getPreviousState():ActionState
    {
        return previousState;
    }
    
}