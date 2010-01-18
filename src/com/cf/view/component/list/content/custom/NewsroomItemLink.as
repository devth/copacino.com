package com.cf.view.component.list.content.custom
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.TextFactory;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	
	import flashpress.vo.WpMediaVO;
	
	public class NewsroomItemLink extends Component
	{
		// CONST
		private const VERTICAL_MARGIN:int		= 14;
		
		// DATA
		private var _media:WpMediaVO;
		private var _color:uint;
		
		// VISUAL
		private var _bg:Sprite = new Sprite();
		private var _link:Sprite = new Sprite();
		private var _pdf:Sprite = new Sprite();
		private var _pdfBg:Sprite = new Sprite();
		private var _rule:Shape = new Shape();
		 
		
		public function NewsroomItemLink( media:WpMediaVO, color:uint )
		{
			super();
			
			_media = media;
			_color = color;
		}
		
		
		//
		// OVERRIDES
		//
		protected override function init() : void
		{
			super.init();
			
			this.buttonMode = this.useHandCursor = true;
			
			
			addChild( _bg );
			addChild( _link );
			
			// LINK: DATE + HEADLINE
			var copyHTML:String = _media.post_date + " <strong>" + _media.post_title + "</strong>";
			var text:TextField = TextFactory.BodyCopyText( copyHTML );
			text.width = 300;
			text.selectable = false;
			text.mouseEnabled = false;
			_link.addChild( text );
			_link.y = VERTICAL_MARGIN;
			
			// PDF
			addChild( _pdf );
			
			var pdfText:TextField = TextFactory.TagText("PDF");
			_pdfBg.addChild( new Bitmap( new BitmapData( pdfText.width + Settings.TILE_TEXT_HORIZONTAL_MARGIN, Settings.TILE_HEIGHT, false, Settings.CONTENT_STROKE_COLOR + 0x111111 ) ) );
			pdfText.x = (_pdfBg.width >> 1) - (pdfText.width >> 1);
			pdfText.y = (_pdfBg.height >> 1) - (pdfText.height >> 1);
			_pdf.addChild( _pdfBg );
			_pdf.addChild( pdfText );
			_pdf.scaleX = _pdf.scaleY = .65;
			_pdf.x = 320;
			_pdf.y = VERTICAL_MARGIN + text.textHeight - _pdf.height;
			
			// RULE
			_rule.graphics.lineStyle( 1, Settings.CONTENT_STROKE_COLOR + 0x333333 );
			_rule.graphics.lineTo( width, 0 );
			_rule.y = text.textHeight + (VERTICAL_MARGIN * 2);
			addChild( _rule );
			
			// BG shape
			_bg.addChild( new Bitmap( new BitmapData( width, text.textHeight + (2 * VERTICAL_MARGIN), false, 0xFFFFFF ) ) );
			_bg.alpha = 0;
			
			// WIRE EVENTS
			addEventListener( MouseEvent.ROLL_OVER, mouse_over );
			addEventListener( MouseEvent.ROLL_OUT, mouse_out );
			addEventListener( MouseEvent.CLICK, click );

		}
		public override function get height() : Number
		{
			return _bg.height + 1;
		}
		
		// 
		// EVENT HANDLERS
		//
		private function click( e:MouseEvent):void
		{
			navigateToURL( new URLRequest( _media.url ), "_new" );
		}
		private function mouse_over(e:MouseEvent):void
		{
			TweenLite.to( _link, .8, { tint: _color });
			TweenLite.to( _pdfBg, .8, { tint: _color });
			//TweenLite.to( _bg, .8, { tint: 0xDDDDDD });
		}
		private function mouse_out(e:MouseEvent):void
		{
			TweenLite.to( _link, .8, { tint: null });
			TweenLite.to( _pdfBg, .8, { tint: null });
			//TweenLite.to( _bg, .8, { tint: null });
		}
	}
}