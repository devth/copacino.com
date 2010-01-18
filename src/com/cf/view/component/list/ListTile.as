package com.cf.view.component.list
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.model.vo.ListItem;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.util.Utility;
	import com.cf.view.component.OpacityLines;
	import com.cf.view.component.list.content.ContentBase;
	import com.cf.view.component.list.content.ListTileContent;
	import com.cf.view.component.list.content.custom.Contact;
	import com.cf.view.component.list.content.custom.Newsroom;
	import com.cf.view.component.list.content.items.ContentItemBase;
	import com.cf.view.component.scrollbar.Scrollbar;
	import com.cf.view.event.UIEvent;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import flashpress.vo.WpPostCategoryVO;
	import flashpress.vo.WpPostVO;

	public class ListTile extends Component
	{
		public static const STATE_MINIMIZED:String		= "listTileMinimized";
		public static const STATE_MAGNIFIED:String		= "listTileMagnified";
		public static const STATE_MAXIMIZED:String		= "listTileMaximized";
		public static const STATE_LARGE:String			= "listTileLarge";
		public static const STATE_HIDDEN:String			= "listTileHidden";
		
		private static const INACTIVE_TILE_ALPHA:Number 		= .4;
		private static const TILE_BG_ALPHA:Number				= .5;
		private static const MAX_SCROLL_SPEED:Number			= 30;
				
		// VISUAL
		private var _mask:Bitmap;
		private var _bg:Sprite;
		private var _bgLines:OpacityLines;
		private var _shapeSmall:Sprite;
		
		private var _closeButton:Sprite;
		
		private var _scrollbar:Scrollbar;
		
		// CONTAINERS
		private var _tagsContainer:Sprite;
		private var _navContainer:Sprite;
		private var _slidingContainer:Sprite;
		private var _contentContainer:Sprite;
		private var _content:ContentBase;
		private var _contentNav:ContentNavTile;
		
		// CURSORS
		private var _cursorContainer:Sprite;
		private var _cursor_prev:Sprite;
		private var _cursor_next:Sprite;
		
		// DATA
		private var _isScrolling				:Boolean	= false;
		private var _isHorzScrollingEnabled		:Boolean 	= false;
		private var _scrollbarPercent			:Number		= 1;
		
		private var _tileHeight					:Number;
		private var _isFullscreen				:Boolean 	= false;
		private var _url						:String;
		private var _currentIndex				:Number 	= 1;
		private var _assetsArray				:Array;
		
		public var originalY:Number;
		private var _displayIndex:int;
		
		private var _title:String;
		private var _color:uint;
		private var _listItem:ListItem;
		
		
		public function ListTile( listItem:ListItem, color:uint, url:String )
		{
			//_title = title;
			_color = color;
			_listItem = listItem;
			_url = url;
			
			super();
			
			state = STATE_HIDDEN;
			
			//this.addEventListener( MouseEvent.MOUSE_MOVE, mouse_move );
			 this.addEventListener( Event.ENTER_FRAME, enter_frame );
			this.addEventListener( MouseEvent.ROLL_OVER, roll_over );
			this.addEventListener( MouseEvent.ROLL_OUT, roll_out );
			this.addEventListener( ContentNavItem.EVENT_SET_ACTIVE, contentNav_set_active );
			this.addEventListener( MouseEvent.MOUSE_WHEEL, mouse_wheel );
			
			if ( listItem.type == ListItem.LIST_ITEM_TYPE_SECTION ) _tileHeight = Settings.TILE_MARGIN + (Settings.TILE_HEIGHT << 1);
			else _tileHeight = Settings.TILE_HEIGHT;
			
			// SMALL SHAPE container
			_shapeSmall = new Sprite();
			addChild( _shapeSmall );
		}
		
		//
		// OVERRIDES
		//
		override protected function init():void
		{
			// BACKGROUND
			_bg = new Sprite();
			_bg.addChild( new Bitmap(new BitmapData((stage.stageWidth * Settings.LIST_WIDTH_PERCENT), _tileHeight, false, _color)));
			addChild(_bg);
			_bg.alpha = TILE_BG_ALPHA;
			
			// BG LINES
			_bgLines = new OpacityLines( Settings.CONTENT_LINE_COLOR );
			_bgLines.y = 3;
			_bgLines.setMinHeight( Settings.CONTENT_AREA_HEIGHT );
			_bgLines.setWidth( stage.stageWidth );
			// addChild( _bgLines );
			_bgLines.alpha = 0;
			
			// MASK
			_mask = Utility.getMaskShape( _bg.width, getMaxHeight() );
			_mask.width = 0;
			addChild( _mask );
			this.mask = _mask;
			
			// SLIDING CONTENT CONTAINER
			_slidingContainer = new Sprite();
			addChild( _slidingContainer );
			
			// CONTENT CONTAINER
			_contentContainer = new Sprite();
			// _contentContainer.mouseEnabled = _contentContainer.mouseChildren = false;
			_slidingContainer.addChild( _contentContainer );
			
			// TAGS CONTAINER
			_tagsContainer = new Sprite();
			_tagsContainer.mouseChildren = _tagsContainer.mouseEnabled = false;
			_slidingContainer.addChild( _tagsContainer );
			
			// NAV CONTAINER
			_navContainer = new Sprite();
			addChild( _navContainer );
			
			// ADD TITLES
			createTitleTags();
			
			// HORIZONTAL SCROLL
			_scrollbar = new Scrollbar( getExpectedWidth(), Settings.TILE_ROW_HEIGHT, Scrollbar.ORIENTATION_HORIZONTAL, 1 );
			_scrollbar.y = Settings.CONTENT_AREA_HEIGHT;
			addChild( _scrollbar );
			_scrollbar.visible = false;
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_START, scrollbar_start );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_STOP, scrollbar_stop );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_UPDATE, scrollbar_update );
		}
		override protected function position() : void
		{
			super.position();
						
			_scrollbar.width = getExpectedWidth();
			
			// BG LINES
			_bgLines.setWidth( stage.stageWidth );
			
			if ( state != STATE_HIDDEN )
			{
				if ( state == STATE_MAXIMIZED )
				{
					_bg.width = _mask.width = int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
					_bg.height = Settings.CONTENT_AREA_HEIGHT;
					
					// FIX SCROLLBAR to bottom edge
					_scrollbar.y = bottomEdge; // - _scrollbarContainer.height;
				}
				else if ( state == STATE_MINIMIZED || state == STATE_MAGNIFIED )
				{
					_bg.width = _mask.width = int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
				}
				else if ( state == STATE_LARGE )
				{
					_bg.width = stage.stageWidth; // int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
					_bg.height = stage.stageHeight;
					_mask.width = stage.stageWidth;
					_mask.height = stage.stageHeight;
					
					// SCROLLBAR
					//_scrollbarBg.width = getExpectedWidth();
					//_scrollbarGutterBg.width = getListWidth() - 30;
					//_scrollbarGutter.x = (_scrollbarBg.width >> 1) - ( _scrollbarGutter.width >> 1 );
					_scrollbar.y = stage.stageHeight - _scrollbar.height;
				}
				
				// ENABLE / DISABLE HORIZONTAL SCROLLING as necessary
				if ( _content != null )
				{
					scrollAsNeeded();	
					scrollUsingScrollbar();
				}
				
			}
			
			if ( _contentNav != null )
			{
				_contentNav.y = this.height - Settings.CONTENT_NAV_VERT_MARGIN;
			}
		}
		 
		override public function get height():Number
		{
			return _bg.height;
		}
		
		//
		// EVENT HANDLERS
		//
