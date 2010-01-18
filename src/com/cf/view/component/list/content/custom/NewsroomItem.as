package com.cf.view.component.list.content.custom
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.view.component.list.content.items.ContentItemBase;
	import com.cf.view.component.scrollbar.Scrollbar;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import flashpress.vo.WpMediaVO;
	
	public class NewsroomItem extends ContentItemBase
	{
		
		// VISUAL
		private var _yearTitle:Sprite = new Sprite();
		private var _pdfListContainer:Sprite = new Sprite();
		private var _listMask:Sprite = new Sprite();
		private var _scrollbar:Scrollbar;
		
		// DATA
		private var _color:uint;
		private var _isScrolling:Boolean = false;
		
		private const DEFAULT_LIST_HEIGHT:int	= 440;
		
		
		public function NewsroomItem(assetInfo:AssetInfo, color:uint)
		{
			super(assetInfo);
			_color = color;
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			// BG white
			_bg.addChild( new Bitmap( new BitmapData( Settings.CONTENT_AREA_WIDTH + 30, Settings.CONTENT_AREA_HEIGHT, false, 0xFFFFFF ) ) );
			
			// YEAR
			addChild( _yearTitle );
			
			var yearText:TextField = TextFactory.TagText( _assetInfo.name );
			var yearBg:Bitmap = new Bitmap( new BitmapData( yearText.width + Settings.TILE_TEXT_HORIZONTAL_MARGIN, Settings.TILE_HEIGHT, false, Settings.CONTENT_STROKE_COLOR ) );
			
			yearText.x = (yearBg.width >> 1) - (yearText.width >> 1);
			yearText.y = (yearBg.height >> 1) - (yearText.height >> 1);
			
			_yearTitle.addChild( yearBg );
			_yearTitle.addChild( yearText );
			
			_yearTitle.scaleX = _yearTitle.scaleY = 2;
			_yearTitle.y = 2 * Settings.TILE_HEIGHT;
			
			// STROKE
			addStroke();
			_stroke.x = 0;
			
			// LOOP asset list
			addChild( _pdfListContainer );
			_pdfListContainer.x = Settings.CONTENT_MARGIN_LEFT;
			_pdfListContainer.y = 6 * Settings.TILE_HEIGHT;
			
			var media:WpMediaVO;
			var currY:Number = 0;
			
			_assetInfo.assetList.sortOn( "menu_order", Array.DESCENDING | Array.NUMERIC );
			
			for each ( media in _assetInfo.assetList )
			{
				var link:NewsroomItemLink = new NewsroomItemLink( media, _color );
				link.y = currY;
				_pdfListContainer.addChild( link );
				currY += link.height;
			}
			
			// LIST MASK
			_listMask.graphics.beginFill( 0x000000 );
			_listMask.graphics.drawRect( 0, 0, _pdfListContainer.width, _viewAreaHeight );
			_listMask.graphics.endFill();
			_listMask.x = _pdfListContainer.x;
			_listMask.y = _pdfListContainer.y;
			addChild( _listMask );
			_pdfListContainer.mask = _listMask;
			
			// IS SCROLLBAR NECESSARY?
			if ( _pdfListContainer.height > _viewAreaHeight )
			{
				createScrollbar();
			}
			
			this.addEventListener( Event.ENTER_FRAME, enter_frame );
		}
		override protected function position() : void
		{
			super.position();
			
			_listMask.height = _viewAreaHeight;
			
			if ( _scrollbar != null )
			{
				_scrollbar.height = _viewAreaHeight;
				updateScrollContent();		
			}
			
			// CHECK if we need to create due to resizing
			if ( _pdfListContainer.height > _viewAreaHeight && (_scrollbar == null || _scrollbar.alpha == 0)  )
			{
				createScrollbar();
			}
			
			// CHECK if we need to hide
			if ( _scrollbar != null && !(_pdfListContainer.height > _viewAreaHeight))
			{
				hideScrollbar();
			}
		}
		
		// 
		// EVENT HANDLERS
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
			updateScrollContent();
		}
		private function enter_frame(e:Event):void
		{
			if (_isScrolling) updateScrollContent();
		}
		
		//
		// PRIVATE
		//
		private function updateScrollContent():void
		{
			_pdfListContainer.y = _listMask.y + ( _scrollbar.percentScrolled * listMinY );			
		}
		private function get listMaxY():Number
		{
			return 0;
		}
		private function get listMinY():Number
		{
			if ( _pdfListContainer.height > _viewAreaHeight ) return _viewAreaHeight - _pdfListContainer.height;
			else return 0;
		}
		private function hideScrollbar():void
		{
			_scrollbar.alpha = 0;
		}
		private function createScrollbar():void
		{
			if ( _scrollbar )
			{
				_scrollbar.alpha = 1;
				return;
			}
			
			// CREATE
			_scrollbar = new Scrollbar( Settings.CONTENT_SCROLL_WIDTH, _viewAreaHeight );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_START, scrollbar_start );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_STOP, scrollbar_stop );
			_scrollbar.addEventListener( Scrollbar.SCROLLBAR_UPDATE, scrollbar_update );
			addChild( _scrollbar );
			_scrollbar.x = _pdfListContainer.x + _pdfListContainer.width + 25;
			_scrollbar.y = _pdfListContainer.y + 10;
		}
		private function get _viewAreaHeight():Number
		{
			return DEFAULT_LIST_HEIGHT - ( Settings.CONTENT_AREA_HEIGHT - desiredHeight );
		}
	}
}