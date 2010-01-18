package com.cf.model.vo
{
	import flashpress.vo.WpPostWithTagAndCatVO;
	
	public class ListItem
	{
		public static const LIST_ITEM_TYPE_POST:String		= "ListItemTypePost";
		public static const LIST_ITEM_TYPE_SECTION:String	= "ListItemTypeSection";
		
		
		public var type:String;
		
		private var _sectionTitle:String;
		private var _postData:WpPostWithTagAndCatVO;
		
		public function ListItem(type:String, postData:WpPostWithTagAndCatVO=null, sectionTitle:String="")
		{
			this.type = type;
			this._sectionTitle = sectionTitle;
			this._postData = postData;
		}
		
		
		//
		// PUBLIC API
		//
		public function get sectionTitle():String
		{
			return _sectionTitle; 
		}
		public function get postData():WpPostWithTagAndCatVO
		{
			return _postData;
		}

	}
}