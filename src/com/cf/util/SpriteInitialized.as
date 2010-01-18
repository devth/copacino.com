package com.cf.util
{
	import com.cf.model.event.StateEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class SpriteInitialized extends Sprite
	{
		public static var instance : SpriteInitialized;
		
		protected var _state:String;
		
		public var desiredWidth:Number;
		public var desiredHeight:Number;
		
		
		public function SpriteInitialized()
		{
			super();
			
			instance = this;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener( StateEvent.STATE_CHANGED, state_changed );
		}
		
		protected function init():void
		{
			
		}
		
		// 
		// EVENT HANDLERS
		//
		protected function state_changed (e:StateEvent):void
		{
			
		}
		protected function onStageResize(e:Event):void
		{	
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
		public function set state(state:String):void
		{
			var prevState:String = _state;
			_state = state;
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, prevState, state, true, true) );
		}
		public function get state():String
		{
			return _state;
		}
		
		public function global():Point
		{
			return this.parent.localToGlobal( new Point(this.x, this.y) );
		}
		
		
		
		
		
	}
}