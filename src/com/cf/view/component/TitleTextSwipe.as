package com.cf.view.component
{
	import com.cf.util.Component;
	import com.cf.util.TextFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextField;
	
	import gs.TweenMax;

	// 
	// PROVIDES a left-to-right masking "swipe" effect for copy
	//
	public class TitleTextSwipe extends Component
	{
		private var text:TextField;
		private var title:String;
		private var color:uint;
		private var titleMask:Bitmap;
		
		public function TitleTextSwipe(title:String, color:uint=0xFFFFFF)
		{
			super();
			
			this.title = title;
			this.color = color;
		}
		
		protected override function init():void
		{
			// TEXT
			text = TextFactory.MainLargeText(title);
			text.textColor = color;
			addChild(text);
			
			// MASK
			titleMask = new Bitmap(new BitmapData(100,100,false,0x000000));
			titleMask.width = 0;
			titleMask.height = text.height;
			addChild(titleMask);
			text.mask = titleMask;
		}
		
		public function wipe():void
		{
			TweenMax.to(titleMask, 1, { width:text.width, delay:.5 });	
		}
		
		public function unWipe():void
		{
			TweenMax.to(titleMask, 1, { width:0, x:text.width, delay:.5, onComplete:remove });
		}
		
		private function remove():void
		{
			if (this.parent != null) this.parent.removeChild(this);
		}
		
		
	}
}