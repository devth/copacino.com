package com.cf.util
{
	import com.cf.model.event.StateEvent;
	import com.devth.view.event.UIEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.geom.Point;

	public class Component extends Sprite
	{
		// WHAT if this was an array of instances ?
		public static var instance : Component;
		
		public static const UIEVENT_STATE_CHANGE:String		= "uievent/state/change";
		public static const TRANSITION_COMPLETE:String		= "transition/complete";
		
		protected var _state:String;
		protected var _isTransitioning:Boolean;
		protected var _isInitialized:Boolean = false;
		
		protected var _desiredWidth:Number;
		protected var _desiredHeight:Number;
		
		public var desiredX:Number;
		public var desiredY:Number;
		
		
		public function Component()
		{
			super();
			
			instance = this;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener( StateEvent.STATE_CHANGED, state_changed );
			this.addEventListener( FullScreenEvent.FULL_SCREEN, full_screen );
		}
		
		protected function init():void
		{
			_isInitialized = true;
		}
		
		// 
		// EVENT HANDLERS
		//
		protected function state_changed (e:StateEvent):void
		{
		}
		protected function onStageResize(e:Event):void
		{	
			position();
		} 
		protected function full_screen(e:FullScreenEvent):void
		{
			onStageResize(null);
		}
		protected function transition_complete(e:Event):void
		{
			this.removeEventListener( TRANSITION_COMPLETE, transition_complete );
		}
		
		private function onAdded(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			stage.addEventListener(Event.RESIZE, onStageResize);
			init();
		}
		
		//
		// POSITIONING
		//
		protected function position():void
		{
			
		}
		
		// TOP
		public function set top(value:Number):void { this.y = value; }
		public function get top():Number { return this.y; }
		
		// LEFT
		public function set left(value:Number):void { this.x = value; }
		public function get left():Number { return this.x; }
		
		// BOTTOM
		public function set bottom(value:Number):void { this.y = (value - this.height); }
		public function get bottom():Number { return (this.y + this.height); }
		
		// RIGHT
		public function set right(value:Number):void { this.x = (value - this.width); }
		public function get right():Number { return (this.x + this.width); }
		
		// CENTER X
		public function set centerX(value:Number):void { this.x = (value - halfWidth); }
		public function get centerX():Number { return (this.x + halfWidth); }
		
		// CENTER Y
		public function set centerY(value:Number):void { this.y = (value - halfHeight); }
		public function get centerY():Number { return (this.y + halfHeight); }
		
		// HALF height
		public function get halfHeight():Number { return (this.height >> 1); }
		// HALF width
		public function get halfWidth():Number { return (this.width >> 1); }
		
		
		//
		// PUBLIC API
		//
		public function set desiredWidth( w:Number ):void { _desiredWidth = w; }
		public function get desiredWidth():Number { return _desiredWidth; }
		public function set desiredHeight( h:Number ):void{ _desiredHeight = h; }
		public function get desiredHeight():Number { return _desiredHeight; }
		
		public function set state(state:String):void
		{
			var prevState:String = _state;
			_state = state;
			
			var stateEvent:StateEvent = new StateEvent(StateEvent.STATE_CHANGED, prevState, state, true, true);
			
			// DISPATCH EVENTS
			
			// TO Mediators
			dispatchEvent( new UIEvent( UIEVENT_STATE_CHANGE, this, stateEvent ) );
			// TO Components
			dispatchEvent( stateEvent );
		}
		public function get state():String
		{
			return _state;
		}
		
		public function global():Point
		{
			return this.parent.localToGlobal( new Point(this.x, this.y) );
		}
		
		public function set isTransitioning( value:Boolean ):void
		{
			_isTransitioning = value;
			if ( _isTransitioning )
			{
				this.addEventListener( TRANSITION_COMPLETE, transition_complete );
			}
			else
			{
				this.dispatchEvent( new Event( TRANSITION_COMPLETE ) );
			}
			
		}
		public function get isTransitioning():Boolean { return _isTransitioning; }
		
	}
}