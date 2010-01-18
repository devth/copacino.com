package com.cf.view.component.list.content.custom
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.Settings;
	import com.cf.view.component.list.content.ContentBase;
	import com.cf.view.component.list.content.IContentBase;
	import com.cf.view.component.list.content.items.ContentItemBase;
	import com.greensock.TweenLite;

	public class Newsroom extends ContentBase implements IContentBase
	{
		// VISUAL
		
		
		public function Newsroom( color:uint )
		{
			_color = color;
		}
		
		
		//
		// OVERRIDES
		//
		override protected function init() : void
		{
			super.init();
		
		}
		override protected function createPostContent():void
		{
			super.createPostContent();	
		}
		override protected function createLoader() : void
		{
			// NEWSROOM doesn't get a loader!
		}
		
		//
		// PRIVATE
		//
		private function createNewsContent():void
		{
			
			// NEWSROOM items
			var ni:NewsroomItem;
			var currX:Number = 0;
			
			var delay:Number = .1;
			for each ( var assetInfo:AssetInfo in _assetInfoArray )
			{
				ni =  new NewsroomItem( assetInfo, _color );
				ni.x = currX;
				ni.alpha = 0;
				_mediaContainer.addChild( ni );
				TweenLite.to(ni, 1, { alpha: 1, delay: delay });
				
				delay += .1;
				currX += ni.width;
			}
			
			// FADE IN
			//TweenLite.to( this, 1, { alpha:1 });
			
			// READY
			assets_loaded();
		}
		
		
		// 
		// PUBLIC API
		//
		override public function addLoadedAsset(ai:AssetInfo) : void
		{
			
		}
		override public function delargify() : void
		{
			super.delargify();
		}
		override public function largify() : void
		{
			super.largify();
		}
		override public function get contentWidth() : Number
		{
			return _mediaContainer.width;
		}
		override public function get currentActiveContent() : ContentItemBase
		{
			return null;
		}
		override public function hide() : void
		{
			super.hide();
			
			TweenLite.to( this, .5, { delay:0, x:0, alpha:0 } );
		}
		override public function show() : void
		{
			super.show();
			TweenLite.to( this, 1, { alpha:1 } );
		}
		override public function load_complete() : void
		{
			
		}
		override public function set assetInfoArray(assetInfoArray:Array) : void
		{
			super.assetInfoArray = assetInfoArray;
			createNewsContent();
		}
		/*override public function set postData(val:WpPostVO) : void
		{
			
		}*/
		override public function setActiveSegment(index:Number) : void
		{
			
		}
	}
}