package com.cf.view.component
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.view.component.container.WeAre;
	import com.cf.view.component.container.WeAreNot;
	import com.cf.view.component.nav.Nav;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	import gs.TweenMax;
	
	import net.hires.debug.Stats;

	public class Site extends Component
	{
		private static const STATE_WEARE:String		= "site/weare";
		private static const STATE_WEARENOT:String	= "site/wearenot";
		private static const STATE_LOADING:String	= "site/loading";
			
		// TRAY STATE	
		public static const TRAY_STATE_NORMAL				:String		= "tray/state/normal";
		public static const TRAY_STATE_LIST					:String		= "tray/state/list";
		public static const TRAY_STATE_FULLSCREEN			:String		= "tray/state/fullscreen";
		public static const TRAY_STATE_WEARENOT_CONTENT		:String		= "tray/state/wearenot_content";
		public static const TRAY_STATE_WEARENOT				:String		= "tray/state/wearenot";
		
		private var _trayState:String = TRAY_STATE_NORMAL;
		
		private var siteBgLayer:Sprite;
		
		private var siteHeight:Number;
		private var siteWidth:Number;
		
		private var menu:ContextMenu;
		private var itemToggleFS:ContextMenuItem;
		
		private var statsLayer:Stats;
		private var weAreLayer:WeAre;
		private var weAreNotLayer:WeAreNot;
		
		private var navLayer:Nav;
		
		private var contentLayer:Sprite;
		
		
		public function Site()
		{
			super();
		}
		
		protected override function init():void
		{
			state = STATE_LOADING;
			
			// SITE BG layer
			siteBgLayer = new Sprite();
			siteBgLayer.addChild(new Bitmap(new BitmapData(100, 100, false, Settings.SITE_BG_COLOR)));
			addChild(siteBgLayer);
			
			
			// CONTENT layer (this layer can move vertically to shift between "we are" and "we are not")
			contentLayer = new Sprite();
			addChild( contentLayer );
			
			// WE ARE
			weAreLayer = new WeAre();
			contentLayer.addChild(weAreLayer);
			
			// WE ARE NOT
			weAreNotLayer = new WeAreNot();
			contentLayer.addChild(weAreNotLayer);
			
			
			// CREATE NAV
			navLayer = new Nav();
			
			// CUSTOM CONTENT MENU
			menu = new ContextMenu();
			menu.hideBuiltInItems();
			this.contextMenu = menu;
			
			// ITEMS
			itemToggleFS = new ContextMenuItem(Settings.ENTER_FULLSCREEN);
			itemToggleFS.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, itemToggleFS_select);
			
			// ADD item
			menu.customItems.push(itemToggleFS);
			
			// EVENTs
			stage.addEventListener( KeyboardEvent.KEY_UP, key_up );
		}
		protected override function onStageResize(e:Event):void
		{
			updateSize( stage.stageWidth, stage.stageHeight );
		}
		
		protected override function position():void
		{
			// POSITION based on state
			
			switch ( state )
			{
				case STATE_LOADING:
				
					weAreNotLayer.y = siteHeight;
				
				break;
				case STATE_WEARE:
				
					if ( _trayState == TRAY_STATE_NORMAL )
						weAreNotLayer.y = siteHeight - Settings.TRAY_HEIGHT;
					else if ( _trayState == TRAY_STATE_LIST )
						weAreNotLayer.y = siteHeight - Settings.TRAY_HEIGHT_LIST;
					else if ( _trayState == TRAY_STATE_FULLSCREEN )
						weAreNotLayer.y = siteHeight - Settings.TRAY_HEIGHT_FULLSCREEN;
				
				break;
				case STATE_WEARENOT:
					if ( _trayState == TRAY_STATE_WEARENOT_CONTENT )
						weAreNotLayer.y = 0;
					else
						weAreNotLayer.y = Settings.TRAY_HEIGHT
				break;
			}
			
			if ( statsLayer ) statsLayer.x = stage.stageWidth - statsLayer.width;
			
			siteBgLayer.width = siteWidth;
			siteBgLayer.height = siteHeight;
		}
		
		private function toggleFSText():void
		{
			if (stage.displayState == StageDisplayState.FULL_SCREEN) itemToggleFS.caption = Settings.EXIT_FULLSCREEN;
			else itemToggleFS.caption = Settings.ENTER_FULLSCREEN;
		}
		
		//
		// EVENT handlers
		//
		private function itemToggleFS_select(e:ContextMenuEvent):void
		{
			stage.displayState = (stage.displayState == StageDisplayState.FULL_SCREEN) ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN;
			toggleFSText();
			
			position();
		}
		private function key_up(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.F1)
			{
				statsLayer.visible = !statsLayer.visible;	
			}
		}
		
		//
		// PUBLIC API
		//
		public function set trayState( trayState:String ):void
		{
			_trayState = trayState;
			var trayHeight:int = 0; 
	
			switch ( trayState )
			{
				case TRAY_STATE_NORMAL:
					weAreNotLayer.toMinimizedState();
					trayHeight = Settings.TRAY_HEIGHT;
				break;
				case TRAY_STATE_LIST:
					weAreNotLayer.toMinimizedListState();
					trayHeight = Settings.TRAY_HEIGHT_LIST;
				break;
				case TRAY_STATE_FULLSCREEN:
					weAreNotLayer.toMinimizedFullscreenState();
					trayHeight = Settings.TRAY_HEIGHT_FULLSCREEN;
				break;
				case TRAY_STATE_WEARENOT_CONTENT:
					trayHeight = stage.stageHeight;
				break;
				case TRAY_STATE_WEARENOT:
					trayHeight = stage.stageHeight - Settings.TRAY_HEIGHT;
				break;
			}
			TweenLite.to( weAreNotLayer, 1, { y: stage.stageHeight - trayHeight });
		}
		public function get trayState():String { return _trayState; }
		public function updateSize(width:Number, height:Number):void
		{
			// Utility.debug(this, width, height);
			siteWidth = width;
			siteHeight = height;
			position();
		}
		public function site_loaded():void
		{
			state = STATE_WEARE;
			
			// ADD NAV
			navLayer.y = Settings.NAV_TOP_MARGIN;
			addChild( navLayer );
			navLayer.reveal();
			
			// RAISE tray
			// 12.31.09		Don't raise tray, swfaddressing should make states do whatever they need to do
			// TweenMax.to(weAreNotLayer, 1, { delay:3, y: stage.stageHeight - Settings.TRAY_HEIGHT });
			weAreNotLayer.shape.reveal( 1.5 );
			
			// STATS
			statsLayer = new Stats();
			statsLayer.visible = false;
			addChild(statsLayer);
			statsLayer.x = stage.stageWidth - statsLayer.width;
		}
		
		public function transitionToWeAre():void
		{
			//TweenLite.to( weAreNotLayer, 1.2, { delay:1, y: stage.stageHeight - Settings.TRAY_HEIGHT });
			state = STATE_WEARE;
		}
		public function transitionToWeAreNot():void
		{
			TweenLite.to( weAreNotLayer, 1.2, { delay:1, y: Settings.TRAY_HEIGHT });
			state = STATE_WEARENOT;
		}
		
		
		//
		// PUBLIC PROPERTIES
		//
		public function get WeAreLayer():WeAre
		{
			return weAreLayer;
		}
		public function get WeAreNotLayer():WeAreNot
		{
			return weAreNotLayer;
		}
		public function get NavLayer():Nav
		{
			return navLayer;
		}
		
	}
}