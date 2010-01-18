package com.cf.view.component.list.content.custom
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.util.AssetManager;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.cf.view.component.list.content.ContentBase;
	import com.cf.view.component.list.content.IContentBase;
	import com.cf.view.component.list.content.items.ContentItemBase;
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapOptions;
	import com.google.maps.MapType;
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Contact extends ContentBase implements IContentBase
	{
		private var _map:Map;
		private var _marker:Marker;
		private var _assetAdded:Boolean = false;
		private var _workCoords:LatLng = new LatLng(47.601633, -122.333855); 
		
		public function Contact( color:uint )
		{
			_color = color;
		}
		
		
		// 
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
		}
		
		//
		// PRIVATE
		//
		private function createContactMap( w:int ):void
		{
			var mapOptions:MapOptions = new MapOptions();
			mapOptions.controlByKeyboard = true;
			
			_map = new Map();
			_map.setInitOptions( mapOptions );
			_map.key = Settings.GOOGLE_MAP_API_KEY;
			_mediaContainer.addChild( _map );
			_map.setSize( new Point( w, Settings.CONTENT_AREA_HEIGHT ) );
			_map.addEventListener( MapEvent.MAP_READY, map_ready );
		}
		
		//
		// EVENT
		// 
		private function map_ready(e:MapEvent):void
		{
			// 101 Yesler Way = 47.601633, -122.333855
			_map.setCenter(_workCoords, 14, MapType.NORMAL_MAP_TYPE);
			_map.addControl( new ZoomControl() );
			_map.addControl( new MapTypeControl() );
			
			
			var labelIcon:Bitmap = AssetManager.InitLoader.getBitmap( Settings.ASSET_MAP_PLUS );
			
			
			// MARKER
			_marker = new Marker( _workCoords,
				new MarkerOptions({
					fillStyle: new FillStyle({ color: _color }),
					hasShadow: true,
					icon: labelIcon,
					iconOffset: new Point(-10, -34),
					labelFormat: new TextFormat( AssetManager.AvenirMediumFont,16, 0xFFFFFF, true)
				})
			);
			_marker.addEventListener( MapMouseEvent.CLICK, marker_click );
				
			_map.addOverlay( _marker );
			
//			var geocoder:ClientGeocoder = new ClientGeocoder();
//			geocoder.addEventListener( GeocodingEvent.GEOCODING_SUCCESS, geo_success );
//			geocoder.geocode( "101 Yesler Way, Seattle, WA" );
		}
		private function marker_click(e:MapMouseEvent):void
		{
			var descHTML:String = "<div><h1>Copacino+Fujikado</h1>\n" +
				"<p>101 Yesler Way\n" +
				"Suite 500\n" +
				"Seattle, WA 98104\n\n" +
				"<a target='_new' href='http://maps.google.com/maps?saddr=&daddr=101%20Yesler%20Way,%20Suite%20500,%20Seattle,%20WA%2098104%20(Copacino%2BFujikado)'>Get Directions</a>" +
				"</p></div>";
			
			var descText:TextField = TextFactory.BodyCopyText( descHTML );
			descText.autoSize = TextFieldAutoSize.LEFT;
			descText.width = 130;
			
			var contentFormat:TextFormat = new TextFormat( AssetManager.AvenirMediumFont, 14, 0xFFFFFF, false );
			
			var infoWinOptions:InfoWindowOptions = new InfoWindowOptions({
				width: 210,
				pointOffset:new Point(0, -32),
				tailOffset: 10,
				tailHeight: 40,
				tailWidth: 30,
				tailAlign: InfoWindowOptions.ALIGN_RIGHT,
				cornerRadius: 0,
				padding:10,
				strokeStyle: new StrokeStyle({color: _color, alpha:0, thickness:0}),
				customContent: descText,
				drawDefaultFrame: true
			});
			
			_map.openInfoWindow(_workCoords, infoWinOptions);
				
		}
		
		
		//
		// PUBLIC API
		//
		override public function addLoadedAsset(ai:AssetInfo) : void
		{
			super.addLoadedAsset( ai );
			
			// SHOULD only happen once in this case
			if (!_assetAdded)
			{
				createContactMap( ai.slate.width );
				_assetAdded = true;
			}
		}
		override public function set assetInfoArray(assetInfoArray:Array) : void
		{
			super.assetInfoArray = assetInfoArray;
			// createContactMap();
		}
		override public function get contentWidth() : Number
		{
			if ( _assetAdded ) return (_assetInfoArray[0] as AssetInfo).slate.width;
			else return 0;
		}
		override public function get currentActiveContent() : ContentItemBase
		{
			return null;
		}
		override public function setActiveSegment(index:Number) : void
		{
		}
		override public function hide() : void
		{
			super.hide();
			
			// _map.visible = false;
			TweenLite.to( this, .5, { delay:0, x:0, alpha:0, onComplete: function():void { _map.visible = false; } } );
		}
		override public function show() : void
		{
			super.show();
			
			if ( _map) _map.visible = true;
			TweenLite.to( this, 1, { alpha:1 } );
		}
	}
}