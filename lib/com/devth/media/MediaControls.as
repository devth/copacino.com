package com.devth.media
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.view.component.list.content.VideoControls;
	
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MediaControls extends Component
	{
		
		// VIDEO CONTROLS DEFAULT SETTINGS
		private static const HEIGHT:Number			= Settings.TILE_HEIGHT - 4;
		private static const BG_COLOR:uint			= 0x333333;
		private static const ROLLOVER:uint			= 0x222222;
		private static const SEPARATOR_COLOR:uint	= 0x777777;
		private static const CONTROLS_COLOR:uint	= 0xFFFFFF;
		
		private static const PROGRESS_COLOR:uint	= Settings.CONTENT_NAV_BG;
		private static const PROGRESS_ALPHA:Number	= Settings.CONTENT_NAV_BG_ALPHA;
		
		private static const BUFFER_COLOR:uint		= 0x262626;
		private static const BUFFER_ALPHA:Number	= .8;
		
		
		private static const GUTTER_COLOR:uint		= 0x262626;
		private static const GUTTER_ALPHA:Number	= .64;
		
		
		
		// EVENT
		public static const PLAY_CLICKED:String			= "event/play/clicked";
		
		// DATA
		private var _isPlaying:Boolean = false;
		private var _mediaController	:IMediaController;
		// private var _desiredWidth:Number;
		
		// VISUAL
		private var _bg:Sprite = new Sprite();
		
		private var _playButton:Sprite = new Sprite();
		private var _playCarat:Sprite = new Sprite();
		private var _pauseIcon:Sprite = new Sprite();
		
		private var _gutter:Sprite = new Sprite();
		private var _buffer:Sprite = new Sprite();
		private var _progress:Sprite = new Sprite();
		
		//private var _fullScreenButton:Sprite = new Sprite();
		//private var _fullScreenArrows:Sprite = new Sprite();
		
		private var _volumeSlider:VolumeSlider;
		
		private var _isSeeking:Boolean = false;
		private var _lineWidth:Number;
		
		
		public function MediaControls( desiredWidth:Number, mediaController:IMediaController )
		{
			super();
			
			_desiredWidth = desiredWidth;
			_mediaController = mediaController;
			
			//
			// WIRE controller events
			//
			_mediaController.addEventListener( MediaEvent.COMPLETE, videoController_event );
			_mediaController.addEventListener( MediaEvent.METADATA, videoController_event );
			_mediaController.addEventListener( MediaEvent.BUFFER_FULL, videoController_event );
			_mediaController.addEventListener( MediaEvent.PLAY, videoController_event );
			
			this.addEventListener( Event.ENTER_FRAME, enter_frame );
			
			//
			// BUILD controls based on desiredWidth
			//
			
			// BG
			//_bg.graphics.beginFill( BG_COLOR );
			//_bg.graphics.lineStyle(1, SEPARATOR_COLOR );
			//_bg.graphics.drawRoundRect( 0, -4, _desiredWidth-1, HEIGHT+8, 2 );
			//_bg.graphics.endFill();
			/*_bg.graphics.lineStyle( 1, SEPARATOR_COLOR, .5 );
			_bg.graphics.moveTo(0,0);
			_bg.graphics.lineTo( _desiredWidth, 0 );*/
			//addChild( _bg );
			
			
			// PLAY
			_playButton.graphics.beginFill( PROGRESS_COLOR );
			_playButton.graphics.drawRect( 0,0, HEIGHT / .8, HEIGHT );
			_playButton.graphics.endFill();
			_playButton.alpha = PROGRESS_ALPHA;
			
			_playButton.mouseChildren = _playButton.useHandCursor = _playButton.buttonMode = true;
			_playButton.addEventListener( MouseEvent.ROLL_OVER, button_roll_over );
			_playButton.addEventListener( MouseEvent.ROLL_OUT, button_roll_out );
			_playButton.addEventListener( MouseEvent.CLICK, playButton_click );
			_playButton.x = 0;
			addChild( _playButton );
			
			// PLAY CARAT
			_playCarat.graphics.beginFill( CONTROLS_COLOR );
			_playCarat.graphics.moveTo( -3, -3 );
			_playCarat.graphics.lineTo( 3, 0 );
			_playCarat.graphics.lineTo( -3, 3 );
			_playCarat.graphics.endFill();
			_playCarat.mouseEnabled = false;
			_playCarat.x = _playButton.x + (_playButton.width >> 1);
			_playCarat.y = _playButton.height >> 1;
			addChild ( _playCarat );
			
			// PAUSE ICON
			_pauseIcon.graphics.lineStyle( 2, CONTROLS_COLOR, 1, false, "normal", CapsStyle.SQUARE );
			_pauseIcon.graphics.moveTo( -2, -3 );
			_pauseIcon.graphics.lineTo( -2, 3 );
			_pauseIcon.graphics.moveTo( 2, -3 );
			_pauseIcon.graphics.lineTo( 2, 3 );
			_pauseIcon.mouseEnabled = false;
			_pauseIcon.x = _playCarat.x;
			_pauseIcon.y = _playCarat.y;
			_pauseIcon.visible = false;
			addChild( _pauseIcon );
			
			// GUIDE
			/*var guide:Sprite = new Sprite();
			guide.graphics.beginFill(0xFF0000);
			guide.graphics.drawRect( 0,0, desiredWidth, HEIGHT );
			guide.graphics.endFill();
			addChild( guide );
			guide.y = HEIGHT;*/
			
			
			// VOLUME SLIDER
			var volAreaWidth:Number = HEIGHT / .5;
			_volumeSlider = new VolumeSlider( volAreaWidth, HEIGHT,  PROGRESS_COLOR, GUTTER_COLOR, CONTROLS_COLOR, _mediaController );
			_volumeSlider.y = ( HEIGHT >> 1) - ( _volumeSlider.height >> 1 );
			_volumeSlider.x = _desiredWidth - volAreaWidth; // + ( (volAreaWidth - _volumeSlider.width) / 2 ) - 4; 
			addChild( _volumeSlider );
			
			_lineWidth = _desiredWidth - ( _playButton.width + volAreaWidth + 4 ); 
			var lineX:Number = _playButton.x + _playButton.width + 2;
			var lineY:Number = 0;// (HEIGHT >> 1);
			
			// GUTTER
			_gutter.graphics.beginFill( GUTTER_COLOR, GUTTER_ALPHA );
			_gutter.graphics.drawRect( 0, 0, _lineWidth, HEIGHT );
			_gutter.graphics.endFill();
			_gutter.x = lineX;
			addChild( _gutter );
			
			// BUFFER
			_buffer.graphics.beginFill( BUFFER_COLOR, BUFFER_ALPHA );
			_buffer.graphics.drawRect( 0, 0, _lineWidth, HEIGHT );
			_buffer.graphics.endFill(); 
			_buffer.x = lineX;
			addChild( _buffer );
			_buffer.scaleX = .001;
			
			// PROGRESS
			_progress.graphics.beginFill( PROGRESS_COLOR, PROGRESS_ALPHA );
			_progress.graphics.drawRect( 0, 0, _lineWidth, HEIGHT );
			_progress.graphics.endFill();
			_progress.mouseEnabled = false;
			_progress.x = lineX;
			addChild( _progress );
			_progress.scaleX = .001;
			
			
			_buffer.buttonMode = true;
			_buffer.addEventListener( MouseEvent.MOUSE_DOWN, _buffer_mouse_down );
		}
		
		
		// 
		// PRIVATE
		//
		private function setPosition( percent:Number ):void
		{
			if ( _mediaController.status == MediaStatus.STATUS_PLAYING )
			{
				_mediaController.play( percent );
			}
			else
			{
				_mediaController.play( percent );
				//_mediaController.pause();
			}
		}
		
		
		//
		// EVENT HANLDERS
		//
		private function enter_frame(e:Event):void
		{
			_buffer.scaleX = _mediaController.getPercentLoaded();
			_progress.scaleX = _mediaController.getPercentPlayed();
			
			isPlaying = ( _mediaController.status == MediaStatus.STATUS_PLAYING );
			
			if ( _isSeeking )
			{
				//var stagePoint:Point = new Point(stage.mouseX, stage.mouseY);
				//var localMouse:Point = globalToLocal( stagePoint );
				
				var p:Number = _buffer.mouseX / _lineWidth * _buffer.scaleX; // USE _buffer.scaleX to offset by percent loaded
				setPosition( p );
				
				//MonsterDebugger.trace( this, "percent: " + p );
				
			}
		}
		private function button_roll_over(e:MouseEvent):void
		{
			// TweenMax.to( e.currentTarget, .4, { alpha: 1 } );
		}
		private function button_roll_out(e:MouseEvent):void
		{
			// TweenMax.to( e.currentTarget, .4, { alpha: 0 } );
		}
		private function _buffer_mouse_down(e:MouseEvent):void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
			_isSeeking = true;
		}
		private function stage_mouse_up(e:MouseEvent):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
			_isSeeking = false;
			
		}
		private function fullscreen_click(e:MouseEvent):void
		{
//			var globalCoords:Point = _videoController.parent.localToGlobal( new Point( _videoController.x, _videoController.y ) );	
//			var rect:Rectangle = new Rectangle( globalCoords.x, globalCoords.y, _videoController.width-1, _videoController.height + this.height-2 );
//			
//			stage.fullScreenSourceRect = rect;


			if (stage.displayState == StageDisplayState.NORMAL)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;      		      		      
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
			
			
		}
		private function playButton_click(e:MouseEvent):void
		{
			if ( _mediaController.status != MediaStatus.STATUS_PAUSED && _mediaController.status != MediaStatus.STATUS_STOPPED )
			{
				_mediaController.pause();
				isPlaying = false;
			}
			else
			{
				if ( _mediaController.getPercentPlayed() > .99 ) _mediaController.play( 0 );
				_mediaController.resume();
				isPlaying = true;
			}
			dispatchEvent( new Event( MediaControls.PLAY_CLICKED ) );
			
		}
		private function videoController_event( e:Event ):void
		{
			
			switch ( e.type )
			{
				case MediaEvent.COMPLETE:
					
					_mediaController.pause();
					
				break;
				case MediaEvent.BUFFER_FULL:
				
				break;
				case MediaEvent.PLAY:
				
				break;
				case MediaEvent.METADATA:
				
				break;
			}
		
		}
		
		//
		// PUBLIC API
		// 
		public function set isPlaying( value:Boolean ):void
		{
			_isPlaying = value;
			
			_playCarat.visible = !_isPlaying;
			_pauseIcon.visible = _isPlaying;
			
		} 
	}

}