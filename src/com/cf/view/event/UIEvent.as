package com.cf.view.event
{
	import com.cf.util.Component;
	
	import flash.events.Event;

	/**
	 * Event subclass for view components to broadcast up to mediators
	 */
	public class UIEvent extends Event
	{
		// NOTE there is a newer better version of UIEvent.  This crap is DEPRICATED X_X
		
		
		// UIEVENT TYPES
		public static const SHAPE_CLICK:String		= "shapeClick";
		public static const LIST_TILE_CLICK:String	= "listTileClick";
		public static const LIST_CLOSE:String		= "listCloseEvent";
		public static const URL_EVENT:String		= "urlEvent";
		
		public var name:String;
		public var url:String;
		
		public var view:Component;
		
		public function UIEvent(type:String, name:String, url:String="", bubbles:Boolean=true, cancelable:Boolean=true)
		{
			this.name = name;
			this.url = url;
			super(type, bubbles, cancelable);
		}
		
	}
}