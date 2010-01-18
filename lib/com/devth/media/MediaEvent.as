package com.devth.media
{
	import flash.events.Event;
	
	public class MediaEvent extends Event
	{
		
		// events
		public static var PLAY			:String = "media_event/play";
		public static var BUFFER_FULL	:String = "media_event/buffer_full";
		public static var METADATA		:String = "media_event/metadata";
		public static var COMPLETE		:String = "media_event/complete";
		
		
		public function MediaEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}