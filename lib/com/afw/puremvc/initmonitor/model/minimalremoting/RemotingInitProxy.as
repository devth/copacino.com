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
package com.afw.puremvc.initmonitor.model.minimalremoting {
	import com.afw.puremvc.initmonitor.model.NotifyingInitProxy;
	import flash.system.Security;
	import flash.events.Event;
	
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	//import com.afw.puremvc.initmonitor.model.SimpleInitProxy;
	
	import com.afw.remoting.MinimalRemoting;
	import com.afw.remoting.RemotingEvent;
	
	/**
	 * Integrates MinimalRemoting into InitMonitorProxy to load multiple external assets.<br />
	 * You can sublass this and override handleResult(), or use getData() from another proxy to do something with the result<br />
	 * <br />
	 * <p>Example:</p>
	 * <listing>
	 *	var myRemoteImages:RemotingInitProxy = new RemotingInitProxy("myRemoteImages", "http://localhost/amfphp", "MyClient.getImagesByCategory", "myCategoryName");
	 *	var myImageLoaderProxy:LoadImagesProxy = new LoadImagesProxy("myImageLoaderPRoxy", myRemoteImages);
	 * 
	 *	var monitor:InitMonitorProxy = new InitMonitorProxy();
	 *	monitor.stop();
	 *	monitor.completeNotification = new Notification(ApplicationFacade.IMAGES_INIT_COMPLETE);
	 *	monitor.addResources([myRemoteImages, myImageLoaderProxy]);
	 *	monitor.start(); 
	 * </listing>
	 * 
	 * The example above assumes that you have created a proxy called <code>LoadImagesProxy</code> (probably by subclassing <code>BulkLoaderInitProxy</code>)
	 * which is responsible for loading the list of images retrieved by the <code>RemotingInitProxy</code>. The <code>LoadImagesProxy</code> 
	 * accesses the list by calling <code>myImageLoaderProxy.getData()</code> from within the <code>ImageLoaderProxy.load()</code> function
	 * <br />
	 * <br />
	 * Note: MinimalRemoting package must be in your classpath to use this.<br />
	 * 
	 * @author Gil Birman [AllFlashWebsite.com]
	 */
    public class RemotingInitProxy extends NotifyingInitProxy implements IInitProxy {
		
		private var _mr:MinimalRemoting;
		
		/**
		 * (optional) arguments to be passed to remote class method
		 * Change this property any time before calling load()
		 */
		public var args:Array;
		
		/**
		 * Remote class mathod (something like: MyClass.myMethod)
		 * You can change this property any time before calling load()
		 */
		public var classMethod:String;
		
		/**
		 * Constructor
		 * @param	proxyName	Unique proxy name
		 * @param	gatewayUrl	URL to your remoting gateway (for instance amfphp gateway looks like <code>http://localhost/amfphp/gateway.php</code>)
		 * @param	classMethod	The remote class method you need to invoke
		 * @param	...args	(optional) arguments to pass to the remote class method
		 */
		public function RemotingInitProxy(proxyName:String, gatewayUrl:String, classMethod:String=null, ...args) {
			super( proxyName );
			this.classMethod = classMethod;
			this.args = args;
			
			//Security.allowDomain("localhost");	// MinimalRemoting does this
			_mr = new MinimalRemoting(gatewayUrl);
		}
		
		/**
		 * Stops any remoting call immediately
		 */
		public override function stop():void {
			// see load
			removeEvents();
			_mr.closeConnection();
			super.stop();
		}
		
		/**
		 * Invokes the remoting call (via MinimalRemoting class)
		 */
		public override function load():void {
			if (_busy) stop();
			_busy = true;
			
			_mr.addEventListener(RemotingEvent.RESULT, onComplete);
			_mr.addEventListener(RemotingEvent.FAILED, onFailed);
			_mr.addEventListener(RemotingEvent.NET_STATUS_FAILED, onFailed);
			
			var callArgs:Array = [];
			if (args && args.length) callArgs = args.slice(0, args.length);
			callArgs.unshift(classMethod);
			
			_mr.call.apply(this, callArgs);
		}
		
		/**
		 * RemotingEvent.FAILED and RemotingEvent.NET_STATUS_FAILED Event Listenter for _mr (MinimalRemoting instance)
		 * @param	e
		 */
		protected function onFailed(e:RemotingEvent):void {
			stop();
			fail();
		}
		
		/**
		 * RemotingEvent.RESULT Event Listenter for _mr (MinimalRemoting instance)
		 * @param	e
		 */
		protected function onComplete(e:RemotingEvent):void {
			handleResult(e.result);
			if (_loadedNote) sendNotification(_loadedNote, data);
			removeEvents();
			finish();
		}
		
		/**
		 * Override this function in your own subclass if you need to process the result some how.<br />
		 * Called from the protected onComplete function when Remoting successfully calls the remote method.
		 * @param	result	This object contains the result
		 */
		protected function handleResult(result:Object):void {
			data = result;
		}
		
		
		private function removeEvents():void {
			_mr.removeEventListener(RemotingEvent.RESULT, onComplete);
			_mr.removeEventListener(RemotingEvent.FAILED, onFailed);
			_mr.removeEventListener(RemotingEvent.NET_STATUS_FAILED, onFailed);
		}
    }
}