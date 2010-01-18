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
	
	/**
	 * 
	 * Adds some functionality to SimpleInitProxy, the base implemenation for Init Monitor.
	 * Adds a finishNotificationName so a notification will be sent when finsh() is called (if you override finish be sure to call super.finish())
	 * Adds a loadedNotificationName that can be sent from a subclass
	 * @author ...
	 */
	public class NotifyingInitProxy extends SimpleInitProxy  implements IInitProxy {
		protected var _finishNote:String = null;
		protected var _loadedNote:String = null;
		
		public function NotifyingInitProxy(proxyName:String=null, data:Object=null ) {
			super( proxyName, data );
		}
		
		/**
		 * OPTIONAL The name of the finish notification
		 */
		public function get finishNotificationName():String {
			return _finishNote;
		}
		
		/**
		 * OPTIONAL The name of the finish notification
		 */
		public function set finishNotificationName(v:String):void {
			_finishNote = v;
		}
		
		/**
		 * OPTIONAL The name of the finish notification
		 */
		public function get loadedNotificationName():String {
			return _loadedNote;
		}
		
		/**
		 * OPTIONAL The name of the finish notification
		 */
		public function set loadedNotificationName(v:String):void {
			_loadedNote = v;
		}
		
		/**
		 * finish notification sent here
		 * this notification is useful because it should be sent even if _complete is true
		 */
		override public function finish():void {
			if (_finishNote) sendNotification(_finishNote, getData());
			super.finish();
		}
	}
	
}