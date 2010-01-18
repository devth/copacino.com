package com.cf.view.component.nav
{
	import com.cf.model.vo.NavData;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class NavBar extends Component
	{
		public static const STATE_OPEN:String			= "state/open";
		public static const STATE_COLLAPSED:String		= "state/collapsed";
		
		// DATA
		private var _items:Array; // ARRAY of NavData objects
		private var _activeNavTile:NavTile;
		private var _itemsBySegment:Dictionary = new Dictionary();
		
		// VISUAL
		private var _navBarMask:Bitmap;
		private var _navItemContainer:Sprite = new Sprite();
		
		
		public function NavBar( items:Array )
		{
			super();
			
			_items = items;
			state = STATE_COLLAPSED;
		}
		
		
		//
		// OVERRIDES
		//
		protected override function init():void
		{
			super.init();
			
			addChild( _navItemContainer );
			
			var currentX:Number = 0;
			var i:uint = 0;
			
			// BUILD nav bar
			for each (var item:NavData in _items)
			{
				var navTile:NavTile = new NavTile(item.title, (Settings.NAV_DARKEST_COLOR + (i * Settings.NAV_COLOR_OFFSET)), item );
				_navItemContainer.addChild( navTile );
				
				_itemsBySegment[ item.segments[1] ] = navTile;
				
				navTile.x = currentX;
				//navTile.open();
				
				// WIRE EVENTS
				navTile.addEventListener( MouseEvent.CLICK, navTile_click );
				
				// INCREMENT
				currentX += navTile.width + 15;
				i++;
			}
			
			
			
			// CREATE mask
			// _navBarMask = Utility.getMaskShape(this.width, this.height);
			// addChild( _navBarMask );
			
			//this.mask = _navBarMask;
			//_navBarMask.width = 0;
		}
		override public function get width():Number
		{
			if ( _activeNavTile && state == STATE_COLLAPSED )
			{		
				return _activeNavTile.width;
			}
			else return super.width;
		}
		
		//
		// EVENT HANLDERS
		//
		protected function navTile_click(e:MouseEvent):void
		{
			// OVERRIDE this
			
		}
		
		
		//
		// PUBLIC API
		//
		/*public function reveal():void
		{
			state = STATE_OPEN;
			//TweenLite.to( _navItemContainer, Settings.NAV_REAVEAL_SPEED, { x:0 } );
			//TweenMax.to( mask, Settings.NAV_REAVEAL_SPEED, { width: _navItemContainer.width });
		}
		public function hide():void
		{
			state = STATE_COLLAPSED;
			if ( _activeNavTile )
			{
				TweenLite.to( _navItemContainer, Settings.NAV_REAVEAL_SPEED, { x: - _activeNavTile.x } );
				TweenMax.to(mask, Settings.NAV_REAVEAL_SPEED, { width: _activeNavTile.width });
			}
			else TweenMax.to(mask, Settings.NAV_REAVEAL_SPEED, { width:0 });
		}*/
		public function set activeNavTileBySegment(segment:String):void
		{
			// var secondaryUri:String = SWFAddressUtil.joinURISecondary([ segment ]);
			
			// CLEAR active
			_activeNavTile = null;
			
			// LOOP and check
			var navTileItem:NavTile;
			for ( var itemSegment:String in _itemsBySegment )
			{
				navTileItem = _itemsBySegment[ itemSegment ] as NavTile;
				if ( itemSegment == segment )
				{
					_activeNavTile = navTileItem;
					navTileItem.isActive = true;
				}
				else
				{
					navTileItem.isActive = false;
				}
			}
			
			/*if ( _itemsBySegment[ segment ] != null )
			{
				_activeNavTile = _itemsBySegment[ segment ] as NavTile;
				_activeNavTile
			
			}
			else _activeNavTile = null;*/
		}
		public function get activeNavTile():NavTile
		{
			return _activeNavTile;
		}
		
	}
}