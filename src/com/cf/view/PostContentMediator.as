package com.cf.view
{
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.cf.controller.LoadPostCommand;
	import com.cf.model.PostAssetsProxy;
	import com.cf.model.vo.AssetInfo;
	import com.cf.view.component.list.ListTile;
	
	import flash.display.Bitmap;
	
	import flashpress.vo.WpPostVO;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class PostContentMediator extends Mediator implements IMediator
	{
		public static const NAME_PREFIX:String = "PostContentMediator";
		
		private var _postId:int;
		
		public function PostContentMediator(postId:int, viewComponent:Object)
		{
			_postId = postId;
			super( getPostContentMediatorName( postId ), viewComponent);
		}
		
		//
		// OVERRIDES
		//
		override public function listNotificationInterests():Array
		{
			return [
				LoadPostCommand.POST_MONITOR_COMPLETE,
				LoadPostCommand.POST_MONITOR_FAIL,
				LoadPostCommand.POST_MONITOR_PROGRESS,
				LoadPostCommand.getPostFinishedNotificationName( _postId ),
				PostAssetsProxy.getDataReadyNotification( _postId ),
				PostAssetsProxy.getImageLoadedNotification( _postId )
			];
		}
		override public function handleNotification(notification:INotification):void
		{
			switch ( notification.getName() )
			{
				case LoadPostCommand.getPostFinishedNotificationName( _postId ):
				
					if ( notification.getBody() is Array )
					{
						var postData:WpPostVO = ( notification.getBody() as Array)[0] as WpPostVO;
						listTile.setPostData( postData );
					}
				
				break;
				case PostAssetsProxy.getDataReadyNotification( _postId ):
				
					if ( notification.getBody() is Array )
					{
						var assetsArray:Array = notification.getBody() as Array;
						listTile.setAssetsArray( assetsArray );
					}
				
				break;
				case PostAssetsProxy.getImageLoadedNotification( _postId ):
				
					var ai:AssetInfo = notification.getBody() as AssetInfo;
					listTile.addLoadedAsset( ai );
				
				break;
				case LoadPostCommand.POST_MONITOR_COMPLETE:
					/*if ( notification.getType() == _postId.toString() )
					{
						trace(_postId + " complete!");
						var postDataProxy:RemotingInitProxy = facade.retrieveProxy( LoadPostCommand.getPostProxyName( _postId ) ) as RemotingInitProxy;
						if (postDataProxy.getData() is Array)
						{
							var postData:WpPostVO = (postDataProxy.getData() as Array)[0];
						}
						var postAssetsProxy:PostAssetsProxy = facade.retrieveProxy( PostAssetsProxy.getProxyNameById( _postId ) ) as PostAssetsProxy;
						var postAssetsDataProxy:RemotingInitProxy = facade.retrieveProxy( LoadPostCommand.getPostAssetsDataProxyName( _postId ) ) as RemotingInitProxy;
						
						
						// SET VOs on view component, triggers createContent()
						// listTile.setData( postData, postAssetsDataProxy.getData() as Array, postAssetsProxy.loader );
					}*/
					
					listTile.load_complete();
				
				break;
				
			}
		}
		
		
		
		//
		// PRIVATE API
		//
		private function get listTile():ListTile
		{
			return viewComponent as ListTile;
		}
		
		//
		// PUBLIC STATIC
		//
		public static function getPostContentMediatorName(postId:int):String
		{
			return NAME_PREFIX + postId;
		}
		
	}
}