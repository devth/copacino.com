package com.cf.view.component.list.content
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.AssetManager;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.util.Utility;
	import com.cf.view.component.list.content.items.ContentItemBase;
	import com.cf.view.component.tile.Tile;
	import com.cf.view.event.UIEvent;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import flashpress.vo.WpPostVO;

	
	
	// ABSTRACT CLASS
	public class ContentBase extends Component implements IContentBase
	{
		private static const windowsCRLF:RegExp = /\r\n/gm;
		
		// EVENTS
		public static const ASSETS_LOADED:String	= "event/assets/loaded";
		
		// STATES
		public static const STATE_HIDDEN:String		= "ListTileContent/hidden";
		public static const STATE_NORMAL:String		= "ListTileContent/revealed";
		public static const STATE_LARGE:String		= "listtilecontent/large";
		
		// DATA
		protected var _color:uint;
		
		protected var _postData:WpPostVO;
		protected var _assetInfoArray:Array; // Array of AssetInfo objects
		
		protected var _numberLoaded:int = 0;
		protected var _minScroll:Number = 0;
		protected var _maxScroll:Number = 0;
		protected var _isScrolling:Boolean = false;
		
		// VISUAL
		protected var _contentContainer:Sprite;
		protected var _bg:Sprite;
		protected var _mediaContainer:Sprite;
		protected var _copy:TextField;
		
		protected var _scrollbar:Sprite;
		protected var _scrolltrack:Shape;
		
		private var _loaderContainer:Sprite;
		private var _loaderText:TextField;
		
		private var _linksContainer:Sprite;

		//
		// OVERRIDES
		//
		protected override function init():void
		{
			super.init();
			
			// COPY BG (white)
			_bg = new Sprite();
			_bg.graphics.beginFill( 0xFFFFFF );
			_bg.graphics.drawRect( 0,0, Settings.CONTENT_AREA_WIDTH, Settings.CONTENT_AREA_HEIGHT );
			_bg.alpha = 0;
			addChild( _bg );
			// TweenLite.to( _bg, .5, { alpha: 1 });
			
			// CONTAINER
			_contentContainer = new Sprite();
			addChild( _contentContainer );
			
			// MEDIA CONTAINER
			_mediaContainer = new Sprite();
			_contentContainer.addChild( _mediaContainer );
			_mediaContainer.x = Settings.CONTENT_AREA_WIDTH;
			
			// LOAD INDICATOR
			_loaderContainer = new Sprite();
			_contentContainer.addChild( _loaderContainer );
			_loaderContainer.x = Settings.CONTENT_AREA_WIDTH;
			_loaderContainer.y = Settings.CONTENT_AREA_HEIGHT - 38 - Settings.TILE_HEIGHT;
		}
		
		
		
		//
		// NON-ABSTRACT
		//
		public function set postData(val:WpPostVO):void
		{ _postData = val; createPostContent(); }
		public function set assetInfoArray( assetInfoArray:Array ):void
		{ _assetInfoArray = assetInfoArray; createLoader(); }
		protected function createLoader():void
		{
			// CREATE LOADER
			_loaderText = TextFactory.TagText( "0 of " + _assetInfoArray.length );
			
			var bg:Sprite = new Sprite();
			bg.addChild( new Bitmap( new BitmapData( _loaderText.width + (Settings.TILE_TEXT_HORIZONTAL_MARGIN << 1), Settings.TILE_HEIGHT, false, _color )));
			_loaderText.x = Settings.TILE_TEXT_HORIZONTAL_MARGIN;
			_loaderText.y = (bg.height >> 1) - (_loaderText.height >> 1);
			_loaderContainer.addChild( bg );
			_loaderContainer.addChild( _loaderText );
			_loaderContainer.alpha = 0;
			TweenLite.to( _loaderContainer, 1, { alpha: 1 });
			
		}
		protected function createPostContent():void
		{
			// COPY
			var copyHTML:String = _postData.post_content; 
			copyHTML = copyHTML.replace(windowsCRLF, "\n"); // FIX double carriage returns 
			//copyHTML = copyHTML.replace(/’/g, "'");
			//copyHTML = copyHTML.replace(/“/g, "&#147;");
			//copyHTML = copyHTML.replace(/”/g, "&#148;");
			//copyHTML = copyHTML.replace(/—/g, "&#151;");
			//copyHTML = copyHTML.replace(/–/g, "&#150;");
			//copyHTML = copyHTML.replace(/—/g, "&#150;");
			
			
			
			_copy = TextFactory.BodyCopyText( copyHTML );
			_copy.x = Settings.CONTENT_MARGIN_LEFT;
			_copy.y = 120;
			_contentContainer.alpha = 0;
			_contentContainer.addChild( _copy );
			
			TweenLite.to( _contentContainer, .4, { alpha:1 });
			
			
			// CUSTOM "who we are" links:
			_linksContainer = new Sprite();
			_contentContainer.addChild( _linksContainer );
			_linksContainer.y = 450;
			
			// WHO WE ARE
			if ( _postData.post_title.toLowerCase() == "who we are" )
			{
				var mediaLink:Tile = new Tile( "c+f media", AssetManager.mediaColor, true );
				_linksContainer.addChild( mediaLink );
				mediaLink.addEventListener( MouseEvent.CLICK, function():void {
					dispatchEvent( new UIEvent( UIEvent.URL_EVENT, "media", Settings.URL_GOOD_TIME + "/media" ));
				});
				
				var rdLink:Tile = new Tile("c+f r+d", AssetManager.rdColor, true);
				_linksContainer.addChild( rdLink );
				rdLink.y = Settings.TILE_ROW_HEIGHT;
				rdLink.addEventListener( MouseEvent.CLICK, function():void {
					dispatchEvent( new UIEvent( UIEvent.URL_EVENT, "r+d", Settings.URL_GOOD_TIME + "/rd" ));
				});
			}
			
			
			// CREATE scrollbar if necessary
			if ( (_copy.height + _copy.y) > (Settings.CONTENT_AREA_HEIGHT - 2))
			{
				// LOWER the height and create a scrollbar
				_copy.height = (Settings.CONTENT_AREA_HEIGHT - _copy.y - 10);
				createScrollbar();
			}
		}
		protected function createScrollbar():void
		{
			_minScroll = _copy.y;
			_maxScroll = _copy.y + _copy.height;
			
			// SCROLL TRACK
			_scrolltrack = new Shape();
			_scrolltrack.graphics.beginFill( Settings.CONTENT_SCROLL_BG, 1 );
			_scrolltrack.graphics.drawRect( 0,0, Settings.CONTENT_SCROLL_WIDTH, _maxScroll - _minScroll );
			_contentContainer.addChild( _scrolltrack ); 
			
			// SCROLL BAR
			_scrollbar = new Sprite();
			_scrollbar.graphics.beginFill( _color, 1 );
			_scrollbar.graphics.drawRect( 0, 0, Settings.CONTENT_SCROLL_WIDTH, _copy.height * .8 ); // SQUARE
			_scrollbar.graphics.endFill();
			_scrollbar.buttonMode = true;
			_scrollbar.alpha = .99;
			_contentContainer.addChild( _scrollbar );
			// INVISLBE clickable area
			var clickArea:Bitmap = new Bitmap( new BitmapData( Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT, _scrollbar.height, true, 0x00000000 ) );
			clickArea.x = -(clickArea.width >> 1) + (_scrollbar.width >> 1);
			_scrollbar.addChild( clickArea );
			
			// WIRE EVENTS
			_scrollbar.addEventListener( MouseEvent.MOUSE_DOWN, scrollbar_mouse_down );
			_copy.addEventListener( MouseEvent.MOUSE_WHEEL, copy_mouse_wheel );
			
			// POSITION
			_scrollbar.x = _scrolltrack.x = _copy.width + _copy.x + 30; 
			_scrolltrack.y = _scrollbar.y = _minScroll;
		}
		protected function assets_loaded():void
		{
			dispatchEvent( new Event( ASSETS_LOADED ) );
		}
		public function delargify():void
		{
			state = STATE_NORMAL;
			
			// FADE IN copy
			TweenLite.to( _copy, .8, { autoAlpha: 1 });
		}
		public function largify():void
		{
			state = STATE_LARGE;
			
			// FADE OUT copy
			TweenLite.to( _copy, .8, { autoAlpha: 0 });
		}
		public function addLoadedAsset( ai:AssetInfo ):void
		{
			_loaderText.text = (_numberLoaded + 1) + " of " + _assetInfoArray.length
				
			if ( (_numberLoaded+1) == _assetInfoArray.length )
			{
				TweenLite.to( _loaderContainer, 1, { alpha: 0 });
			}
		}
		public function hide():void
		{
			state = STATE_HIDDEN;
			TweenLite.to( _bg, .5, { alpha: 0 });
		}
		public function show():void
		{
			this.state = STATE_NORMAL;
			TweenLite.to( _bg, .5, { alpha: 1 });
		}
		public function load_complete():void
		{
		}
		
		//
		// PRIVATE
		//
		private function setAmountScrolled( percent:Number ):void
		{
			// COPY
			_copy.scrollV = percent * _copy.maxScrollV;
			
			// SCROLL BAR
			if ( !_isScrolling )
				TweenMax.to( _scrollbar, .5, { ease: Strong.easeOut, y: Utility.boundNumber( _minScroll + ( percent * (_maxScroll-_minScroll)), _minScroll, _maxScroll - _scrollbar.height ) } );
		}
		
		//
		// EVENT HANLDERS
		//
		private function copy_mouse_wheel(e:MouseEvent):void
		{
			if ( e.delta < 0 && _copy.scrollV == 0 ) return; // AT MIN
			if ( e.delta > 0 && _copy.scrollV == _copy.maxScrollV ) return; // AT MAX
			setAmountScrolled( ((_copy.scrollV-1) - int(e.delta/1.4)) / _copy.maxScrollV );
		}
		private function scrollbar_mouse_down(e:MouseEvent):void
		{
			_isScrolling = true;
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
			stage.addEventListener( Event.MOUSE_LEAVE, stage_mouse_leave );
			this.addEventListener( Event.ENTER_FRAME, enter_frame );
			_scrollbar.startDrag( false, new Rectangle( _scrollbar.x, _minScroll, 0, _maxScroll - _scrollbar.height - _minScroll ) );
		}
		private function stage_mouse_up(e:Event):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
			stage.removeEventListener( Event.MOUSE_LEAVE, stage_mouse_leave );
			this.removeEventListener( Event.ENTER_FRAME, enter_frame );
			_isScrolling = false;
			_scrollbar.stopDrag();
		}
		private function stage_mouse_leave(e:Event):void
		{
			stage_mouse_up(null);
		}
		private function enter_frame(e:Event):void
		{
			var percentScrolled:Number = (_scrollbar.y - _minScroll) / (_maxScroll - _scrollbar.height -_minScroll);
			trace( percentScrolled );
			setAmountScrolled(percentScrolled);
		}
		
		
		
		//
		// ABSTRACT PROTECTED METHODS
		//
		
		
		//
		// ABSTRACT PUBLIC METHODS
		//
		public function setActiveSegment( index:Number ):void
		{
			throw new Error("Abstract method.  Must be overridden in subclass");
		}
		public function get currentActiveContent():ContentItemBase
		{
			throw new Error("Abstract method.  Must be overridden in subclass");
		}
		public function get contentWidth():Number
		{
			throw new Error("Abstract method.  Must be overridden in subclass");
		}
		
	}
}