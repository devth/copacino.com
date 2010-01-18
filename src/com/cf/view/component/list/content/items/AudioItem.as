package com.cf.view.component.list.content.items
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.devth.media.AudioController;
	import com.devth.media.MediaControls;
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.hires.controllers.VideoController;

	public class AudioItem extends ContentItemBase
	{
		// VISUAL
		private var _mediaContainer:Sprite = new Sprite();
		private var _mediaController	:AudioController;
		private var _mediaControls		:MediaControls;
		private var _clickArea:Sprite = new Sprite();
		
		// DATA
		
		// STATE
		private var _isVideoCreated:Boolean = false;
		
		public function AudioItem( assetInfo:AssetInfo )
		{
			super( assetInfo );
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
			
			// SIZING
			this.desiredWidth = Settings.CONTENT_VIDEO_AREA_WIDTH;
			this.desiredHeight = Settings.CONTENT_AREA_HEIGHT;
			this._aspectRatio = desiredWidth / desiredHeight;
			
			// BG
			_bg.graphics.beginFill( Settings.CONTENT_VIDEO_AREA_BG, 1 );
			_bg.graphics.drawRect( 0, 0, Settings.CONTENT_VIDEO_AREA_WIDTH, Settings.CONTENT_VIDEO_AREA_HEIGHT );
			_bg.graphics.endFill();
			
			// CENTER VIDEO SLATE
			_content.addChild( _slate );
			_content.x = ( _bg.width >> 1 ) - ( _slate.width >> 1 );
			_content.y = ( _bg.height >> 1 ) - ( _slate.height >> 1 );
			
			// VIDEO CONTAINER
			_content.addChild( _mediaContainer );

			// INIT TINT
			initTint( Settings.CONTENT_VIDEO_AREA_WIDTH, Settings.CONTENT_VIDEO_AREA_HEIGHT );			

			// WIRE EVENTS
			_content.addEventListener( MouseEvent.MOUSE_DOWN, content_mouse_down );
			
			
			// CLICK AREA - initially on top
			_clickArea.addChild( Utility.getMaskShape( Settings.CONTENT_VIDEO_AREA_WIDTH, Settings.CONTENT_VIDEO_AREA_HEIGHT ) );
			_clickArea.alpha = 0;
			addChild( _clickArea );

			// WHEN INACTIVE, let any portion be the cursor:
			_clickArea.addEventListener( MouseEvent.ROLL_OUT, bg_mouse_out );
			_clickArea.addEventListener( MouseEvent.ROLL_OVER, bg_mouse_over );
			_clickArea.addEventListener( MouseEvent.MOUSE_DOWN, bg_mouse_down );
			
			// DISABLE click area
			_clickArea.visible = false;
			
			// TODO: TEMP init vid
			initMedia();
			
			
			addStroke();
			
		}
		override public function toActive( ) : void
		{
			super.toActive( );
			if (_mediaController == null) initMedia();
			
			// WHEN ACTIVE, only the bg is the cursor
			_bg.addChild( _clickArea );
		}
		override public function toInactive( useTint:Boolean = true) : void
		{
			super.toInactive( useTint );
			
			_mediaController.pause();
			
			// WHEN INACTIVE, let any portion be the cursor:
			this.addChild( _clickArea );
		}
		override public function toModeLarge() : void
		{
			super.toModeLarge();
			
			// SIZING
			//this.desiredHeight = stage.stageHeight;
			//this.desiredWidth = stage.stageWidth; // stage.stageHeight  * _aspectRatio;
			
			// BG
			TweenLite.to( _bg, .8, { delay:1, width: desiredWidth, height: desiredHeight });
			
			// RESIZE CLICK AREA
			_clickArea.width = desiredWidth;
			_clickArea.height = desiredHeight;
			
			// POSITION _content
			TweenLite.to( _content, .8, { delay:1, x: (desiredWidth >> 1) - (_content.width >> 1), y: (desiredHeight >> 1) - (_content.height >> 1) });
		}
		override public function toModeNormal() : void
		{
			super.toModeNormal();
			
			// SIZING
			//this.desiredHeight = Settings.CONTENT_AREA_HEIGHT;
			//this.desiredWidth = Settings.CONTENT_VIDEO_AREA_WIDTH;
			
			// BG
			TweenLite.to( _bg, .8, { delay:1, width: desiredWidth, height: desiredHeight });
			
			// RESIZE CLICK AREA
			_clickArea.width = desiredWidth;
			_clickArea.height = desiredHeight;
			
			// POSITION _content
			TweenLite.to( _content, .8, { delay:1, x: (desiredWidth >> 1) - (_content.width >> 1), y: (desiredHeight >> 1) - (_content.height >> 1) });
		}
		override protected function position() : void
		{
			super.position();
			
			if ( _mode == MODE_LARGE )
			{
				// RECALC desired size
				//this.desiredHeight = stage.stageHeight;
				//this.desiredWidth = stage.stageWidth; // stage.stageHeight  * _aspectRatio;
				
				_bg.width = _clickArea.width = desiredWidth;
				_bg.width = _clickArea.width = desiredHeight;
			}
			
			// POSITION _content
			_content.x = (desiredWidth >> 1) - (_slate.width >> 1);
			_content.y = (desiredHeight >> 1) - (_slate.height >> 1);
		}
		override public function get desiredWidth():Number
		{
			return Settings.CONTENT_VIDEO_AREA_WIDTH;
		}
		override public function get desiredHeight():Number
		{
			if ( _mode == MODE_LARGE ) return stage.stageHeight;
			else 
			{
				if ( stage.stageHeight < (Settings.CONTENT_AREA_HEIGHT + (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT)) )
				{
					return ( stage.stageHeight - (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT));
				}
				else
					return Settings.CONTENT_AREA_HEIGHT;
			}
		}
		
		//
		// PRIVATE
		//
		private function initMedia():void
		{
			// CONTROLLER
			_mediaController = new AudioController();
			_mediaController.addEventListener( VideoController.METADATA, videoController_metadata );
			// _mediaContainer.addChild( _mediaController );
			
			_mediaController.load( _assetInfo.assetURL );
			_mediaController.pause();
			
			// CONTROLS
			_mediaControls = new MediaControls( _slate.width, _mediaController );
			_mediaControls.x = _slate.x;
			_mediaControls.y = _slate.y + _slate.height + 2;
			_mediaContainer.addChild( _mediaControls );
		}
		
		//
		// EVENT HANLDERS
		//
		private function bg_mouse_down(e:MouseEvent):void
		{
			dispatchEvent( new Event( ContentItemBase.CURSOR_CLICK, true, true ) );
		}
		private function bg_mouse_out(e:MouseEvent):void
		{
			dispatchEvent( new Event( ContentItemBase.CURSOR_DISABLED, true, true ) );
		}
		private function bg_mouse_over(e:MouseEvent):void
		{
			dispatchEvent( new Event( ContentItemBase.CURSOR_ENABLED, true, true ) );
		}
		private function videoController_metadata(e:Event):void
		{
			
		}
		private function content_mouse_down(e:MouseEvent):void
		{			
			// TOGGLE
			
		}
	}
}