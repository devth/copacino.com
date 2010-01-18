package com.afw.remoting {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Security;
	import flash.net.Responder;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.events.NetStatusEvent;
	
	/**
	 * Simplifies remoting and adds Event Listeners.<br />
	 * <br />
	 * You should probably do something like this at your app startup:<br />
	 * <pre>NetConnection.defaultObjectEncoding = ObjectEncoding.AMF3; </pre>
	 * <br />
	 * AND/OR pass the encoding type into the constructor of this class.<br />
	 * <br />
	 * most code ripped & modified from Josh Strike's remoting package
	 * <a href="http://www.joshstrike.com/">http://www.joshstrike.com/</a><br />
	 * <br />
	 * and also from ProDevTips
	 * <a href="http://www.prodevtips.com/2008/07/28/amfphp-in-flash-cs3-with-as3-jquerypost-style/">http://www.prodevtips.com/2008/07/28/amfphp-in-flash-cs3-with-as3-jquerypost-style/</a>
	 * <br /> <br />
	 * Note: It might be good for you to read the comments above the private methods of this class. (see the source)
	 * @author AllFlashWebsite.com [Gil Birman]
	 */
	public class MinimalRemoting extends EventDispatcher {
		/**
		 * You get access to the connection, probably shouldn't touch this though
		 */
		public var connection:NetConnection;
		
		/**
		 * You get access to the responder, probably shouldn't touch this though
		 */
        public var resp:Responder; 
		
		/**
		 * Type of encoding, ignored when null, otherwise gets casted to uint
		 */
        public var encoding:Object = null;
		
		/**
		 * URL of AMF Gateway
		 */
		public var url:String;
		
		/**
		 * 
		 * @param	url				URL of AMF Gateway
		 * @param	encoding		Type of encoding (optional) see NetConnection.objectEncoding and flash.net.ObjectEncoding
		 * @param	openConnection	Automatically open the connections? (optional) (by calling openConnection())
		 */
        function MinimalRemoting(url:String, encoding:Object=null, openConnection:Boolean=false):void { 
            Security.allowDomain("localhost"); 	// todo: take this out?
			this.encoding = encoding;
			this.url = url;
            resp = new Responder(onResult, onFault); 
			if (openConnection) this.openConnection();
        } 
        
		/**
		 * Here we construct the call to our NetConnection object connection
		 * Automatically open the connection if necessary
		 * @param	classMethod	method on the server you are calling
		 * @param	args		can be an array or an object (an object will be packaged into an array)
		 */
        public function call(classMethod:String, ...args):void {
			args.unshift(classMethod, this.resp);
			
			if (connection == null || ! connection.connected) openConnection();
            connection.call.apply(this, args);
        }
		
		/**
		 * Close the connection (NetConnection) object
		 * Note that we don't capture the NET_STATUS sent after connection.close()
		 */
		public function closeConnection():void {
			connection.removeEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
			connection.close();
		}
		
		/**
		 * Call this function to create a persistent connection (by connecting via the connection [NetConnection] object)<br />
		 * This is optional because the call(...) function will call this automatically if necessary
		 */
		private function openConnection():void {
			connection = new NetConnection(); 
			connection.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler,false,0,true);
			if (encoding != null) connection.objectEncoding = uint(encoding);
			connection.connect(url);
		}
		
        private function convRec(r:Object):Array { 
            var rsArr:Array = new Array(); 
            var colCount:Number = r.serverInfo.columnNames.length; 
            for (var row:Number = 0; row < r.serverInfo.initialData.length; row++) { 
                rsArr[row] = new Array(); 
                for (var colIndex:* in r.serverInfo.columnNames) { 
                    rsArr[row][r.serverInfo.columnNames[colIndex]] = r.serverInfo.initialData[row][colIndex]; 
                } 
            } 
            return rsArr; 
        } 
        
		/**
		 * Yay a result was recieved... now serialize it and dispatch a RemotingEvent
		 * @param	re
		 */
        private function onResult(re:Object):void { 
            var resultType:String = "null"; 
			var evt:RemotingEvent = new RemotingEvent(RemotingEvent.RESULT);
			
            if (!re) { 
                resultType = "false"; 
                var outFalse:Boolean = false; 
            } else if (re is Number) { 
                resultType = "Number"; 
                var outN:Number = Number(re); 
            } else if (re is String) { 
                resultType = "String"; 
                var outS:String = String(re); 
            } else { 
                var outA:Object = new Object(); 
                if (!("serverInfo" in re)) { 
                    resultType = "Array"; 
                    outA = re; 
                    for (var i:* in re) { 
                        if (re[i]) { 
                            if ("serverInfo" in re[i]) { 
                                var z:Array = this.convRec(re[i]); 
                                re[i] = z; 
                            } 
                        } 
                    } 
                } else { 
                    resultType = "RecordSet"; 
                    var rsArr:Array = new Array(); 
                    var colCount:Number = re.serverInfo.columnNames.length; 
                    for (var row:Number = 0; row < re.serverInfo.initialData.length; row++) { 
                        rsArr[row] = new Array(); 
                        for (var colIndex:* in re.serverInfo.columnNames) { 
                            rsArr[row][re.serverInfo.columnNames[colIndex]] = re.serverInfo.initialData[row][colIndex]; 
                        } 
                    } 
                    outA = rsArr; 
                } 
            } 
            switch (resultType) { 
                case "false":  
                    evt.result = outFalse; 
                    break; 
                case "Number": 
                    evt.result = outN; 
                    break; 
                case "String": 
                    evt.result = outS; 
                    break; 
                case "Array": 
                    evt.result = outA; 
                    break; 
                case "RecordSet": 
                    evt.result = outA; 
                    break; 
                default:  
                    evt.result = null; 
                    break; 
            } 
            
            evt.resultType = resultType; 
			
			dispatchEvent(evt);	//RemotingEvent(this.r.result));
        } 
        
		/**
		 * We connected to the server, but the call failed
		 * This is probably an unrecoverable error because the server is not setup properly
		 * @param	fault
		 */
        private function onFault(fault:Object):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.FAILED, fault));
		} 
		
		/**
		 * Probably unable to connect to the server
		 * @param	event
		 */
		private function netStatusHandler(event:NetStatusEvent):void {
			//trace("netStatusHandler: " + event.info.code);
			switch (event.info.code) {
				case "NetConnection.Call.Failed":
					dispatchEvent(new RemotingEvent(RemotingEvent.NET_STATUS_FAILED, event.info));
					break;
				// TODO: Are there other possibilities we need to handle?
				default:
					trace("MinimalRemoting: Unhandled NET_STATUS Event");
			}
			
        }
	} 
}