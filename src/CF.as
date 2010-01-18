package
{
	import com.afw.swfaddress.SWFAddressUtil;
	import com.cf.ApplicationFacade;
	import com.cf.util.Settings;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Security;

	[SWF(width=1024,height=768,backgroundColor="#000000",frameRate=31)]
	public class CF extends Sprite
	{
		
		// STATE names
		public static const STATE_LOADING:String				= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_LOADING ]);
		public static const STATE_WE_ARE:String					= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE ]);
		public static const STATE_WE_ARE_NOT:String				= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE_NOT ]);
		
		public static const STATE_WE_ARE_LIST:String			= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE, Settings.URL_LIST ]);
		public static const STATE_WE_ARE_CONTENT:String			= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE, Settings.URL_CONTENT ]);
		public static const STATE_WE_ARE_FULLSCREEN:String		= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE, Settings.URL_FULLSCREEN ]);
		
		public static const STATE_WE_ARE_NOT_LIST:String		= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE_NOT, Settings.URL_LIST ]);
		public static const STATE_WE_ARE_NOT_CONTENT:String		= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE_NOT, Settings.URL_CONTENT ]);
		public static const STATE_WE_ARE_NOT_FULLSCREEN:String	= SWFAddressUtil.joinURI([ Settings.FSM_STATE, Settings.URL_WE_ARE_NOT, Settings.URL_FULLSCREEN ]);
		
		
		// ACTIONS
		public static const TO_WE_ARE:String					= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE ]);
		public static const TO_WE_ARE_NOT:String				= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE_NOT ]);
		
		public static const TO_WE_ARE_LIST:String				= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE, Settings.URL_LIST ]);
		public static const TO_WE_ARE_CONTENT:String			= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE, Settings.URL_CONTENT ]);
		public static const TO_WE_ARE_FULLSCREEN:String			= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE, Settings.URL_FULLSCREEN ]);
		
		public static const TO_WE_ARE_NOT_LIST:String			= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE_NOT, Settings.URL_LIST ]);
		public static const TO_WE_ARE_NOT_CONTENT:String		= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE_NOT, Settings.URL_CONTENT ]);
		public static const TO_WE_ARE_NOT_FULLSCREEN:String		= SWFAddressUtil.joinURI([ Settings.FSM_ACTION, Settings.URL_WE_ARE_NOT, Settings.URL_FULLSCREEN ]);
		
		
		private var _isStarted:Boolean = false;
		
		public function CF()
		{
			Security.allowDomain("*");
			
			// STAGE properties
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addEventListener( Event.ENTER_FRAME, enter_frame );
			
			// ENABLE scrolling
			//var _mwSupport:ExternalMouseWheelSupport = ExternalMouseWheelSupport.getInstance(stage);
			//_mwSupport.dispatchingObjectDeterminationMethod = ExternalMouseWheelSupport.COPY_MOUSEMOVE_EVENTS;

			
			// DEBUG
			// new MonsterDebugger( this );
			
		}
		private function startup():void
		{
			if ( _isStarted ) return;
			_isStarted = true;
			
			ApplicationFacade.getInstance().startup( stage );
		}
		private function enter_frame(e:Event):void
		{
			if ( stage.stageWidth > 0 && stage.stageHeight > 0)
			{
				removeEventListener( Event.RESIZE, enter_frame );
				startup();
			}
		}


	}
}