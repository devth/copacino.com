package com.cf.util
{
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextFactory
	{
		
		private static var mainLargeTextFormat:TextFormat = new TextFormat(AssetManager.AvenirFont, 56, 0xFFFFFF, false, false, false, "", "", TextFormatAlign.CENTER, 0,0,0);
		private static var tagTextFormat:TextFormat = new TextFormat(AssetManager.AvenirFont, 14, 0xFFFFFF, true, false, false, "", "", TextFormatAlign.CENTER);
		private static var tagTextMediumFormat:TextFormat = new TextFormat(AssetManager.AvenirMediumFont, 14, 0xFFFFFF, false, false, false, "", "", TextFormatAlign.CENTER);
		private static var bodyCopyFormat:TextFormat = new TextFormat(AssetManager.AvenirMediumFont, 12, 0x222222, null,null,null,null,null, TextFormatAlign.LEFT );
		
		public static function GetTextField(format:TextFormat):TextField
		{
			// CREATE textfield
			var t:TextField = new TextField();
			t.embedFonts = true;
			t.selectable = false;
			t.background = false;
			t.border = false;
			t.autoSize = TextFieldAutoSize.LEFT;
			
			// SET textformat
			t.defaultTextFormat = format;
			
			return t;
		}
		
		//
		// METHODS FOR CREATING ALL TEXT STYLES
		//
		public static function MainLargeText( value:String ):TextField
		{
			var t:TextField = GetTextField(mainLargeTextFormat);
			t.text = value;
			return t;
		}
		public static function TagText(value:String, isMedium:Boolean = false):TextField
		{
			var format:TextFormat = (isMedium) ? tagTextMediumFormat : tagTextFormat;
			var t:TextField = GetTextField( format );
			t.thickness = 200;
			t.htmlText = value;
			return t;
		}
		public static function BodyCopyText(value:String):TextField
		{
			var t:TextField = GetTextField( bodyCopyFormat );
			//var t:TextField = new TextField();
			//t.defaultTextFormat = bodyCopyFormat;
			
			
			// STYLESHEET
			var style:StyleSheet = Stylesheet();

			t.styleSheet = style;
			
			
			t.htmlText = "<div>" + value + "</div>";
			
			t.condenseWhite = true;
			t.multiline = true;
			t.wordWrap = true;
			t.antiAliasType = AntiAliasType.ADVANCED;
			t.thickness = 10;
			t.selectable = true;
			t.width = Settings.CONTENT_COPY_WIDTH;
			t.autoSize = TextFieldAutoSize.NONE;
			t.height = t.textHeight + 40;
			
			
			return t;
		}
		
		public static function Stylesheet():StyleSheet
		{
			var style:StyleSheet = new StyleSheet();
			style.setStyle( "div", { leading:3, fontFamily: AssetManager.AvenirMediumFont });
			
			//style.setStyle( "ul", { display:"inline", bullet: true });
			style.setStyle( "li", { display:"block" });
			
			style.setStyle( "p",  { display:"block" });
			style.setStyle( "h1", { fontSize: 14, fontStyle:"normal", fontWeight:"bold", display:"inline", fontFamily: AssetManager.AvenirFont });
			style.setStyle( "b", { fontStyle:"normal", fontWeight:"bold", display:"inline", fontFamily: AssetManager.AvenirFont });
			style.setStyle( "strong", { fontStyle:"normal", fontWeight:"bold", display:"inline", fontFamily: AssetManager.AvenirFont });
			
			style.setStyle( "em", { display: "inline", fontWeight:"normal", fontStyle:"normal", fontFamily: AssetManager.AvenirObliqueFont });
			style.setStyle( "i", { display: "inline", fontWeight:"normal", fontStyle:"normal", fontFamily: AssetManager.AvenirObliqueFont });
			
			style.setStyle( "a", { color: "#0000FF", textDecoration: "underline" });
			style.setStyle( "a:hover", { color: "#000000", textDecoration: "underline" });
			
			return style;
		}
	}
}