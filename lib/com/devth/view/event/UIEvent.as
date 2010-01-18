package com.devth.view.event
{
	import flash.events.Event;

	/**
	 * Event subclass for view components to broadcast up to mediators
	 */
	public class UIEvent extends Event
	{
		public var view:Object;
		public var data:Object;
		
		public function UIEvent(type:String, view:Object, data:Object, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			this.view = view;
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
	}
}