package com.cf
{
	import com.cf.controller.AddressChangeCommand;
	import com.cf.controller.LoadPostCommand;
	import com.cf.controller.StartupCommand;
	import com.cf.controller.TitleChangeCommand;
	
	import flash.display.DisplayObject;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		// NOTIFICATION name constants
		public static const STARTUP:String			= "startup";
		public static const LOAD_POST:String		= "loadPost";
		
		public static const INITIALIZE_SITE:String	= "initializeSite";
		public static const STAGE_RESIZE:String 	= "stageResize";
		
		public static const INIT_LOAD:String			= "initLoad";
		public static const INIT_LOAD_PROGRESS:String	= "initLoadProgress";
		public static const INIT_LOAD_COMPLETE:String	= "initLoadComplete";
		public static const INIT_LOAD_FAIL:String		= "initLoadFail";
		
		// SWF ADDRESS
		public static const ADDRESS_CHANGE:String 		= "address_change";
		public static const TITLE_CHANGE:String 		= "title_change";
		public static const ADDRESS_CHANGED:String		= "address_changed";
		
		// NAMES for multi-instance mediators and proxies
		//public static const WE_ARE:String		= "WeAre";
		//public static const WE_ARE_NOT:String	= "WeAreNot";
		
		
		/**
		 * Startup method 
		 */
		public static function getInstance():ApplicationFacade
		{
			if ( instance == null ) instance = new ApplicationFacade();
			return instance as ApplicationFacade;
		}
		
		override protected function initializeController():void
		{
			super.initializeController();
			
			// WIRE SWF ADDRESSING
			registerCommand( ApplicationFacade.ADDRESS_CHANGE, AddressChangeCommand );
			registerCommand( ApplicationFacade.TITLE_CHANGE, TitleChangeCommand );
			
			registerCommand( STARTUP, StartupCommand );
			registerCommand( LOAD_POST, LoadPostCommand );
			
			// NOTE: SWFAddress AddressChangeCommand isn't registered until
			// site loaded notification is handled in SiteMediator
		}
		
		public function startup( root:DisplayObject ):void
		{
			sendNotification( STARTUP, root );
		}
	}
}