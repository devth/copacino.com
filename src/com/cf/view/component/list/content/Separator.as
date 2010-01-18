package com.cf.view.component.list.content
{
	import flash.display.Shape;
	
	public class Separator extends Shape
	{
		public function Separator( height:Number, color:uint )
		{
			super();
			
			this.graphics.lineStyle( 1, color );
			this.graphics.lineTo( 0, height );
		}
	}
}