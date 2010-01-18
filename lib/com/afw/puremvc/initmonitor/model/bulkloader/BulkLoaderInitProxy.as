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
	import com.afw.puremvc.initmonitor.model.NotifyingInitProxy;
	import org.puremvc.as3.patterns.observer.Notification;
	import br.com.stimuli.loading.BulkLoader;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	//import com.afw.puremvc.initmonitor.model.SimpleInitProxy;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.system.Security;
	
	/**
	 * Integrates BulkLoader into InitMonitorProxy to load multiple external assets.<br />
	 * This class needs to be extended to be useful. See MultiAssetInitProxy for an example implementation.<br />
	 * In your subclass, you do not need to handle BulkProgressEvent.PROGRESS events. <br />
	 * BulkProgressEvent.PROGRESS events are captured here and <code>percentLoaded</code> is updated in the process.
	 */
    public class BulkLoaderInitProxy extends NotifyingInitProxy implements IInitProxy {
		/**
		 * The BulkLoader instance is instantiated in the contructor.<br />
		 * Add files to <code>_loader</code> in the <code>load</code> function, which you must override in your subclass.
		 */
		protected var _loader:BulkLoader;
		//protected var myContext : LoaderContext;
		
		/**
		 * Constructor
		 * @param	proxyName	This name should be unique among your proxies
		 */
        public function BulkLoaderInitProxy(proxyName:String):void {
			super( proxyName );
			
			_loader = new BulkLoader(proxyName);
			_loader.addEventListener(BulkProgressEvent.PROGRESS, onBulkProgress);
			//_loader.logLevel = BulkLoader.LOG_INFO;
			_loader.logLevel = BulkLoader.LOG_SILENT;
			//Security.allowDomain("localhost");
			//myContext = new LoaderContext(false, ApplicationDomain.currentDomain);
        }
		
		/**
		 * immediately stops the loader and sets busy=false
		 * Override this function if you need to...
		 */
		public override function stop():void {
			_loader.pauseAll();
			super.stop();
		}
		
		/**
		 * Shorthand function for retrieving an asset's class
		 * 
		 * @param	asset_name - a file name
		 * @param	classLib - a class name (defined in as3, or in the flash library)
		 * @return	a Class that you can instantiate
		 */
		public function getClass(asset_name:String, classLib:String):Class {
			return loader.getMovieClip(asset_name).loaderInfo.applicationDomain.getDefinition(classLib) as Class;
		}
		
		/**
		 * retrieve BulkLoaded instance. subclasses should use _loader
		 */
		public function get loader():BulkLoader {
			return _loader;
		}
		
		private function onBulkProgress(e:BulkProgressEvent = null):void {
			percentLoaded = e.percentLoaded;
		}
    }
}