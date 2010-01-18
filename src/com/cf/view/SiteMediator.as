package com.cf.view
{
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.asual.swfaddress.SWFAddress;
	import com.cf.ApplicationFacade;
	import com.cf.controller.LoadSiteCommand;
	import com.cf.model.SWFAddressProxy;
	import com.cf.model.StageProxy;
	import com.cf.util.AssetManager;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.component.Site;
	import com.cf.view.component.container.ContainerBase;
	import com.cf.view.component.shape.ShapePlus;
	import com.cf.view.event.UIEvent;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import flashpress.vo.WpMediaVO;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.utilities.statemachine.StateMachine;

	public class SiteMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SiteMediator";
		
		private var _containersReady:int	= 0;
		private var _containersTotal:int 	= 2;
		
		public function SiteMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			
			//site.addEventListener( ShapePlus.UIEVENT_SITE_READY, uievent_site_ready );
			site.addEventListener( ContainerBase.CONTAINER_READY, container_ready );
		}
		
		//
		// OVERRIDES
		//
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.INIT_LOAD_COMPLETE,
				StateMachine.CHANGED,
				Utility.enteringNote( CF.STATE_WE_ARE ),
				Utility.exitingNote( CF.STATE_WE_ARE ),
				Utility.enteringNote( CF.STATE_WE_ARE_NOT ),
				Utility.exitingNote( CF.STATE_WE_ARE_NOT ),
				ApplicationFacade.ADDRESS_CHANGED
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			//Utility.debugColor(this, 0x00FF00, notification.getBody() );
			//Utility.debugColor(this, 0x00FF00, notification.getType() );
			
			switch ( notification.getName() )
			{
				
				case ApplicationFacade.INIT_LOAD_COMPLETE:
					site.site_loaded();
					Utility.debug("INIT_LOAD_COMPLETE");
					
					var bgPathProxy:RemotingInitProxy = facade.retrieveProxy( LoadSiteCommand.REMOTE_ACTIVE_VIDEO_BG_PROXY ) as RemotingInitProxy;
					if ( bgPathProxy.getData() is Array && (bgPathProxy.getData() as Array).length > 0 )
						AssetManager.bgVideoURL = ((bgPathProxy.getData() as Array)[0] as WpMediaVO).url; 
					
					// TODO, check if we need to go somewhere first before defaulting the URL to we are
					
					
					
										
				break;
				case ApplicationFacade.INIT_LOAD_FAIL:
					
				break;
				case Utility.enteringNote( CF.STATE_WE_ARE ):
					
					Utility.debug( this, "entering", CF.STATE_WE_ARE );
					
					// CHANGE title
					//sendNotification( ApplicationFacade.TITLE_CHANGE, "
					
					// OPEN we are
					(facade.retrieveMediator( ContainerMediator.getName( Settings.WP_CAT_WE_ARE ) ) as ContainerMediator).transitionToOpen();
					
				break;
				case Utility.exitingNote( CF.STATE_WE_ARE ):
				
					if (notification.getType().toString() == CF.STATE_WE_ARE_NOT)
					{
						// MINIMIZE we are
						(facade.retrieveMediator( ContainerMediator.getName( Settings.WP_CAT_WE_ARE ) ) as ContainerMediator).transitionToMinimized();
						// TRANSITION site
						site.transitionToWeAreNot();
					}
					/*else
					{
						// LIST we are
						(facade.retrieveMediator( ContainerMediator.getName( Settings.WP_CAT_WE_ARE ) ) as ContainerMediator).transitionToList();
					}*/
				
				break;
				case Utility.enteringNote( CF.STATE_WE_ARE_NOT ):
				
					// OPEN we are not
					(facade.retrieveMediator( ContainerMediator.getName( Settings.WP_CAT_WE_ARE_NOT ) ) as ContainerMediator).transitionToOpen();
				
				break;
				case Utility.exitingNote( CF.STATE_WE_ARE_NOT ):
				
					if (notification.getType().toString() == CF.STATE_WE_ARE)
					{
						// MINIMIZE we are not
						(facade.retrieveMediator( ContainerMediator.getName( Settings.WP_CAT_WE_ARE_NOT ) ) as ContainerMediator).transitionToMinimized();
						// TRANSITION site
						site.transitionToWeAre();
					}
					/*else
					{
						// LIST we are
						(facade.retrieveMediator( ContainerMediator.getName( Settings.WP_CAT_WE_ARE_NOT ) ) as ContainerMediator).transitionToList();
					}*/
				
				break;
				case ApplicationFacade.ADDRESS_CHANGED:
				
					// LISTEN for address changed on the site level to handle a few edge cases:
					// 1. fullscreen mode, remove tray
					// 2. we are's list mode needs to lower tray a bit
				
					var segments:Array = notification.getBody() as Array;
					
					if ( segments[0] == Settings.WP_CAT_WE_ARE ) // BELONGS to WE ARE
					{
						if ( segments.length > 1 && segments[1] != "") // 2ND level nav
						{
							site.trayState = Site.TRAY_STATE_FULLSCREEN;
							/*if ( segments.length > 3 && segments[3] == Settings.URL_FLAG_LARGE)
							{
								site.trayState = Site.TRAY_STATE_FULLSCREEN;
							}
							else
							{
								site.trayState = Site.TRAY_STATE_LIST;
							}*/
						}
						else
						{
							site.trayState = Site.TRAY_STATE_NORMAL;
						}
					}
					if ( segments[0] == Settings.WP_CAT_WE_ARE_NOT )
					{
						if ( segments.length > 1 && segments[1] != "") // 2nd
						{
							site.trayState = Site.TRAY_STATE_WEARENOT_CONTENT;
						}
						else
						{
							if ( site.trayState == Site.TRAY_STATE_WEARENOT_CONTENT )
							{
								site.trayState = Site.TRAY_STATE_WEARENOT;
							}
						}
					}
				
				break;
			}
		}
		
		//
		// HANDLERS
		//
		private function stageResize(stageProxy:StageProxy):void
		{
			Utility.debug(this, ApplicationFacade.STAGE_RESIZE);
			site.updateSize(stageProxy.stage.stageWidth, stageProxy.stage.stageHeight);
		}
		private function container_ready(e:Event):void
		{
			_containersReady++;
			
			// WAIT FOR BOTH CONTAINERS TO BE READY
			if ( _containersReady == _containersTotal )
			{
				// SWFADDRESS proxy
				facade.registerProxy( new SWFAddressProxy() );
				
	
				// DEFAULT SWFADDRESS if not already set					
				var s:String = SWFAddress.getValue();
				if ( s == "" || s == "/" ) s = Settings.URL_WE_ARE;
				Utility.debugColor( this, 0xdc4999, "uievent_site_ready SWFadress value: " + SWFAddress.getValue() );
				Utility.debugColor( this, 0xdc4999, "uievent_site_ready loading: " + s );
				
				setTimeout( init_url, 900, s );
				
				//sendNotification( ApplicationFacade.ADDRESS_CHANGE, e.url );
			}
			
		}
		private function uievent_site_ready(e:UIEvent):void
		{
		}
		private function init_url(s:String):void
		{
			Utility.debug(this, "init_url", s);
			sendNotification( ApplicationFacade.ADDRESS_CHANGE, s );
		}
		
		//
		// PROPERTIES
		//
		private function get site():Site
		{
			return viewComponent as Site;
		}
		
		
		//
		// PUBLIC API
		//
		
		
	}
}