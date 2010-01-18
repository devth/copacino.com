package com.cf.view.component.tile
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import flashpress.vo.WpPostWithTagAndCatVO;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	// TILE for surface-level posts
	public class Tile extends Component
	{
		protected var unwipeTime:Number	= 1.5;
		
		protected var title:String;
		protected var bg:Bitmap;
		protected var bgMask:Bitmap;
		
		protected var bgMouseOver:Bitmap;
		protected var bgMouseOverMask:Bitmap;
		
		protected var bgColor:uint = 0x000000; // bgColor is set when tiles are arranged, since color depends on the tile's location
		protected var titleText:TextField;
		protected var titleContainer:Sprite;
		
		protected var wipeDelay:Number = Math.random() * 2;
		protected var _wipeTime:Number = 3;
		
		protected var isMedium:Boolean = false;
		//protected const UNWIPE_TIME:Number = 1.5;
		
		protected var autoReveal:Boolean = true;
		
		protected var _tileData:WpPostWithTagAndCatVO;
		
		
		// SETTER bgColor
		public function set BgColor(value:uint):void
		{
			bgColor = value;
			
			var ct:ColorTransform = new ColorTransform();
			ct.color = bgColor;
			bg.bitmapData.colorTransform(new Rectangle(0,0,bg.width,bg.height), ct);
		}
		public function get BgColor():uint { return bgColor; }
		
		public function Tile(title:String, bgColor:uint=0x000000, autoReveal:Boolean=true, tileData:WpPostWithTagAndCatVO=null)
		{
			super();
			
			this.title = title;
			this._tileData = tileData;
			this.bgColor = bgColor;
			this.autoReveal = autoReveal;
			
			this.buttonMode = true;
		}
		
		
		// INIT
		protected override function init():void
		{
			super.init();
			
			this.mouseChildren = false;
			
			// TITLE container
			titleContainer = new Sprite();
			addChild(titleContainer);
			
			// TITLE
			titleText = TextFactory.TagText(title, isMedium);
			titleContainer.addChild(titleText);
			
			// SECOND TITLE
			var secondTitle:DisplayObject = TextFactory.TagText(title);
			titleContainer.addChild(secondTitle);
			titleContainer.mouseChildren = false;
			
			// BACKGROUND
			bg = new Bitmap(new BitmapData(titleText.width + Settings.TILE_TEXT_HORIZONTAL_MARGIN, Settings.TILE_HEIGHT, false, bgColor));
			bg.x = bg.y = 0;
			addChildAt(bg, 0);
			
			// MOUSE OVER background
			bgMouseOver = new Bitmap(new BitmapData(titleText.width + Settings.TILE_TEXT_HORIZONTAL_MARGIN, Settings.TILE_HEIGHT, false, 0x000000));
			bgMouseOver.x = bgMouseOver.y = 0;
			addChildAt(bgMouseOver,0);
			
			// MASKs
			bgMask = bgMouseOverMask = new Bitmap(bg.bitmapData.clone());
			addChild(bgMask);
			this.mask = bgMask;
			bgMask.width = 0;
			
			addChild(bgMouseOverMask);
			bgMouseOverMask.width = 0;
			//bgMouseOver.mask = bgMouseOverMask;
			
			
			// POSITION
			titleText.x = (bg.width >> 1) - (titleText.width >> 1);
			titleText.y = (bg.height >> 1) - (titleText.height >> 1);
			
			secondTitle.x = titleText.x;
			secondTitle.y = titleText.y - bg.height;
			
			
			// ANIMATE reveal
			if (autoReveal) wipe( wipeDelay );
			
			// MOUSE OVER
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		//
		// OVERRIDES
		//
		public override function get centerY():Number
		{
			return (y + (Settings.TILE_HEIGHT >> 1));
		}
		public override function set centerY(value:Number):void
		{
			this.y = value + (Settings.TILE_HEIGHT >> 1);
		}
		public override function get bottom():Number
		{
			return (y + (Settings.TILE_HEIGHT));
		}
		public override function set bottom(value:Number):void
		{
			this.y = (value - Settings.TILE_HEIGHT);
		}
		
		
		//
		// PROTECTED
		//
		protected function onMouseOver(e:MouseEvent):void
		{
			// CLEAN up
			TweenMax.killTweensOf(bg);
			TweenMax.killTweensOf(titleContainer);
			tweenBack = false;
			mouseReveal();
		}
		protected function checkTweenBack():void
		{
			if (tweenBack)
			{
				mouseUnReveal();
				tweenBack = false;
			}
		}
		protected var tweenBack:Boolean = false;
		protected function onMouseOut(e:MouseEvent):void
		{
			if (TweenMax.isTweening(bg))
			{
				tweenBack = true;
			}
			else mouseUnReveal();
		}
		
		
		protected function mouseReveal():void
		{
			TweenMax.to(titleContainer, 1, { y: ((bg.height >> 1) - (titleText.height >> 1)) + Settings.TILE_HEIGHT, ease:Strong.easeInOut });
			TweenMax.to(bg, 1, {width:0, ease:Strong.easeInOut, onComplete:checkTweenBack});
		}
		protected function mouseUnReveal():void
		{
			bg.x = bgMouseOver.width;
			TweenMax.to(bg, .4, {width:bgMouseOver.width, x:0, ease:Strong.easeInOut});
			
			TweenMax.to(titleContainer, 1, { y: ((bg.height >> 1) - (titleText.height >> 1)), ease:Strong.easeInOut })
		}
		
		
		//
		// PUBLIC API
		//
		public function get tileData():WpPostWithTagAndCatVO
		{
			return _tileData;
		}
		public function wipe( customDelay:Number = 0 ):void
		{
			TweenMax.killTweensOf( bgMask );
			this.visible = true;
			TweenMax.to(bgMask, _wipeTime, {width:bgMouseOver.width, ease:Strong.easeInOut, delay: customDelay });
		}
		public function unWipe( newUnwipeTime:Number = -1):void
		{
			if ( newUnwipeTime > 0 ) unwipeTime = newUnwipeTime;
			
			TweenMax.killTweensOf( bgMask );
			TweenMax.to(bgMask, unwipeTime, {width:0, ease:Strong.easeInOut, onComplete: function():void {
				this.visible = false;
			}});
		}
		public function get TitleContainer():Sprite
		{
			return titleContainer;
		}
		public override function toString():String
		{
			return this.title;
		}
		public function get background():Bitmap
		{
			return bg;
		}
		
		public function set wipeTime( time:Number ):void
		{
			_wipeTime = time;
		}
		
		// OPENS the tile without animation
		public function open():void
		{
			this.bgMask.width = bgMouseOver.width;
		}
		
	}
}