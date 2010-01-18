package com.cf.model.postsearch
{
	public class PostSearchContext
	{
		private var ps:IPostSearch;
		
		public function PostSearchContext(ps:IPostSearch)
		{
			this.ps = ps;
		}
		
		public function search( postCache:Dictionary ):Array
		{
			return ps.search(posts );
		}
	}
}