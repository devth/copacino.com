package com.cf.util
{
	import br.com.stimuli.loading.BulkLoader;
	
	public class AssetManager
	{
		[Embed(source="assets/AvenirLTStd/AvenirLTStd-Black.otf", fontFamily="Avenir", mimeType="application/x-font")]
		private static var Avenir:String;
		public static var AvenirFont:String = "Avenir";
		
		
		[Embed(source="assets/AvenirLTStd/AvenirLTStd-Medium.otf", fontFamily="AvenirMedium", mimeType="application/x-font")]
		private static var AvenirMedium:String;
		public static var AvenirMediumFont:String = "AvenirMedium";
		
		[Embed(source="assets/AvenirLTStd/AvenirLTStd-LightOblique.otf", fontStyle="italic", fontFamily="AvenirLightOblique", mimeType="application/x-font")]
		private static var AvenirOblique:String;
		public static var AvenirObliqueFont:String = "AvenirLightOblique";
		
		/*[Embed(source="assets/Palatino/PalatRom.ttf", fontFamily="Palatino", mimeType="application/x-font-truetype")]
		private static var Palatino:String;
		*/
		
		[Embed(systemFont='Palatino', fontName="Palatino", mimeType="application/x-font-truetype")]
		private static const Palatino:String;
		public static const PalatinoFont:String = "Palatino";
		
		[Embed(systemFont='Palatino', fontName="Palatino", fontWeight="bold", mimeType="application/x-font-truetype")]
		private static const PalatinoBold:String;
		
		[Embed(systemFont='Palatino', fontName="Palatino", fontStyle="italic", mimeType="application/x-font-truetype")]
		private static const PalatinoItalic:String;
		
		// [Embed(source="assets/Palatino/PalatBol.ttf", fontStyle="normal", fontFamily="PalatinoBold", mimeType="application/x-font-truetype")]
		/*[Embed(systemFont='Palatino', fontName="Palatino", fontWeight="bold", mimeType="application/x-font-truetype")]
		private static var PalatinoBold:String;
		public static var PalatinoBoldFont:String = "PalatinoBold";*/
		
		/*[Embed(source="assets/Palatino/PalatIta.ttf", fontFamily="PalatinoItalic", mimeType="application/x-font")]
		private static var PalatinoItalic:String;
		public static var PalatinoItalicFont:String = "PalatinoItalic";*/
		
		//[Embed(systemFont='Everyday', fontName='Everyday', mimeType='application/x-font')]
		//public static var EverydayFont:Class;
		
		public static var bgVideoURL:String;
		
		public static var mediaColor:uint = 0x7d3dc6;
		public static var rdColor:uint = 0x52859b;
		
		private static var initLoader:BulkLoader;
		
		
		public static function get InitLoader():BulkLoader
		{
			return initLoader;
		} 
		public static function set InitLoader(l:BulkLoader):void
		{
			initLoader = l;
		}
	}
}