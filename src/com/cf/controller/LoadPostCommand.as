package com.cf.controller
{
	import com.afw.puremvc.initmonitor.model.InitMonitorProxy;
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.cf.model.PostAssetsProxy;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.PostContentMediator;
	import com.cf.view.component.list.ListTile;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;

	/**
	 * CREATES a proxy to load full post data and a proxy for loading associated images
	 */
	public class LoadPostCommand extends SimpleCommand implements ICommand
	{
		public static const NAME:String						= "LoadPostCommand";
		public static const ASSETS_DATA_PROXY:String		= "AssetsProxy";
		public static const POST_PROXY:String				= "PostProxy";

		public static const POST_MONITOR_PREFIX:String		= NAME + "initmonitor";
		
		public static const POST_MONITOR_COMPLETE:String			= "PostMonitorComplete";
		public static const POST_MONITOR_PROGRESS:String			= "PostMonitorProgress";
		public static const POST_MONITOR_FAIL:String				= "PostMonitorFail";
		
		
		// INDIVIDUAL proxy notifications, combined with ID to make it unique in static helpers below
		public static const POST_PROXY_FINISH 		:String				= "post/proxy/finish/";
		public static const POST_ASSETS_DATA_FINISH	:String				= "post/assetsData/finish/";
		
		

		public function LoadPostCommand()
		{
			super();
		}
		
		
		override public function execute(notification:INotification):void
		{
			var listTile:ListTile = notification.getBody() as ListTile;
			var postId:int = listTile.listItem.postData.postId;
			
			// CHECK to see if it exists to prevent reloading content that's already been loaded
			// TODO: does this need to send complete notification?
			if (facade.hasMediator( PostContentMediator.getPostContentMediatorName( postId ) )) return;
			
			
			// SETUP mediator
			var postContentMediator:PostContentMediator = new PostContentMediator( postId, listTile );
			facade.registerMediator( postContentMediator );
			
			
			// SETUP loader proxies
			
			// POST
			var postDataProxy:RemotingInitProxy = new RemotingInitProxy( getPostProxyName(postId), Settings.GATEWAY_PATH, Settings.GET_POST_BY_ID, postId );
			postDataProxy.finishNotificationName = getPostFinishedNotificationName( postId );
			
			// POST ASSETS DATA
			var postAssetsDataProxy:RemotingInitProxy = new RemotingInitProxy( getPostAssetsDataProxyName( postId ), Settings.GATEWAY_PATH, Settings.GET_POST_ASSETS, postId );
			//postAssetsDataProxy.finishNotificationName = getAssetsDataFinishedNotificationName( postId );
			// POST ASSETS
			var postAssetsProxy:PostAssetsProxy = new PostAssetsProxy( postId, postAssetsDataProxy );
			
			var monitor:InitMonitorProxy = new InitMonitorProxy( getPostMonitorName(postId) );
			
			// REGISTER proxies
			facade.registerProxy( postDataProxy );
			facade.registerProxy( postAssetsDataProxy );
			facade.registerProxy( postAssetsProxy );
			facade.registerProxy( monitor );
			
			// INIT
			monitor.debug = trace;
			monitor.stop();
			
			monitor.completeNotification = new Notification( POST_MONITOR_COMPLETE, null, postId.toString() );
			monitor.progressNotificationName = POST_MONITOR_PROGRESS; //getProgressNotificationName( postId );
			monitor.failedNotificationName = POST_MONITOR_FAIL; //getFailNotificationName( postId );
			monitor.addResources([
				postDataProxy,
				postAssetsDataProxy,
				postAssetsProxy
			]);
			monitor.start();
			
			Utility.debug(this, "LoadPostCommand start", postId);
			
		}
		
	
		//
		// PUBLIC
		//
		public static function getPostProxyName(postId:Number):String
		{
			return NAME + POST_PROXY + postId.toString();
		}
		public static function getPostAssetsDataProxyName(postId:Number):String
		{
			return NAME + ASSETS_DATA_PROXY + postId.toString();
		}
		public static function getPostMonitorName(postId:Number):String
		{
			return POST_MONITOR_PREFIX + postId.toString();
		}
		
		// DYNAMIC NOTIFICATION naming
		public static function getPostFinishedNotificationName( postId:int ):String
		{
			return POST_PROXY_FINISH + postId;
		}
		public static function getAssetsDataFinishedNotificationName( postId:int ):String
		{
			return POST_ASSETS_DATA_FINISH + postId;
		}
		
	}
}