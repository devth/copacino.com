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
	import flash.display.MovieClip;
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
	import flash.system.SecurityDomain;
	
	/**
	 * This class extends BulkLoaderInitProxy to load one SWF File.<br />
	 * <br />
	 * Example 1: load Home.swf, when complete send new Notification with type ApplicationFacade.HOME_SWF_LOADED and body the loaded MovieClip<br />
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new SwfAssetInitProxy(
	 * 			ApplicationFacade.HOME_INIT_PROXY_NAME, 
	 * 			"Home.swf", 
	 * 			null, 
	 * 			ApplicationFacade.HOME_SWF_LOADED
	 * 		)
	 * 	);
	 * </listing>
	 * <br />
	 * Example 2: simlar to example 1, except the body of the notification is the Class object for app.view.Home<br />
	 * NOTE: Two instances are created in this example. An instance is created by the loader and then an instance is created by 
	 * 			the mediator handling the ApplicationFacade.HOME_SWF_LOADED notification.<br />
	 * <listing>
	 * 	facade.registerProxy(
	 * 		new SwfAssetInitProxy(
	 * 			ApplicationFacade.HOME_INIT_PROXY_NAME, 
	 * 			"Home.swf", 
	 * 			"app.view.Home", 
	 * 			ApplicationFacade.HOME_SWF_LOADED
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
	 * <br />
	 * Note: Recently, I have stopped 
	 * using the className parameter and instead instantiate my class in the mediator. It takes an extra line of code to do it this
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
	 *			null,							// className (null means we don't use this feature)
	 * 			ApplicationFacade.HOME_SWF,		// loadedNotification
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
	 */
    public class SwfAssetInitProxy extends SingleAssetInitProxy implements IInitProxy {		
		
		/**
		 * Constructor
		 * @param	proxyName	Unique name for the proxy
		 * @param	swfUrl		URL of the SWF File
		 * @param	className	(optional) A non-null value for className will set the data of this proxy to the className reference within the swf after it is loaded.  Please avoid using this feature it will probably be removed.
		 * @param	loadedNotificationName	(optional) A non-null value meens that the notification will be sent with the body set to the swf MovieClip or the class if className is specified
		 * @param	finishNotificationName	(optional) A non-null value meens that the notification will be sent (with body same as loadedNotificationName). This is sent every time, unlike the loaded notification
		 */
        public function SwfAssetInitProxy(proxyName:String, swfUrl:String, className:String=null, loadedNotificationName:String=null, finishNotificationName:String=null, autoClearMemory:Boolean=false):void {
			super(proxyName, swfUrl, loadedNotificationName, finishNotificationName, new LoaderContext(false, ApplicationDomain.currentDomain), className, autoClearMemory);
        }
    }
}