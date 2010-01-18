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
 package com.afw.puremvc.initmonitor 
{
	/**
	 * This class is compiled into your code ONLY if you use BasicInitMonitorProxy.
	 * 
	 * This class holds constants which are default names for notifications sent by BasicInitMonitorProxy.<br />
	 * For simple apps, just use the default constants and you'll never have to change any of the properties 
	 * in InitMonitorProxy that end with <em>NotificationName</em>.
	 * <br />
	 * For more sophisticated apps, especially when you want to instantiate multiple InitMonitorProxy's, 
	 * (giving each a different name), the <em>NotificationName</em> properties can be set to something other
	 * than default before each call to <code>InitMonitorProxy.start</code>
	 * 
	 * @see com.afw.puremvc.initmonitor.model.InitMonitorProxy
	 * @version 0.5
	 * @author Gil Birman [AllFlashWebsite.com]
	 */
	public class InitMonitor {
		public static const INIT_MONITOR_PROGRESS:String = "initMonitorProgress";
		public static const INIT_MONITOR_START:String = "initMonitorStart";
		public static const INIT_MONITOR_STOP:String = "initMonitorStop";
		public static const INIT_MONITOR_INTERRUPT:String = "initMonitorInterrupt";
		public static const INIT_MONITOR_COMPLETE:String = "initMonitorComplete";
		public static const INIT_MONITOR_FAILED:String = "initMonitorFailed";
		public static const INIT_MONITOR_RESOURCE_FAILED:String = "initMonitorResourceFailed";
	}
	
}