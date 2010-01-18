package com.cf.view.component.list.content
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.view.component.list.content.items.AudioItem;
	import com.cf.view.component.list.content.items.ContentItemBase;
	import com.cf.view.component.list.content.items.ImageItem;
	import com.cf.view.component.list.content.items.VideoItem;
	import com.cf.view.component.list.content.items.YoutubeItem;
	import com.greensock.easing.Strong;
	
	import gs.TweenLite;
	import gs.TweenMax;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class ListTileContent extends ContentBase implements IContentBase
	{
		
		
		// STATE
		private var _isLoadingImages:Boolean = true;
		private var _currX:Number = 0;
		private var _currentActiveContent:ContentItemBase;
		
		
		
		public function ListTileContent( color:uint )
		{
			state = STATE_HIDDEN;
			
			_color = color;
		}
		
		//
		// PRIVATE
		//
		private function positionLoadedContent():void
		{
			var currX:Number = 0;
			if ( _assetInfoArray == null ) return;
			for each ( var ai:AssetInfo in _assetInfoArray )
			{
				if ( ai.slate != null && ai.slate.parent != null ) // IT'S LOADED and ADDED
				{
					var item:ContentItemBase = _mediaContainer.getChildByName( ai.name ) as ContentItemBase;
					item.x = item.desiredX = currX;
					currX += item.desiredWidth + 1;
					
					// FADE IN
					TweenLite.to( item, .8, { autoAlpha: 1 } );
				}
				else break; // DON't position if there's a gap in the proper order of loaded assets
			}
		}
		
		
		//
		// OVERRIDES
		//
		protected override function position() : void
		{
			// _bg.width = stage.stageWidth;
			
			// RE-REPOSITION
			if ( state == STATE_LARGE || state == STATE_NORMAL )
			{
				var currX:Number = 0;
				if ( _assetInfoArray == null ) return;
				for each ( var ai:AssetInfo in _assetInfoArray )
				{
					if ( ai.slate != null && ai.slate.parent != null ) // IT'S LOADED and ADDED
					{
						var item:ContentItemBase = _mediaContainer.getChildByName( ai.name ) as ContentItemBase;
						
						item.x = item.desiredX = currX;
						currX += item.desiredWidth + 1; // ( stage.stageHeight * item.aspectRatio);
					}
				}
			}
		}
		
		//
		// PUBLIC API
		//
		override public function largify():void
		{
			super.largify();
			
			// SPREAD out the assets
			var currX:Number = 0;
			if ( _assetInfoArray == null ) return;
			for each ( var ai:AssetInfo in _assetInfoArray )
			{
				if ( ai.slate != null && ai.slate.parent != null ) // IT'S LOADED and ADDED
				{
					var item:ContentItemBase = _mediaContainer.getChildByName( ai.name ) as ContentItemBase;
					
					item.toModeLarge();
					
					item.desiredX = currX;
					TweenLite.to( item, 1, { x: currX, delay: 1, ease:Strong.easeInOut } );
					
					currX += item.desiredWidth;
				}
			}
		}
		override public function delargify():void
		{
			super.delargify();
			
			// NORMALIZE the assets
			// SPREAD out the assets
			var currX:Number = 0;
			if ( _assetInfoArray == null ) return;
			for each ( var ai:AssetInfo in _assetInfoArray )
			{
				if ( ai.slate != null && ai.slate.parent != null ) // IT'S LOADED and ADDED
				{
					var item:ContentItemBase = _mediaContainer.getChildByName( ai.name ) as ContentItemBase;
					
					item.toModeNormal();
					item.desiredX = currX;
					
					TweenLite.to( item, .8, { x: currX } );
					currX += item.desiredWidth;
				}
			}
		}
		
		
		override public function addLoadedAsset( ai:AssetInfo ):void
		{
			super.addLoadedAsset( ai );
			
			MonsterDebugger.trace(this, ai );
			
			// CREATE ITEM based on type
			var item:ContentItemBase;
			if ( ai.isVideo ) item = new VideoItem( ai );
			else if ( ai.isAudio ) item = new AudioItem( ai );
			else if ( ai.isYoutube ) item = new YoutubeItem( ai );
			else item = new ImageItem( ai );
			
			
			// POSITION and set alpha
			item.visible = false;			
			item.alpha = 0;
			if ( ai == _assetInfoArray[0] ) item.isFirstItem = true;
			if ( ai == _assetInfoArray[ _assetInfoArray.length - 1 ]) item.isLastItem = true;
			_mediaContainer.addChild( item );
			
			_isLoadingImages = (_mediaContainer.numChildren < _assetInfoArray.length);
			_numberLoaded++;
			
			
			if ( !_isLoadingImages )
			{
				assets_loaded();
			}
			
			
			// POSITION
			positionLoadedContent();
		}
		
		
		override public function hide():void
		{
			super.hide();
			TweenMax.to( this, .5, { delay:0, x:0, alpha:0 } );
			
			// LOOP through items and make sure all items are inactive
			for ( var i:int = 0; i < _mediaContainer.numChildren; i++ )
			{
				var item:ContentItemBase = _mediaContainer.getChildAt( i ) as ContentItemBase;
				if ( item ) item.toInactive( false );
			}
		}
		override public function show():void
		{
			super.show();
			TweenMax.to( this, 1, { alpha:1 } );
		}
		
		
		override public function setActiveSegment(index:Number):void
		{
			if ( _assetInfoArray == null ) return; // TODO: SAVE index to default to after it's loaded
			
			if ( _currentActiveContent != null ) _currentActiveContent.toInactive();
			
			var toX:Number = 0;
			var xOffset:Number = 0;
			
			if ( index == 0 )
			{
				_currentActiveContent = null; // DESCRIPTION slide
				// HIDE THE TINT of the first slide
				if ( _mediaContainer.numChildren > 0 && _assetInfoArray.length > 0 )
				{
					var firstItem:ContentItemBase = _mediaContainer.getChildByName( (_assetInfoArray[0] as AssetInfo).name ) as ContentItemBase;
					if ( firstItem )
					{
						TweenLite.killTweensOf( firstItem.tint );
						firstItem.tint.alpha = 0;
					}
				}
			}
			else // ITEM slide
			{
				var ai:AssetInfo;
				
				if ( _assetInfoArray.length < index ) ai = (_assetInfoArray[ _assetInfoArray.length - 1 ] as AssetInfo); // GET LAST if index is out of bounds
				else ai = (_assetInfoArray[ index - 1 ] as AssetInfo);
				
				if ( ai != null )
				{
					var item:ContentItemBase = _mediaContainer.getChildByName( ai.name ) as ContentItemBase;
					if ( item )
					{
						_currentActiveContent = item;
						_currentActiveContent.toActive();
					}
				}
			}
			
		}
		override public function get currentActiveContent():ContentItemBase
		{
			return _currentActiveContent;
		}
		override public function load_complete():void
		{
			super.load_complete();
			// _bg.x = _mediaContainer.width + _mediaContainer.x;
			// TweenLite.to( _bg, .8, { alpha:1} );
		}
	
		override public function get contentWidth():Number
		{
			return _mediaContainer.width;
		}
		
	}
}