//		private function stage_mouse_up(e:MouseEvent):void
//		{
//			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
//			stage.removeEventListener( Event.MOUSE_LEAVE, stage_mouse_leave );
//			this.removeEventListener( Event.ENTER_FRAME, enter_frame );
//			_isScrolling = false;
//			_scrollbarSlider.stopDrag();
//		}
//		private function stage_mouse_leave(e:Event):void
//		{
//			//stage_mouse_up(null);
//		}
//		private function scrollbarSlider_mouse_down(e:MouseEvent):void
//		{
//			_isScrolling = true;
//			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
//			stage.addEventListener( Event.MOUSE_LEAVE, stage_mouse_leave );
//			this.addEventListener( Event.ENTER_FRAME, enter_frame );
//
//			var dragBounds:Rectangle = new Rectangle( 0, _scrollbarSlider.y, _scrollbarGutter.width - _scrollbarSlider.width, 0 );
//			_scrollbarSlider.startDrag( false, dragBounds );
//		}
		
		
		
		private function mouse_wheel( e:MouseEvent ):void
		{
			if ( (state == STATE_MAXIMIZED || state == STATE_LARGE) && _isHorzScrollingEnabled )
			{
				/*var toX:Number = Utility.boundNumber( _scrollbarSlider.x - (e.delta * 1000 / ( _scrollbarSlider.width )), _minSlider, _maxSlider );
				_scrollbarSlider.x = toX;
				var percentScrolled:Number = (_scrollbarSlider.x - _minSlider) / (_maxSlider - _minSlider);
				
				setAmountScrolled( percentScrolled );*/
				
				_scrollbar.scrollByDelta( e.delta );
			}
		}
		private function content_mode_small(e:Event):void
		{
			// CHANGE url to return to normal
			dispatchEvent( new UIEvent( UIEvent.URL_EVENT, _listItem.postData.postTitle, _url + "/" + _currentIndex, true, true ) );
		}
		private function content_mode_large(e:Event):void
		{
			// CHANGE url to go large
			if ( _currentIndex == 0 ) _currentIndex = 1;
			dispatchEvent( new UIEvent( UIEvent.URL_EVENT, _listItem.postData.postTitle, _url + "/" + _currentIndex + "/" + Settings.URL_FLAG_LARGE, true, true ) );
		}
		private function contentNav_set_active(e:Event):void
		{
			// DISPATCH event to change url
			var item:ContentNavItem = e.target as ContentNavItem;
			
			dispatchEvent( new UIEvent( UIEvent.URL_EVENT, _listItem.postData.postTitle, _url + "/" + item.number, true, true ) );
		}
		private function roll_over(e:MouseEvent):void
		{
			if ( this.state == STATE_MINIMIZED && this.listItem.type != ListItem.LIST_ITEM_TYPE_SECTION) _bg.alpha = .8;
		}
		private function roll_out(e:MouseEvent):void
		{
			if ( this.state == STATE_MINIMIZED ) _bg.alpha = TILE_BG_ALPHA; // INACTIVE_TILE_ALPHA;
		}
		private function disableHorzScroll():void
		{
			// TODO large view positioning
			TweenLite.to( _scrollbar, .8, { y: Settings.CONTENT_AREA_HEIGHT - Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT });
			_isHorzScrollingEnabled = false;
			_scrollbar.visible = false;
		}
		private function enableHorzScroll():void
		{
			// TODO large view positioning
			TweenLite.to( _scrollbar, .8, { y: Settings.CONTENT_AREA_HEIGHT });
			_isHorzScrollingEnabled = true;
			_scrollbar.visible = true;
		}
		private function showVertScroll():void
		{
			
		}
		private function content_assets_loaded(e:Event):void
		{
			// check if scrolling is necessary
			scrollAsNeeded();
		}
		private function scrollUsingScrollbar():void
		{
			setAmountScrolled( _scrollbar.percentScrolled );	
		}
		private function enter_frame(e:Event):void
		{
			if ( _isScrolling ) scrollUsingScrollbar();
		}
		
		//
		// PRIVATE
		//
		private function scrollbar_stop(e:Event):void
		{
			_isScrolling = false;
		}
		private function scrollbar_start(e:Event):void
		{
			_isScrolling = true;
		}
		private function scrollbar_update(e:Event):void
		{
			scrollUsingScrollbar();
		}
		private function getContentToViewportRatio():Number
		{
			var contentWidth:Number = _content.width;
			var viewableWidth:Number = getExpectedWidth();
			//var scrollAreaWidth:Number = getListWidth();
			//var scrollbarWidth:Number = (viewableWidth * scrollAreaWidth) / contentWidth;
			
			return viewableWidth / contentWidth;
			// return scrollbarWidth;
		}
		private function scrollAsNeeded():void
		{
			if ( (_content.width) > getExpectedWidth() )
			{
				// SCROLLBAR SLIDER WIDTH
				// TweenLite.to( _scrollbar, .2, { ease:Strong.easeOut, width: getExpectedScrollbarWidth() });
				
				// SET scrollbar content ratio
				_scrollbar.contentRatio = getContentToViewportRatio(); 
				
				if ( !_isHorzScrollingEnabled ) enableHorzScroll();
			}
			else
			{
				if ( _isHorzScrollingEnabled ) disableHorzScroll();
			}
		}
		private function get _minScroll():Number
		{
			if ( state == STATE_LARGE ) return -Settings.CONTENT_AREA_WIDTH;
			else return 0;
		}
		private function get _maxScroll():Number
		{
//			if ( state == STATE_LARGE )
//			{
//				return -_content.contentWidth - getExpectedWidth();
//			}
//			else
				return -_content.contentWidth - Settings.CONTENT_AREA_WIDTH + getExpectedWidth();
		}
		//private function get _minSlider():Number { return 0; }
		//private function get _maxSlider():Number { return _scrollbarGutter.width - _scrollbarSlider.width }
			
		private function setAmountScrolled( percent:Number ):void
		{
			percent = Utility.boundNumber( percent, 0, 1 );
			// trace( percent );
			
			// CONTENT position
			var min:Number = getExpectedWidth() - _slidingContainer.width;
			_slidingContainer.x = _minScroll + (percent * (_maxScroll - _minScroll)); // Math.min( min, -_slidingContainer.width * percent );
			// _copy.scrollV = percent * _copy.maxScrollV;
			
			
			// SCROLL BAR
//			if ( !_isScrolling )
//				TweenMax.to( _scrollbarSlider, .5, { ease: Strong.easeOut, 
//					y: Utility.boundNumber( _minSlider + ( percent * (_maxSlider-_minSlider)), _minSlider, _maxSlider - getExpectedWidth() ) } );
		}
		private function getExpectedWidth():Number
		{
			if ( state == STATE_LARGE )
			{
				return stage.stageWidth;
			}
			else
			{
				return getListWidth();
			}
		}
		private function getListWidth():Number
		{
			return int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
		}
		
		private function buildContentNav( count:Number ):void
		{
			//_contentNav = new ContentNavTile( count );
			// _contentNav.x = -_contentNav.width;
			
			// _contentNav.alpha = 0;
			// TweenLite.to( _contentNav, .8, { alpha:1 } );
			
			// _navContainer.addChild( _contentNav );
			position();
		}
		private function getWidth():Number
		{
			if ( this.state == STATE_LARGE ) return stage.stageWidth;
			else return stage.stageWidth * Settings.LIST_WIDTH_PERCENT;
		}
		private function getMaxHeight():Number
		{
			// TODO: make dynamic based on browser height, snapped to lines
			return Settings.CONTENT_AREA_HEIGHT;
		}
		private function createTitleTags():void
		{
			// GENERATE titles array
			var titlesArray:Array = new Array();
			if ( _listItem.type == ListItem.LIST_ITEM_TYPE_SECTION ) titlesArray = [ _listItem.sectionTitle ];
			else if ( _listItem.type == ListItem.LIST_ITEM_TYPE_POST )
			{
				// LOOP post tags
				for each (var tag:WpPostCategoryVO in _listItem.postData.tags)
				{
					titlesArray.push( tag.categoryName );
				}
				
				// FOR "What's New" - we add a date tile
				if ( _listItem.sectionTitle == Settings.NAV_MAIN_NEW )
				{
					var date:Date = Utility.parseDate( _listItem.postData.postDate );
					titlesArray.push( (date.month+1) + "/" + date.date + "/" + date.fullYear );
				}
				
				// ADD post title last
				titlesArray.push( _listItem.postData.postTitle );
			}
			
			// CREATE visual tags
			var tileAlpha:Number = 1;
			for each (var title:String in titlesArray)
			{
				addTag( title.toLowerCase(), tileAlpha );
				if ( tileAlpha > .2 ) tileAlpha -= .25;
			}
		}

		private var _currentX:Number = 0;
		private function addTag(title:String, alpha:Number):void
		{
			var sprite:Sprite = new Sprite();
			sprite.alpha = alpha;
			_tagsContainer.addChild( sprite );
			
			// TITLE
			var titleText:TextField = TextFactory.TagText( title );
			titleText.scaleX = titleText.scaleY = _tileHeight / Settings.TILE_HEIGHT;
			sprite.addChild( titleText );
			
			// BACKGROUND
			var bg:Bitmap = new Bitmap(new BitmapData(titleText.width + Settings.TILE_TEXT_HORIZONTAL_MARGIN, _tileHeight, false, _color));
			sprite.addChildAt( bg, 0 );
			
			// POSITION
			titleText.x = (bg.width >> 1) - (titleText.width >> 1);
			titleText.y = (bg.height >> 1) - (titleText.height >> 1);
			
			sprite.x = _currentX;
			_currentX += bg.width + Settings.TILE_MARGIN;
		}
		
		
		//
		// PUBLIC API
		//
		public function get bottomEdge():Number
		{
			if ( stage.stageHeight < ( Settings.CONTENT_AREA_HEIGHT + (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT) ) )
			{
				return stage.stageHeight - (2 * Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT);	
			}
			else
				return Settings.CONTENT_AREA_HEIGHT;
		}
		public function set bgAndMaskHeight(h:Number):void
		{
			_bg.height = _mask.height = h;
			
			//if ( _isHorzScrollingEnabled )
			//{
				_mask.height = h + Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT;
			//}
		}
		public function get bgAndMaskHeight():Number { return _bg.height; }
		
		public function setShapeSmall( ss:Sprite ):void
		{
			_shapeSmall.x = 0;
			_shapeSmall.addChild( ss );
		}
		
		public function reveal(delay:Number):void
		{
			if ( (state != STATE_HIDDEN || state != STATE_MINIMIZED) && listItem.type == ListItem.LIST_ITEM_TYPE_POST ) minimize();
			//_mask.width = 0;
			
			_bg.width = int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
			state = STATE_MINIMIZED;
			//trace(this, "reveal", delay);
			TweenMax.to( _mask, 2, { ease:Strong.easeInOut, delay:delay, width: int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT) })
		}
		public function hide(delay:Number):void
		{
			if ( state == STATE_HIDDEN ) return;
			
			state = STATE_HIDDEN;
			TweenMax.to( _mask, 2, { ease:Strong.easeInOut, delay:delay, width: 0 })
		}
		public function get listItem():ListItem
		{
			return _listItem;
		}
		public function createContent():void
		{
			// CREATE content
			switch ( _listItem.postData.postTitle.toLowerCase() )
			{
				case "newsroom":
					_content = new Newsroom( _color );
					break;
				case "contact":
					_content = new Contact( _color );
					break;
				default:
					_content = new ListTileContent( _color );
					break;
			}
			
			_contentContainer.addEventListener( ContentItemBase.MODE_LARGE, content_mode_large );
			_contentContainer.addEventListener( ContentItemBase.MODE_NORMAL, content_mode_small );			
			_content.addEventListener( ContentBase.ASSETS_LOADED, content_assets_loaded );
			
			_contentContainer.addChild( _content );			
		}
		
		// GET/SET content
		public function get content():ContentBase
		{
			return _content;
		}
		public function get tileHeight():Number { return _tileHeight; }
		
		// STATE transitions
		public function largify():TweenMax
		{
			// need to wait for current content item to be ready to transition
			if ( state == STATE_LARGE ) return TweenMax.to(this, 0, {}); 
			state = STATE_LARGE;
			
			_content.largify();
			
			// scrollToSegment( _currentIndex, 1 );
			
			// BG HEIGHTEN and TINT
			TweenMax.to( _bg, 1, { tint: Settings.CONTENT_OPEN_BG, height: stage.stageHeight, width: stage.stageWidth }); // 
			
			// ALIGN scrollbar
			TweenMax.to( _scrollbar, 1, { y: stage.stageHeight - _scrollbar.height, width: getExpectedWidth() });
			
			
			//TweenMax.to( _scrollbarGutter, 1, { x: ( stage.stageWidth - (getListWidth() - 30) >> 1) });
			//TweenMax.to( _scrollbarGutterBg, 1, { width: getListWidth() - 30 });
			
			// MASK ENLARGE
			TweenMax.to( _mask, 1, { width: stage.stageWidth });
			TweenMax.to( _mask, 1, { delay: 1, height: stage.stageHeight });
			
			// TAGS are fixed-position in large mode, instead of scrolling
			this.addChild( _tagsContainer );
			_tagsContainer.x = -_tagsContainer.width;
			
			// TAGS go back to 100%, push on top of contents
			TweenMax.to ( _tagsContainer, .3, { scaleX:1, scaleY:1, y: Settings.LIST_MARGIN_TOP + int(2.5 * (Settings.TILE_HEIGHT)) + Settings.TILE_MARGIN } );
			
			// SLIDE tags X in place
			var lastTag:DisplayObject = _tagsContainer.getChildAt(_tagsContainer.numChildren - 1) as DisplayObject;
			return TweenMax.to ( _tagsContainer, 1.5, { delay:1.5, x: int(2.5 * Settings.TILE_HEIGHT) + (3 * Settings.TILE_MARGIN) + (1 * -lastTag.x), ease:Strong.easeInOut }); // scaleX:1, scaleY:1, x:0, y:0 } );
		}
		public function maximize( slideTiles:Boolean = true ):TweenMax
		{
			if ( _scrollbar ) _scrollbar.percentScrolled = 0;
			
			var prevState:String = state;
			
			if ( state == STATE_MAXIMIZED ) return TweenMax.to(this, 0, {});
			if ( state == STATE_HIDDEN ) reveal(0); // NECESSARY in cases where we're just opening the tile for CLOUD_DISPLAY
			state = STATE_MAXIMIZED;
			
			// SLIDE tags left till only last tag is shown
			var lastTag:DisplayObject = _tagsContainer.getChildAt(_tagsContainer.numChildren - 1) as DisplayObject;
			if ( slideTiles )
				TweenLite.to( _tagsContainer, .8, { delay:.3, ease:Strong.easeInOut, x: 2 * -lastTag.x } );
			
			// BRIGHTEN all tags
			for (var i:int = 0;i < _tagsContainer.numChildren; i++)
			{
				var s:DisplayObject = _tagsContainer.getChildAt( i );
				TweenMax.to(s, 1, { alpha: 1 });
			}
			
			// BG LINES
			TweenMax.to( _bgLines, 1, { alpha: 1 });
			
			// SHOW CONTENT
			if (_content != null)
			{
				if ( prevState == STATE_LARGE )
				{
					_content.delargify();
					// ALIGN scrollbar
					var scrollbarY:Number = Settings.CONTENT_AREA_HEIGHT;
					if ( stage.stageHeight < ((Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT * 2) + Settings.CONTENT_AREA_HEIGHT) )
					{
						scrollbarY = stage.stageHeight - _scrollbar.height - Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT;
					}
					TweenMax.to( _scrollbar, 1, { y: scrollbarY });
					
					//TweenMax.to( _scrollbarBg, 1, { width: getExpectedWidth() });
					//TweenMax.to( _scrollbarGutter, 1, { x: 15 });
					//TweenMax.to( _scrollbarGutterBg, 1, { width: getExpectedWidth() - 30 }); 
				}
				else
				{
					_content.show();
					// CHECK IF scrollbar needs to float
					if ( stage.stageHeight < ((Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT * 2) + Settings.CONTENT_AREA_HEIGHT) )
					{
						_scrollbar.y = stage.stageHeight - _scrollbar.height - Settings.CONTENT_SCROLL_HORZ_CONTAINER_HEIGHT;
					}
				}
			}
			
			
			
			// ENABLE HORIZONTAL SCROLLING
			// _isHorzScrollingEnabled = true;
			
			// RETURNING FROM large
			if ( prevState == STATE_LARGE )
			{
				// TINT back
				TweenMax.to( _bg, 1, { tint: Settings.CONTENT_OPEN_BG, height: Settings.CONTENT_AREA_HEIGHT });
				
				// SIZE mask + bg: _bg.width
				_mask.width = int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
				
				// TAGS SLIDE AGAIN
				_slidingContainer.addChild( _tagsContainer );
				
				// MOVE BACK
				scrollToSegment( _currentIndex, 0 );
			}
			else
			{
				// TINT BG
				TweenMax.to( _bg, .4, { tint: Settings.CONTENT_OPEN_BG, alpha:1 });
			}
			
			TweenMax.to( _tagsContainer, .4, { y: 2 * Settings.TILE_HEIGHT } );
			TweenMax.to( _tagsContainer, .2, { ease:Strong.easeInOut, scaleX:2, scaleY:2 } );
			
			
			
			// GROW BG AND MASK
			return TweenMax.to( this, .4, { ease:Strong.easeInOut, bgAndMaskHeight: getMaxHeight(), alpha:1 });
		}
		public function magnify():TweenMax
		{
			state = STATE_MAGNIFIED;
			
			var magnifyTime:Number = 1; //.2;
			
			this.alpha = 1;
			
			var magScale:Number = 1; // 2
			
			// MAGNIFY TAGS
			TweenMax.to ( _tagsContainer, magnifyTime, { ease:Strong.easeInOut, scaleX:magScale, scaleY:magScale, x:0, y:0 } );
			
			TweenMax.to( _bg, magnifyTime, { tint: null, alpha:INACTIVE_TILE_ALPHA } );
			
			// GROW BG and MASK
			return TweenMax.to( this, magnifyTime, { ease:Strong.easeInOut,
						bgAndMaskHeight: (Settings.TILE_HEIGHT * magScale) + ((magScale-1) * Settings.TILE_MARGIN)
			});
		}
		public function minimize():TweenMax
		{
			var prevState:String = state;
			state = STATE_MINIMIZED;
			
			// STOP current tweens
			//TweenMax.killTweensOf( this, true );
			//TweenMax.killTweensOf( _bg, true );
			//TweenMax.killTweensOf( _tagsContainer, true );
			
			// DECIDE close time
			var closeTime:Number = 1;//.02;
			if (prevState == STATE_MAXIMIZED)  // RETURNING from maximized
			{
				closeTime = .4;
				
				// RESTORE brightness
				var tileAlpha:Number = 1;
				for (var i:int = 0;i < _tagsContainer.numChildren; i++)
				{
					var s:DisplayObject = _tagsContainer.getChildAt( i );
					TweenMax.to(s, 1, { alpha: tileAlpha });
					if ( tileAlpha > .2 ) tileAlpha -= .25;
				}
				_content.hide();
				
				// BG LINES
				TweenMax.to( _bgLines, 1, { alpha: 0 });
			}
			
			// RETURN to 1st slide
			scrollToSegment( 0 );
			
			// SCALE DOWN and slide to 0
			TweenLite.to( _tagsContainer, closeTime, { ease:Strong.easeInOut, scaleX:1, scaleY:1, x:0, y:0 } );
			
			// REMOVE the tint and return the _bg alpha
			TweenMax.to( _bg, closeTime, { tint: null, alpha:TILE_BG_ALPHA });
			return TweenMax.to( this, closeTime, { ease:Strong.easeInOut, bgAndMaskHeight: Settings.TILE_HEIGHT });
		}
		
		public function scrollToSegment( index:Number, delay:Number = 0 ):void
		{
			if ( _content == null ) return; // TODO: CONTENT isn't loaded, SAVE it for later to jump to specific index
			_currentIndex = index;
			
			// ACTIVATE item
			_content.setActiveSegment( index );
			
			// CENTER the active item
			var item:ContentItemBase = _content.currentActiveContent;
			var toX:Number = 0;
			
			var containerWidth:Number;
			if ( this.state == STATE_LARGE ) containerWidth = stage.stageWidth;
			else containerWidth = stage.stageWidth * Settings.LIST_WIDTH_PERCENT; 
			
			if ( item != null )
			{
				var itemDesiredWidth:Number;
				if ( this.state == STATE_LARGE ) itemDesiredWidth = (stage.stageHeight * item.aspectRatio);
			 	else itemDesiredWidth = item.desiredWidth;
			 	
			 	var itemDesiredX:Number = item.desiredX;
			 	// if ( this.state == STATE_LARGE ) itemDesiredX = item.desiredX;
			
				// CENTERING
				// toX = int(-(Settings.CONTENT_AREA_WIDTH + itemDesiredX) + (containerWidth >> 1) - (itemDesiredWidth >> 1));
				// LEFT ALIGN
				toX = int(-(Settings.CONTENT_AREA_WIDTH + itemDesiredX));
			}
			
			TweenLite.to( _slidingContainer, 1, { ease: Strong.easeInOut, delay:delay, x: Math.min( toX, 0 ) });
		}
		
		public function setPostData( postData:WpPostVO ):void
		{
			_content.postData = postData;
		}
		public function setAssetsArray( assetsArray:Array ):void // assetsArray = Array of AssetInfo objects
		{
			// buildContentNav( assetsArray.length + 1 );
			_assetsArray = assetsArray;
			_content.assetInfoArray = assetsArray;
			
			// TOOD: _content.setData( postData, postAssetsData, postAssets );
		}
		public function load_complete():void
		{
			content.load_complete();
		}
		public function addLoadedAsset( ai:AssetInfo ):void	
		{
			content.addLoadedAsset( ai );
			// SCROLLING?
			scrollAsNeeded();
		}
		public function get displayIndex():int { return _displayIndex; }
		public function set displayIndex(i:int):void { _displayIndex = i; }

		public function get color():uint { return _color; }
	}
}