package com.cf.view.component
{
	import com.cf.util.AssetManager;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.util.Utility;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class WeArePlusCopy extends Component
	{
		private var _isRollEnabled:Boolean = true;
		
		public var logo:Bitmap;
		public var weAreText:TitleTextSwipe;
		
		private var textContainer:Sprite;
		private var textMask:Bitmap;
		
		private var rollTimer:Timer;
		private var termIndex:Number = 0;
		
		public function WeArePlusCopy()
		{
			super();
		}
		
		override protected function init():void
		{
			// CONTAINER
			textContainer = new Sprite();
			addChild(textContainer);
			
			// MASK
			textMask = Utility.getMaskShape(Settings.BAR_WIDTH, Settings.BAR_HEIGHT);
			addChild(textMask);
			this.mask = textMask;
			
			// WE ARE
			weAreText = new TitleTextSwipe("we are");
			textContainer.addChild(weAreText);
			weAreText.wipe();
			
			// POSITION
			weAreText.centerX = textMask.width >> 1;
			weAreText.centerY = textMask.height >> 1;
			
			// LOOP
			for (var i:int = 0; i < Settings.WE_ARE_TERMS.length; i++)
			{
				var term:String = Settings.WE_ARE_TERMS[i];
				var color:uint = Settings.WE_ARE_TERMS_COLORS[i];
				
				// TERM TEXT
				var termText:TextField = TextFactory.MainLargeText(term);
				termText.textColor = color;
				textContainer.addChild(termText);
				
				// POSITION
				if (termText.width > Settings.BAR_WIDTH) termText.width = Settings.BAR_WIDTH - 10;
				termText.x = weAreText.centerX - (termText.width >> 1);
				termText.y = (weAreText.centerY - (termText.height >> 1)) - ((i+1) * Settings.BAR_HEIGHT);
			}
			
			// LOGO
			logo = AssetManager.InitLoader.getBitmap( Settings.ASSET_LOGO_LIGHT );
			textContainer.addChild( logo );
			logo.x = weAreText.centerX - (logo.width >> 1);
			logo.y = (weAreText.centerY - (logo.height >> 1)) - ((i+1) * Settings.BAR_HEIGHT) + 4;
			
			// EVENT WIRING
			this.addEventListener(MouseEvent.ROLL_OVER, mouse_over);
			this.addEventListener(MouseEvent.ROLL_OUT, mouse_out);
			
			// ROLL TIMER
			rollTimer = new Timer(Settings.WE_ARE_ROLL_INTERVAL);
			rollTimer.addEventListener(TimerEvent.TIMER, rollTimer_timer);
		}
		
		//
		// EVENT HANLDERS
		//
		private function rollTimer_timer(e:TimerEvent=null):void
		{
			if (termIndex == (Settings.WE_ARE_TERMS.length + 1))
			{
				rollTimer.stop();
				TweenMax.to(textContainer, 1, { delay:3, ease: Strong.easeOut, y: 0 });
			}
			else TweenMax.to(textContainer, 1, { ease: Strong.easeOut, y: (termIndex + 1) * Settings.BAR_HEIGHT });
			termIndex++;
		}
		private function mouse_over(e:MouseEvent):void
		{
			if (!rollTimer.running && _isRollEnabled)
			{
				termIndex = 0;
				//rollTimer_timer(); // HIT it immediately
				rollTimer.start();
			}
		}
		private function mouse_out(e:MouseEvent):void
		{
			//rollTimer.stop();
			//TweenMax.to(textContainer, 1, { ease: Strong.easeOut, y: 0 });
		}
		
		//
		// PUBLIC API
		//
		public function set isRollEnabled(value:Boolean):void
		{
			_isRollEnabled = value;
			if (!value)
			{
				// STOP roll effect
				TweenMax.killTweensOf( textContainer );
				rollTimer.stop();
				TweenMax.to(textContainer, 1, { delay:0, ease: Strong.easeOut, y: 0 });
				
			}
		}
		
		
		//
		// OVERRIDES
		//
		public override function get centerX():Number
		{
			return (this.x + (textMask.width >> 1));
		}
		public override function set centerX(value:Number):void
		{
			this.x = (value - (textMask.width >> 1));
		}
		public override function get centerY():Number
		{
			return (this.y + (textMask.height >> 1));
		}
		public override function set centerY(value:Number):void
		{
			this.y = (value - (textMask.height >> 1));
		}
		
	}
}