package com.cf.view
{
	import com.cf.ApplicationFacade;
	import com.cf.controller.LoadSiteCommand;
	import com.cf.model.StageProxy;
	import com.cf.model.postsearch.WeAreListSearch;
	import com.cf.model.postsearch.WeAreNotListSearch;
	import com.cf.util.Settings;
	import com.cf.view.component.Site;
	
	import flash.display.Stage;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class StageMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "StageMediator";
		
		public function StageMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		//
		// OVERRIDES
		//
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.INITIALIZE_SITE,
				ApplicationFacade.STAGE_RESIZE
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.INITIALIZE_SITE:
					initializeSite();
					break;
			}
		}
		
		
		//
		// HANLDERS
		//
		private function initializeSite():void
		{
			// CREATE site
			var site:Site = new Site();
			stage.addChild( site );
			
			// REGISTER MEDIATORS
			facade.registerMediator( new SiteMediator( site ));
			facade.registerMediator( new ContainerMediator( Settings.WP_CAT_WE_ARE, site.WeAreLayer, new WeAreListSearch() ));
			facade.registerMediator( new ContainerMediator( Settings.WP_CAT_WE_ARE_NOT, site.WeAreNotLayer, new WeAreNotListSearch() ));
			facade.registerMediator( new NavMediator( site.NavLayer ));
			
			// SET stage size
			var stageProxy:StageProxy = facade.retrieveProxy( StageProxy.NAME ) as StageProxy;
			site.updateSize(stageProxy.stage.stageWidth, stageProxy.stage.stageHeight);
			
			// LOAD SITE
			facade.registerCommand( ApplicationFacade.INIT_LOAD, LoadSiteCommand );
			sendNotification( ApplicationFacade.INIT_LOAD );
			
		}
		
		
		//
		// PROPERTIES
		//
		protected function get stage():Stage
		{
			return viewComponent as Stage;
		}
		
		
	}
}