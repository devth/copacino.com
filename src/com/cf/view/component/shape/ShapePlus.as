package com.cf.view.component.shape
{
	import com.cf.model.event.StateEvent;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.view.component.TitleTextSwipe;
	import com.cf.view.component.WeArePlusCopy;
	import com.cf.view.component.tile.TileLoader;
	import com.cf.view.event.UIEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextField;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class ShapePlus extends ShapeBase
	{
		public static const UIEVENT_SITE_READY:String		= "uievent/site/ready";
		
		protected var barVert:Bitmap;
		protected var barHorz:Bitmap;

		private var _weAreCopy:WeArePlusCopy;
		
		
		public function ShapePlus()
		{
			name = "shapePlus";
			url = Settings.URL_WE_ARE;
			super();
			
			state = STATE_EXPANDED;
		}
			
		//
		// OVERRIDES
		//
		protected override function init():void
		{			
			super.init();
			
			// REVEAL
			reveal();
			
		}
		protected override function createShape():void
		{
			// CREATE bars
			barHorz = new Bitmap(new BitmapData(Settings.BAR_WIDTH, Settings.BAR_HEIGHT, false, Settings.WE_ARE_CROSS_BG));
			barVert = new Bitmap(new BitmapData(Settings.BAR_WIDTH, Settings.BAR_HEIGHT, false, Settings.WE_ARE_CROSS_BG));
			barVert.rotation = 90;
			
			_shapeContainer.addChild(barHorz);
			_shapeContainer.addChild(barVert);
			
			// POSITION bars, centered over 0,0
			barHorz.x = -(Settings.BAR_WIDTH >> 1);
			barHorz.y = -(Settings.BAR_HEIGHT >> 1);
			
			barVert.x = (Settings.BAR_HEIGHT >> 1);
			barVert.y = -(Settings.BAR_WIDTH >> 1);
			
			//barVert.x = (Settings.BAR_WIDTH >> 1) + (Settings.BAR_HEIGHT >> 1);
			//barHorz.y = (Settings.BAR_WIDTH >> 1) - (Settings.BAR_HEIGHT >> 1);
			
			// SMALL SHAPE - draw but don't add.  ListTiles will add to themselves later on
			var smallLength:Number = (4 * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
			var startCoord:Number = (smallLength >> 1); //  - (Settings.TILE_HEIGHT >> 1);
			var halfHeight:Number = Settings.TILE_HEIGHT >> 1;
			
			_shapeSmall.graphics.beginFill( Settings.WE_ARE_CROSS_BG );
			_shapeSmall.graphics.drawRect( -startCoord, -halfHeight, smallLength, Settings.TILE_HEIGHT ); // HORZ
			_shapeSmall.graphics.endFill();
			_shapeSmall.graphics.beginFill( Settings.WE_ARE_CROSS_BG );
			_shapeSmall.graphics.drawRect( -halfHeight, -startCoord, Settings.TILE_HEIGHT, smallLength ); // VERT
			_shapeSmall.graphics.endFill();
			
			var title:TextField = TextFactory.TagText( "we are" );
			title.y = ( Settings.TILE_HEIGHT >> 1) - (title.height >> 1) - halfHeight - 1;
			title.x = 5 - startCoord;
			title.name = "shapeTitle";
			_shapeSmall.addChild( title );
			
		}
		override protected function initMinMaxValues():void
		{
			//
			// INIT min/max values to accomidate PLUS shape
			//
			
			// WIDE
			for (var i1:int = -2; i1 < 2; i1++)
			{
				// MIN
				minXForRows[i1] = originPoint.x - (Settings.BAR_WIDTH >> 1) - (Settings.TILE_MARGIN);
				// MAX
				maxXForRows[i1] = originPoint.x + (Settings.BAR_WIDTH >> 1) + (Settings.TILE_MARGIN) + 1;
			}
			// THIN
			for (var i2:int = 2; i2 < 8; i2++)
			{
				// MIN
				minXForRows[i2] = minXForRows[-(i2+1)] = originPoint.x - (Settings.BAR_HEIGHT >> 1) - (Settings.TILE_MARGIN) - 1;
				// MAX
				maxXForRows[i2] = maxXForRows[-(i2+1)] = originPoint.x + (Settings.BAR_HEIGHT >> 1) + (Settings.TILE_MARGIN);
			}
			
		}
		override protected function state_changed(e:StateEvent):void
		{
			if (_weAreCopy == null) return;
			
			if (state == STATE_EXPANDED) _weAreCopy.isRollEnabled = true;
			else _weAreCopy.isRollEnabled = false;
			
		}
		override public function collapseList():void
		{
			super.collapseList();
			
			if ( _weAreCopy == null ) return;
			
			TweenMax.to(_copyContainer, 1.2, { delay:1, ease:Strong.easeOut,
				x: 7 + (-(Settings.BAR_WIDTH >> 1) * Settings.SHAPE_MINIMIZED_SCALE) + ( Settings.SHAPE_MINIMIZED_SCALE * (_weAreCopy.weAreText.width >> 1))
			});
			
			// state = STATE_LIST_COLLAPSED;
		}
		override public function expand(delay:Number=0) : void
		{
			super.expand( delay );
			
			TweenMax.to(_copyContainer, 1.2, { delay:1, ease:Strong.easeOut,
				x: 0
			}); // 7 + (-(Settings.BAR_WIDTH >> 1) * Settings.SHAPE_MINIMIZED_SCALE) + ( Settings.SHAPE_MINIMIZED_SCALE * (_weAreCopy.weAreText.width >> 1))
		}
		
		//
		// TITLE TEXT : replaces current title copy and reveals, while de-revealing the old copy
		//
		public function titleOverlay(text:String, color:uint=0xFFFFFF):void
		{
			if (currentTitle != null) currentTitle.unWipe();
			
			// CREATE
			currentTitle = new TitleTextSwipe(text, color);
			_copyContainer.addChild(currentTitle);
			
			// POSITION
			currentTitle.centerX = originPoint.x;
			currentTitle.centerY = originPoint.y - 2;
			
			// WIPE
			currentTitle.wipe();
		}
		private function tweenTitleColorTo(color:uint):void
		{
			titleOverlay("loading...", color);
		}
		
		public function getTitleMask():Bitmap
		{
			var b:Bitmap = new Bitmap(new BitmapData(100,100,false, 0x000000));
			
			b.width = title.width;
			b.height = title.height;
			b.x = title.x;
			b.y = title.y;
			b.mask = title;
			
			return b;
		}
		
		
		
		//
		// HANDLES specialized loading utility
		// plus shape is visible when site begins loading
		//
		public function addLoadingTile(percent:Number):void
		{
			// CREATE tile
			//trace(this, percent);
			var tile:TileLoader = new TileLoader((int(percent)).toString());
			_tileContainer.addChild(tile);
			
			// POSITION tile randomly
			var currentHorzPos:Number = -1 + (Math.random() * 2);
			var currentVertPos:Number = int((-Settings.MAX_VERTICAL_LINES_FROM_CENTER) + (Math.random() * 2 * Settings.MAX_VERTICAL_LINES_FROM_CENTER));
			
			
			// X
			if (currentHorzPos < 0) // left of center
			{
				// DEFAULT if null
				if (minXForRows[currentVertPos] == undefined) minXForRows[currentVertPos] = originPoint.x - 1;
				// POSITION as far left as possible
				tile.right = minXForRows[currentVertPos] - (Math.random() * 200);
				// SUBTRACT width to the min
				minXForRows[currentVertPos] -= (tile.width + Settings.TILE_MARGIN + getRandomSpacer(currentVertPos));
			}
			else if (currentHorzPos > 0) // right of center
			{
				// DEFAULT if null
				if (maxXForRows[currentVertPos] == undefined) maxXForRows[currentVertPos] = originPoint.x;
				// POSITION as far right as possible
				tile.left = maxXForRows[currentVertPos] + (Math.random() * 200);
				// ADD width to the max
				maxXForRows[currentVertPos] += (tile.width + Settings.TILE_MARGIN + getRandomSpacer(currentVertPos));
			}
			
			// Y
			tile.bottom = originPoint.y - (currentVertPos * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
			
			// COLOR
			var color:uint = getTileColor(tile); 
			tile.BgColor = color;
			tweenTitleColorTo(color);
		}
		
		
		//
		// PUBLIC API
		//
		public function load_complete():void
		{
			// UNWIPE the last "loading..."
			if (currentTitle) currentTitle.unWipe();
			
			// ADD we are copy
			_weAreCopy = new WeArePlusCopy();
			_copyContainer.addChild(_weAreCopy);
			_weAreCopy.centerX = originPoint.x;
			_weAreCopy.centerY = originPoint.y - 2;
			
			dispatchEvent( new UIEvent( UIEVENT_SITE_READY, "shapePlus" ) );
			
		}
		
	}
}