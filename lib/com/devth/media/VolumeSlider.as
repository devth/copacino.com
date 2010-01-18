package com.devth.media
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class VolumeSlider extends Sprite
	{
		// SLIDER SETTINGS
		private var barWidth:Number 	= 3;
		private var barMargin:Number	= 2;
		
		
		// PRIVATE MEMBERS
		private var _bgColor:uint;
		private var _fgColor:uint;
		private var _gutterColor:uint;
		private var _mediaController	:IMediaController;
		private var _desiredWidth:Number;
		private var _desiredHeight:Number;
		
		private var _gutter:Sprite = new Sprite();
		private var _fg:Sprite = new Sprite();
		private var _bg:Sprite = new Sprite();
		private var _hitArea:Sprite = new Sprite();
		private var _fgMask:Sprite = new Sprite();
		
		
		public function VolumeSlider( desiredWidth:Number, desiredHeight:Number, bgColor:uint, gutterColor:uint, fgColor:uint, mediaController: IMediaController )
		{
			super();
			
			_bgColor = bgColor;
			_fgColor = fgColor;
			_mediaController = mediaController;
			_desiredWidth = desiredWidth;
			_desiredHeight = desiredHeight;
			
			var _controlHeight:Number = _desiredHeight * .6;
			var _controlWidth:Number = _desiredWidth * .7;
			
			
			var barTick:Number = barWidth + barMargin;
			var maxIndex:Number = ( _controlWidth / (barWidth + barMargin) );
			
			// BG
			_bg.graphics.beginFill( _bgColor );
			_bg.graphics.drawRect( 0, 0, desiredWidth, desiredHeight );
			_bg.graphics.endFill();
			addChild( _bg );
			
			// GUTTER + FOREGROUND loop
			for (var i:int = 0; i < maxIndex; i++)
			{
				var percentAcross:Number = .1 + ( i / maxIndex );
				
				// GUTTER
				_gutter.graphics.beginFill( _gutterColor );
				_gutter.graphics.drawRect( i * barTick, _controlHeight, barWidth, -(_controlHeight * percentAcross) );
				_gutter.graphics.endFill();
			
				// FG
				_fg.graphics.beginFill( _fgColor );
				_fg.graphics.drawRect( i * barTick, _controlHeight, barWidth, -(_controlHeight * percentAcross) );
				_fg.graphics.endFill();
			}
			
			
			// FG MASK
			_fgMask.graphics.beginFill( 0x000000 );
			_fgMask.graphics.drawRect( 0, 0, _desiredWidth, _controlHeight );
			_fgMask.graphics.endFill(); 
			
			
			// POSITION
			_gutter.y = _fg.y = _fgMask.y = ( _desiredHeight - _controlHeight ) >> 1;
			_gutter.x = _fg.x = _fgMask.x = ( _desiredWidth - _controlWidth ) >> 1;
			
			// ADD
			addChild( _gutter );
			addChild( _fg );
			addChild( _fgMask );
			
			// HIT AREA
			_hitArea.graphics.beginFill( _bgColor, 0 );
			_hitArea.graphics.drawRect( -10,-5, _controlWidth + 20, _controlHeight + 10 );
			_hitArea.graphics.endFill();
			addChild( _hitArea );
			
			this.hitArea = _hitArea;
			
			
			_fg.mask = _fgMask;
			
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouse_down );
			
		}
		
		//
		// OVERRIDES
		// 
		override public function get width():Number { return _desiredWidth; }
		override public function get height():Number { return _desiredHeight; }
		
		//
		// PRIVATE
		//
		private function setVolume(volPercent:Number):void
		{
			_mediaController.setVolume( volPercent );
		}
		
		//
		// EVENT HANLDERS
		//
		private function mouse_down(e:MouseEvent):void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, mouse_up );
			this.addEventListener( Event.ENTER_FRAME, enter_frame );
		}
		private function mouse_up(e:MouseEvent):void
		{
			this.removeEventListener( Event.ENTER_FRAME, enter_frame ); 
		}
		private function enter_frame(e:Event):void
		{
			var stagePoint:Point = new Point( stage.mouseX, stage.mouseY );
			var localPoint:Point = globalToLocal( stagePoint );
			
			// ADJUST VOLUME
			_fgMask.width = Math.max( 0, Math.min( _desiredWidth, localPoint.x ) );
			
			setVolume( _fgMask.width / _desiredWidth );
		}
		
		
		//
		// PUBLIC API
		//
		public function get desiredWidth():Number { return _desiredWidth; }
		
		
	}

}