package com.cf.controller
{
	import com.afw.puremvc.initmonitor.model.InitMonitorProxy;
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.cf.ApplicationFacade;
	import com.cf.model.InitAssetsProxy;
	import com.cf.model.SiteContentProxy;
	import com.cf.util.Settings;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class LoadSiteCommand extends SimpleCommand implements ICommand
	{
		public static const NAME:String = "LoadSiteCommand";
		public static const REMOTE_NAME:String	= NAME + "RemoteProxy";
		
		public static const SURFACE:String 	= "surface";
		public static const SITE:String		= "site";
		
		
		public static const REMOTE_INIT_PROXY:String					= "siteInitData";
		public static const REMOTE_CATEGORIES_PROXY:String				= "remoteCategoriesProxy";
		public static const REMOTE_ACTIVE_VIDEO_BG_PROXY:String			= "activeVideoBgProxy";
		
		// DYNAMIC names
		// public static const REMOTE_SITE_CONTENT_WE_ARE:String			= getSiteContentName( ApplicationFacade.WE_ARE );
		// public static const REMOTE_SITE_CONTENT_WE_ARE_NOT:String		= getSiteContentName( ApplicationFacade.WE_ARE_NOT );
		// public static const REMOTE_SURFACE_CONTENT_WE_ARE:String		= getSurfaceName( ApplicationFacade.WE_ARE );
		// public static const REMOTE_SURFACE_CONTENT_WE_ARE_NOT:String	= getSurfaceName( ApplicationFacade.WE_ARE_NOT );
		
		
		override public function execute(notification:INotification):void
		{
			// SETUP loader proxies
			var siteInitData:RemotingInitProxy = new RemotingInitProxy(REMOTE_INIT_PROXY, Settings.GATEWAY_PATH, Settings.GET_SITE_ASSETS);
			var remoteCategories:RemotingInitProxy = new RemotingInitProxy(REMOTE_CATEGORIES_PROXY, Settings.GATEWAY_PATH, Settings.GET_CATEGORIES);
			
			
			
			//var surfaceContentWeAre:RemotingInitProxy = new RemotingInitProxy(REMOTE_SURFACE_CONTENT_WE_ARE, Settings.GATEWAY_PATH, Settings.GET_SURFACE_CONTENT, Settings.WP_CAT_WE_ARE);
			//var siteContent:RemotingInitProxy = new RemotingInitProxy(REMOTE_SITE_CONTENT_WE_ARE, Settings.GATEWAY_PATH, Settings.GET_SITE_CONTENT, Settings.WP_CAT_WE_ARE);
			
			//var surfaceContentWeAreNot:RemotingInitProxy = new RemotingInitProxy(REMOTE_SURFACE_CONTENT_WE_ARE_NOT, Settings.GATEWAY_PATH, Settings.GET_SURFACE_CONTENT, Settings.WP_CAT_WE_ARE_NOT);
			//var siteContentNot:RemotingInitProxy = new RemotingInitProxy(REMOTE_SITE_CONTENT_WE_ARE_NOT, Settings.GATEWAY_PATH, Settings.GET_SITE_CONTENT, Settings.WP_CAT_WE_ARE_NOT);
			
			// GET ALL combined POST data
			var siteContentProxy:SiteContentProxy = new SiteContentProxy( Settings.GATEWAY_PATH, Settings.GET_SITE_CONTENT );
			
			var siteInitAssets:InitAssetsProxy = new InitAssetsProxy( siteInitData );
			var monitor:InitMonitorProxy = new InitMonitorProxy();
			
			var activeVideoPathProxy:RemotingInitProxy = new RemotingInitProxy( REMOTE_ACTIVE_VIDEO_BG_PROXY, Settings.GATEWAY_PATH, Settings.GET_MEDIA_BY_CATEGORY, Settings.WP_CAT_ACTIVE_VIDEO );
			
			
			// REGISTER proxies
			facade.registerProxy( siteInitData );
			facade.registerProxy( remoteCategories );
			facade.registerProxy( siteInitAssets );
			
//			facade.registerProxy( surfaceContentWeAre );
//			facade.registerProxy( surfaceContentWeAreNot );
//			facade.registerProxy( siteContentNot );
//			facade.registerProxy( siteContent );

			facade.registerProxy( siteContentProxy );
			facade.registerProxy( activeVideoPathProxy );
			facade.registerProxy( monitor );
			
			// INIT
			//monitor.debug = Utility.debug;
			monitor.stop();
			monitor.completeNotificationName = ApplicationFacade.INIT_LOAD_COMPLETE;
			monitor.progressNotificationName = ApplicationFacade.INIT_LOAD_PROGRESS;
			monitor.failedNotificationName = ApplicationFacade.INIT_LOAD_FAIL;
			monitor.addResources([
				siteInitData,
				siteInitAssets,
				siteContentProxy,
				remoteCategories,
				activeVideoPathProxy
			]);
			monitor.start();
		}
		
		
		/*public static function getSurfaceName(name:String):String
		{
			return REMOTE_NAME + SURFACE + name;
		}
		public static function getSiteContentName(name:String):String
		{
			return REMOTE_NAME + SITE + name;
		}*/
		
		
		
	}
}