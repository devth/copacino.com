package com.cf.view.component
{
	import com.cf.util.Component;
	import com.cf.util.Utility;

	public class Mask extends Component implements IMask
	{
		public function Mask()
		{
			super();
		}
		
		public function reveal():void
		{
			Utility.debug(this, "Mask", "reveal");
		}
		
		public function hide():void
		{
		}
		
	}
}