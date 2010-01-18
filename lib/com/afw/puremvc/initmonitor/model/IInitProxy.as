/*
 Copyright (c) 2008 AllFlashWebsite.com
 All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 @ignore
 */
 
package com.afw.puremvc.initmonitor.model
{
	import flash.events.EventDispatcher;
	import org.puremvc.as3.interfaces.IProxy;

    /**
	 *  Application proxy classes for use with InitMonitorProxy,
	 *  all proxies passed to InitMonitorProxy must implement this interface and extend SimpleInitProxy.
	 * 
	 * @version 0.3
	 * @author Gil Birman [AllFlashWebsite.com]
     */
    public interface IInitProxy extends IProxy {
		/**
		 * This function gets called by InitMonitorProxy. At some point after load() is called, 
		 * a Notification based on completeNotificationName is sent.
		 */
		function load():void;
		
		/**
		 * sends final Notification
		 */
		function finish():void;
		
		/**
		 * This function should stop loading in its tracks. Although the proxy may continue to process,
		 * the completeNotificationName Notification should not be sent after stop() is called.<br />
		 * Ussually, stop will simply remove an event listener to prevent finish() from being called.
		 */
		function stop():void;
		
		/**
		 * The complete property helps InitMonitorProxy to calculate loading progress.<br />
		 * Keep in mind that some proxies may already be complete even before InitMonitorProxy.start() is called<br />
		 */
		function get complete():Boolean;
		
		/**
		 * OPTIONAL (return 0 if not implementing)<br />
		 * InitMonitor will use this to calculate a more accurate progress notification<br />
		 */
		function get percentLoaded():Number;
		function set percentLoaded(v:Number):void;
		
		/**
		 * The IInitProxy should instantiate an EventDispatcher object which will be used to send InitProxyEvent's picked up by InitMonitorProxy<br />
		 */
		function get dispatcher():EventDispatcher;
		
		/**
		 * Every IInitProxy must have an associated weight. This number is relative to the other weights.<br />
		 * SimpleInitProxy defaults weight to 1<br />
		 */
		function set weight(v:Number):void;
		function get weight():Number;
	}
}