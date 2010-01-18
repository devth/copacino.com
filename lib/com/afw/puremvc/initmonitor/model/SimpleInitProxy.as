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
	import flash.events.Event;
	import flash.events.EventDispatcher;
    import org.puremvc.as3.patterns.proxy.Proxy;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import com.afw.puremvc.initmonitor.InitProxyEvent;
	
	/**
	 * This is the base implemenation for IInitProxy. One way to use Init Monitor is to have all
	 * your IInitProxy's sublass SimpleInitProxy, although you could also create your own base implemenation.
	 * 
	 * @see com.afw.puremvc.initmonitor.model.util.BulkLoaderInitProxy
	 * @see com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy
	 */
    public class SimpleInitProxy extends Proxy implements IInitProxy
    {
        //public static const NAME:String = 'SimpleInitProxy';
		private var _weight:Number = 1;
		//private var _type:String = null;
		private var _dispatcher:EventDispatcher = new EventDispatcher();
		private var _percentLoaded:Number = 0;
		
		/**
		 * complete? used to store value for IInitProxy.complete
		 */
		protected var _complete:Boolean = false;
		
		/**
		 * busy? note this is not part of IInitProxy, it may be used by subclasses, (but not by InitMonitorProxy)
		 */
		protected var _busy:Boolean = false;
		
		
        public function SimpleInitProxy(proxyName:String, data:Object=null ) {
			super( proxyName, data );
        }
		
		/**
		 * Override this function.
		 * stop should prevent any further InitProxyEvent's from being dispatched out for the current load.
		 * note: after stop() is called, finish() should not be immediately called. << ??? 	TODO
		 */
		public function stop():void {
			_busy = false;
		}
		
		/**
		 * Override this function.
		 * load() should always result in a (ussually asyncronous) call to finish() (ussually in an onComplete function).
		 * [ note: stop() will prevent finish() from being called ]
		 */
		public function load():void {
		
		}
		
		/**
		 * sends final Notification
		 * This function is public because InitMonitorProxy calls finish() if complete==true
		 */
		public function finish():void {
			_complete = true;
			_busy = false;
			dispatcher.dispatchEvent(new InitProxyEvent(InitProxyEvent.COMPLETE, this));
			_percentLoaded = 0;
		}
		
		/**
		 * sends failure Notification<br />
		 * When an error has occurred, your proxy should ussually do<br />
		 * <pre>
		 * 		stop();
		 * 		fail();
		 * 	</pre>
		 */
		protected function fail():void {
			dispatcher.dispatchEvent(new InitProxyEvent(InitProxyEvent.FAILED, this));
		}
		
		/**
		 * When this is true, InitMonitorProxy will always call finish() instead of load() 
		 */
        public function get complete():Boolean {
        	return _complete;
        }
		
		/**
		 * complete?
		 */
        public function set complete(v:Boolean):void {
        	_complete = v;
        }
		
		/**
		 * busy is True between start and onCompleteWhatever
		 */
        public function get busy():Boolean {
        	return _busy;
        }   
		
		/**
		 * (Optional) a subclass of SimpleInitProxy may use type when sending a 
		 * notification, probably after some task has completed 
		 */
		/*public function set type(v:String):void {
			_type = v;
		} */
		
		/**
		 * (Optional) a subclass of SimpleInitProxy may use type when sending a 
		 * notification, probably after some task has completed 
		 */
		/*public function get type():String {
			return _type;
		}*/
		
		public function get percentLoaded():Number {
			return _percentLoaded;
		}
		
		/**
		 * Changing this property will automatically dispatch an event handled by InitMonitorProxy
		 * which in turn can send a notification to the app about the new progress state.
		 */
		public function set percentLoaded(v:Number):void {
			var e:InitProxyEvent = new InitProxyEvent(InitProxyEvent.PROGRESS, this);
			e.progress = v - _percentLoaded;
			_dispatcher.dispatchEvent(e);
			_percentLoaded = v;
		}
		
		/**
		 * @see com.afw.puremvc.initmonitor.model.IInitProxy.dispatcher
		 */
		public function get dispatcher():EventDispatcher {
			return _dispatcher;
		}
		
		public function get weight():Number {
			return _weight;
		}
		
		/**
		 * Every IInitProxy must have an associated weight. This number is relative to the other weights.
		 * 
		 * @default 1.0
		 */
		public function set weight(v:Number):void {
			_weight = v;
		}

    }
}