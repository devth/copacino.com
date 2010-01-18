package com.cf.view.component.list
{
	import com.cf.view.component.shape.ShapeBase;
	
	import flash.display.DisplayObject;
	
	import gs.TweenLite;

	public class WeAreList extends ListBase
	{
		
		public function WeAreList( data:Array, shape:ShapeBase, url:String )
		{
			super( data, shape, url );
		}
		
		
		//
		// OVERRIDES
		//
		override public function largifyCurrentMaximized() : void
		{
			super.largifyCurrentMaximized();
			
			// SLIDE "we are" over
			var title:DisplayObject = _shapeSmall.getChildByName( "shapeTitle" );
			if ( title )
			{
				TweenLite.to( title, 1, { x: -5 } );
			}
		}
		override public function delargifyCurrentMaximized( slideTiles:Boolean = true ) : void
		{
			super.delargifyCurrentMaximized( slideTiles );
			
			// SLIDE "we are" back in place
			var title:DisplayObject = _shapeSmall.getChildByName( "shapeTitle" );
			if ( title )
			{
				TweenLite.to( title, 1, { x: 5 - title.width } );
			}
		}
	}
}