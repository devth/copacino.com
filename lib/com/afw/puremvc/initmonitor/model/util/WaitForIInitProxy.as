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
 
package com.afw.puremvc.initmonitor.model.util
{
	import com.afw.puremvc.initmonitor.model.NotifyingInitProxy;
	import org.puremvc.as3.patterns.observer.Notification;
	//import com.afw.puremvc.initmonitor.model.SimpleInitProxy;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import flash.events.Event;
	import com.afw.puremvc.initmonitor.InitProxyEvent;
	
	/**
	 * This class waits for a specified IInitProxy instance to load. 
	 *  It will therefore have the same percentLoaded value as the IInitProxy it is waiting for
	 *   (assuming that proxy dispatches the PROGRESS event).
	 *  The main purpose for this class is to wait for an instance of InitMonitorProxy
	 *   from another InitMonitorProxy.<br />
	 * <br />
	 * Example 1: Lets say you have one InitMonitorProxy instance for the home section and 
	 *  you need to wait on it from another section...
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new WaitForIInitProxy(
	 *			"waitForHomeInitMonitor",
	 * 			ApplicationFacade.HOME_INIT_MONITOR_NAME, 
	 * 		)
	 * 	);
	 * </listing>
	 * <br />
	 * Example 2: simlar to example 1, except include finish notification TODO<br />
	 * <listing>

	 * </listing>
	 * <br />
	 */
    public class WaitForIInitProxy extends NotifyingInitProxy implements IInitProxy {
		private var _initProxy:IInitProxy = null;
		
		
		/**
		 * Constructor
		 * @param	proxyName	Unique name for this proxy
		 * @param	initProxy	Actual IInitProxy instance to wait on, or it's string Name
		 * @param	finishNotificationName	(optional) A non-null value meens that the notification will be sent. 
		 */
        public function WaitForIInitProxy(proxyName:String, initProxy:*, finishNotificationName:String=null):void {
			this._initProxy = ((initProxy is String) ? facade.retrieveProxy(initProxy) : initProxy) as IInitProxy;
			this._finishNote = finishNotificationName;
			super( proxyName );
        }
		
		public override function stop():void {
			removeEvents();
			super.stop();
		}
		
		/**
		 * Load Function (don't override)<br />
		 */
		public override function load():void {
			if (_busy) return;
			_busy = true;
			
			_initProxy.dispatcher.addEventListener(InitProxyEvent.COMPLETE, onComplete);
			_initProxy.dispatcher.addEventListener(InitProxyEvent.PROGRESS, onProgress);
			_initProxy.dispatcher.addEventListener(InitProxyEvent.FAILED, onError);

		}
		
		private function removeEvents():void {
			_initProxy.dispatcher.removeEventListener(InitProxyEvent.COMPLETE, onComplete);
			_initProxy.dispatcher.removeEventListener(InitProxyEvent.PROGRESS, onProgress);
			_initProxy.dispatcher.removeEventListener(InitProxyEvent.FAILED, onError);
		}
		
		private function onProgress(evt:InitProxyEvent = null):void {
			percentLoaded = _initProxy.percentLoaded;
		}
		
		private function onComplete(evt:InitProxyEvent = null):void {
			removeEvents();
			finish();
		}
		
		private function onError(evt:InitProxyEvent = null):void {
			stop();
			fail();
		}
    }
}