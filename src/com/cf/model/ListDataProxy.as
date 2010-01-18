package com.cf.model
{
	import com.cf.model.postsearch.IListSearcher;
	import com.cf.model.postsearch.IPostSearch;
	import com.cf.model.vo.ListItem;
	
	import flash.utils.Dictionary;
	
	import flashpress.vo.WpPostCategoryVO;
	import flashpress.vo.WpPostWithTagAndCatVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ListDataProxy extends Proxy implements IProxy
	{
		private var _listSearch:IListSearcher;
		private var _dataByCategory:Dictionary;
		
		public static const NAME:String		= "ListDataProxy";
		
		private var _arrangedListData:Array; // Array of ListItems
		
		
		public function ListDataProxy(proxyName:String, data:Object, listSearch:IListSearcher )
		{
			super(NAME + proxyName, data);
			_listSearch = listSearch;
			
			// BUILD CACHE
			_dataByCategory = new Dictionary();
			
			for each (var post:WpPostWithTagAndCatVO in listData)
			{
				for each (var category:WpPostCategoryVO in post.categories)
				{
					// MAKE sure the key exists
					if (!(category.slug in _dataByCategory)) _dataByCategory[category.slug] = new Array();
					
					// ADD the post to the cache
					(_dataByCategory[category.slug] as Array).push( post );
				}
			}
			
			
			// BUILD arranged list
			_arrangedListData = new Array();
			
			var query:Dictionary = _listSearch.getQuery();
			for each ( var key:String in _listSearch.getKeys() )
			{
				// ADD section header item
				_arrangedListData.push( new ListItem( ListItem.LIST_ITEM_TYPE_SECTION, null, key ) );
				
				var postSearchItems:Array = query[key];
				
				for each ( var postSearchItem:IPostSearch in postSearchItems )
				{ 
					var returnArray:Array = postSearchItem.search( _dataByCategory );
					for each ( var postItem:WpPostWithTagAndCatVO in returnArray )
					{
						_arrangedListData.push( new ListItem( ListItem.LIST_ITEM_TYPE_POST, postItem, key ));
					}
				}
			}
		}
	
		//
		// OVERRIDES
		//
		public override function getData():Object
		{
			return _arrangedListData;
		}
		
		//
		// PRIVATE
		//
		private function get listData():Array
		{
			return this.data as Array;
		}
	}
}