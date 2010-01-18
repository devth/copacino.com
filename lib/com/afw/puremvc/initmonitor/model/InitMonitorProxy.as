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
	import flash.utils.Dictionary;
    import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;
	import org.puremvc.as3.patterns.observer.Notification;
	//import com.afw.puremvc.initmonitor.InitMonitor;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import com.afw.puremvc.initmonitor.InitProxyEvent;
	import flash.utils.setTimeout;
	
	/**
	 * InitMonitorProxy: Sequentially processes a list of Proxies (proxies that implement IInitProxy Interface)
	 * 	This monitor invokes each proxy by calling load() directly. The Monitor detects eventDispatches when each
	 * 	proxy has completed its processing.<br />
	 * <br />
	 * TO USE: (using a gallery app as an example...)<br />
	 * <ul>
	 * 	<li> Register this proxy in StartCommand or whatever:<br />
	 * 		<pre>facade.registerProxy(new InitMonitorProxy());</li></pre>
	 * 
	 *  <li> Create your Init Proxies by extending SimpleInitProxy (make sure they also implement interface IInitProxy)
	 * 		<ul>
	 *  	<li> Notifications should be added as necessary to your IInitProxy </li>
	 * 		<li> Remember to register the proxy (in StartCommand or something) </li>
	 * 		</ul>
	 *  </li>
	 * 	<li>
	 *   Create a Command called GalleryInitCommand, the execute() function should look something like this:
	 * 		<pre>
	 *			var monitor:InitMonitorProxy = (facade.retrieveProxy( InitMonitorProxy.NAME ) as InitMonitorProxy);
	 * 
	 *			monitor.addResources( [ GalleryInitOneProxy.NAME, GalleryInitTwoProxy.NAME ] );
	 * 
	 *			monitor.start();
	 * 		</pre>
	 * 	</li>
	 * 
	 * 	<li> Remember to define ApplicationFacade.GALLERY_INIT_COMPLETE in ApplicationFacade</li>
	 * </ul>
	 * <br />
	 * Note: Additional documentation in the source.
	 * 
	 * @version 0.5 -- (Untested) InitMonitorProxy now implements IInitProxy so you can treat it like another IInitProxy for some strange loading scenarios 
	 * @author Gil Birman [AllFlashWebsite.com]
	 * 
	 */
    public class InitMonitorProxy extends NotifyingInitProxy implements IInitProxy {
		/**
		 * This is the default name for InitMonitorProxy. If you are instansiating multiple
		 * instances of this proxy, then you should pass a unique name into the constructor.
		 */
        public static const NAME:String = 'InitMonitorProxy';
		
		private var _debug:Function = null;
		
		private var resources:Array = [];
		private var proxies:Array = [];
		private var currIndex:int;
		
		// before we start loading a group of proxies (resources) keep a dictionary of the 
		// proxies with IInitProxy.complete == true
		private var alreadyCompleteProxies:Dictionary;
		
		// These are actually multiplied by the proxies weight value (IInitProxy.weight)
		private var toCompleteCount:Number=0;
		private var completedCount:Number=0;
		
		// The number of completed proxies in current group (not multiplied by a weight value)
		private var currCompletedCount:int=0;
		
		/**
		 * This notification is sent after all proxies have issued COMPLETE commands (optional) 
		 * Use this notification instead of/in addition to completeNotificationName if you want more control
		 * over the final Notification (like it's body or type).
		 * @default null
		 */
		public var completeNotification:Notification = null;
		
		/**
		 * Sent immediately after InitMonitorProxy.start() is called <br />
		 * (new notification for v0.5.1)
		 * @default null
		 */
		public var startNotification:Notification = null;
		
		/**
		 * Sent by InitMonitorProxy.stop(), even if InitMonitorProxy is not busy <br />
		 * (new notification for v0.5.1)
		 * @default null
		 */
		public var stopNotification:Notification = null;
		
		/**
		 * Sent by InitMonitorProxy.stop() if stop() is called when _busy==true
		 * (_busy == true when the InitMonitorProxy is still loading IInitProxy's)<br />
		 * (new notification for v0.5.1)
		 * @default null
		 */
		public var interruptNotification:Notification = null;
		
		/**
		 * Sent after when maxRetries
		 * (new notification for v0.5.1)
		 * @default null
		 */
		public var failedNotification:Notification = null;

		/**
		 * Sent each time a proxy is complete
		 * @default null
		 */
		public var progressNotificationName:String = null;
		
		/**
		 * Sent immediately after InitMonitorProxy.start() is called
		 * @default null
		 */
		public var startNotificationName:String = null;
		
		/**
		 * Sent by InitMonitorProxy.stop(), even if InitMonitorProxy is not busy
		 * @default null
		 */
		public var stopNotificationName:String = null; 
		
		/**
		 * Sent by InitMonitorProxy.stop() if stop() is called when _busy==true
		 * (_busy == true when the InitMonitorProxy is still loading IInitProxy's)
		 * @default null
		 */
		public var interruptNotificationName:String = null; 
		
		/**
		 * Sent when all resources are complete
		 * @default null
		 */
		public var completeNotificationName:String = null;
		
		/**
		 * Sent whenever a IInitProxy fails to load()
		 * @default null
		 */
		public var resourceFailedNotificationName:String = null;
		
		/**
		 * Sent after when maxRetries
		 * @default null
		 */
		public var failedNotificationName:String = null;
		
		/**
		 * For convenience (also simplifies the upgrade process from v0.1 to v0.3)<br />
		 * IF TRUE: When calling InitMonitorProxy.addResources(...) you can add the IInitProxy names and/or instances<br />
		 * IF FALSE: only instances are allowed<br />
		 * <br />
		 * Note: Proxy names are resolved immediately when you call addResources(), so they must already be registered<br />
		 * 			... maybe change this for added flexibility?<br />
		 * @default true
		 */
		// v0.4: removed because wondering if there was significant speedup?
		//public var allowProxyNames:Boolean = true;
		
		/**
		 * Pause between retries for failed IInitProxy.load()'s
		 * @default 5000
		 */
		public var retryFailedDelay:int = 5000; // default == 5 seconds
		
		/**
		 * Number of times we have retried (don't change this)
		 * @default 0
		 */
		public var retryCount:int = 0;
		
		/**
		 * Maximum number of retries allowed, for all proxies NOT each individual
		 * @default 99999
		 */
		public var maxRetries:int = 99999;
		
		/**
		 * Constructor	(second arguments changed in v0.4 from allowProxyNames)
		 * @param	proxyName				Default is 'InitMonitorProxy'
		 */
        public function InitMonitorProxy(proxyName:String = NAME):void {
			super( proxyName, Number(0) );
        }
		
		/**
		 * Remember to call stop() before start() to cancel the previous operation and reset the queue
		 * Necessary in certain situations
		 */
		override public function stop():void {
			if (stopNotificationName != null) sendNotification(stopNotificationName);
			if (stopNotification != null) sendNote(stopNotification);
			
			// initialize counters for progress notification
			toCompleteCount = 0;
			completedCount = 0;
			retryCount = 0;
			
			if (_busy) {
				if (interruptNotificationName != null) sendNotification(interruptNotificationName);	// TODO: MAYBE MOVE THIS LINE LOWER?
				if (interruptNotification != null) sendNote(interruptNotification);	// TODO: MAYBE MOVE THIS LINE LOWER?
				
				for each (var proxy:IInitProxy in resources[currIndex]) {
					if (! proxy.complete) {
						// note: IInitProxy's that immediately wipe their memory and set complete=false will get
						// an unneaded proxy.stop() call here. Keep this in mind when designing your proxies
						proxy.stop();
						
						// hmmm.. this shouldn't be necessary ..?
						proxy.dispatcher.removeEventListener(InitProxyEvent.COMPLETE, resourceComplete);
						proxy.dispatcher.removeEventListener(InitProxyEvent.PROGRESS, progressUpdate);
						proxy.dispatcher.removeEventListener(InitProxyEvent.FAILED, resourceFailed);
					}
				}
				_busy = false;
			}
			resources = [];
			_complete = false;
		}
		
		/**
		 * Call this function at least 1X before calling start()
		 * @param	resources	A array of proxies or string names of the proxies to process (ie., MyInitProxy.NAME)
		 */
		public function addResources(resources:Array):void {
			for each (var r:* in resources) {
				var ra:Array = (r is Array) ? r : [r];
				
				for (var i:int = 0; i < ra.length; i++) {
					//if (allowProxyNames && ra[i] is String) {		// v0.4: removed this logic, do we really need this speedup?
					if (ra[i] is String) {
						// convert proxy names
						if (_debug != null) _debug("IM.addResources: Converting name to proxy (" + ra[i] + ")...");
						ra[i] = facade.retrieveProxy(ra[i]);
						if (_debug != null) _debug("IM.addResources:      ...converted to: " + ra[i]);
					}
					
					// calculate toCompleteCount (by proxy weight)
					if ( ! (ra[i] as IInitProxy).complete )
						toCompleteCount += (ra[i] as IInitProxy).weight;
				}
				
				this.resources.push(ra);
			}
		}
		
		/**
		 * Call this to start the process, !!!remember to call stop() first if this is a new section!!!
		 */
		public function start():void {			
			currIndex = 0;
			_busy = true;
			if (startNotificationName != null) sendNotification(startNotificationName);
			if (startNotification != null) sendNote(startNotification);
			
			startCurrGroup();
		}
		
		/*
		 * Calculates the the total weight of the job -- used internally
		 * by InitMonitor for progress calculations. Call this function before start() if the InitMonitorProxy is 
		 * reporting incorrect progress. This can happen in the rare case when you have instantiated the InitMonitorProxy 
		 * but doing stuff with the IInitProxy's before calling start()... OR another active instance of the 
		 * InitMonitorProxy is sharing IInitProxy's.
		 * 
		 * 03.12.09
		 * A IInitProxy could set it's complete property to false right after calling finish()
		 * the InitMonitorProxy would initially consider the proxy as complete (as expected)
		 * but subsequent calls to analyzeResources would calculate an incorrect toCompleteCount 
		 * This problem is eliminated if IInitProxy's don't wipe their data immediately after completing,
		 * however this is a nice feature to have so I am commenting out this function (it isn't really necessary anyway)
		 */
		/*public function analyzeResources():void {
			// calculate toCompleteCount
			toCompleteCount = 0;
			
			for each (var arr:Array in resources)
				for each (var proxy:IInitProxy in arr)
					if ( ! proxy.complete )
						toCompleteCount += proxy.weight;
		}*/
		
		/**
		 * Do monitor.debug=trace to see the messages as trace output. <br />
		 * This can be set to any function reference which takes one string value argument.
		 * @default null
		 */
		public function set debug(v:Function):void {
			_debug = v;
		}
		
		/**
		 * Sets to null: <br />
		 * completeNotificationName, failedNotificationName, interruptNotificationName, 
		 * progressNotificationName, resourceFailedNotificationName, 
		 * startNotificationName, stopNotificationName <br />
		 */
		public function nullAllNotifications():void {
			completeNotificationName = failedNotificationName = 
			interruptNotificationName = progressNotificationName = 
			resourceFailedNotificationName = startNotificationName = stopNotificationName = null;
		}
		
		/**
		 * Starts loading the current group of IInitProxy's
		 */
		private function startCurrGroup():void {
			//var pname:String;
			var proxy:IInitProxy;
			
			// create alreadyCompletePNames hash for current proxy group
			currCompletedCount = 0;
			alreadyCompleteProxies = new Dictionary(true);
			for each (proxy in resources[currIndex])
				alreadyCompleteProxies[proxy] = (proxy as IInitProxy).complete;
			
			// call proxy.load() on all proxies in current group
			for each (proxy in resources[currIndex]) {
				proxy.dispatcher.addEventListener(InitProxyEvent.COMPLETE, resourceComplete);
				proxy.dispatcher.addEventListener(InitProxyEvent.PROGRESS, progressUpdate);
				proxy.dispatcher.addEventListener(InitProxyEvent.FAILED, resourceFailed);
				
				if (proxy.complete)
					proxy.finish();
				else
					proxy.load();
			}
		}
		
		/**
		 * Handles InitProxyEvent.PROGRESS events
		 * @see com.afw.puremvc.initmonitor.InitProxyEvent
		 */
		private function progressUpdate(e:InitProxyEvent=null):void {
			completedCount += e.progress * e.proxy.weight;
			if (_debug != null) _debug("IM.progressUpdate @" + Math.round(100*completedCount / toCompleteCount) + "% (" + e.proxy.getProxyName() + ": "+ e.progress+") " + completedCount + "/"+toCompleteCount );
			var pct:Number = Number( completedCount / toCompleteCount );
			if (progressNotificationName != null) sendNotification(progressNotificationName, pct, getProxyName() );
			percentLoaded = pct;
		}
		
		/**
		 * Handles InitProxyEvent.COMPLETE events
		 * @see com.afw.puremvc.initmonitor.InitProxyEvent
		 */
		private function resourceComplete(e:InitProxyEvent=null):void {
			if (_debug != null) _debug("IM.resourceComplete " + e.proxy.getProxyName() );
			
			e.proxy.dispatcher.removeEventListener(InitProxyEvent.COMPLETE, resourceComplete);
			e.proxy.dispatcher.removeEventListener(InitProxyEvent.PROGRESS, progressUpdate);
			e.proxy.dispatcher.removeEventListener(InitProxyEvent.FAILED, resourceFailed);

			// update progress if necessary
			if (! alreadyCompleteProxies[e.proxy] ) {
				e.progress = (1 - e.proxy.percentLoaded);
				progressUpdate(e);
			}
			currCompletedCount++
			
			// if notification received for all proxies in current group, advance to next group
			if (currCompletedCount >= (resources[currIndex] as Array).length) {
				currIndex++;
				
				if (currIndex >= resources.length) {
					// all done
					if (_debug != null) _debug("IM: All done!");
					_busy = false;
					_complete = true;
					
					if (completeNotificationName != null) sendNotification(completeNotificationName);
					if (completeNotification != null)
						sendNote(completeNotification);
						
					finish();
				} else {
					// process next group in sequence
					startCurrGroup();
				}
			}
		}
		
		/**
		 * Handles InitProxyEvent.FAILED events
		 * IInitProxy.load(..) call failed for one of the resources... retry after delay
		 * If we've reached maxRetries, then dispatch failedNotificationName 
		 * The program should probably call InitMonitorProxy.stop() and then go to some previous state, if possible
		 * @param	e
		 * @see com.afw.puremvc.initmonitor.InitProxyEvent
		 */
		private function resourceFailed(e:InitProxyEvent = null):void {
			if (_debug != null) _debug("IM.resourceFailed " + e.proxy.getProxyName());
			if (resourceFailedNotificationName != null) sendNotification(resourceFailedNotificationName);
			
			if (++retryCount > maxRetries) {
				if (failedNotificationName != null) sendNotification(failedNotificationName);
				if (failedNotification != null) sendNote(failedNotification);
				fail();
			} else {
				setTimeout(e.proxy.load, retryFailedDelay);
			}
		}
		
		private function sendNote(note:Notification):void {
			sendNotification(note.getName(), note.getBody(), note.getType());
		}
		
		///////////////////////////////////// added for IInitProxy //////////////////////////////////////////
		
		/**
		 * This might change...
		 */
		override public function load():void {
			//stop();
			start();
		}
    }
}