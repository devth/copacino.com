package com.cf.view
{
	import com.cf.ApplicationFacade;
	import com.cf.controller.LoadPostCommand;
	import com.cf.model.ListDataProxy;
	import com.cf.model.SiteContentProxy;
	import com.cf.model.event.StateEvent;
	import com.cf.model.postsearch.IListSearcher;
	import com.cf.model.vo.ListItem;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.component.container.ContainerBase;
	import com.cf.view.component.container.WeAre;
	import com.cf.view.component.list.ListBase;
	import com.cf.view.component.list.ListTile;
	import com.cf.view.component.shape.ShapeBase;
	import com.cf.view.event.UIEvent;
	
	import flash.utils.getTimer;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	//
	// SPECIAL mediator, can be multiple instances, enumerated by NAME_* constants
	//
	public class ContainerMediator extends Mediator implements IMediator
	{
		public static const NAME:String	= "ContainerMediator";
		
		public var uniqueNamePart:String;
		
		private var _timestamp:int = 0;
		private var _timeDifference:int = 0;
		private var _listSearch:IListSearcher;
		
		private var _currentMaximizedListTile:ListTile;
		
		public function ContainerMediator( name:String, viewComponent:Object, listSearch:IListSearcher )
		{
			uniqueNamePart = name;
			_listSearch = listSearch;
			
			super( getName( uniqueNamePart ), viewComponent);
			
			// WIRE EVENT HANDLERS
			containerBase.addEventListener( UIEvent.SHAPE_CLICK, shape_click ); 
			containerBase.addEventListener( StateEvent.STATE_CHANGED, state_changed );
			containerBase.addEventListener( UIEvent.LIST_CLOSE, list_close );
			containerBase.addEventListener( ShapeBase.UIEVENT_TILE_CLICK, tile_click );
			containerBase.addEventListener( UIEvent.URL_EVENT, url_event );
			
			// containerBase.addEventListener( Component.UIEVENT_STATE_CHANGE, container_state_change );
		}
		
		// PUBLIC STATIC API
		public static function getName( name:String ):String
		{
			return NAME + name;
		}
		
		//
		// OVERRIDES
		//
		override public function listNotificationInterests():Array
		{
			return [
					ApplicationFacade.INIT_LOAD_PROGRESS,
					ApplicationFacade.INIT_LOAD_COMPLETE,
					LoadPostCommand.POST_MONITOR_COMPLETE,
					LoadPostCommand.POST_MONITOR_FAIL,
					LoadPostCommand.POST_MONITOR_PROGRESS,
					ApplicationFacade.ADDRESS_CHANGED
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch ( notification.getName() )
			{
				case LoadPostCommand.POST_MONITOR_COMPLETE:
					trace( notification.getBody() );
					trace( notification.getType() );
					trace("post_monitor_complete");
				
				break;
				case LoadPostCommand.POST_MONITOR_FAIL:
					trace("post_monitor_fail");
				
				break;
				case LoadPostCommand.POST_MONITOR_PROGRESS:
					trace("post_monitor_progress");
				
				break;
				case ApplicationFacade.INIT_LOAD_PROGRESS:
					
					// HANDLE LOADING indicator for we are container only
					if (containerBase is WeAre)
					{
						_timeDifference = getTimer() - _timestamp;
						
						// ONLY SHOW a fixed number of loading tiles per second, unless it's 100%
						if (( _timeDifference > (1000 / Settings.LOAD_TILE_PER_SECOND) ) || notification.getBody() as Number == 1)
						{
							_timestamp = getTimer();
							(containerBase as WeAre).load_update( notification.getBody() as Number );							
						}
					}
					
				break;
				case ApplicationFacade.INIT_LOAD_COMPLETE:


					var siteContentProxy:SiteContentProxy = facade.retrieveProxy( SiteContentProxy.NAME ) as SiteContentProxy;

					// GET dynamic proxy names
					//var surfaceProxyName:String = LoadSiteCommand.getSurfaceName( this.uniqueNamePart );
					//var siteContentProxyName:String = LoadSiteCommand.getSiteContentName( this.uniqueNamePart );
					
					// RETRIEVE proxies and set data on the view components
					//var surfaceContentProxy:IProxy = facade.retrieveProxy( surfaceProxyName );
					//var siteContentProxy:IProxy = facade.retrieveProxy( siteContentProxyName );
					
					containerBase.tileData = siteContentProxy.getSurfaceContent( this.uniqueNamePart );
					
					// CREATE a ListDataProxy to query and sort the correct posts
					var listDataProxy:ListDataProxy = new ListDataProxy( this.uniqueNamePart, siteContentProxy.getSiteContent( this.uniqueNamePart ) as Array, _listSearch );
					
					containerBase.listData = listDataProxy.getData() as Array;
					
					// LOAD COMPLETE
					containerBase.loadComplete();
					
					
					
				break;
				case ApplicationFacade.ADDRESS_CHANGED:
				
					var segments:Array = notification.getBody() as Array;
					
					if ( this.uniqueNamePart == segments[0] ) // BELONGS to this mediator
					{
						if ( segments.length > 1 && segments[1] != "") // 2ND level nav
						{
							// 1. CHECK TO SEE IF IT's PART OF THE MAIN NAV
							var isMainNav:Boolean = Utility.isMainNav( segments[1] );
							
							// 2. ANYTHING at the second level requires list so just transition to either full LIST VIEW or CLOUD DISPLAY
							var isCloudDisplay:Boolean = (!isMainNav) && (
											(containerBase.state == ContainerBase.STATE_OPEN)
											||
											(containerBase.list.state == ListBase.STATE_CLOUD_DISPLAY) // ONCE a list is in CLOUD DISPLAY, only a mainNav section can get it out (from here anyway)
							);
							
							
							MonsterDebugger.trace(this, containerBase.state);
							
							transitionToList( isCloudDisplay );
							
							// 3. SCROLL TO MAIN NAV or open the exact item
							if ( isMainNav )
							{
								// List needs to scroll to segments[1]
								containerBase.list.scrollToSection( segments[1] );
							}
							else
							{
								containerBase.list.openPost( segments[1] );
								
								// CHECK for specific content index
								if ( segments.length > 2 && segments[2] != "")
								{
									var index:Number = Number(segments[2]);
									containerBase.list.currentListTileMaximized.scrollToSegment( index ); 
								}
								else
								{
									containerBase.list.currentListTileMaximized.scrollToSegment( 0 );
								}
								
								// CHECK for view large flag
								if ( segments.length > 3 && segments[3] == Settings.URL_FLAG_LARGE)
								{
									containerBase.list.largifyCurrentMaximized();
								}
								else
								{
									containerBase.list.delargifyCurrentMaximized();
								}
							}
						}
						else // TOP LEVEL
						{
							transitionToOpen();
						}
						
					}
					else // THE OTHER mediator
					{
						if ( this.containerBase.list != null &&  this.containerBase.list.state == ListBase.STATE_REVEALED ) transitionToMinimized();
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
		private function tile_click(e:UIEvent):void
		{
			sendNotification( ApplicationFacade.ADDRESS_CHANGE, e.url );
			sendNotification( ApplicationFacade.TITLE_CHANGE, e.name );	
		}
		private function list_close(e:UIEvent):void
		{
			sendNotification( ApplicationFacade.ADDRESS_CHANGE, containerBase.url );
		}
		private function shape_click(e:UIEvent):void
		{
			sendNotification( ApplicationFacade.ADDRESS_CHANGE, e.url );
			
		}
		private function state_changed(e:StateEvent):void
		{
			if (e.state == ListTile.STATE_MAXIMIZED)
			{
				// HOLD REFERENCE to the current maximized list tile
				_currentMaximizedListTile = e.target as ListTile;
				
				if (_currentMaximizedListTile.listItem.type == ListItem.LIST_ITEM_TYPE_POST)
				{
					// ENSURE content exists
					if ( _currentMaximizedListTile.content == null ) _currentMaximizedListTile.createContent();
					
					// LOAD post
					sendNotification( ApplicationFacade.LOAD_POST, _currentMaximizedListTile );
				}
			}
			
			if ( e.target is ContainerBase )
			{
				// TELL the NavMediator that container's state is changing so it can react
				var navMediator:NavMediator = facade.retrieveMediator( NavMediator.NAME ) as NavMediator;
				navMediator.containerStateChange( e );
			}
			
			// STOP bubbling
			e.stopPropagation();
		}
		
		
		//
		// PUBLIC API
		//
		public function transitionToList( isCloudDisplay:Boolean = false ):void
		{
			containerBase.toListState( isCloudDisplay );
		}
		public function transitionToMinimized():void
		{
			containerBase.toMinimizedState();
		}
		public function transitionToOpen():void
		{
			containerBase.toOpenState();
		}
		
		
		//
		// PROPERTIES
		//
		public function get containerBase():ContainerBase
		{
			return viewComponent as ContainerBase;
		}
	}
}