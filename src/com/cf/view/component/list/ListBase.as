package com.cf.view.component.list
{
	import com.cf.model.vo.ListItem;
	import com.cf.util.AssetManager;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.util.Utility;
	import com.cf.view.component.OpacityLines;
	import com.cf.view.component.scrollbar.Scrollbar;
	import com.cf.view.component.shape.ShapeBase;
	import com.cf.view.event.UIEvent;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Strong;
	import com.greensock.events.TweenEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class ListBase extends Component
	{
		public static const STATE_HIDDEN:String			= "list/state/hidden";
		public static const STATE_CLOUD_DISPLAY:String	= "list/state/cloud_display";
		public static const STATE_REVEALED:String		= "list/state/revealed";
		
		private static const SCROLL_VERTICAL_MARGIN:int = 15;
		
		// DATA
		private var _data:Array;
		private var _listHeight:Number;
		
		protected var _url:String;
		
		protected var _listTilesByPostSlug:Dictionary;
		protected var _listSectionsBySlug:Dictionary;
		protected var _listTiles:Array;
		
		private var _lastSectionY:Number;
		
		// VISUAL
		private var _shape:ShapeBase;
		private var _opacityLines:OpacityLines;
		private var _screen:Sprite;
		private var _bg:Sprite;
		
		protected var _shapeSmall:Sprite;
		private var _shapeSmallMask:Sprite;
		
		private var _closeButton:Sprite;
		private var _closeButtonBg:Sprite;
		private var _closeButtonMask:Sprite;
		
		private var _maskShape:Sprite;
		
		private var _scrollbar:Scrollbar;
		
		private var _strokeLines:Sprite = new Sprite();
		private var _strokeLeft:Sprite = new Sprite();
		private var _strokeRight:Sprite = new Sprite();
		
		// STATE
		private var _currentListTileMagnified:ListTile;
		private var _currentListTileMaximized:ListTile;
		private var _lastOpenListTile:ListTile;
		
		private var _tilesTransitioningCount:int = 0;
		private var _isScrolling:Boolean = false;
		private var _isDragging:Boolean = false;
		private var _isScrollVisible:Boolean = true;
		private var _isScrollbarHidden:Boolean = false;
		
		// CONTENT LAYERS		
		protected var _listTilesContainer:Sprite;
		protected var _modalTint:Sprite = new Sprite();
		protected var _modalContent:Sprite = new Sprite();
		
		// TWEENS
		private var _tweenVertical:TweenMax;
		
		public function ListBase( data:Array, shape:ShapeBase, url:String )
		{
			super();
			
			this._data = data;
			this._shape = shape;
			this._url = url;
			
			this.state = STATE_HIDDEN;
		}
		
		//
		// OVERRIDES
		//
		override protected function init():void
		{
			super.init();
			
			this.cacheAsBitmap = true;
			
			// BG
			_bg = new Sprite();
			_bg.graphics.beginFill( 0x00FF00, 0 );
			_bg.graphics.drawRect( 0,0, stage.stageWidth, stage.stageHeight );
			_bg.graphics.endFill();
			_bg.mouseEnabled = true;
			_bg.addEventListener( MouseEvent.MOUSE_DOWN, bg_mouse_down );
			_bg.visible = false;
			addChild( _bg );
			
			
			// SCREEN
			_screen = new Sprite();
			_screen.graphics.beginBitmapFill( AssetManager.InitLoader.getBitmapData( Settings.ASSET_SCREEN_BG ) );
			_screen.graphics.drawRect( 0, 0, stage.stageWidth * Settings.LIST_WIDTH_PERCENT, stage.stageHeight );
			_screen.graphics.endFill();
			_screen.visible = false;
			_screen.alpha = 0;
			addChild( _screen );
			
			// SCROLLBAR
			_scrollbar = new Scrollbar( Settings.TILE_HEIGHT, stage.stageHeight - Settings.FIRST_LINE_HEIGHT - Settings.TILE_HEIGHT );
			_scrollbar.y = Settings.FIRST_LINE_HEIGHT + Settings.TILE_HEIGHT;
			addChild( _scrollbar );
			_scrollbar.alpha = 0;
			_scrollbar.visible = false;
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_START, scrollbar_start );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_STOP, scrollbar_stop );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_UPDATE, scrollbar_update );
			
			// TICK LINES
			addChild( _strokeLines );
			([ _strokeLeft, _strokeRight ] as Array).forEach( function( tick:Sprite, index:int, arr:Array):void {
				tick.graphics.beginFill( Settings.LINE_COLOR, 1 );
				var h:Number = stage.stageHeight;
				tick.graphics.drawRect( 0, 0, 1, stage.stageHeight ); 
			});
			_strokeLines.addChild( _strokeLeft );
			_strokeLines.addChild( _strokeRight );
			
			_strokeLines.visible = false;
			_strokeLines.alpha = 0;
			
			// CREATE LIST TILES using pre-arranged _data Array
			_listTilesByPostSlug = new Dictionary();
			_listSectionsBySlug = new Dictionary();
			_listTiles = new Array();
			_listTilesContainer = new Sprite();
			
			// OPACITY lines
			_opacityLines = new OpacityLines();
			addChild( _opacityLines );
			_opacityLines.alpha = 0;
			
			// TILES container LAYER
			addChild( _listTilesContainer );
			_listTilesContainer.y = Settings.LIST_MARGIN_TOP;
			
			var currY:Number = -(Settings.TILE_HEIGHT);
			var currDegrees:Number = 0;
			var degreesIncrements:Number = 360 / _data.length;
			
			for each (var listItem:ListItem in _data)
			{
				// EXTRA MARGIN for SECTION HEAD
				if ( listItem.type == ListItem.LIST_ITEM_TYPE_SECTION )
					currY += (Settings.TILE_HEIGHT + Settings.TILE_MARGIN);
					
				// BUILD listTile
				var listTile:ListTile;
				var color:uint = (listItem.type == ListItem.LIST_ITEM_TYPE_SECTION) ? Settings.LIST_DEFAULT_COLOR : Utility.getColorForAngle(currDegrees); //Utility.getRandomPositiveColor();
				
				// STORE colors for media and r+d
				if ( listItem.type == ListItem.LIST_ITEM_TYPE_POST )
				{
					if ( listItem.postData.postTitle.toLowerCase() == "media" ) AssetManager.mediaColor = color;
					if ( listItem.postData.postTitle.toLowerCase() == "r+d" ) AssetManager.rdColor = color;
				}
				
				// URL
				var listTileUrl:String;
				if ( listItem.type == ListItem.LIST_ITEM_TYPE_POST) listTileUrl = _url + "/" + Utility.formatAsSlug( listItem.postData.postTitle.toLocaleLowerCase() ); 
				else listTileUrl = _url + "/" + Utility.formatAsSlug( listItem.sectionTitle );
				 
				listTile = new ListTile( listItem, color, listTileUrl );
				_listTilesContainer.addChild( listTile );
				
				// WIRE EVENT LISTENERS
				listTile.addEventListener( MouseEvent.MOUSE_DOWN, listTile_mouse_down );
				listTile.addEventListener( MouseEvent.ROLL_OVER, listTile_roll_over );
				
				// POSITION
				listTile.y = listTile.originalY = currY;
				currY += listTile.tileHeight + Settings.TILE_MARGIN;
				
				// SAVE a reference for posts
				if (listItem.type == ListItem.LIST_ITEM_TYPE_POST)
					_listTilesByPostSlug[ Utility.formatAsSlug( listItem.postData.postTitle.toLocaleLowerCase() ) ] = listTile;
				else
				{
					_listSectionsBySlug[ Utility.formatAsSlug( listItem.sectionTitle )] = listTile;
					
					// EXTRA increments for sections
					currDegrees += ( degreesIncrements * 4 );
					
					// SAVE LAST SECTION Y - (after the full loop it'll be last)
					_lastSectionY = listTile.y;
				}
				
				// SAVE a reference for correct sort order
				_listTiles.push( listTile );
				
				// SAVE the index so we can maintain display list order
				listTile.displayIndex = _listTiles.length - 1;
				
				// INCREMENT DEGREES for color
				currDegrees += degreesIncrements;
			}
			
			
			// MASKING
			_maskShape = new Sprite();
			_maskShape.addChild( Utility.getMaskShape( stage.stageWidth, _listHeight ) );
			_maskShape.y = Settings.LIST_MARGIN_TOP - Settings.TILE_HEIGHT; //  + Settings.TILE_MARGIN);
			
			addChild( _maskShape );
			_maskShape.mouseEnabled = false;
			_listTilesContainer.mask = _maskShape;
			
			// MODAL TINT
			_modalTint.graphics.beginFill( 0x000000, Settings.MODAL_TINT_ALPHA );
			_modalTint.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			_modalTint.alpha = 0;
			_modalTint.visible = false;
			_modalTint.mouseEnabled = _modalTint.mouseChildren = false;
			_modalTint.addEventListener( MouseEvent.MOUSE_DOWN, model_mouse_down );
			addChild( _modalTint );
			
			// MODAL CONTENT (top layer)
			addChild( _modalContent );
			
			// SMALL SHAPE
			_shapeSmall = _shape.shapeSmall;
			_shapeSmall.mouseChildren = _shapeSmall.mouseEnabled = false;
			_shapeSmall.x = -(Settings.TILE_HEIGHT >> 1);
			_modalContent.addChild( _shapeSmall );

			// SMALL SHAPE MASK
			_shapeSmallMask = new Sprite();
			_shapeSmallMask.addChild( Utility.getMaskShape( _shapeSmall.width, _shapeSmall.height ) );
			_shapeSmallMask.width = 0;
			_shapeSmallMask.x = _shapeSmall.width >> 1;
			_shapeSmallMask.y = - _shapeSmall.width >> 1;
			
			_shapeSmall.addChild( _shapeSmallMask );
			_shapeSmall.mask = _shapeSmallMask;
			
			// CLOSE BUTTON
			_closeButton = new Sprite();
			// BG
			_closeButtonBg = new Sprite();
			_closeButton.addChild( _closeButtonBg );
			_closeButtonBg.graphics.beginFill( Settings.WE_ARE_CROSS_BG );
			_closeButtonBg.graphics.drawRect( 0,0, Settings.TILE_HEIGHT / .8, Settings.TILE_HEIGHT );
			_closeButtonBg.graphics.endFill();
			// TEXT
			var x:TextField = TextFactory.TagText( "x" );
			x.mouseEnabled = false;
			_closeButton.addChild( x );
			x.x = (_closeButton.width >> 1) - (x.width >> 1);
			x.y = (_closeButton.height >> 1) - (x.height >> 1);
			_modalContent.addChild( _closeButton );
			_closeButton.buttonMode = _closeButton.useHandCursor = true;
			_closeButton.addEventListener( MouseEvent.MOUSE_DOWN, _closeButton_mouse_down );
			
			// CLOSE BUTTON mask
			_closeButtonMask = new Sprite();
			_closeButtonMask.addChild( Utility.getMaskShape( _closeButton.width, _closeButton.height ) );
			_closeButton.mask = _closeButtonMask;
			_closeButtonMask.width = 0;
			_closeButton.addChild( _closeButtonMask );
			
			// WIRE EVENTS
			stage.addEventListener( KeyboardEvent.KEY_DOWN, key_down );
			this.addEventListener( Event.ENTER_FRAME, enter_frame );
			this.addEventListener( MouseEvent.MOUSE_WHEEL, mouse_wheel );
			
			position();
		}
		
		override protected function position():void
		{
			// CALCULATE proper width and X instead of relying on listTilescontainer since there could be a delay in sizing
			var contentWidth:int = int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
			var contentX:Number = (stage.stageWidth >> 1) - (contentWidth >> 1);
			
			// CENTER list
			_listTilesContainer.x = contentX;
			
			// SIZE opacity lines
			_opacityLines.setMinHeight( _listTilesContainer.height );
			_opacityLines.width = contentWidth;
			
			// POSITION center screen + opacity lines
			_screen.x = _opacityLines.x = contentX;
			
			// MASK
			_maskShape.width = stage.stageWidth;
			
			// SCREEN
			_screen.graphics.clear();
			_screen.graphics.beginBitmapFill( AssetManager.InitLoader.getBitmapData( Settings.ASSET_SCREEN_BG ) );
			_screen.graphics.drawRect( 0, 0, stage.stageWidth * Settings.LIST_WIDTH_PERCENT, stage.stageHeight );
			_screen.graphics.endFill();
			
			// SCROLLBAR
			if ( _isScrollbarHidden )
				_scrollbar.x = stage.stageWidth;
			else
				_scrollbar.x = stage.stageWidth - Settings.TILE_HEIGHT;
			
			_scrollbar.height = stage.stageHeight - Settings.FIRST_LINE_HEIGHT - Settings.TILE_HEIGHT;
			// _scrollbarGutter.height = (maxScrollbarY - minScrollbarY) + _scrollbarSlider.height;
			
			
			// TINT
			_modalTint.width = stage.stageWidth;
			_modalTint.height = stage.stageHeight;
			
			// MODAL content
			if ( _currentListTileMaximized != null && _currentListTileMaximized.state == ListTile.STATE_LARGE )
				_modalContent.x = 0;
			else if ( _currentListTileMaximized != null && _currentListTileMaximized.state == ListTile.STATE_MAXIMIZED )
			{
				// CENTER VERTICALLY in maximized view
				if ( _currentListTileMaximized )
				{
					// SCROLL to vertically center the maximized tile
					var vertMultiple:int = Math.min( 8, Math.max(1, int( (( stage.stageHeight >> 1 ) - (Settings.CONTENT_AREA_HEIGHT >> 1)) / (Settings.TILE_HEIGHT + Settings.TILE_MARGIN) ) )); // 4
					var toVerticalScroll:Number = -_currentListTileMaximized.originalY + (vertMultiple * Settings.TILE_ROW_HEIGHT) + Settings.FIRST_LINE_HEIGHT;
					// TweenMax.to( this, 1, { verticalScroll: toVerticalScroll, ease: Expo.easeOut });
					verticalScroll = toVerticalScroll;
					
					// SMALL SHAPE Y
					_shapeSmall.y = _closeButton.y = _currentListTileMaximized.y + (3 * Settings.TILE_HEIGHT);
					_closeButton.y -= .5 * Settings.TILE_HEIGHT;
					
					_closeButton.x = contentWidth - 1;
				}
				
				_modalContent.x = contentX;
			}
			else
			{
				_modalContent.x = contentX;
			}
			
			// BG
			_bg.width = stage.stageWidth;
			_bg.height = stage.stageHeight;
			
			// TICK
			listHeight = listLowerBoundary - (Settings.LIST_MARGIN_TOP - (Settings.TILE_HEIGHT + Settings.TILE_MARGIN)); // AFFECTS mask height and ticks vertical position
			/*_tickUpper.x = _tickLower.x = contentX - Settings.TILE_HEIGHT;
			_tickUpperRight.x = _tickLowerRight.x = contentWidth + Settings.TILE_HEIGHT;
			*/
			
			_strokeLines.x = contentX - 1;
			_strokeLines.height = stage.stageHeight;
			_strokeRight.x = contentWidth+ 1;
		}
		
		
		//
		// EVENT handlers
		//
		private function bg_mouse_down( e:MouseEvent ):void
		{
			_closeButton_mouse_down( null );
		}
		private function model_mouse_down(e:MouseEvent):void
		{
			// default close
			_closeButton_mouse_down( null );	
		}
		private function scrollbar_start(e:Event):void
		{
			_isScrolling = true;
		}
		private function scrollbar_stop(e:Event):void
		{
			_isScrolling = false;
		}
		private function scrollbar_update(e:Event):void
		{
			updateFromScrollbar();
		}		
		private function key_down(e:KeyboardEvent):void
		{
		}
		private function mouse_wheel(e:MouseEvent):void
		{
			// verticalScroll = Math.min( 0, e.delta + verticalScroll );
			if ( _currentListTileMaximized != null ) return;
			
			_scrollbar.scrollByDelta( e.delta );
		}
		
		private var _scrollwheelTweenCount:int = 0;
		private function monitorScrollwheelTween( t:TweenMax ):void
		{
			_scrollwheelTweenCount++;
			t.addEventListener( TweenEvent.COMPLETE, scrollwheel_tween_complete );
		}
		private function scrollwheel_tween_complete( e:TweenEvent ):void
		{
			_scrollwheelTweenCount--;
			
			if ( _scrollwheelTweenCount == 0 ) _isScrolling = false;
		}
		
		private function _modalTint_click(e:MouseEvent):void
		{
			// _closeButton_mouse_down( null );
		}
		private function _closeButton_mouse_down(e:MouseEvent):void
		{
			if ( (state == STATE_REVEALED && _currentListTileMaximized == null) || ( state == STATE_CLOUD_DISPLAY ))
			{
				// CLOSE LIST
				dispatchEvent( new UIEvent( UIEvent.LIST_CLOSE, this.name, "", true, true ) );
			}
			else if ( state == STATE_REVEALED && _currentListTileMaximized != null )
			{
				// DYNAMICALLY choose the listTile's parent section
				var parentSlug:String = Utility.formatAsSlug( _currentListTileMaximized.listItem.sectionTitle );
				var title:String = _currentListTileMaximized.listItem.sectionTitle;
				
				_lastOpenListTile = _currentListTileMaximized;
				
				dispatchEvent( new UIEvent( UIEvent.URL_EVENT, title, this._url + "/" + parentSlug ) );
			}
		}
		private function listTile_mouse_down(e:MouseEvent):void
		{
			// NAV to tile url
			var tile:ListTile = e.currentTarget as ListTile; 
			if ( tile.listItem.type == ListItem.LIST_ITEM_TYPE_POST && tile != _currentListTileMaximized )
				dispatchEvent( new UIEvent( ShapeBase.UIEVENT_TILE_CLICK, tile.listItem.postData.postTitle.toLowerCase(), _url + "/" + Utility.formatAsSlug( tile.listItem.postData.postTitle.toLowerCase() ), true, true ) );
		}
		private function listTile_roll_over(e:MouseEvent):void
		{
			// ON ROLL OVER magnify only if it's minimized AND there isn't a current maximized tile
			// var tile:ListTile = e.currentTarget as ListTile;
			// if ( state == STATE_REVEALED && tile.state == ListTile.STATE_MINIMIZED && _currentListTileMaximized == null ) magnifyTile( tile );
		}
		private function enter_frame(e:Event):void
		{
			if ( state == STATE_REVEALED )
			{
				if ( _isScrolling ) updateFromScrollbar();
				
				// SYNC lines always
				_opacityLines.y = _listTilesContainer.y - Settings.LIST_MARGIN_TOP;
			}
		}
		
		
		//
		// PRIVATE
		//
		private function updateFromScrollbar():void
		{
			var contentAreaHeight:Number = _maskShape.height;
			var pScrolled:Number = _scrollbar.percentScrolled;
			scrollListToPercent( pScrolled );
		}
		private function get _contentWidth():int { return int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT); }
		private function moveNext():void // MOVE to the next tile in the list
		{
			if ( _currentListTileMaximized )
			{
				var nextIndex:int = _currentListTileMaximized.displayIndex + 1;
				
				// CHECK IF WE HAVE TO move next further (if we can) if it's a section head
				if ( (nextIndex < _listTiles.length - 1) && (_listTiles[ nextIndex ] as ListTile) != null && (_listTiles[ nextIndex ] as ListTile).listItem.type == ListItem.LIST_ITEM_TYPE_SECTION ) nextIndex++;
				
				var nextTile:ListTile = _listTiles[ nextIndex ] as ListTile;
				if ( nextTile && nextTile.listItem.type == ListItem.LIST_ITEM_TYPE_POST )
				{
					minimizeTile( _currentListTileMaximized );
					// CHANGE URL
					dispatchEvent( new UIEvent( ShapeBase.UIEVENT_TILE_CLICK, nextTile.listItem.postData.postTitle.toLowerCase(), _url + "/" + Utility.formatAsSlug( nextTile.listItem.postData.postTitle.toLowerCase() ), true, true ) );
				}
			}
		}
		private function movePrev():void // MOVE to the previous tile in the list
		{
			if ( _currentListTileMaximized )
			{
				var prevIndex:int = _currentListTileMaximized.displayIndex - 1;
				
				// CHECK IF WE HAVE TO move back further (if we can) if it's a section head
				if ( prevIndex > 0 && (_listTiles[ prevIndex ] as ListTile) != null && (_listTiles[ prevIndex ] as ListTile).listItem.type == ListItem.LIST_ITEM_TYPE_SECTION ) prevIndex--;
				
				var prevTile:ListTile = _listTiles[ prevIndex ] as ListTile;
				if ( prevTile && prevTile.listItem.type == ListItem.LIST_ITEM_TYPE_POST  )
				{
					minimizeTile( _currentListTileMaximized );
					// CHANGE URL
					dispatchEvent( new UIEvent( ShapeBase.UIEVENT_TILE_CLICK, prevTile.listItem.postData.postTitle.toLowerCase(), _url + "/" + Utility.formatAsSlug( prevTile.listItem.postData.postTitle.toLowerCase() ), true, true ) );
				}
			}
		}
		
		private function set listHeight( height:Number ):void
		{
			_listHeight = height;
			_maskShape.height = height + (Settings.TILE_HEIGHT + Settings.TILE_MARGIN);
			// _tickLower.y = height + Settings.LIST_MARGIN_TOP;
		}
		private function get listLowerBoundary():Number
		{
			var yBoundary:Number = stage.stageHeight - (3 * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
			yBoundary -= (yBoundary % (Settings.TILE_HEIGHT + Settings.TILE_MARGIN)) - 5;
			return yBoundary;
		}
		private function scrollListToPercent(percent:Number):void
		{
			var toY:Number = (minListY + (percent * (maxListY - minListY)));
			toY = Settings.LIST_MARGIN_TOP - (int( toY / Settings.TILE_ROW_HEIGHT ) * Settings.TILE_ROW_HEIGHT ); 
			
			// JUST SET IT, don't tween
			_listTilesContainer.y = toY;
		}
		private function tween_complete(e:TweenEvent):void
		{
			_tilesTransitioningCount--;
		}
		private function monitorTransitionTween(tween:TweenMax):void
		{
			_tilesTransitioningCount++;
			//Utility.debugColor( this, 0xFFFF00, "monitorTransitionTween", _tilesTransitioningCount );
			tween.addEventListener( TweenEvent.COMPLETE, tween_complete );
		}
		private function minimizeTile( tileToMin:ListTile ):void
		{
			if ( _currentListTileMaximized.state == ListTile.STATE_LARGE ) delargifyCurrentMaximized( false );
			
			// SHOW SCROLLBARS
			showScrollbar();
			
			// PUT Y back
			tileToMin.y = tileToMin.originalY;
			
			// FADE OUT MODAL
			TweenLite.to( _modalTint, .5, { autoAlpha:0 } );
			
			// if ( tileToMin.state == ListTile.STATE_MAXIMIZED ) _listTilesContainer.addChildAt( _currentListTileMaximized, _currentListTileMaximized.displayIndex );
			// PUT IT BACK on the right layer
			if ( tileToMin.parent == _modalContent ) _listTilesContainer.addChildAt( _currentListTileMaximized, _currentListTileMaximized.displayIndex );
			
			// MINIMIZE
			monitorTransitionTween( tileToMin.minimize() );
			
			// CLEAR REFERENCE
			_currentListTileMaximized = null;
			
			// UNWIND SMALL SHAPE
			TweenLite.killTweensOf( _shapeSmallMask );
			TweenLite.to( _shapeSmallMask, .3, { x: (_shapeSmall.width >> 1), width: 0 } );
			
			// CLOSE BUTTON hide
			TweenLite.to( _closeButtonMask, .4, { width:0 } );
		}
		private function maximizeTile( tileToMax:ListTile ):void
		{
			TweenMax.to( _closeButtonBg, 1, { tint: tileToMax.color });
			
			if ( _currentListTileMaximized == tileToMax ) return; // DO NOTHING
			
			if ( _currentListTileMaximized != null && _currentListTileMaximized.state == ListTile.STATE_LARGE )
				delargifyCurrentMaximized();
			
			// MINIMIZE the current maximized tile
			if ( _currentListTileMaximized != null ) minimizeTile( _currentListTileMaximized );	
			_currentListTileMaximized = tileToMax;
			
			// SQUEEZE scrollbars in
			hideScrollbar();
			
			// SCROLL to vertically center the maximized tile
			var vertMultiple:int = Math.min( 8, Math.max(1, int( (( stage.stageHeight >> 1 ) - (Settings.CONTENT_AREA_HEIGHT >> 1)) / (Settings.TILE_HEIGHT + Settings.TILE_MARGIN) ) ) ); // 4
			var toVerticalScroll:Number = -tileToMax.originalY + (vertMultiple * Settings.TILE_ROW_HEIGHT) + Settings.FIRST_LINE_HEIGHT;
			TweenMax.to( this, .5, { verticalScroll: toVerticalScroll, ease: Expo.easeOut });
			
			// ADD content tile to the modalContent layer
			_modalContent.addChild( _currentListTileMaximized );
			TweenLite.to( _modalTint, .5, { autoAlpha:1 } );
			
			// CHECK delay - needs longer delay when transition into list and opening a post at the same time
			var shapeDelay:Number = .5;
			if ( tileToMax.mask.width < int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT) ) shapeDelay = 3.5;
			
			// MAXIMIZE
			monitorTransitionTween( _currentListTileMaximized.maximize() ); 
			
			// SMALL SHAPE + CLOSE button - position + show
			_shapeSmall.y = _closeButton.y = tileToMax.y + (3 * Settings.TILE_HEIGHT);
			_closeButton.x = _contentWidth;
			TweenLite.to( _shapeSmallMask, .6, { x: -(_shapeSmall.width >> 1), width: _shapeSmall.width, delay: shapeDelay } );
			TweenLite.to( _closeButtonMask, 1, { width: _closeButton.width, delay:shapeDelay + .6 } );
			
		}
		private function magnifyTile( tileToMag:ListTile ):void
		{
			if ( _currentListTileMagnified == tileToMag ) return; // DO NOTHING
			
			if ( _currentListTileMagnified != null ) _currentListTileMagnified.minimize();
			_currentListTileMagnified = tileToMag;
			monitorTransitionTween( _currentListTileMagnified.magnify() );
		}
		private function get localShapeCoordinates():Point
		{
			return this.globalToLocal( _shape.global() );
		}
		
		
		private function hideScrollbar():void
		{
			// FADE OUT 1px stroke also
			TweenMax.to( _strokeLines, 1, { alpha: 0 });
			
			_isScrollbarHidden = true;
			TweenMax.to( _scrollbar, 1, { x: stage.stageWidth });
		}
		private function showScrollbar():void
		{
			// FADE OUT 1px stroke also
			TweenMax.to( _strokeLines, 1, { alpha: 1 });
			
			_isScrollbarHidden = false;
			TweenMax.to( _scrollbar, 1, { x: stage.stageWidth - _scrollbar.width });
		}
		private function get minListY():Number
		{
			return 0;
		}
		
		private function get maxListY():Number
		{
			// IS "we are not" content higher than viewable 
			var lastTile:ListTile = _listTiles[ _listTiles.length-1 ] as ListTile; 
			if ( (lastTile.y - _lastSectionY ) > ( _maskShape.height ))
			{
				return lastTile.y - _maskShape.height + (2 * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
			} 
			
			return _lastSectionY - Settings.TILE_MARGIN;
		}
		
		//
		// PUBLIC API
		//
		public function largifyCurrentMaximized():void
		{
			_currentListTileMaximized.largify();
			
			// RAISE tile to top of screen
			TweenLite.to( this, .8, { delay:1, verticalScroll: -_currentListTileMaximized.originalY, ease: Expo.easeOut });
			
			// TweenLite.to( _currentListTileMaximized, .8, { delay:1, y: _currentListTileMaximized.originalY - Settings.LIST_MARGIN_TOP });
			
			// PULL MODAL to left of screen
			TweenLite.to( _modalContent, 1, { x: 0, ease:Strong.easeInOut } );
			
			// MOVE SHAPE to top layer
			_modalContent.addChild( _shapeSmall );
			
			// SLIDE SHAPE over
			TweenLite.to( _shapeSmall, .8, { x: (Settings.TILE_HEIGHT >> 1) });
			
			// SMALL SHAPE Y
			TweenLite.to( _shapeSmall, .8, { y: Settings.LIST_MARGIN_TOP + _currentListTileMaximized.originalY + (3 * Settings.TILE_HEIGHT) });
			
			
		}
		public function delargifyCurrentMaximized( slideTiles:Boolean = true ):void
		{
			if ( _currentListTileMaximized != null && _currentListTileMaximized.state == ListTile.STATE_LARGE )
			{
				_currentListTileMaximized.maximize( slideTiles );
				
				// LOWER tile to original position
				// TweenLite.to( _currentListTileMaximized, .8, { y: _currentListTileMaximized.originalY });
				// SCROLL to vertically center the maximized tile
				var vertMultiple:int = Math.min( 8, Math.max(1, int( (( stage.stageHeight >> 1 ) - (Settings.CONTENT_AREA_HEIGHT >> 1)) / (Settings.TILE_HEIGHT + Settings.TILE_MARGIN) ) ) ); // 4
				var toVerticalScroll:Number = -_currentListTileMaximized.originalY + (vertMultiple * Settings.TILE_ROW_HEIGHT) + Settings.FIRST_LINE_HEIGHT;
				TweenMax.to( this, .5, { verticalScroll: toVerticalScroll, ease: Expo.easeOut });
				
				// RETURN modal content container x position
				var contentWidth:int = int(stage.stageWidth * Settings.LIST_WIDTH_PERCENT);
				var contentX:Number = (stage.stageWidth >> 1) - (contentWidth >> 1);
				TweenLite.to( _modalContent, 1, { x: contentX, ease:Strong.easeInOut } );
				
				// MOVE SHAPE back to the bottom
				_modalContent.addChildAt( _shapeSmall, 0 );
				// SLIDE SHAPE back over
				TweenLite.to( _shapeSmall, .8, { x: -(Settings.TILE_HEIGHT >> 1) });
				
				// SMALL SHAPE Y
				TweenLite.to( _shapeSmall, .8, { y: _currentListTileMaximized.y + (3 * Settings.TILE_HEIGHT) });	
			}
		}
		public function scrollToSection( sectionSlug:String ):void
		{
			var isClosing:Boolean = false;
			// ENSURE there is no maximized content
			if ( _currentListTileMaximized != null )
			{
				minimizeTile( _currentListTileMaximized );
				isClosing = true;			
			}
			
			
			var tile:ListTile;
			if ( isClosing && _lastOpenListTile && sectionSlug == Utility.formatAsSlug( _lastOpenListTile.listItem.sectionTitle )  ) // USE last open tile to figure out where to scroll to if the sectionSlug is the last open tile's parent
				tile = _lastOpenListTile;
			else
				tile = _listSectionsBySlug[ sectionSlug ] as ListTile;
			
			
			if ( tile )
			{
				// 1. TWEEN the list position
				var toListY:Number = Settings.LIST_MARGIN_TOP - (tile.y - Settings.TILE_MARGIN);
				TweenLite.to( _listTilesContainer, .8, { y: toListY });
			
			
				// 2. CALCULATE percentage scrolled
				var listScrolledY:Number = Math.abs( toListY - Settings.LIST_MARGIN_TOP ) ; 
				var percent:Number = ( listScrolledY - minListY ) / ( maxListY - minListY );
				
				// 3. TWEEN the scrollbar position
				_scrollbar.percentScrolled =  percent;
			}
		}
		
		public function get currentListTileMaximized():ListTile { return _currentListTileMaximized; }
		
		public function openPost( slug:String ):void
		{
			// OPEN POST using the slug from the url
			MonsterDebugger.trace(this, "openPost: " + slug );
			
			var tile:ListTile = _listTilesByPostSlug[ slug ] as ListTile;
			if ( tile ) maximizeTile( tile );
		}
		public function get verticalScroll():Number
		{
			return _listTilesContainer.y;
		}
		public function set verticalScroll( y:Number ):void
		{
			_listTilesContainer.y = _modalContent.y = y;
		}
		public function set data(data:Array):void
		{
			this.data = data;
		}
		public function reveal( initDelay:Number, isCloudDisplay:Boolean ):void
		{
			_bg.visible = true;
			if ( !isCloudDisplay) 
			{
				for (var i:int=0; i < _listTiles.length; i++)
				{
					var tile:ListTile = _listTiles[i] as ListTile;
					tile.reveal( initDelay + (i * .02) );
				}
				
				// OPACTIY LINES
				TweenLite.to( _opacityLines, 1, { delay:2, alpha: 1 } );
				
				// SCREEN
				TweenLite.to( _screen, 2, { delay:2, autoAlpha: .35 } );
				
				// STROKES
				TweenLite.to( _strokeLines, 1, { delay:2, autoAlpha:1 } );
				
				// SCROLLBAR
				TweenMax.to( _scrollbar, 1.5, { delay:2, autoAlpha:1 } );
			}
			if ( isCloudDisplay ) state = STATE_CLOUD_DISPLAY;
			else state = STATE_REVEALED;
		}
		public function hide( initDelay:Number ):void
		{
			if ( _currentListTileMaximized != null ) minimizeTile( _currentListTileMaximized );
			
			_bg.visible = false;
			// ENSURE all tiles are hidden
			for (var i:int=0; i < _listTiles.length; i++)
			{
				var tile:ListTile = _listTiles[i] as ListTile;
				tile.hide( initDelay + (i * .04) );
			}
			if ( state != STATE_CLOUD_DISPLAY )
			{	
				// HIDE scrollbar
				TweenMax.to( _scrollbar, 1, { delay:1, autoAlpha:0 } );
				
				// OPACTIY LINES
				TweenLite.to( _opacityLines, 1, { delay:1, alpha: 0 } );
				
				// SCREEN
				TweenLite.to( _screen, 1, { delay:1, autoAlpha: 0 } );
				
				// HIDE ticks
				TweenLite.to( _strokeLines, 1, { delay:2, autoAlpha:0 } );
			}
			
			// CLOSE BUTTON
			TweenLite.killTweensOf( _closeButtonMask );
			TweenLite.to( _closeButtonMask, .4, { width:0 } );
			
			state = STATE_HIDDEN;
		}
	}
}