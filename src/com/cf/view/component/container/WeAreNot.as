package com.cf.view.component.container
{
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.component.list.WeAreNotList;
	import com.cf.view.component.shape.ShapeMinus;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;

	public class WeAreNot extends ContainerBase
	{
		
		
		public function WeAreNot()
		{
			state = STATE_MINIMIZED;
			url = Settings.URL_WE_ARE_NOT;
			super( ShapeMinus, WeAreNotList );
			
		}
		
		protected override function init():void
		{
			super.init();
			
			// INIT in minimized state
			_shape.collapse(); //scaleX = _shape.scaleY = Settings.SHAPE_MINIMIZED_SCALE; // SCALE
			
			// HIDE LINES for initial minimized state
			_opacityLines.alpha = 0;
		}
		
		
		//
		// OVERRIDES
		//
		override protected function setupBackground():void
		{
			// BG GRAD
			var matr:Matrix = new Matrix();
    		matr.createGradientBox( stage.stageWidth, stage.stageHeight, Utility.degreesToRadians( -90 ), 0, 0 );
			//_bg.addChild( new Bitmap( new BitmapData( stage.stageWidth, Settings.FIRST_LINE_HEIGHT + Settings.TILE_ROW_HEIGHT, false, Settings.WE_ARE_CROSS_BG ) ) );
			_background.graphics.beginGradientFill( GradientType.LINEAR, [ Settings.DARK_GRADIENT_START, Settings.DARK_GRADIENT_END ], [ 1, 1 ], [ 0, 255 ], matr, SpreadMethod.PAD );
			_background.graphics.drawRect(0,0, stage.stageWidth, stage.stageHeight );
			
			//_background.addChild( new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, Settings.WE_ARE_CROSS_BG)) );
			
			// STROKE
			_background.addChild( new Bitmap( new BitmapData( stage.stageWidth, 2, false, Settings.WE_ARE_NOT_STROKE )) );
			
		}
		public override function loadComplete():void
		{
			createTiles( false );
			
			// READY
			super.loadComplete();
		}
	}
}