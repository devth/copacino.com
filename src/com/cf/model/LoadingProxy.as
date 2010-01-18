package com.cf.model
{
	import com.cf.ApplicationFacade;
	import com.cf.util.Settings;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import org.puremvc.as3.utilities.statemachine.StateMachine;

	/**
	 * 
	 * @author thartman
	 * 
	 */	
	public class LoadingProxy extends Proxy implements IProxy
	{
		private var testLoadTimer:Timer;
		private var loadTimeElapsed:Number = 0;
		
		public static const NAME:String = "LoadingProxy";
		
		public function LoadingProxy( )
		{
			super(NAME);
			
			testLoadTimer = new Timer( Settings.LOAD_REPORT_INTERVAL );
			testLoadTimer.addEventListener(TimerEvent.TIMER, testLoadTimer_timer );
			testLoadTimer.start();
			
		}
		
		
		private function testLoadTimer_timer(e:TimerEvent):void
		{
			loadTimeElapsed += Settings.LOAD_REPORT_INTERVAL;
			
			if (!(loadTimeElapsed < Settings.TESTING_LOAD_TIME))
			{
				testLoadTimer.stop();
			}
			
			var percentLoaded:Number = Math.min(100 * loadTimeElapsed / Settings.TESTING_LOAD_TIME, 100);
		
			
			sendNotification( ApplicationFacade.INIT_LOAD_PROGRESS, percentLoaded );
			
			if (percentLoaded == 100)
			{
				sendNotification( ApplicationFacade.INIT_LOAD_COMPLETE );
				sendNotification( StateMachine.ACTION, null, CF.TO_WE_ARE );
			}
		}
		
	}
}