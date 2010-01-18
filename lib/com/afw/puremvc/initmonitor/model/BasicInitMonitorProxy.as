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
 
package com.afw.puremvc.initmonitor.model {
	import com.afw.puremvc.initmonitor.InitMonitor;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * BasicInitMonitorProxy: Same as InitMonitorProxy, with default notification names from InitMonitor Class 
	 *  
	 * @version 0.5 
	 * @author Gil Birman [AllFlashWebsite.com]
	 * 
	 */
    public class BasicInitMonitorProxy extends InitMonitorProxy implements IInitProxy {
		/**
		 * This is the default name for BasicInitMonitorProxy. If you are instansiating multiple
		 * instances of this proxy, then you should pass a unique name into the constructor.
		 */
		public static const NAME:String = "BasicInitMonitorProxy";
		
		/**
		 * Constructor	(second arguments changed in v0.4 from allowProxyNames)
		 * @param	proxyName				Default is 'InitMonitorProxy'
		 */
        public function BasicInitMonitorProxy(proxyName:String = NAME):void {
			progressNotificationName = InitMonitor.INIT_MONITOR_PROGRESS;
			startNotificationName = InitMonitor.INIT_MONITOR_START;
			stopNotificationName = InitMonitor.INIT_MONITOR_STOP;
			interruptNotificationName = InitMonitor.INIT_MONITOR_INTERRUPT;
			completeNotificationName = InitMonitor.INIT_MONITOR_COMPLETE;
			resourceFailedNotificationName = InitMonitor.INIT_MONITOR_RESOURCE_FAILED;
			failedNotificationName = InitMonitor.INIT_MONITOR_FAILED;
			
			super( proxyName );
        }
    }
}