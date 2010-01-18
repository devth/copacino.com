package com.cf.model
{
	import com.cf.ApplicationFacade;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.observer.Notification;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class StageProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "StageProxy";
		
		public function StageProxy(data:DisplayObject)
		{
			super(NAME, data);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			
			
			stage.addEventListener( Event.RESIZE, stage_resize );
		}
		
		
		private function stage_resize (e:Event):void
		{
			facade.notifyObservers( new Notification( ApplicationFacade.STAGE_RESIZE, this ) );
		}
		
		public function get stage():Stage
		{
			return (this.getData() as DisplayObject).stage;
		}
		
	}
}