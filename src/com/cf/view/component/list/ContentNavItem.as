package com.cf.view.component.list
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.util.Utility;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import gs.TweenLite;
	import gs.TweenMax;

	public class ContentNavItem extends Component
	{
		// CONST
		private static const FADE_SPEED	:Number	= .4;
		
		// EVENT
		public static const EVENT_SET_ACTIVE:String		= "event/set-active";
		
		// DATA
		private var _number:Number; 
		private var _isLast:Boolean;
		private var _isActive:Boolean;
		private var _tweenBack:Boolean = false;
		
		// VISUAL
		private var _hitArea:Sprite = new Sprite();
		
		
		public function ContentNavItem( number:Number, isLast:Boolean )
		{
			super();
			
			_isActive = false;
			this.alpha = Settings.CONTENT_NAV_INACTIVE_ALPHA;
			
			_number = number;
			_isLast = isLast;
			
			var text:String = _number.toString() + ( _isLast ? "" : "," );
			var tf:TextField = TextFactory.TagText( text );
			addChild( tf );
			
			// CURSOR
			this.buttonMode = true;
			
			// HIT AREA
			_hitArea.addChild( Utility.getMaskShape( tf.width, tf.height ) );
			_hitArea.alpha = 0;
			addChild( _hitArea );
			this.hitArea = _hitArea;
			
			// WIRE EVENTS
			this.addEventListener( MouseEvent.ROLL_OVER, this_roll_over );
			this.addEventListener( MouseEvent.ROLL_OUT, this_roll_out );
			this.addEventListener( MouseEvent.CLICK, this_click );
		}
		
		
		//
		// EVENT HANLDERS
		//
		private function this_roll_over(e:MouseEvent):void
		{
			if ( !_isActive ) TweenMax.to( this, FADE_SPEED, { alpha: 1, onComplete: checkTweenBack });
		}
		private function this_roll_out(e:MouseEvent):void
		{
			if ( !_isActive )
			{
				if ( TweenMax.isTweening( this ) ) _tweenBack = true;	
				TweenMax.to( this, FADE_SPEED, { alpha: Settings.CONTENT_NAV_INACTIVE_ALPHA });
			}
		}
		private function checkTweenBack():void
		{
			if ( _tweenBack ) this_roll_out(null)
			_tweenBack = false;
		}
		private function this_click(e:MouseEvent):void
		{
			dispatchEvent( new Event( EVENT_SET_ACTIVE, true, true ) );
		}
		
			
		//
		// PUBLIC API
		//
		public function get number():Number { return _number }
		public function set isActive( value:Boolean ):void
		{
			_isActive = value;
			TweenLite.to( this, .6, { alpha: (_isActive ? 1 : Settings.CONTENT_NAV_INACTIVE_ALPHA) });
		}
		public function get isActive():Boolean { return _isActive; }
	}
}