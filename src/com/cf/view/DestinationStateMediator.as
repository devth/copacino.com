package com.cf.view
{
	import com.cf.model.vo.StateChangeRequest;
	import com.cf.util.Utility;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;

	public class DestinationStateMediator extends Mediator implements IMediator
	{
		public static const CHANGE_STATE_REQUEST:String	= "actionRequets";
		
		public static const NAME:String	= "DestinationStateMediator";
		
		private var fromState:State;
		private var toState:State;
		
		private var isInTransition:Boolean;
		
		
		
		public function DestinationStateMediator( viewComponent:Object=null )
		{
			super(NAME, viewComponent);
		}
		
		
		//
		// OVERRIDES
		//
		override public function listNotificationInterests():Array
		{
			return [
				StateMachine.CHANGED,
				CHANGE_STATE_REQUEST
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			
			switch ( notification.getName() )
			{
				case StateMachine.CHANGED:
					Utility.debugColor(this, 0x12d4db, "StateMachine.CHANGED", notification.getType(), notification.getBody() );
					
					
					
					break;
					
				case CHANGE_STATE_REQUEST:
				
					var changeRequest:StateChangeRequest = notification.getBody() as StateChangeRequest;
				
					// 1. DETERMINE direction
					var direction:int = 0;
					
					
				
				
					break;
			}
		}
		
		//
		// METHODS
		//
		private function handleStateTransition(fromState:String, toState:State):void
		{
			
		} 
		
	}
}