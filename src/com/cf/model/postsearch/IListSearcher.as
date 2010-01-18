package com.cf.model.postsearch
{
	import flash.utils.Dictionary;
	
	public class IListSearcher
	{
		protected var _queryDictionary:Dictionary = new Dictionary();
		protected var _keysArray:Array = new Array(); // for sorting
		
		public function getQuery():Dictionary
		{
			return _queryDictionary;
		}
		public function getKeys():Array
		{
			return _keysArray;
		}
	}
}