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
 
package com.afw.puremvc.initmonitor.model.bulkloader
{
   // import org.puremvc.as3.patterns.proxy.Proxy;
	import org.puremvc.as3.patterns.observer.Notification;
	import br.com.stimuli.loading.BulkLoader;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import flash.events.Event;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.ErrorEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	//import com.afw.puremvc.initmonitor.model.bulkloader.BulkLoaderInitProxy;
	
	/**
	 * This class extends BulkLoaderInitProxy to load multiple files of any type supported by BulkLoader.<br />
	 * <br />
	 * Example 1: We create a MultiAssetInitProxy that performs the following tasks when loaded:
	 *	Load Home.jpg and Logo.jpg, when complete send new Notification with type ApplicationFacade.HOME_IMAGES_LOADED and body the loaded MovieClip.
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new MultiAssetInitProxy(
	 * 			ApplicationFacade.HOME_IMAGES_PROXY, 
	 * 			[ "Home.jpg", "Logo.jpg" ], 
	 * 			ApplicationFacade.HOME_IMAGES_LOADED
	 * 		)
	 * 	);
	 * </listing>
	 * <br />
	 *	 Our loadedNotification (ApplicationFacade.HOME_SWF_LOADED) will be sent for each of the files loaded. 
	 *	In the example, the loadedNotification will be sent twice as long as the files are loaded properly.<br />
	 *  <br />
	 *	What if we instead used the finishNotification argument of the loadedNotification? It would look like this:
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new MultiAssetInitProxy(
	 * 			ApplicationFacade.HOME_IMAGES_PROXY, 
	 * 			[ "Home.jpg", "Logo.jpg" ], 
	 *			null,
	 * 			ApplicationFacade.HOME_IMAGES_FINISHED
	 * 		)
	 * 	);
	 * </listing>
	 * The first time our InitMonitorProxy calls the load() function for this proxy, the finishNotification (ApplicationFacade.HOME_IMAGES_FINISHED)
	 * will be sent after all of the images have been loaded. HOWEVER, if the same (or another) InitMonitorProxy needs to load this
	 * proxy at some later point, and all the images have allready been completely loaded, then the finishNotification will be sent AGAIN, 
	 * without calling load() on this proxy first. <br />
	 * <br />
	 * While loadedNotification will only be sent once for each url you are trying to load, finishNotification will be sent every time we even think about
	 * loading these assets. HOWEVER, if you set autoClearMemory==true in the constructor, then this proxy's internal memory will be cleared immediately
	 * after successfully loading all of the assets. When autoClearMemory==true the loadedNotification may be sent again and again if we keep 
	 * trying to load the same proxy.
	 *	<br />
	 */
    public class MultiAssetInitProxy extends BulkLoaderInitProxy implements IInitProxy {
		private var urls:Array;
		private var context:* = null;
		private var _autoClearMemory:Boolean;
		
		/**
		 * Constructor
		 * @param	proxyName	Unique name for the proxy
		 * @param	urls		array of URLs
		 * @param	loadedNotificationName	(optional) A non-null value meens that the notification will be sent with the body set to the file or the class if className is specified (only SWFs support className)
		 * @param	finishNotificationName	(optional) A non-null value meens that the notification will be sent (with body same as loadedNotificationName). This is sent every time, unlike the loaded notification
		 * @param	context	(optional) LoaderContext.
		 * @param	autoClearMemory	(optional) Automatically clear the memory in onComplete() and stop() ?
		 */
        public function MultiAssetInitProxy(proxyName:String, urls:Array, loadedNotificationName:String=null, finishNotificationName:String=null, context:*=null, autoClearMemory:Boolean=false):void {
			this.urls = urls;
			this.context = context;
			this._loadedNote = loadedNotificationName;
			this._finishNote = finishNotificationName;
			this._autoClearMemory = autoClearMemory;
			super( proxyName );
        }
		
		public override function stop():void {
			removeEvents();
			super.stop();
			if (_autoClearMemory) clearMemory();
		}
		
		/**
		 * Load Function (don't override)<br />
		 */
		public override function load():void {
			if (_busy) return;
			_busy = true;
			
			clearMemory();
			
			for each (var url:String in urls) {
				if (context)
					_loader.add(url,  { context: context } ).addEventListener(Event.COMPLETE, onLoaded);
				else
					_loader.add(url ).addEventListener(Event.COMPLETE, onLoaded);
			}
			_loader.addEventListener(BulkProgressEvent.COMPLETE, onComplete);
			_loader.addEventListener(BulkLoader.ERROR, onError);
			_loader.start();
		}
		
		/**
		 * Event handling function
		 * @param	evt
		 */
		protected function onComplete(evt:Event = null):void {
			removeEvents();
			
			var items:Array = [];
			for each (var url:String in urls)
				items.push(_loader.getContent(url));
				
			data = items;
			finish();
			if (_autoClearMemory) clearMemory();
		}
		
		/**
		 * Event handling function
		 * @param	evt
		 */
		protected function onLoaded(evt:Event = null):void {
			var li:LoadingItem = evt.target as LoadingItem;
			
			if (_loadedNote)
				sendNotification(_loadedNote, li.content, li.url.url);
		}
		
		/**
		 * Event handling function
		 * @param	evt
		 */
		protected function onError(evt:ErrorEvent = null):void {
			stop();
			fail();
		}
		
		private function removeEvents():void {
			for each (var url:String in urls)
				_loader.get(url).removeEventListener(Event.COMPLETE, onLoaded);
			_loader.removeEventListener(BulkLoader.ERROR, onError);
			_loader.removeEventListener(BulkProgressEvent.COMPLETE, onComplete);
		}
		
		public function clearMemory():void {
			_loader.removeAll();
			data = null;
			_complete = false;
		}
    }
}