package com.cf.model
{
	import com.afw.swfaddress.SWFAddressUtil;
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.cf.ApplicationFacade;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	
	import flash.external.ExternalInterface;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import org.puremvc.as3.utilities.statemachine.StateMachine;

	public class SWFAddressProxy extends Proxy implements IProxy
	{
		public static const NAME:String = 'SWFAddressProxy';
		
		
		public function SWFAddressProxy()
		{
			super( NAME, Number(0) );
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onAddressChange);
		}
		
		public function requestURI(uri:String):void
		{
			Utility.debug(this, "requestURI", uri);
			
			var currentURI:String = SWFAddress.getValue();
			Utility.debug(this, "currentURI", currentURI );
			
			// IF it's the same url, just setTargetURI so the event is still propogated
			if (ExternalInterface.available && currentURI != uri )
			{
				Utility.debug("set the actual swf address to: " + uri);
				SWFAddress.setValue(uri);
			}
			else
			{
				setTargetURI( SWFAddressUtil.segmentURI(uri) );
			}
		}
		
		public function setTitle(title:String):void
		{
			// Utility.debug(this, "setTitle", title);
			title = Settings.TITLE_DEFAULT + " " + title;
			SWFAddress.setTitle(title);
		}
		
		private function onAddressChange(e:SWFAddressEvent):void
		{
			// Utility.debug("onAddressChange " + e.value);
			setTargetURI( SWFAddressUtil.segmentURI(e.value) );
		}
		
		private function setTargetURI(uriSegments:Array):void
		{
			Utility.debug(this, "setTargetURI " + uriSegments);	
			
			// OLD: this is allflashwebsite.com's way of doing swfaddress: 
			// sendNotification("$" + uriSegments[0], uriSegments, "Array");
			
			var uri:String = SWFAddressUtil.joinURI( uriSegments );
			
			// SEND NOTIFICATION to change state machine
			// var primarySegments:Array = SWFAddressUtil.segmentPrimary( uri );
			//var secondarySegments:Array	 = SWFAddressUtil.segmentSecondary( uri );
			
			// Utility.debug( SWFAddressProxy, secondarySegments );
			
			// todo:
			// FSM action is now just the first segment. there are only two FSM states
			
			
			var action:String = SWFAddressUtil.joinURI( [Settings.FSM_ACTION, uriSegments[0]] );
			
			
			// 1. SEND fsm action to make sure we're on the right side of we-are / we-are-not
			sendNotification( StateMachine.ACTION, uriSegments, action );
			
			
			// 2. SEND swf address segments so the two containers can properly 
			sendNotification( ApplicationFacade.ADDRESS_CHANGED, uriSegments, uri );
			
			
		}
	
	}
}