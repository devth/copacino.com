package com.cf.view.component.list.content.items
{
	import br.com.stimuli.loading.BulkLoader;
	
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.Settings;
	import com.greensock.easing.Strong;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;

	public class ImageItem extends ContentItemBase
	{
		
		private var _loader:BulkLoader;
		private var _isAssetLoaded:Boolean = false;
		
		private var _asset:Bitmap;
		
		public function ImageItem( assetInfo:AssetInfo )
		{
			super( assetInfo );
		}
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
			
			// ADD SLATE
			_assetInfo.slate.smoothing = true;
			_content.addChild( _assetInfo.slate );
			
			_aspectRatio = _slate.width / _slate.height;
			
			this.desiredWidth = _content.width;
			this.desiredHeight = _content.height;
			
			// SCALE if necessary
			var b:Bitmap = _assetInfo.slate;
			var scale:Number = 1
			if ( b.height > Settings.CONTENT_AREA_HEIGHT )
			{
				scale = Settings.CONTENT_AREA_HEIGHT / b.height;
			}
			// b.scaleX = b.scaleY = scale;
			b.width *= scale;
			b.height *= scale;
			
			// INIT TINT
			initTint( b.width, b.height );
			
			// WIRE CURSOR EVENTS
			_content.addEventListener( MouseEvent.ROLL_OVER, content_mouse_over );
			_content.addEventListener( MouseEvent.ROLL_OUT, content_mouse_out );
			_content.addEventListener( MouseEvent.MOUSE_DOWN, content_mouse_down );
			
			addStroke();
			
			position();
		}
		override protected function position() : void
		{
			if ( _mode == MODE_LARGE || _mode == MODE_NORMAL )
			{
				// RESET dimensinos
				_content.width = desiredWidth;
				_content.height = desiredHeight;
			}
			super.position();
		}
		override public function toModeLarge() : void
		{
			super.toModeLarge();
			
			// MAKE SURE it's loaded
			ensureAssetIsLoaded();
			// SHOW ASSET (if available)
			if ( _asset ) TweenLite.to( _asset, 1, { autoAlpha: 1 });
			
			// RESIZE _content( slate + asset)
			TweenLite.to( _content, 1, { delay: 1, width: desiredWidth, height: desiredHeight, ease:Strong.easeInOut } );
			
		}
		override public function toModeNormal() : void
		{
			super.toModeNormal();
			
			// RESIZE _content (slate + asset)
			TweenLite.to( _content, .8, { width: desiredWidth, height: desiredHeight } );
			
			// HIDE ASSET
			if ( _asset ) TweenLite.to( _asset, 1, { autoAlpha: 0 });
		}
		override public function get desiredWidth():Number
		{
			return desiredHeight * aspectRatio;
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
		// PRIVATE
		//
		private function ensureAssetIsLoaded() : void
		{
			// LOAD large asset
			if ( !_isAssetLoaded && _assetInfo.assetURL != "" )
			{
				_loader = new BulkLoader( _assetInfo.assetURL );
				_loader.addEventListener( BulkLoader.COMPLETE, loader_loaded );
				_loader.add( _assetInfo.assetURL );
				_loader.start();
			}
			else if ( _assetInfo.assetURL != "" )
			{
				loader_loaded(null);
			}
		}
		
		//
		// EVENT HANLDERS
		//
		private function loader_loaded( e:Event ):void
		{
			_isAssetLoaded = true;
			_asset = _loader.getBitmap( _assetInfo.assetURL );
			
			/*var scale:Number = 1;
			if ( height > stage.stageHeight ) scale = stage.stageHeight / height;
			var height:Number = _asset.height * scale;
			var width:Number = _asset.width * scale;*/
			
			_asset.width = _assetInfo.slate.width;
			_asset.height = _assetInfo.slate.height;
			
			_asset.smoothing = true;
			
			// _assetInfo.slate.visible = false;
			// FADE IN
			_asset.alpha = 0;
			TweenLite.to( _asset, 1, { alpha: 1 });  //{ width: width, height: height });
			
			_content.addChild( _asset );
			
		}
		private function content_mouse_down(e:MouseEvent):void
		{
			dispatchEvent( new Event( ContentItemBase.CURSOR_CLICK, true, true ) );
		}
		private function content_mouse_out(e:MouseEvent):void
		{
			dispatchEvent( new Event( ContentItemBase.CURSOR_DISABLED, true, true ) );
		}
		private function content_mouse_over(e:MouseEvent):void
		{
			dispatchEvent( new Event( ContentItemBase.CURSOR_ENABLED, true, true ) );
		}
	}
}