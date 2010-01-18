package com.cf.view
{
	import com.afw.swfaddress.SWFAddressUtil;
	import com.cf.ApplicationFacade;
	import com.cf.model.event.StateEvent;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.component.container.ContainerBase;
	import com.cf.view.component.nav.Nav;
	import com.cf.view.component.nav.NavTile;
	import com.cf.view.event.UIEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class NavMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NavMediator";
				
		
		public function NavMediator( viewComponent:Object=null )
		{
			super(NAME, viewComponent);
			
			nav.addEventListener( MouseEvent.CLICK, navClick );
			nav.addEventListener( UIEvent.URL_EVENT, url_event );
		}
		
		//
		// OVERRIDES
		//
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.INIT_LOAD_COMPLETE,
				ApplicationFacade.ADDRESS_CHANGED
			];
		}
		
		
		override public function handleNotification(notification:INotification):void
		{
			switch (notification.getName())
			{
				case ApplicationFacade.INIT_LOAD_COMPLETE:
					
				break;
			
				case ApplicationFacade.ADDRESS_CHANGED:
					
					var primarySegments:Array = SWFAddressUtil.segmentPrimary( notification.getType() as String );
					
					
					// SET ACTIVE NAV ITEM
					// ENSURE it's at /we-are and one of the main nav segments or "contact"
					if ( primarySegments.length > 1 && primarySegments[0] == Settings.URL_WE_ARE && (Utility.isMainNav( primarySegments[1] ) || primarySegments[1] == "contact") )
					{
						//MonsterDebugger.trace(this, "address_changed: " + notification.getType());
						// SET the active nav
						nav.activeNavTileBySegment = primarySegments[1];
					}
					else
					{
						// CLEAR the active nav out
						if ( nav.activeNavTile != null ) nav.activeNavTileBySegment = "";
					}
					
					// SET ACTIVE ICON
					if ( primarySegments[0] == Settings.URL_WE_ARE && primarySegments.length > 1 && Utility.isMainNav( primarySegments[1] ))
					{
						nav.activeIconByName = "list";
					}
					else if (primarySegments[0] == Settings.URL_WE_ARE && primarySegments.length == 1 )
					{
						nav.activeIconByName = "cloud";
					}
					else
					{
						nav.activeIconByName = "";
					}
				break;
			}
		}
		
		
		//
		// EVENT HANDLERS
		//
		private function url_event(e:UIEvent):void
		{
			sendNotification( ApplicationFacade.ADDRESS_CHANGE, e.url );
			sendNotification( ApplicationFacade.TITLE_CHANGE, e.name );
		}
		
		private function navClick(e:Event):void
		{
			// NAV was clicked - see if it's a tile, update url and title
			var navTile:NavTile = e.target as NavTile;
			
			if ( navTile && navTile.navData != null)
			{
				sendNotification( ApplicationFacade.ADDRESS_CHANGE, navTile.navData.fullUrl );
				sendNotification( ApplicationFacade.TITLE_CHANGE, navTile.navData.title );
			}
		}
		
		// 
		// PUBLIC API
		//
		public function containerStateChange(e:StateEvent):void
		{
			if (e.state == ContainerBase.STATE_LIST || e.state == ContainerBase.STATE_MINIMIZED_LIST) nav.state = Nav.STATE_INDENTED;
			else nav.state = Nav.STATE_LEFT;
		}
		public function get nav():Nav
		{
			return viewComponent as Nav;
		}
		
	}
}