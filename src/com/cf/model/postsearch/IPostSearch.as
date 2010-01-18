package com.cf.model.postsearch
{
	import flash.utils.Dictionary;
	
	public interface IPostSearch
	{
		function search( postCache:Dictionary ):Array;
	}
}