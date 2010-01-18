package com.cf.view.component.tile
{
	import com.cf.util.Settings;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class TileLoader extends Tile
	{
		
		
		private var decimalTimer:Timer;
		private var originalTitle:String;
		
		private var currentDecimal:Number = 0;
		
		public function TileLoader(title:String, bgColor:uint=0x000000)
		{
			unwipeTime = 3;
			
			originalTitle = title;
			if (title == "100") currentDecimal = 0; 
			else
			{
				currentDecimal = int( 10 + (Math.random() * 90));
				// decimal flicker timer
				decimalTimer = new Timer(30);
				decimalTimer.addEventListener(TimerEvent.TIMER, decimalTimer_timer);
				decimalTimer.start();
			}
			super(title + ".0" + currentDecimal, bgColor);
			
			
			
			wipeDelay = 0;
			unwipeTime = 1;
			_wipeTime = Settings.LOAD_TILE_WIPE_TIME;
			
			TweenMax.to(this, 2, { onComplete:this.unWipe });
			
			this.buttonMode = false;
		}
		
		
		private function decimalTimer_timer(e:TimerEvent):void
		{
			//Utility.debug(title, int(currentDecimal));
			currentDecimal += 2; //(5 * Math.random());
			titleText.text = originalTitle + "." + int(currentDecimal).toString();
		}
		
		
		protected override function onMouseOver(e:MouseEvent):void
		{
			// do nothing
		}
		
		protected override function onMouseOut(e:MouseEvent):void
		{
			// do nothing
		}
		
		
		public override function unWipe( newUnwipeTime:Number=-1):void
		{
			TweenMax.to(bgMask, unwipeTime, {width:0, x:this.width, ease:Strong.easeInOut, onComplete:stopTimer });
		}
		
		private function stopTimer():void
		{
			if (decimalTimer != null) decimalTimer.stop();
		}
		
	}
}