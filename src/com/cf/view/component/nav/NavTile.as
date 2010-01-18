package com.cf.view.component.nav
{
	import com.cf.model.vo.NavData;
	import com.cf.util.Settings;
	import com.cf.view.component.tile.Tile;
	import com.greensock.easing.Strong;
	
	import flash.events.MouseEvent;
	
	import gs.TweenLite;

	public class NavTile extends com.cf.view.component.tile.Tile
	{
		private var _navData:NavData;
		private var _allowRollover:Boolean = true;
		private var _isActive:Boolean = false;
		
		public function NavTile(title:String, bgColor:uint, navData:NavData, allowRollover:Boolean = true)
		{
			_navData = navData;
			_allowRollover = allowRollover;
			super(title, bgColor, false);
			
			this.buttonMode = allowRollover;
			
			
			// ENABLE MEDIUM font 
			isMedium = true;
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
			
			// HIDE BG
			this.bg.visible = false;
			this.bgMouseOver.alpha = 0;
			
			this.open();
		}
		protected override function mouseUnReveal() : void
		{
			bg.x = bgMouseOver.width;
			TweenLite.to(bg, .4, {width:bgMouseOver.width, x:0, ease:Strong.easeInOut});
			
			if ( !_isActive )
				TweenLite.to(titleContainer, 1, { y: ((bg.height >> 1) - (titleText.height >> 1)), ease:Strong.easeInOut })
		}
		
		// 
		// PROTECTED
		//
		protected override function onMouseOver(e:MouseEvent) : void
		{
			if (_allowRollover) super.onMouseOver( e );
		}
		protected override function onMouseOut(e:MouseEvent) : void
		{
			if (_allowRollover) super.onMouseOut( e );
		}
		
		//
		// PUBLIC API
		// 
		public function get navData():NavData
		{
			return _navData;
		}
		public function bgColorTrans( color:uint ):void
		{
			TweenLite.to( bg, 1, { tint:color } );
		}
		
		public function set isActive( value:Boolean ):void
		{
			_isActive = value;
			var tY:Number = ((bg.height >> 1) - (titleText.height >> 1));
			if ( _isActive )
			{
				tY = ((bg.height >> 1) - (titleText.height >> 1)) + Settings.TILE_HEIGHT;	
			}
			TweenLite.to(titleContainer, 1, { y: tY, ease:Strong.easeInOut });
		}
		public function get isActive():Boolean { return _isActive; }
	}
}