package com.cf.model.event
{
	import flash.events.Event;

	public class StateEvent extends Event
	{
		public static var STATE_CHANGED:String	= "stateChanged";
		
		public var previousState:String;
		public var state:String;
		
		public function StateEvent(type:String, previousState:String, state:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.state = state;
			this.previousState = previousState;
			super(type, bubbles, cancelable);
		}
		
	}
}