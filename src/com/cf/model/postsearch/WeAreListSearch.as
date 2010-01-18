package com.cf.model.postsearch
{
	import com.cf.util.Settings;
	
	public class WeAreListSearch extends IListSearcher
	{
		
		
		public function WeAreListSearch()
		{
			_keysArray.push( Settings.NAV_MAIN_AGENCY );
			_queryDictionary[ Settings.NAV_MAIN_AGENCY ] = [
				new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "who we are" ),
				new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "the c+f team" ),
				new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "clients" ),
				//new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "media" ),
				//new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "c+f ip" ),
				//new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "r+d" ),
				new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "magnet" ),
				//new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "an agency" ),
				new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "newsroom" ),
				new PostTitleSearch( Settings.WP_CAT_SECTIONS_AGENCY, "contact" )
			];
			
			_keysArray.push( Settings.NAV_MAIN_WORK );
			_queryDictionary[ Settings.NAV_MAIN_WORK ] = [
				new PostCategoriesSearch( Settings.WP_CAT_SECTIONS_WORK, PostCategoriesSearch.SORT_ALPHABETICALLY )
			];
				
			
			// no more what's new
			/*_keysArray.push( Settings.NAV_MAIN_NEW );
			_queryDictionary[ Settings.NAV_MAIN_NEW ] = [
				new PostCategoriesSearch( Settings.WP_CAT_SECTIONS_WHATS_NEW, PostCategoriesSearch.SORT_CHRONOLOGICALLY ),
			];*/
			
			_keysArray.push( Settings.NAV_MAIN_GOOD_TIME );
			_queryDictionary[ Settings.NAV_MAIN_GOOD_TIME ] = [
				new PostCategoriesSearch( Settings.WP_CAT_SECTIONS_GOOD_TIME, PostCategoriesSearch.SORT_ALPHABETICALLY )
			];
			
		}
	}
}