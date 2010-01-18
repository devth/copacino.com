package com.cf.view.component.nav
{
	import com.cf.model.event.StateEvent;
	import com.cf.model.vo.NavData;
	import com.cf.util.AssetManager;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.event.UIEvent;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class Nav extends Component
	{
		public static const STATE_LEFT		:String		= "state/left";
		public static const STATE_INDENTED	:String		= "state/indented";
		public static const NAV_CLICK:String 			= "navClick";
		
		private const LEFT_MARGIN:Number			= 12;
		private const BASE_DELAY:Number 			= 0;
		private const INACTIVE_ICON_ALPHA:Number	= .55;
		private const ROLLOVER_ICON_ALPHA:Number	= .7;
		
		// VISUAL
		private var _bg:Sprite;
		private var _navContainer:Sprite;
		private var _tileContainer:Sprite;
		private var _mainNav:MainNav;
		private var _contactTile:NavTile;
		
		private var _navRightContainer:Sprite;
		private var _iconCloud:Sprite;
		private var _iconList:Sprite;
		
		
		private var _logo:Sprite;
		private var _maskShape:Bitmap;
		private var _highlightColor:uint = Settings.NAV_DEFAULT_HIGHLIGHT; // RED default
		
		private var _activeIcon:Sprite = null;
		
		public function Nav()
		{
			super();
			
			_state = STATE_LEFT;
			
			// MASK
			_maskShape = Utility.getMaskShape();
			_maskShape.width = 0;
			_maskShape.height = Settings.TILE_HEIGHT;
			_maskShape.x = 0;
		}
		
		// 
		// OVERRIDES
		//
		override protected function init():void
		{
			super.init();
			
			// BG
			_bg = new Sprite();
			addChild( _bg );
			
			
			// NAV CONTAINER
			_navContainer = new Sprite();
			addChild( _navContainer );
			_navContainer.addChild( _maskShape );
			_navContainer.mask = _maskShape;
			
			// NAV RIGHT-aligned 
			_navRightContainer = new Sprite();
			_navContainer.addChild( _navRightContainer );
			
			// CLOUD ICON
			_iconCloud = new Sprite();
			_iconCloud.alpha = INACTIVE_ICON_ALPHA;
			_navRightContainer.addChild( _iconCloud );
			_iconCloud.addChild( AssetManager.InitLoader.getBitmap( Settings.ICON_CLOUD ) );
			_iconCloud.x = -_iconCloud.width - 5;
			_iconCloud.y = Settings.FIRST_LINE_HEIGHT + 2;
			_iconCloud.useHandCursor = _iconCloud.buttonMode = true;
			Utility.addInvisibleHitArea( _iconCloud, 4 );
			_iconCloud.addEventListener( MouseEvent.MOUSE_OVER, icon_mouse_over );
			_iconCloud.addEventListener( MouseEvent.MOUSE_OUT, icon_mouse_out );
			_iconCloud.addEventListener( MouseEvent.MOUSE_DOWN, icon_cloud_mouse_down );
			
			// LIST ICON
			_iconList = new Sprite();
			_iconList.alpha = INACTIVE_ICON_ALPHA;
			_navRightContainer.addChild( _iconList );
			_iconList.addChild( AssetManager.InitLoader.getBitmap( Settings.ICON_LIST ) );
			_iconList.x = _iconCloud.x - _iconList.width - 10;
			_iconList.y = Settings.FIRST_LINE_HEIGHT + 3;
			_iconList.useHandCursor = _iconList.buttonMode = true;
			Utility.addInvisibleHitArea( _iconList, 4 );
			_iconList.addEventListener( MouseEvent.MOUSE_OVER, icon_mouse_over );
			_iconList.addEventListener( MouseEvent.MOUSE_OUT, icon_mouse_out );
			_iconList.addEventListener( MouseEvent.MOUSE_DOWN, icon_list_mouse_down );
			
			// LOGO
			_logo = new Sprite();
			_navContainer.addChild( _logo );
			
			// TILE container
			_tileContainer = new Sprite();
			_navContainer.addChild( _tileContainer );
			
			// WIRE EVENTS
			this.addEventListener( MouseEvent.ROLL_OVER, this_roll_over );
			
			// MAIN items
			_mainNav = new MainNav();
			_tileContainer.addChild( _mainNav );
			
			// CONTACT
			_contactTile = new NavTile( "contact", 0x000000, new NavData("contact", Settings.URL_WE_ARE, "contact" ) );
			_tileContainer.addChild( _contactTile );
			
			_contactTile.x = _mainNav.width + _mainNav.x + 15;
			
			
			// NOTE: ASSETS must be loaded at this point
			logo = new Bitmap( AssetManager.InitLoader.getBitmapData( Settings.ASSET_LOGO_LIGHT ) );
				
			// BG - gradient
			var matr:Matrix = new Matrix();
    		matr.createGradientBox( stage.stageWidth, Settings.FIRST_LINE_HEIGHT + Settings.TILE_ROW_HEIGHT, Utility.degreesToRadians( 90 ), 0, 0 );
			//_bg.addChild( new Bitmap( new BitmapData( stage.stageWidth, Settings.FIRST_LINE_HEIGHT + Settings.TILE_ROW_HEIGHT, false, Settings.WE_ARE_CROSS_BG ) ) );
			_bg.graphics.beginGradientFill( GradientType.LINEAR, [ Settings.DARK_GRADIENT_START, Settings.DARK_GRADIENT_END ], [ 1, 1 ], [ 0, 255 ], matr, SpreadMethod.PAD );
			_bg.graphics.drawRect(0,0, stage.stageWidth, Settings.FIRST_LINE_HEIGHT + Settings.TILE_ROW_HEIGHT );
			_bg.mouseEnabled = _bg.mouseChildren = false;
			
			// POSITION
			this.y = -_bg.height;
			_navContainer.x = getExpectedX();
			// _contactTile.x = (stage.stageWidth * Settings.LIST_WIDTH_PERCENT) - _contactTile.width; //  _navContainer.width - _contactTile.width; // stage.stageWidth - (stage.stageWidth * (1 - Settings.LIST_WIDTH_PERCENT)) - _contactTile.width;
			
			_navRightContainer.x = (stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
			
			// POSITION
			_tileContainer.x = _logo.width + 10;
			_navContainer.y = Settings.FIRST_LINE_HEIGHT + Settings.TILE_MARGIN;
			
			// TRANSITION
			TweenLite.to( this, 1, { delay:2, y: 0 });
			TweenLite.to( _maskShape, 3, { delay:4, ease: Strong.easeInOut, width: stage.stageWidth * Settings.LIST_WIDTH_PERCENT });
		}
		override protected function position() : void
		{
			_bg.width = stage.stageWidth;
			_navContainer.x = getExpectedX();
			// _logo.x = maskShape.x = getExpectedLogoX();
			_maskShape.width = stage.stageWidth * Settings.LIST_WIDTH_PERCENT;
			//_contactTile.x = (stage.stageWidth * Settings.LIST_WIDTH_PERCENT) - _contactTile.width;
			
			_navRightContainer.x = (stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
		}
		
		
		//
		// EVENT HANDLERS
		//
		override protected function state_changed(e:StateEvent) : void
		{
		}
		private function this_roll_over (e:MouseEvent):void
		{
		}
		private function logo_mouse_down( e:MouseEvent ):void
		{
			dispatchEvent( new UIEvent( UIEvent.URL_EVENT, "we are", Settings.WP_CAT_WE_ARE, true, true ) );
		}
		private function icon_list_mouse_down( e:MouseEvent ):void
		{
			dispatchEvent( new UIEvent( UIEvent.URL_EVENT, "the agency", Settings.WP_CAT_WE_ARE + "/" + Settings.URL_AGENCY, true, true ) );
		}
		private function icon_cloud_mouse_down( e:MouseEvent ):void
		{
			dispatchEvent( new UIEvent( UIEvent.URL_EVENT, "we are", Settings.WP_CAT_WE_ARE, true, true ) );
		}
		private function icon_mouse_over(e:MouseEvent):void
		{
			var icon:Sprite = e.target as Sprite;
			if (icon != _activeIcon) TweenMax.to( icon, .7, { alpha: ROLLOVER_ICON_ALPHA });
		}
		private function icon_mouse_out(e:MouseEvent):void
		{
			var icon:Sprite = e.target as Sprite;
			if (icon != _activeIcon) TweenMax.to( icon, .7, { alpha: INACTIVE_ICON_ALPHA });			
		}
		
		//
		// PRIVATE API
		//
		private function getExpectedLogoX():Number
		{
			switch ( state )
			{
				case STATE_INDENTED:
					return LEFT_MARGIN;
				break;
				case STATE_LEFT:
				default:
					return LEFT_MARGIN;
				break;
			}
		}
		private function getExpectedX():Number
		{
			return  (stage.stageWidth * (1 - Settings.LIST_WIDTH_PERCENT) * .5);
			
			switch ( state )
			{
				case STATE_LEFT:
					return 0;
				break;
				case STATE_INDENTED:
				default:
					
				break;
			}
		}
		
		
		//
		// PUBLIC API
		//
		public function set logo(b:Bitmap):void
		{
			// ADD
			b.x = Settings.TILE_TEXT_HORIZONTAL_MARGIN >> 1;
			b.x = 2;
			_logo.addChild( new Bitmap( new BitmapData( b.width + Settings.TILE_TEXT_HORIZONTAL_MARGIN, Settings.TILE_HEIGHT, false, Settings.NAV_LOGO_BG ) ) );
			_logo.addChild( b );

			_logo.buttonMode = _logo.useHandCursor = true;
			_logo.addEventListener( MouseEvent.MOUSE_DOWN, logo_mouse_down );
		}
		public function hide( delay:Number = BASE_DELAY, speed:Number = 2 ):void
		{
			TweenMax.to( _maskShape, speed, { delay: delay, width: 0, ease: Strong.easeInOut });
			
			// HIDE nav
			TweenMax.to( _mainNav, speed, { delay: delay, alpha: 0 });
		}
		public function reveal( delay:Number = BASE_DELAY, speed:Number = 1.5 ):void
		{
			TweenMax.to(_maskShape, speed, { delay: delay, width: _logo.width, ease: Strong.easeInOut });
			
			// SHOW nav
			TweenMax.to( _mainNav, speed, { delay: delay, alpha: 1 });
		}
		public function set highlightColor(color:uint):void
		{
			_highlightColor = color;
		}
		public function set activeNavTileBySegment(name:String):void
		{
			if ( name == "contact" ) 
			{
				_contactTile.isActive = true;
				_mainNav.activeNavTileBySegment = "";
			}
			else
			{
				_mainNav.activeNavTileBySegment = name;
				_contactTile.isActive = false;			
			}
		}
		public function get activeNavTile():NavTile
		{
			return _mainNav.activeNavTile;
		}
		
		
		public function set activeIconByName( name:String ):void
		{
			if ( name == "list" )
			{
				_activeIcon = _iconList;
				TweenMax.to( _iconList, 1, { alpha: 1 });
				TweenMax.to( _iconCloud, 1, { alpha: INACTIVE_ICON_ALPHA });
			}
			else if ( name == "cloud" )
			{
				_activeIcon = _iconCloud;
				TweenMax.to( _iconList, 1, { alpha: INACTIVE_ICON_ALPHA });
				TweenMax.to( _iconCloud, 1, { alpha: 1 });
			}
			else if ( name == "" )
			{
				_activeIcon = null;
				TweenMax.to( _iconCloud, 1, { alpha: INACTIVE_ICON_ALPHA });
				TweenMax.to( _iconList, 1, { alpha: INACTIVE_ICON_ALPHA });
			}
		}
	}
}