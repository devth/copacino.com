package com.cf.view.component.list.content.items
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.view.component.tile.Tile;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import gs.TweenLite;

	public class ContentItemBase extends Component
	{
		// EVENTs
		public static const STATE_ACTIVE	:String		= "contentItem/state/active";
		public static const STATE_INACTIVE	:String		= "contentItem/state/inactive";
		
		public static const CURSOR_ENABLED:String		= "contentItem/cursor/enabled";
		public static const CURSOR_DISABLED:String		= "contentItem/cursor/disabled";
		public static const CURSOR_CLICK:String			= "contentItem/cursor/click";
		
		public static const MODE_LARGE	:String			= "contentItem/mode/large";
		public static const MODE_NORMAL	:String			= "contentItem/mode/normal";
		
		public static const MODE_LARGE_IS_READY:String	= "contentItem/status/largeIsReady";
		public static const MODE_LARGE_LOADING:String	= "contentItem/status/largeLoading";
		
		protected var _mode:String = MODE_NORMAL;
		
		// DATA
		protected var _assetInfo:AssetInfo;
		protected var _content:Sprite = new Sprite();
		protected var _aspectRatio:Number = 1.33; // DEFAULT
		protected var _isFirstItem:Boolean = false;
		protected var _isLastItem:Boolean = false;
		
		// VISUAL
		protected var _bg:Sprite = new Sprite(); 
		protected var _slate:Bitmap;
		protected var _captionContainer:Sprite = new Sprite();
		protected var _tint:Sprite = new Sprite();
		protected var _caption:Sprite = new Sprite();
		protected var _stroke:Shape = new Shape();
		
		// BUTTONS
		private var _viewLargeButton:Tile;
		private var _closeLargeButton:Tile;
		
		// CONTAINER
		
		public function ContentItemBase( assetInfo:AssetInfo )
		{
			super();
			this.name = assetInfo.name;
			
			_state = STATE_INACTIVE;
			_assetInfo = assetInfo;
			_slate = _assetInfo.slate;
			
			addChild( _bg );
			addChild( _content );
			addChild( _captionContainer );
			addChild( _stroke );
			addChild( _tint );
			
			_bg.mouseChildren = _bg.mouseEnabled;
			
			_tint.mouseChildren = _tint.mouseEnabled = false;
			_tint.alpha = 1 - Settings.CONTENT_ALPHA_INACTIVE;
			
			
			// TODO: tie tinting to scroll (for now just hide the tint)
			_tint.visible = false;
		}
		
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			// BUILD CAPTION
			if ( _assetInfo.slateMediaVO.post_excerpt != "" )
			{
				_captionContainer.addChild( _caption );
				var capText:TextField = TextFactory.TagText( _assetInfo.slateMediaVO.post_excerpt.toLowerCase() );
				var capBg:Sprite = new Sprite();
				capBg.addChild( new Bitmap( new BitmapData( capText.width + (Settings.TILE_TEXT_HORIZONTAL_MARGIN << 1), Settings.TILE_HEIGHT, false, Settings.CONTENT_NAV_BG ) ) );
				capBg.alpha = Settings.CONTENT_NAV_BG_ALPHA;
				capText.x = Settings.TILE_TEXT_HORIZONTAL_MARGIN;
				
				// capBg.mouseChildren = capBg.mouseEnabled = false;
				// capText.mouseEnabled = false;
				
				_caption.addChild( capBg );
				_caption.addChild( capText );

			}
			
			// Y
			//_captionContainer.y = Settings.CONTENT_AREA_HEIGHT - Settings.CONTENT_NAV_VERT_MARGIN + Settings.TILE_HEIGHT + 1;
			
			// VIEW LARGE button for work pieces
			if ( _assetInfo.isViewLargeEnabled )
			{
				_viewLargeButton = new Tile("view large", 0x555555, true );
				_viewLargeButton.alpha = .7;
				_viewLargeButton.x = (_caption.width == 0) ? 0 : _caption.width + Settings.TILE_MARGIN;
				_captionContainer.addChild( _viewLargeButton );
				
				_viewLargeButton.addEventListener( MouseEvent.MOUSE_DOWN, viewLarge_mouse_down );
			}
			
			position();
		}
		override protected function position() : void
		{
			super.position();
			
			/*if ( _mode == MODE_NORMAL )
			{
				_captionContainer.y = Settings.CONTENT_AREA_HEIGHT - Settings.CONTENT_NAV_VERT_MARGIN + Settings.TILE_HEIGHT + 1;
			}
			else if ( _mode == MODE_LARGE )
			{
				// CAPTION
				_captionContainer.y = stage.stageHeight - Settings.CONTENT_NAV_VERT_MARGIN + Settings.TILE_HEIGHT + 1;
			}*/
			
			_captionContainer.y = _bottomEdge - Settings.CONTENT_NAV_VERT_MARGIN + Settings.TILE_HEIGHT + 1;
			
			// DISABLE VIEW LARGE
			if ( _bottomEdge < Settings.CONTENT_AREA_HEIGHT )
			{
				if ( _viewLargeButton != null ) _viewLargeButton.visible = false;	
			}
			else
			{
				if ( _viewLargeButton != null ) _viewLargeButton.visible = true;
			}
			
			// CAPTION X
			/*if ( desiredWidth > stage.stageWidth && _mode == MODE_LARGE )
			{
				//TweenLite.to( _captionContainer, 1, { x: (desiredWidth - stage.stageWidth) >> 1 });
				_captionContainer.x = (desiredWidth - stage.stageWidth) >> 1;
			}
			else if ( desiredWidth > (stage.stageWidth * Settings.LIST_WIDTH_PERCENT) && _mode == MODE_NORMAL )
			{
				//TweenLite.to( _captionContainer, 1, { x: (desiredWidth - (stage.stageWidth * Settings.LIST_WIDTH_PERCENT)) >> 1 });
				_captionContainer.x = (desiredWidth - (stage.stageWidth * Settings.LIST_WIDTH_PERCENT)) >> 1;
			}
			else
			{
				_captionContainer.x = 0;
			}*/
			
			
			// SIZE tint to content
			_tint.width = desiredWidth; // _content.width;
			_tint.height = desiredHeight; // _content.height;
			
			// STROKE
			_stroke.x = desiredWidth;
			_stroke.height = desiredWidth;
		}
		override public function get desiredHeight():Number
		{
			if ( _mode == MODE_LARGE ) return stage.stageHeight;
			else 
			{
				if ( stage.stageHeight < (Settings.CONTENT_AREA_HEIGHT + (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT)) )
				{
					return ( stage.stageHeight - (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT));
				}
				else
					return Settings.CONTENT_AREA_HEIGHT;
			}
		}
		
		//
		// PROTECTED
		//
		protected function addStroke():void
		{
			if ( !_isLastItem )
			{
				// STROKE
				_stroke.graphics.lineStyle( 1, Settings.CONTENT_STROKE_COLOR );
				_stroke.graphics.lineTo( 0, Settings.CONTENT_AREA_HEIGHT );
				_stroke.x = this.width;
			}
		}
		
		
		//
		// EVENT HANLDERS
		//
		protected function viewLarge_mouse_down(e:MouseEvent):void
		{
			dispatchEvent( new Event( MODE_LARGE, true, true ) );
		}
		protected function closeLarge_mouse_down(e:MouseEvent):void
		{
			dispatchEvent( new Event( MODE_NORMAL, true, true ) );
		}
		
		
		//
		// PRIVATE
		//
		private function createCloseButton():void
		{
			_closeLargeButton = new Tile("exit large", 0x555555 );
			_closeLargeButton.alpha = .7;
			_closeLargeButton.x = (_caption.width == 0) ? 0 : _caption.width + Settings.TILE_MARGIN;
			
			_captionContainer.addChild( _closeLargeButton );
			
			_closeLargeButton.addEventListener( MouseEvent.MOUSE_DOWN, closeLarge_mouse_down );
		}
		private function get _bottomEdge():Number
		{
			if ( _mode == MODE_NORMAL)
			{
				if ( stage.stageHeight < ( Settings.CONTENT_AREA_HEIGHT + (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT) ) )
				{
					return stage.stageHeight - (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT);	
				}
				else
					return Settings.CONTENT_AREA_HEIGHT;
			}
			else
			{
				return stage.stageHeight;
			}
			
		}
		
		//
		// PROTECTED
		//
		protected function initTint(width:Number, height:Number):void
		{
			_tint.addChild( new Bitmap( new BitmapData( width, height, false, Settings.MODAL_TINT_COLOR ) ) );
			_tint.alpha = Settings.MODAL_TINT_ALPHA;
			
			if ( _isFirstItem ) _tint.alpha = 0; 
		}
		
		//
		// PUBLIC API
		//
		public function get tint():Sprite
		{
			return _tint;
		} 
		public function toActive():void
		{	
			TweenLite.to( _tint, .6, { alpha: 1 - Settings.CONTENT_ALPHA_ACTIVE } );
			this.state = STATE_ACTIVE;
		}
		public function toInactive( useTint:Boolean = true ):void
		{
			if ( useTint ) TweenLite.to( _tint, .6, { alpha: 1 - Settings.CONTENT_ALPHA_INACTIVE } );
			this.state = STATE_INACTIVE;
			
		}
		public function toModeLarge():void
		{
			// UPDATE mode 1st so mode-dependent functions will be accurate
			_mode = MODE_LARGE;
			
			if ( _closeLargeButton == null ) createCloseButton();
			
			// SWAP buttons (if they exist)
			if ( _closeLargeButton ) _closeLargeButton.visible = true;
			if ( _viewLargeButton ) _viewLargeButton.visible = false;
			
			// CAPTION
			TweenLite.to( _captionContainer, 1, { y: stage.stageHeight - Settings.CONTENT_NAV_VERT_MARGIN + Settings.TILE_HEIGHT + 1 });
			
			// RESIZE TINT
			TweenLite.to( _tint, .8, { delay:1, width: desiredWidth, height: desiredHeight } );
			
			// STROKE
			TweenLite.to( _stroke, 1, { delay:1, x: desiredWidth, height: desiredHeight } );
			
		}
		public function toModeNormal():void
		{
			// UPDATE mode 1st so mode-dependent functions will be accurate
			_mode = MODE_NORMAL;
			
			// SWAP buttons
			if ( _closeLargeButton ) _closeLargeButton.visible = false;
			if ( _viewLargeButton ) _viewLargeButton.visible = true;
			
			// RECALC desired size
			//var scale:Number = desiredHeight / Settings.CONTENT_AREA_HEIGHT;
			//this.desiredWidth = desiredWidth / scale;
			//this.desiredHeight = desiredHeight / scale;
			
			// CAPTION y
			TweenLite.to( _captionContainer, 1, { y: Settings.CONTENT_AREA_HEIGHT - Settings.CONTENT_NAV_VERT_MARGIN + Settings.TILE_HEIGHT + 1 });
			
			// RESIZE TINT
			TweenLite.to( _tint, 1, { width: desiredWidth, height: desiredHeight } );
			
			// STROKE
			TweenLite.to( _stroke, .8, { x: desiredWidth, height: desiredHeight } );
			
		}
		public function get aspectRatio():Number
		{
			return _aspectRatio;
		}
		public function set isFirstItem( b:Boolean ):void
		{
			_isFirstItem = b;
		}
		public function set isLastItem( b:Boolean ):void
		{
			_isLastItem = b;
		}
		
	}
}