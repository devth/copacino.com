package com.cf.view.component.shape
{
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextField;

	public class ShapeMinus extends ShapeBase
	{
		private var barHorz:Bitmap
		private var copy:TextField;
		
		
		public function ShapeMinus()
		{
			name = "shapeMinus";
			url = Settings.URL_WE_ARE_NOT;
			super();
			
			state = STATE_COLLAPSED;
			
			_saturationOffset = 0;
		}
		
		
		//
		// OVERRIDES
		//
		protected override function init():void
		{
			super.init();
		}
		protected override function createShape():void
		{
			// BAR
			barHorz = new Bitmap(new BitmapData(Settings.BAR_WIDTH, Settings.BAR_HEIGHT, false, Settings.WE_ARE_NOT_BG));
			_shapeContainer.addChild(barHorz);
			
			// POSITION
			barHorz.x = -(Settings.BAR_WIDTH >> 1);
			barHorz.y = -(Settings.BAR_HEIGHT >> 1);
			
			// 
			/*var smallLength:Number = (4 * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
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
			_shapeSmall.addChild( title );*/
			
			// SMALL SHAPE
			var leftOffset:Number = 25;
			var smallLength:Number = (4 * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
			var startCoord:Number = (smallLength >> 1) + leftOffset; //  - (Settings.TILE_HEIGHT >> 1);
			var halfHeight:Number = Settings.TILE_HEIGHT >> 1;
			
			_shapeSmall.graphics.beginFill( Settings.WE_ARE_NOT_BG );
			_shapeSmall.graphics.drawRect( -startCoord, -halfHeight, smallLength, Settings.TILE_HEIGHT ); // HORZ
			_shapeSmall.graphics.endFill();
			// VERT space to make dimensions consistent
			_shapeSmall.graphics.beginFill( 0x000000, 0 );
			_shapeSmall.graphics.drawRect( -halfHeight, -startCoord, Settings.TILE_HEIGHT, smallLength ); // VERT
			_shapeSmall.graphics.endFill();
			
			// TRANSPARENT end-cap to make it symetrical
			_shapeSmall.graphics.beginFill( 0x0000FF, 0 );
			_shapeSmall.graphics.drawRect( (smallLength >> 1) - leftOffset, -halfHeight, leftOffset, Settings.TILE_HEIGHT );
			_shapeSmall.graphics.endFill(); 
			
			// SMALL SHAPE MASK
			/*var shapeMask:Sprite = new Sprite();
			//shapeMask.name = "shapeMask";
			shapeMask.addChild( Utility.getMaskShape( _shapeSmall.width, _shapeSmall.height ) );
			shapeMask.x = -startCoord;
			shapeMask.y = -star*/
			
			var title:TextField = TextFactory.TagText( "we are not" );
			title.y = ( Settings.TILE_HEIGHT >> 1) - (title.height >> 1) - halfHeight;
			title.x = 5 - startCoord;
			_shapeSmall.addChild( title );
		}
		protected override function initMinMaxValues():void
		{
			// (hack - add the copy now)
			// COPY
			_copyContainer.mouseEnabled = _copyContainer.mouseChildren = false;
			copy = TextFactory.MainLargeText("we are not");
			_copyContainer.addChild(copy);
			
			copy.x = barHorz.x + ((barHorz.width >> 1) - (copy.width >> 1));
			copy.y = barHorz.y + ((barHorz.height >> 1) - (copy.height >> 1) - 2);
			
			//
			// INIT min/max values to accomidate MINUS shape
			//
			
			// WIDE
			for (var i1:int = -2; i1 < 2; i1++)
			{
				// MIN
				minXForRows[i1] = originPoint.x - (Settings.BAR_WIDTH >> 1) - (Settings.TILE_MARGIN);
				// MAX
				maxXForRows[i1] = originPoint.x + (Settings.BAR_WIDTH >> 1) + (Settings.TILE_MARGIN) + 1;
			}
			
		}
		
	}
}