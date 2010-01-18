package com.cf.model.postsearch
{
	import com.cf.util.Settings;
	
	public class WeAreNotListSearch extends IListSearcher
	{
		public function WeAreNotListSearch()
		{
			_keysArray.push( "we are not" );
			_queryDictionary["we are not"] = [
				new PostCategoriesSearch( Settings.WP_CAT_WE_ARE_NOT )
			];
		}
		
	}
}