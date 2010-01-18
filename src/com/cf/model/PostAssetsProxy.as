package com.cf.model
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.afw.puremvc.initmonitor.model.bulkloader.BulkLoaderInitProxy;
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.cf.model.vo.AssetInfo;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import flashpress.vo.WpMediaVO;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class PostAssetsProxy extends BulkLoaderInitProxy
	{
		public static const NAME:String		= "PostAssetsProxy";
		
		// NOTIFICATIONS (dynamic)
		private static const DATA_READY:String			= "postassets/data/ready/";
		private static const IMAGE_LOADED:String		= "postassets/image/loaded/";
		
		// DATA
		private var _postAssetData:RemotingInitProxy;
		private var _postId:int;
		
		
		private var _assets:Dictionary = new Dictionary();
		public var _assetsArray:Array = new Array();
		
		private var _time:Number;
		
		
		public function PostAssetsProxy( postId:int, postAssetData:RemotingInitProxy )
		{
			super( getProxyNameById(postId) );
			_postAssetData = postAssetData;
			_postId = postId;
		}
		
		//
		// OVERRIDES
		//
		public override function load():void
		{
			if (busy) return;
			_busy = true;
			_loader.removeAll();
			//_loader.logLevel = BulkLoader.LOG_VERBOSE;
						
			// PARSE AssetInfo and saved fully paired AI's to the assetsArray
			for each (var media:WpMediaVO in _postAssetData.getData())
			{
				// PARSE FILE NAME PARTS
				var filenameRegEx:RegExp = new RegExp( "^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))" ); 
				var filenameParts:Object = filenameRegEx.exec( media.url );
				
				// 0 = string, 1 = path, 2 = file name, 3 = file extension
				if ( filenameParts.length >= 4 )
				{
					var filename:String = filenameParts[2];
					var extension:String = filenameParts[3];
					
					var youtubeSlateRegEx:RegExp = new RegExp( "(.*)(_youtube_slate)$" );
					var slateRegEx:RegExp = new RegExp( "(.*)(_598|_slate)$" );
					var assetRegEx:RegExp = new RegExp( "(.*)(_1000|_video|_audio)$" );
					var datedFile:RegExp = new RegExp( "([0-9]*)_([0-9]*)_([0-9]*)$" ); // 2009_04_03
					//var otherRegEx:RegExp = new RegExp
					
					// AN ASSET IS:
					// 1. A full size image _1000
					// 2. An audio file: _audio
					// 3. A video file: _video
					// 4. A slate that includes a youtube ID
					// 5. A list of PDFs or other assets
					var isAsset:Boolean;
					var isYoutube:Boolean;
					var nameParts:Object;
					
					if ( youtubeSlateRegEx.test( filename ) )
					{
						isYoutube = true;
						nameParts = youtubeSlateRegEx.exec( filename );
					}
					else if ( slateRegEx.test( filename ) )
					{
						isAsset = false;
						nameParts = slateRegEx.exec( filename );
					}
					else if ( assetRegEx.test( filename ) )
					{
						isAsset = true;
						nameParts = assetRegEx.exec( filename );
					}
					else if ( datedFile.test( filename ) )
					{
						nameParts = datedFile.exec( filename );
						var year:int = nameParts[1];
						var month:int = nameParts[2];
						var day:int = nameParts[3];
						
						var date:Date = new Date( year, (month-1), day );
						
						
						trace("======");
						
						trace(year, month, day);
						trace(date.getTime() );
						trace( date );
						
						
						// FIND AI, push this media on the year - note: we're working directly on the _assetsArray array since asset lists don't require any pairing validation
						if ( _assetsArray[year] == null )
						{
							var newYearAI:AssetInfo = new AssetInfo();
							newYearAI.name = year.toString();
							_assetsArray[year] = newYearAI;
							
						}
						var yearAI:AssetInfo = _assetsArray[year] as AssetInfo;
						
						if ( yearAI.assetList == null ) yearAI.assetList = new Array();
						
						// MODIFY post date to date specified in filename
						media.post_date = month.toString() + "/" + day.toString() + "/" + year.toString();
						media.menu_order = date.getTime();// (int)( year.toString() + month.toString() + day.toString() );
						
						trace(media.menu_order);
						trace("======");
						
						
						yearAI.assetList.push( media );
						
						yearAI.order = -year; // DESCENDING order hack
						
						// DONE processing asset type, continue on to the next
						continue;
					}
					else
					{
						continue; // INVALID ASSET NAMING, move on o_O
					}
					
					// PARSE [name] and [suffix]
					var name:String = nameParts[1];
					var nameSuffix:String = nameParts[2];
					
					// BUILD or RETRIEVE AssetInfo
					var ai:AssetInfo;
					if ( _assets[name] == null ) _assets[name] = new AssetInfo();
					ai = _assets[name] as AssetInfo;
					ai.name = name;
					
					
					if ( isYoutube )
					{
						ai.isYoutube = true;
						ai.slateURL = media.url;
						ai.slateMediaVO = media;
						ai.youtubeID = nameParts[1];
					}
					else if ( isAsset )
					{
						ai.assetURL = media.url;
						ai.assetSuffix = nameSuffix;
						
						// DETERMINE ASSET TYPE
						ai.isVideo = ( nameSuffix == "_video" );
						ai.isAudio = ( nameSuffix == "_audio" );
						ai.isImage = ( nameSuffix == "_1000" );
					}
					else // IT's just a slate 
					{
						ai.slateURL = media.url;
						ai.order = media.menu_order;
						ai.slateMediaVO = media;
					}
				
					// SAVE in assetsArray if it's valid / paired
					if ( ai.isValid && _assetsArray.indexOf( ai ) < 0 ) _assetsArray.push( ai );
					
				}
			}
			
			// SORT
			_assetsArray.sortOn( "order", Array.NUMERIC );
			
			// SEND DATA READY NOTIFICATION
			sendNotification( getDataReadyNotification( _postId ), _assetsArray );
			
			// LOOP assetsArray and load slates
			var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
			
			var priority:int = _assetsArray.length;
			
			for each ( var assetInfo:AssetInfo in _assetsArray )
			{
				if ( assetInfo.slateURL != "" ) // NOT ALL AIs have slates (e.g. custom)
				{
					var li:LoadingItem = _loader.add(assetInfo.slateURL, { id: assetInfo.name, context: context, priority:priority  } );
					li.addEventListener( Event.COMPLETE, li_complete ); // LISTEN PER ITEM
				
					priority--;
				}
			}
			
			// START LOADING
			if ( _loader.itemsTotal == 0 ) finish();
			_loader.addEventListener(BulkProgressEvent.COMPLETE, _loader_complete );
			_loader.addEventListener(BulkLoader.ERROR, _loader_error );
			_time = getTimer();
			_loader.start();
			
		}
		public override function finish():void
		{
			super.finish();
		}
		
		//
		// EVENT HANDLERS
		//
		private function li_complete(e:Event):void
		{
			var item:LoadingItem = e.target as LoadingItem;
			var ai:AssetInfo = _assets[ item.id ] as AssetInfo;
			
			
			ai.slate = _loader.getBitmap( item.id );
			
			MonsterDebugger.trace( this, item.id + " loaded:" + (getTimer() - _time)  );
			
			//MonsterDebugger.trace(this, ai );
			
			
			// SEND OUT PER-IMAGE NOTIFICATION
			sendNotification( getImageLoadedNotification( _postId ), ai );
			
		}
		private function _loader_complete( e:BulkProgressEvent ):void
		{
			finish();
		}
		private function _loader_error( e:ErrorEvent = null):void
		{
			MonsterDebugger.trace(this, "LOAD ERROR", 0xFF0000 );
			stop();
			fail();
		}
		
		//
		// PUBLIC
		//
		public static function getProxyNameById( postId:int ):String
		{
			return NAME + postId;
		}
		
		public static function getDataReadyNotification( postId:int ):String
		{
			return DATA_READY + postId;
		}
		public static function getImageLoadedNotification( postId:int ):String
		{
			return IMAGE_LOADED + postId;
		}
		
	}
}