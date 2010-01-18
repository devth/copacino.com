package com.afw.remoting {
	import flash.events.Event;
	
	/**
	 * This is the event object that MinimalRemoting dispatches. <br />
	 * <br />
	 * The result data or information about the event is stored in the result property.<br />
	 * Only RESULT type events will also have a non-null resultType property
	 * 
	 * @author AllFlashWebsite.com [Gil Birman]
	 */
	public class RemotingEvent extends Event {
		public static const RESULT:String = "RESULT";
		public static const FAILED:String = "FAILED";
		public static const NET_STATUS_FAILED:String = "netStatusFailed";
		
		public var result:Object;
		public var resultType:String;
		
		public function RemotingEvent(type:String, result:Object=null, resultType:String=null) {
			this.result = result;
			this.resultType = resultType;
			super(type, bubbles, cancelable);
		}
		
	}
	
}