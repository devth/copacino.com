package com.cf.view.component.list
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ContentNavTile extends Component
	{
		// DATA
		private var _count:Number;
		private var _currentActiveItem:ContentNavItem;
		
		// VISUAL
		private var _bg:Sprite = new Sprite();
		private var _linkContainer:Sprite = new Sprite();
		
		public function ContentNavTile( count:Number )
		{
			_count = count;
			
			addChild( _bg );
			addChild( _linkContainer );
		}
		
		//
		// OVERRIDES
		//
		override protected function init() : void
		{
			super.init();
			
			// BUILD LINKS
			var currX:Number = Settings.TILE_TEXT_HORIZONTAL_MARGIN;
			
			for ( var i:int = 0; i < _count; i++ )
			{
				var item:ContentNavItem = new ContentNavItem( i+1, ((i+1)==_count) );
				item.x = currX;
				// item.addEventListener( ContentNavItem.EVENT_SET_ACTIVE, contentNav_set_active );
				_linkContainer.addChild( item );
				
				// ACTIVATE first item by default
				if ( currX == Settings.TILE_TEXT_HORIZONTAL_MARGIN )
				{
					item.isActive = true;
					_currentActiveItem = item;
				}
				
				currX += item.width;
			}
			
			// BG
			_bg.addChild( new Bitmap( new BitmapData( _linkContainer.width + (Settings.TILE_TEXT_HORIZONTAL_MARGIN << 1), Settings.TILE_HEIGHT, false, Settings.CONTENT_NAV_BG ) ) );
			_bg.alpha = Settings.CONTENT_NAV_BG_ALPHA;
		}
		
		
		
		//
		// PUBLIC API
		//
		public function setActiveByIndex( index:Number ):void
		{
			var c:ContentNavItem = _linkContainer.getChildAt( index ) as ContentNavItem;
			
			// DEACTIATE old
			if ( _currentActiveItem ) _currentActiveItem.isActive = false;
			
			// ACTIVATE new
			_currentActiveItem = c;
			_currentActiveItem.isActive = true;
		}
		public function returnToDefault():void
		{
			setActiveByIndex( 0 );
		}
		public function get count():Number
		{
			return _count;
		}
		public function get currentActiveItem():ContentNavItem
		{
			return _currentActiveItem;
		}
	}
}