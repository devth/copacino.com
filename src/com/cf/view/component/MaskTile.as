package com.cf.view.component
{
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import flashpress.vo.WpPostWithTagAndCatVO;
	
	import gs.TweenLite;
	import gs.easing.Strong;

	public class MaskTile extends Tile
	{
		private var _maskedTitle:String;
		private var _maskedTitleText:TextField;
		
		private var _collapsedWidth:Number;
		
		public function MaskTile(title:String, maskedTitle:String, bgColor:uint=0x000000, autoReveal:Boolean=false, tileData:WpPostWithTagAndCatVO=null)
		{
			super(title, bgColor, autoReveal, tileData);
			
			_maskedTitle = maskedTitle;
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
			
			// CREATE maksed title
			_maskedTitleText = TextFactory.TagText( _maskedTitle );
			addChild( _maskedTitleText );
			_maskedTitleText.y = titleText.y;
			_maskedTitleText.x = titleText.x + titleText.width + (Settings.TILE_TEXT_HORIZONTAL_MARGIN );
			
			// EXTEND BG
			_collapsedWidth = bg.width;
			bg.width += _maskedTitleText.width + (Settings.TILE_TEXT_HORIZONTAL_MARGIN);
			bgMouseOver.width = bg.width;
			
			bgMask.width = _collapsedWidth;
		}
		
		protected override function onMouseOver(e:MouseEvent) : void
		{
			super.onMouseOver(e);
			
			TweenLite.killTweensOf( bgMask );
			TweenLite.to( bgMask, .6, { width: bg.width, ease: Strong.easeInOut });
			
		}
		protected override function onMouseOut(e:MouseEvent) : void
		{
			super.onMouseOut( e );
			
			TweenLite.killTweensOf( bgMask );
			TweenLite.to( bgMask, .6, { width: _collapsedWidth, ease: Strong.easeInOut });
		}
		
	}
}