package com.cf.view.component.scrollbar
{
	import com.cf.util.AssetManager;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Scrollbar extends Component
	{
		// ORIENTATION
		public static const ORIENTATION_VERTICAL	:String		= "orientation/vertical";
		public static const ORIENTATION_HORIZONTAL	:String 	= "orientation/horizontal";
		
		// EVENTS
		public static const SCROLLBAR_START		:String		= "event/scrollbar/start";
		public static const SCROLLBAR_STOP		:String		= "event/scrollbar/stop";
		public static const SCROLLBAR_UPDATE	:String		= "event/scrollbar/update";
		
		
		// CONST
		private static const BG_DARK:uint		= 0x222222;
		private static const BG_LIGHT:uint		= 0x404040; // 0x2c2d31;
		
		private static const BAR_DARK:uint		= 0x494949; // 0x3c3c3c;
		private static const BAR_LIGHT:uint		= 0x666666; // 
		
		// PRIVATE
		private var _fgColor		:uint;
		private var _bgColor		:uint;
		private var _height			:int;
		private var _width			:int;
		private var _contentRatio	:Number;
		private var _orientaion		:String;
		
		private var _length			:Number;
		private var _thickness		:Number;
		
		// VISUAL
		private var _track:Sprite;
		private var _bar:Sprite;
		
		private var _caretTop:Sprite;
		private var _caretBottom:Sprite;
		
		
		public function Scrollbar( width:int, height:int, orientation:String = ORIENTATION_VERTICAL, contentRatio:Number = .3, fgColor:uint = 0xFFFFFF, bgColor:uint = 0x000000 )
		{
			super();
			_fgColor = fgColor;
			_bgColor = bgColor;
			_contentRatio = contentRatio;
			_orientaion = orientation;

			this.width = width;
			this.height = height;
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			
			// TRACK
			_track = new Sprite();
			addChild( _track );
			
			var matrBg:Matrix = new Matrix();
			matrBg.createGradientBox( _thickness, _length, Utility.degreesToRadians( 0 ), 0, 0 );
			_track.graphics.beginGradientFill( GradientType.LINEAR, [ BG_DARK, BG_LIGHT ],
				[1, 1], [90, 255], matrBg, SpreadMethod.PAD );
			_track.graphics.drawRect(0, 0, _thickness, _length );
			_track.graphics.endFill();
			_track.addEventListener( MouseEvent.MOUSE_DOWN, track_mouse_down );
			
			// BAR
			_bar = new Sprite();
			addChild( _bar );
			
			var matrBar:Matrix = new Matrix();
			matrBar.createGradientBox( _thickness, _length, Utility.degreesToRadians( 0 ), 0, 0 );
			_bar.graphics.beginGradientFill( GradientType.LINEAR, [ BAR_DARK + 0x222222, BAR_LIGHT, BAR_DARK ],
				[1, 1, 1], [0, 60, 255], matrBar, SpreadMethod.PAD );
			_bar.graphics.drawRect(0, 0, _thickness, _length * _contentRatio);
			_bar.graphics.endFill();
			_bar.buttonMode = _bar.useHandCursor = true;
			_bar.y = _minY;
			
			// INVISIBLE hit area
			_bar.graphics.beginFill( _fgColor, 0 );
			_bar.graphics.drawRect( -_thickness, 0, _thickness * 3, _bar.height );
			_bar.graphics.endFill();
			
			_bar.addEventListener( MouseEvent.MOUSE_DOWN, bar_mouse_down );
			
			// CARET
			_caretTop = buildCaret( );
			_caretTop.rotation = -90;
			_caretTop.y = _thickness;
			addChild( _caretTop );
			_caretTop.addEventListener( MouseEvent.MOUSE_DOWN, caretTop_mouse_down );
			
			_caretBottom = buildCaret();
			_caretBottom.rotation = 90;
			_caretBottom.scaleY = -1;
			addChild( _caretBottom );
			_caretBottom.y = _length - _thickness;
			_caretBottom.addEventListener( MouseEvent.MOUSE_DOWN, caretBottom_mouse_down );
			
			// HANDLE ORIENTATION change
			if ( _orientaion == ORIENTATION_HORIZONTAL )
			{
				this.rotation = -90;
				this.scaleX = -1;
			}
			
			super.init();
		}
		
		//
		// EVENT HANDLERS
		//
		private function track_mouse_down(e:MouseEvent):void
		{
			// SNAP middle of scroll bar to point
			_bar.y = Utility.boundNumber( (e.localY - (_bar.height >> 1)), _minY, _maxY );
			dispatchUpdate();
		}
		private function bar_mouse_down(e:MouseEvent):void
		{
			dispatchEvent( new Event( SCROLLBAR_START ) );
			_bar.startDrag(false, new Rectangle(0, _minY, 0, _maxY - _minY));
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
		}
		private function stage_mouse_up(e:MouseEvent):void
		{
			dispatchEvent( new Event( SCROLLBAR_STOP ) );
			_bar.stopDrag();
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
		}
		private function caretTop_mouse_down(e:MouseEvent):void
		{
			scrollByDelta( 2 );
		}
		private function caretBottom_mouse_down(e:MouseEvent):void
		{
			scrollByDelta( -2 );
		}
		
		//
		// PRIVATE
		//
		private function get _maxY():Number
		{
			return _length - _bar.height - (_thickness);
		}
		private function get _minY():Number
		{
			return _thickness;
		}
		private function buildCaret():Sprite
		{
			var caret:Sprite = new Sprite();
			caret.graphics.beginFill(0x000000, 0);
			caret.graphics.drawRect( 0, 0, _thickness, _thickness );
			caret.graphics.endFill();
			
			var b:Bitmap = new Bitmap( AssetManager.InitLoader.getBitmapData( Settings.ASSET_CARET ) );
			b.x = (caret.width >> 1) - (b.width >> 1);
			b.y = (caret.height >> 1) - (b.height >> 1);
			caret.addChild( b );
			TweenMax.to( b, .2, { tint: 0x585858 });
			
			caret.buttonMode = caret.useHandCursor = true;
			
			return caret;
		}
		private function dispatchUpdate():void
		{
			// POSITION CHANGED so send an update
			dispatchEvent( new Event( SCROLLBAR_UPDATE ) );
		}
		private function set length( value:Number ):void
		{
			_length = value;
			if ( _isInitialized )
			{
				_track.height = _length; // _height = 
				_caretBottom.y = _length - _thickness;
			
				if ( _bar.y > _maxY )
				{
					_bar.y = Utility.boundNumber( _maxY, _minY, _maxY );
					dispatchUpdate();
				}
			}
		}
		private function get length():Number { return _length; }
		private function set thickness( value:Number ):void
		{
			_thickness = value;
		}
		private function get thickness():Number { return _thickness; }
		
		
		//
		// PUBLIC API
		//
		public function scrollByDelta( delta:Number ):void
		{
			_bar.y = Utility.boundNumber( _bar.y - delta * 10, _minY, _maxY );
			dispatchUpdate();
		}
		public function get percentScrolled():Number
		{
			return (_bar.y - _minY) / (_maxY - _minY);
		}
		public function set percentScrolled( p:Number ):void
		{
			// TWEEN it
			var toY:Number = _minY + (p * (_maxY - _minY));
			TweenLite.to( _bar, .6, { ease: Strong.easeOut, y: toY });
		}
		public function set contentRatio( r:Number ):void
		{
				_contentRatio = r;
				_bar.height = _length * _contentRatio;
		}
		
		//
		// PUBLIC OVERRIDES
		//
		public override function set height(value:Number) : void
		{
			if ( _orientaion == ORIENTATION_HORIZONTAL ) thickness = value;
			else length = value;
		}
		public override function get height() : Number
		{
			if ( _orientaion == ORIENTATION_HORIZONTAL ) return thickness;
			else return length;
		}
		public override function set width(value:Number) : void
		{
			if ( _orientaion == ORIENTATION_HORIZONTAL ) length = value;
			else thickness = value;
		}
		public override function get width() : Number
		{
			if ( _orientaion == ORIENTATION_HORIZONTAL ) return length;
			else return thickness;
		}
	}
}