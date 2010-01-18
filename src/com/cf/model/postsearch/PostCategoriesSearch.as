package com.cf.model.postsearch
{
	import com.cf.util.Utility;
	
	import flash.utils.Dictionary;
	
	import flashpress.vo.WpPostCategoryVO;
	import flashpress.vo.WpPostWithTagAndCatVO;

	public class PostCategoriesSearch implements IPostSearch
	{
		public static const SORT_ALPHABETICALLY:String		= "sort/alphabetically";
		public static const SORT_CHRONOLOGICALLY:String		= "sort/chronologically";
		
		private var _categoryName:String;
		private var _sortMethod:String
		
		public function PostCategoriesSearch( categoryName:String, sortMethod:String = "" )
		{
			_categoryName = categoryName;
			_sortMethod = sortMethod;
		}

		public function search( postCache:Dictionary ):Array
		{
			var resultsArray:Array = postCache[ _categoryName ];
			
			if ( _sortMethod == SORT_CHRONOLOGICALLY ) resultsArray.sort( sortChrono );
			if ( _sortMethod == SORT_ALPHABETICALLY ) resultsArray.sort( sortAlpha );  
			 
			return resultsArray;
		}

		
		final private function sortAlpha( a:WpPostWithTagAndCatVO, b:WpPostWithTagAndCatVO ):int
		{
			var aFirstTag:String = (a.tags.length > 0) ? (a.tags[0] as WpPostCategoryVO).categoryName : a.postTitle;
			var bFirstTag:String = (b.tags.length > 0) ? (b.tags[0] as WpPostCategoryVO).categoryName : b.postTitle;
			
			return aFirstTag.toLowerCase().localeCompare( bFirstTag.toLowerCase() );
		}
		final private function sortChrono( a:WpPostWithTagAndCatVO, b:WpPostWithTagAndCatVO ):int
		{
			var aDateMilliseconds:Number = Utility.parseDateMillisecondsEllapsed( a.postDate );
			var bDateMilliseconds:Number = Utility.parseDateMillisecondsEllapsed( b.postDate );
			
			if ( aDateMilliseconds > bDateMilliseconds ) return -1;
			else if ( aDateMilliseconds < bDateMilliseconds ) return 1;
			else return 0; 
		}
	}
}