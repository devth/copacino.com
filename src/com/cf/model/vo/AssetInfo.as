package com.cf.model.vo
{
	import flash.display.Bitmap;
	
	import flashpress.vo.WpMediaVO;

	// Flexible VO class for various asset types
	public class AssetInfo
	{
		private var _isImage:Boolean = true; // DEFAULT
		private var _isAudio:Boolean = false;
		private var _isVideo:Boolean = false;
		private var _isYoutube:Boolean = false;
		private var _youtubeID:String;
		
		private var _assetList:Array;
		
		public var name:String;
		public var assetSuffix:String;
		public var assetURL:String = "";
		public var slateURL:String = "";
		public var order:int;

		public var slateMediaVO:WpMediaVO;
		public var slate:Bitmap;
		
		
		public function AssetInfo()
		{
		}
		
		
		
		//
		// PUBLIC API
		//
		public function get isValid():Boolean
		{
			return ( _isImage && slateURL != "" ) || // IMAGE WITH SLATE URL or
					( assetURL != "" && slateURL != "" ) || // HAS ASSET and SLATE URL or
					( _isYoutube && slateURL != "") || // YOUTUBE WITH SLATE URL
					( _assetList != null ); // ASSET LIST doesn't even require a slate
		}
		public function get isViewLargeEnabled():Boolean
		{
			return ( _isImage && assetURL != "" );
		}
		
		public function get isImage():Boolean { return _isImage; }
		public function get isAudio():Boolean { return _isAudio; }
		public function get isVideo():Boolean { return _isVideo; }
		public function get isYoutube():Boolean { return _isYoutube; }
		
		public function set isImage( b:Boolean ):void
		{
			if ( b ) 
			{
				_isAudio = false;
				_isVideo = false;
				_isYoutube = false;
			}
			_isImage = b;
		}
		public function set isAudio( b : Boolean ):void
		{
			if ( b )
			{
				_isImage = false;
				_isVideo = false;
				_isYoutube = false;
			}
			_isAudio = b;
		}
		public function set isVideo( b : Boolean ) : void
		{
			if ( b )
			{
				_isImage = false;
				_isAudio = false;
				_isYoutube = false;
			}
			_isVideo = b;
		}
		public function set isYoutube( b:Boolean ) : void
		{
			if ( b )
			{
				_isImage = false;
				_isAudio = false;
				_isVideo = false;
			}
			_isYoutube = b;
		}
		
		// YOUTUBE ID
		public function set youtubeID(id:String):void
		{
			_youtubeID = id;
		}
		public function get youtubeID():String
		{
			return _youtubeID;
		}
		
		// PDF LIST
		public function set assetList( list:Array ):void // ARRAY of WpMediaVO
		{
			_assetList = list;
		}
		public function get assetList():Array
		{
			return _assetList;
		}
		
	}
}