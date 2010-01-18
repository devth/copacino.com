package com.afw.puremvc.initmonitor {
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import flash.events.Event;
	
	/**
	 * Internally, <code>InitMonitorProxy</code> uses events to communicate the status of it's resources (IInitProxy objects).<br />
	 * @author AllFlashWebsite.com [Gil Birman]
	 * @see com.afw.puremvc.initmonitor.model.IInitProxy.dispatcher
	 */
	public class InitProxyEvent extends Event{
		public static const COMPLETE:String = "complete";
		public static const FAILED:String = "failed";
		public static const PROGRESS:String = "progress";
		
		public var proxy:IInitProxy;
		public var progress:Number;
		
		/**
		 * Constructor
		 * @param	type
		 * @param	proxy
		 */
		public function InitProxyEvent(type:String, proxy:IInitProxy):void {
			super(type);
			this.proxy = proxy;
		}
	}
	
}