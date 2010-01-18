package com.cf.view.component.list.content.items
{
	import choppingblock.video.YouTubeLoaderEvent;
	
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.Settings;
	import com.devth.media.MediaControls;
	import com.devth.media.YoutubeController;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class YoutubeItem extends ContentItemBase
	{
		// VISUAL
		private var _videoContainer:Sprite = new Sprite();
		//private var _videoController:VideoController;
		//private var _videoControls:VideoControls;
		private var _clickArea:Sprite = new Sprite();
		
		
		private var _youtubeController:YoutubeController;
		private var _mediaControls:MediaControls;
		
		public function YoutubeItem(assetInfo:AssetInfo)
		{
			super(assetInfo);
			
			MonsterDebugger.trace(this, "youtube item created");
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
			
			MonsterDebugger.trace(this, "youtube item added to stage");
			MonsterDebugger.trace(this, _assetInfo.youtubeID + " = youtubeid");
			
			// CREATE YOUTUBE LOADER
			_youtubeController = new YoutubeController();
			_youtubeController.addEventListener( YouTubeLoaderEvent.LOADED, youtube_loaded );
			_youtubeController.addEventListener( YouTubeLoaderEvent.STATE_CHANGE, youtube_state_change, false, 0, true );
			_youtubeController.addEventListener( YouTubeLoaderEvent.IO_ERROR, youtube_io_error );
			_youtubeController.create();
			_videoContainer.addChild( _youtubeController );
			
			
			// SIZING
			this.desiredWidth = Settings.CONTENT_VIDEO_AREA_WIDTH;
			this.desiredHeight = Settings.CONTENT_AREA_HEIGHT;
			this._aspectRatio = desiredWidth / desiredHeight;
			
			// BG
			_bg.graphics.beginFill( Settings.CONTENT_VIDEO_AREA_BG, 1 );
			_bg.graphics.drawRect( 0, 0, Settings.CONTENT_VIDEO_AREA_WIDTH, Settings.CONTENT_VIDEO_AREA_HEIGHT );
			_bg.graphics.endFill();
			
			
			// VIDEO CONTAINER
			_content.addChild( _videoContainer );
			
			
			// CENTER VIDEO SLATE
			_content.addChild( _slate );
			_content.x = ( _bg.width >> 1 ) - ( _slate.width >> 1 );
			_content.y = ( _bg.height >> 1 ) - ( _slate.height >> 1 );
			
			// MEDIA CONTROLS
			_mediaControls = new MediaControls( _slate.width, _youtubeController );
			_videoContainer.addChild( _mediaControls );
			
			_mediaControls.y = _slate.height;
			
			
			addStroke();
		}
		override public function toInactive(useTint:Boolean=true) : void
		{
			super.toInactive(useTint);
			
			_youtubeController.pause();
		}
		
		
		//
		// EVENT HANLDERs
		//
		private function youtube_io_error(e:YouTubeLoaderEvent):void
		{
			MonsterDebugger.trace(this, "io error!!");
			MonsterDebugger.trace(this, e);
		}
		private function youtube_state_change(e:YouTubeLoaderEvent):void
		{
			MonsterDebugger.trace(this, "youtubeLoader state change!!");
			MonsterDebugger.trace(this, e.state);
			
			if ( e.state == "playing" )
			{
				TweenLite.to( _slate, .6, { alpha: 0 });
			}
			else
			{
				TweenLite.to( _slate, .6, { alpha: 1 });
			}
			
		}
		private function youtube_loaded(e:YouTubeLoaderEvent):void
		{
			MonsterDebugger.trace(this, "youtubeLoader loaded!");
			MonsterDebugger.trace(this, _assetInfo.youtubeID );
			
			// LOAD the video
			_youtubeController.loadVideoById( _assetInfo.youtubeID );
			_youtubeController.pause();
			
			// SIZE to slate
			_youtubeController.setSize( _content.width, _content.height );
		}
	}
}