package com.cf.model.postsearch
{
	import flash.utils.Dictionary;
	
	import flashpress.vo.WpPostWithTagAndCatVO;
	
	public class PostTitleSearch implements IPostSearch
	{
		private var _slug:String;
		private var _title:String;
		
		public function PostTitleSearch( slug:String, title:String )
		{
			_slug = slug;
			_title = title;
		}

		public function search( postCache:Dictionary ):Array
		{
			var retArray:Array = new Array();
			var postsByCategory:Array = postCache[ _slug ];
			
			
			for each (var post:WpPostWithTagAndCatVO in postsByCategory)
			{
				if (post.postTitle.toLowerCase().indexOf( _title.toLowerCase() ) > -1) retArray.push( post );
			}
		
			
			return retArray;
		}
	}
}