package com.cf.view.component
{
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class PianoKeyMask extends Mask implements IMask
	{
		public static const MASK_DRAWN:String		= "maskDrawn";
		
		private var linesAreInitialized:Boolean = false;
		//private var desiredWidth:Number = 0;
		//private var desiredHeight:Number = 0;
		
		private var currentI:Number = 0;
		
		private var currentMinHeight:Number = 0;
		
		
		public function PianoKeyMask(dW:Number, dH:Number)
		{
			desiredWidth = dW;
			desiredHeight = dH;
			
			super();
		}
		
		protected override function init():void
		{
			// draw() is called by setDesiredSize
		}
		
		
		
		private function draw():void
		{
			//Utility.debug(this, "draw");
			currentMinHeight = Utility.roundUpToEvenInt( desiredHeight / (Settings.TILE_HEIGHT + Settings.TILE_MARGIN) ) + 1;
			
			for (currentI = currentI; currentI < currentMinHeight; currentI++)
			{
				var b:Bitmap = getLine();
				b.width = 0;
				addChild(b);
				b.y = (currentI * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
			}
			
		}
		
		private function getLine():Bitmap
		{
			var b:Bitmap = new Bitmap(new BitmapData(1, (Settings.TILE_HEIGHT + Settings.TILE_MARGIN), false, 0x000000));
			if (linesAreInitialized) b.width = desiredWidth;
			return b;
		}
		
		private function tween_complete(index:uint):void
		{
			if (index == (this.numChildren - 1)) { dispatchEvent(new Event(MASK_DRAWN)); linesAreInitialized = true; }
		}
		
		//
		// PUBLIC API
		//
		override public function reveal():void
		{
			//Utility.debug(this, "reveal?!", desiredWidth, this.numChildren);
			
			for (var i:uint = 0; i < this.numChildren; i++)
			{
				var d:DisplayObject = this.getChildAt(i);
				TweenMax.to(d, 2, { width:desiredWidth, ease:Strong.easeInOut, delay: i * .02, onComplete:tween_complete, onCompleteParams:[i] });
			}
		}
		override public function hide():void
		{
			// meh
		}
		
		public function setDesiredSize(dW:Number, dH:Number):void
		{
			desiredWidth = dW;
			desiredHeight = dH;
			
			for (var i:uint = 0; i < this.numChildren; i++)
			{
				this.getChildAt(i).width = desiredWidth;
			}
			
			draw();
		}
		
		
	}
}