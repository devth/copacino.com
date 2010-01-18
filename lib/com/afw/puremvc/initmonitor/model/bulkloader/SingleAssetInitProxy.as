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
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	//import com.afw.puremvc.initmonitor.model.SimpleInitProxy;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import flash.events.Event;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.ErrorEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	//import com.afw.puremvc.initmonitor.model.bulkloader.BulkLoaderInitProxy;
	
	/**
	 * TODO: UPDATE EXAMPLES BELOW
	 * This class extends MultiAssetInitProxy to load one File.<br />
	 * <br />
	 * Example 1: load Home.swf, when complete send new Notification with type ApplicationFacade.HOME_SWF_LOADED and body the loaded MovieClip<br />
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new SingleAssetInitProxy(
	 * 			ApplicationFacade.HOME_INIT_PROXY_NAME, 
	 * 			"Home.swf", 
	 * 			ApplicationFacade.HOME_SWF_LOADED
	 * 		)
	 * 	);
	 * </listing>
	 * <br />
	 * Example 2: simlar to example 1, except the body of the loadedNotification is the Class object for app.view.Home<br />
	 * NOTE: Two instances are created in this example. An instance is created by the loader and then an instance is created by 
	 * 			the mediator handling the ApplicationFacade.HOME_SWF_LOADED notification.<br />
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new SingleAssetInitProxy(
	 * 			ApplicationFacade.HOME_INIT_PROXY_NAME, 
	 * 			"Home.swf", 
	 * 			ApplicationFacade.HOME_SWF_LOADED,
	 *			null,
				new LoaderContext(false, ApplicationDomain.currentDomain),
	 * 			"app.view.component.Home", 
	 * 		)
	 * 	);
	 * </listing>
	 * <br />
	 * ... later in your view you can instantiate the class with:<br />
	 * <listing>
	 * 	var myClass:Class = notification.getBody() as Class;
	 * 	var myClassInstance:* = new myClass();
	 * </listing>
	 * <br />
	 * Keep in mind that SingleAssetInitProxy can load any type of asset. If you are loading a single SWF asset, your code
	 * may be simpler if you instead use SwfAssetInitProxy (which extends SingleAssetInitProxy). <br />
	 * <br />
	 * Note: Recently, I have stopped 
	 * using the className parameter and instead instantiate my class in the mediator. It takes a little more code to do it this
	 * way, but I like to have the class names in the Mediator. For example:
	 * <listing>
	 *	// IN THE ApplicationFacade:
	 *	public static const HOME_SWF:String = "Home.swf";
	 *	
	 *	// IN A Command:
	 * 	facade.registerProxy(
	 * 		new SingleAssetInitProxy(
	 * 			ApplicationFacade.HOME_SWF, 	// proxyName
	 * 			ApplicationFacade.HOME_SWF, 	// url
	 * 			ApplicationFacade.HOME_SWF,		// loadedNotification
	 *			null,
	 *			new LoaderContext(false, ApplicationDomain.currentDomain),
	 * 		)
	 * 	);
	 *
	 *	// IN THE MEDIATOR (handleNotification function):
	 *		case ApplicationFacade.HOME_SWF:
	 *			homeClass = MovieClipUtil.getClass(notification.getBody() as MovieClip, "app.view.component.Home");
	 *			// later we'll do something with homeClass... myHome = new homeClass(...);
	 *		break;
	 * </listing>
	 *
	 * NOTE: In the code above I have used the same constant for the proxyName, the url, and the loadedNotification.
	 * This is how you can really simplify your code but keep in mind that you are "cheating" by doing this.
	 * Only cheat if you are pretty sure it is not going to confuse anyone who has to look at it.
	 * 
	 */
    public class SingleAssetInitProxy extends MultiAssetInitProxy implements IInitProxy {
		private var className:String = null;
		private var url:String = null;
		
		/**
		 * Constructor
		 * @param	proxyName	Unique name for the proxy
		 * @param	url		URL of the File
		 * @param	loadedNotificationName	(optional) A non-null value meens that the notification will be sent with the body set to the file or the class if className is specified (only SWFs support className)
		 * @param	finishNotificationName	(optional) A non-null value meens that the notification will be sent (with body same as loadedNotificationName). This is sent every time, unlike the loaded notification
		 * @param	context	(optional) LoaderContext.
		 * @param	className	(optional) A non-null value for className will set the data of this proxy to the className reference within the swf after it is loaded.
		 * @param	autoClearMemory (optional) Automatically clear the memory in onComplete and stop() ?
		 */
        public function SingleAssetInitProxy(proxyName:String, url:String, loadedNotificationName:String=null, finishNotificationName:String=null, context:LoaderContext=null, className:String=null, autoClearMemory:Boolean=false):void {
			this.url = url;
			this.className = className;
			super(proxyName, [url], loadedNotificationName, finishNotificationName, context, autoClearMemory);
		}
		
		/**
		 * Shorthand function for retrieving an assets class from the swf file (dont override)<br />
		 * 
		 * @param	classLib - a class name (defined in as3, or in the flash library)
		 * @return	a Class that you can instantiate
		 */
		public function getMyClass(classLib:String):Class {
			return super.getClass(url, classLib);
		}
		
		override protected function onLoaded(evt:Event = null):void {			
			if (className)
				data = getMyClass(className);
			else
				data = (evt.target as LoadingItem).content;
			
			if (_loadedNote)
				sendNotification(_loadedNote, data);
				
			finish();
		}
    }
}