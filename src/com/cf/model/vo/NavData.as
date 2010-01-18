package com.cf.model.vo
{
	import com.afw.swfaddress.SWFAddressUtil;

	public class NavData
	{
		
		public var title:String;
		//public var url:String;
		//public var urlSecondary:String;
		public var segments:Array;
		
		public function NavData( title:String, ...segments)
		{
			this.title = title;
			//this.url = url;
			//this.urlSecondary = urlSecondary;
			this.segments = segments;
		}
		
		
		
		public function get fullUrl():String
		{
			return SWFAddressUtil.joinURI( segments );
		}

	}
}