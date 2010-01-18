package com.cf.view.component
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class OpacityLines extends Component
	{
		public static const LINES_INIT:String	 = "linesInit";
		
		private var currentMinHeight:Number;
		private var currentI:Number = 0;
		
		private var linesAreInitialized:Boolean = false;
		private var first:Boolean = true;
		
		private var _color:uint = Settings.LINE_COLOR;
		
		public function OpacityLines( color:uint = 0 )
		{
			super();
			if ( color > 0 ) _color = _color;
		}
		
		protected override function init():void
		{
			// init a min height
			currentMinHeight = Utility.roundUpToEvenInt( stage.stageHeight / Settings.TILE_HEIGHT );
			createOpacityLines();
		}
		
		private function createOpacityLines():void
		{
			for (currentI = currentI; currentI < currentMinHeight; currentI++)
			{
				var b:Bitmap = getOpacityLine();
				addChild(b);
				b.y = (currentI * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN)) - (Settings.TILE_HEIGHT + Settings.TILE_MARGIN - Settings.FIRST_LINE_HEIGHT);
				
				// HIDE the first line
				if (first)
				{
					b.visible = false;
					first = false;
				}
			}
		}
		
		/*private function getOpacityLine():Bitmap
		{
			var b:Bitmap = new Bitmap(new BitmapData(1, Settings.TILE_HEIGHT, false, Settings.LINE_COLOR));
			b.alpha = Settings.LINE_OPACITY;
			if (linesAreInitialized) b.width = stage.stageWidth;
			return b;
		}*/
		private function getOpacityLine():Bitmap
		{
			var b:Bitmap = new Bitmap(new BitmapData(1, 1, false, _color));
			b.alpha = Settings.LINE_OPACITY;
			if (linesAreInitialized) b.width = stage.stageWidth;
			return b;
		}
		
		private function tween_complete(index:uint):void
		{
			if (index == (this.numChildren - 1)) { dispatchEvent(new Event(LINES_INIT)); linesAreInitialized = true; }
		}
		
		//
		// PUBLIC API
		//
		public function setMinHeight(h:Number):void
		{
			currentMinHeight = Utility.roundUpToEvenInt( h / Settings.TILE_HEIGHT );
			createOpacityLines();
		}
		public function setWidth(w:Number):void
		{
			for (var i:uint = 0; i < this.numChildren; i++)
			{
				var d:DisplayObject = this.getChildAt(i);
				d.width = w;
			}
		}
		public function initLines():void
		{
			for (var i:uint = 0; i < this.numChildren; i++)
			{
				var d:DisplayObject = this.getChildAt(i);
				TweenMax.to(d, 2, { width:stage.stageWidth, ease:Strong.easeInOut, delay: i * .02, onComplete:tween_complete, onCompleteParams:[i] });
			}
		}
		
		
		
	}
}