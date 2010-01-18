package com.cf.util
{
	import com.cf.model.vo.NavData;
	
	import flash.utils.Dictionary;
	
	//
	// CF.com SITE SETTINGS
	//
	public class Settings
	{
		
		//
		// SITE
		//
		public static const TRAY_HEIGHT				:int 	= 100;
		public static const TRAY_HEIGHT_LIST		:int	= 35;
		public static const TRAY_HEIGHT_FULLSCREEN	:int	= 0;
		public static const SITE_BG_COLOR:uint				= 0x121212;
		public static const LOAD_REPORT_INTERVAL:Number		= 800; // (depricated) MILLISECONDS between load notifications
		public static const MODAL_TINT_ALPHA:Number			= .6;
		public static const MODAL_TINT_COLOR:Number			= 0x000000;
		public static const DARK_GRADIENT_START		:uint	= 0x363636;
		public static const DARK_GRADIENT_END		:uint	= 0x202020;
		public static const GOOGLE_MAP_API_KEY		:String	= "ABQIAAAAH0eoBtvPoXwqLR3DumzHGhQosytj3AURBrm7hi0u-oyZIH35xRROJOYFxeStCqxH_Ji66G1o3RIekA";
		
		//
		// WE ARE / WE ARE NOT shape settings
		//
		public static const WE_ARE_CROSS_BG:uint 			= 0x202020; //0x252525;  
		public static const WE_ARE_NOT_BG:uint				= 0xdb1a12;
		public static const WE_ARE_NOT_STROKE	:uint		= 0x3a3a3a;
		public static const BAR_WIDTH:uint 					= 383;
		public static const BAR_HEIGHT:uint 				= 95;
		public static const WE_ARE_TERMS:Array 				= [ "thinkers", "doers", "right brained", "left brained", "logic + magic" ];
		public static const WE_ARE_TERMS_COLORS:Array 		= [ 0x6acfdb, 0x77db6a, 0xfa008e, 0xf2c741, 0x6acfdb ];
		public static const WE_ARE_ROLL_INTERVAL:Number		= 900;
		public static const SHAPE_MINIMIZED_SCALE:Number	= (Settings.TILE_HEIGHT / Settings.BAR_HEIGHT) + .01;
		// public static const SHAPE_SMALL_MASK_NAME:Number	=
		
		//
		// OPACITY LINE settings
		//
		public static const LINE_OPACITY:Number 					= .9;
		public static const FIRST_LINE_HEIGHT:Number 				= 5;
		public static const LINE_COLOR:uint 						= 0x000000;
		public static const INIT_LINE_CONTAINER_OPACITY:Number 		= .69;
		public static const NORMAL_LINE_CONTAINER_OPACITY:Number	= 1;
		
		
		//
		// TILE settings
		//
		public static const TILE_HEIGHT:uint 					= 23;
		public static const TILE_MARGIN:Number 					= 1;
		public static const TILE_ROW_HEIGHT:Number 				= TILE_HEIGHT + TILE_MARGIN;
		public static const MAX_VERTICAL_LINES_FROM_CENTER:uint	= 9; // HOW many lines above/below center of + it can stack
		public static const MAX_TILES_PER_VERTICAL_EDGE:uint	= 3; // HOW many tiles can stack on top and bottom
		public static const TILE_TEXT_HORIZONTAL_MARGIN:Number	= 10;
		public static const LOAD_TILE_WIPE_TIME:Number 			= 1;
		public static const LOAD_TILE_PER_SECOND:Number			= 14; // HOW MANY tiles per second when loading
		
		
		//
		// LIST settings
		//
		public static const LIST_PLUS_LEFT:Number				= 68;
		public static const LIST_PLUS_TOP:Number				= 149;
		public static const LIST_MARGIN_TOP:Number				= 125;
		public static const LIST_MARGIN_LEFT:Number 			= 73;
		public static const LIST_DEFAULT_COLOR:Number			= 0x434343;
		public static const LIST_HEIGHT:Number					= 672;
		public static const LIST_WIDTH_PERCENT:Number			= .8;
		public static const LIST_SCROLLBAR_BG:uint				= 0x353535;
		public static const LIST_SCROLLBAR_FG:uint				= 0x696969;
		public static const LIST_ARROW_WIDTH:int				= 8;
		
		
		//
		// CONTENT settings
		//
		public static const CONTENT_AREA_HEIGHT:Number			= 598;
		public static const CONTENT_AREA_WIDTH:Number			= 400; // 445
		public static const CONTENT_COPY_WIDTH:Number			= 325;
		public static const CONTENT_MARGIN_LEFT:Number			= 17;
		public static const CONTENT_OPEN_BG:uint				= 0x222222;
		public static const CONTENT_LINE_COLOR:uint				= 0x343434;
		public static const MAX_SCROLL_SPEED:Number				= 30;
		public static const CONTENT_NAV_VERT_MARGIN:Number		= 109; // HOW far from the bottom edge the content's nav tiles should be
		public static const CONTENT_NAV_BG:uint					= 0x000000; //0x434343;
		public static const CONTENT_NAV_BG_ALPHA:Number			= .4;
		public static const CONTENT_NAV_INACTIVE_ALPHA:Number	= .5;
		public static const CONTENT_STROKE_COLOR:uint			= 0xa5a5a5;
		// VIDEO
		public static const CONTENT_VIDEO_AREA_WIDTH:Number		= 880;
		public static const CONTENT_VIDEO_AREA_HEIGHT:Number	= 598;
		public static const CONTENT_VIDEO_AREA_BG:uint			= 0x000000;
		// CONTENT ITEMS
		public static const CONTENT_ALPHA_ACTIVE:Number			= 1;
		public static const CONTENT_ALPHA_INACTIVE:Number		= .3;
		// SHAPE
		// public static const CONTENT_SHAPE_OFFSET:Number			= 58;
		// SCROLLBAR
		public static const CONTENT_SCROLL_BG		:uint			= 0x868686; // 0xFFFFFF; // 0xe7e7e7;
		public static const CONTENT_SCROLL_FG		:uint			= 0xFFFFFF; // 0xc6c6c6;// 0xCCCCCC; // ;
		public static const CONTENT_SCROLL_WIDTH	:int			= 20;
		// SCROLLBAR horizontal
		public static const CONTENT_SCROLL_HORZ_CONTAINER_BG		:uint		= 0x212121; //0x303030;
		public static const CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT	:int		= 27;
		
		
		// 
		// CONTEXT menu
		//
		public static const ENTER_FULLSCREEN:String 	= "Fullscreen";
		public static const EXIT_FULLSCREEN:String 		= "Exit";
		
		
		//
		// STATIC ASSET paths
		//
		public static const ASSET_MAP_PLUS:String		= "map-plus";
		public static const ASSET_CLOSE_BUTTON:String	= "close-button";
		public static const ASSET_LOGO_LIGHT:String		= "logo-light";
		public static const ASSET_LOGO_DARK:String 		= "logo-dark";
		public static const ASSET_CARET:String 			= "carat";
		public static const ASSET_SCREEN_BG:String		= "screen";
		public static const ASSET_WE_ARE_BG:String		= "we-are-bg";
		// ICONS
		public static const ICON_LIST:String			= "icon-list";
		public static const ICON_CLOUD:String			= "icon-cloud";
		
		
		/*public static const ICON_EXIT:String			= "icon-exit";
		public static const ICON_PREV_UP:String			= "icon-prev-up";
		public static const ICON_PREV_LEFT:String		= "icon-prev-left";
		public static const ICON_NEXT_DOWN:String		= "icon-next-down";
		public static const ICON_NEXT_RIGHT:String		= "icon-next-right";
		*/
		
		//
		// REMOTING
		//
//		public static const GATEWAY_PATH:String			= "amfphp/gateway.php";
		public static const GATEWAY_PATH:String			= "http://www.copacino.com/amfphp/gateway.php";
//		public static const GATEWAY_PATH:String			= "http://webdev.copacino.com/CF/amfphp/gateway.php";
		
		public static const SERVICE:String 				= "flashpress.FlashPressService";
		//	METHODS
		public static const GET_SITE_ASSETS:String 			= SERVICE + "." + "getSiteAssets";
		public static const GET_CATEGORIES:String 			= SERVICE + "." + "getCategories";
		public static const GET_SITE_CONTENT:String 		= SERVICE + "." + "getSiteContent";
		//public static const GET_SURFACE_CONTENT:String		= SERVICE + "." + "getSurfacePosts";
		public static const GET_POST_BY_ID:String			= SERVICE + "." + "getPostOrPageById"; 
		public static const GET_POST_ASSETS:String			= SERVICE + "." + "getPostAssets";
		public static const GET_MEDIA_BY_CATEGORY:String	= SERVICE + "." + "getMediaByCategory";
		
		
		
		//
		// URLs - used to generate and parse SWFAddress URLs
		//
		public static const URL_LOADING:String		= "loading";
		public static const URL_WE_ARE:String		= "we-are";
		public static const URL_WE_ARE_NOT:String	= "we-are-not";
		public static const URL_LIST:String			= "list";
		public static const URL_CONTENT:String		= "content";
		public static const URL_FULLSCREEN:String	= "full";
		
		public static const URL_AGENCY:String		= "the-agency";
		public static const URL_WORK:String			= "the-work";
		public static const URL_NEW:String			= "whats-new";
		public static const URL_GOOD_TIME:String	= "we-are";
		
		// URL flags
		public static const URL_FLAG_LARGE:String	= "large";
		
		
		//
		// TITLES - paired with url
		//
		private static var _titles:Dictionary = null;
		public static function get TITLES():Dictionary
		{
			if (_titles == null)
			{
				_titles = new Dictionary();
				_titles[URL_LOADING] = "loading";
				_titles[URL_WE_ARE] = "we are";
				_titles[URL_WE_ARE_NOT] = "we are not";	
			}
			return _titles;
		}

		
		
		// URL modifyers
		public static const URL_PARAM:String		= "+";
		
		
		//
		// STATE MACHINE
		//
		public static const FSM_STATE:String		= "state";
		public static const FSM_ACTION:String		= "action";
		
		
		
		//
		// NAV
		//
		public static const NAV_TOP_MARGIN:Number 		= 0;
		public static const NAV_LOGO_BG:uint			= 0x4f4f4f;
		// MOTION
		public static const NAV_REAVEAL_SPEED:Number 	= .6;
		public static const NAV_COLLAPSE_TIMER:Number 	= 2000;
		// COLORS
		public static const NAV_DEFAULT_HIGHLIGHT:uint	= 0xdb1a12;
		public static const NAV_DARKEST_COLOR:uint 		= 0x333433;
		public static const NAV_COLOR_OFFSET:uint 		= 0x111111;
		// 	MAIN
		public static const NAV_MAIN_AGENCY:String 		= "the agency";
		public static const NAV_MAIN_WORK:String 		= "the work";
		public static const NAV_MAIN_NEW:String 		= "what's new";
		public static const NAV_MAIN_GOOD_TIME:String 	= "we are";
		public static const NAV_MAIN:Array 				= [ 
							new NavData( NAV_MAIN_AGENCY, URL_WE_ARE, URL_AGENCY ), // [ URL_WE_ARE, URL_LIST ]), SWFAddressUtil.joinURISecondary([ URL_AGENCY ]) ),
							new NavData( NAV_MAIN_WORK, URL_WE_ARE, URL_WORK ), // [ URL_WE_ARE, URL_LIST ]), SWFAddressUtil.joinURISecondary([ URL_WORK ] ) ),
							// new NavData( NAV_MAIN_NEW, URL_WE_ARE, URL_NEW ), // [ URL_WE_ARE, URL_LIST ]), SWFAddressUtil.joinURISecondary([ URL_NEW  ] ) ),
							new NavData( NAV_MAIN_GOOD_TIME, URL_WE_ARE, URL_GOOD_TIME ) // [ URL_WE_ARE, URL_LIST ]), SWFAddressUtil.joinURISecondary([ URL_GOOD_TIME ]) )
		];
		
		// WORK sub nav
		public static const SUB_NAV_WORK_DISC:String	= "by discipline";
		public static const SUB_NAV_WORK_CLIENT:String	= "by client";
		
		
		
		//
		// WORDPRESS CATEGORY slugs
		//
		public static const WP_CAT_SECTIONS_AGENCY:String				= "agency";
		public static const WP_CAT_SECTIONS_WORK:String					= "work";
		//public static const WP_CAT_SECTIONS_WORK_BY_CLIENT:String 		= "work-by-client";
		//public static const WP_CAT_SECTIONS_WORK_BY_DISCIPLINE:String 	= "work-by-discipline";
		public static const WP_CAT_SECTIONS_WHATS_NEW:String			= "whats-new";
		public static const WP_CAT_SECTIONS_GOOD_TIME:String			= "what-we-are";
		
		public static const WP_SUB_CAT_CASE_STUDIES:String				= "case-studies";
		public static const WP_SUB_CAT_BLOG:String						= "blog";
		public static const WP_SUB_CAT_NEWS:String						= "news";
		
		public static const WP_CAT_WE_ARE:String						= "we-are";
		public static const WP_CAT_WE_ARE_NOT:String					= "we-are-not";
		public static const WP_CAT_SURFACE_LEVEL:String					= "surface-level";
		
		public static const WP_CAT_ACTIVE_VIDEO:String					= "video-active";
		
		
		
		//
		// TITLE
		//
		public static const TITLE_DEFAULT:String	= "[ copacino + fujikado ]";
		
		
		// 
		// TESTING
		//
		//public static const TESTING_LOAD_TIME:Number = 2 * 999; // MILLISECONDS
		
		
	}
	
	
	
	
}