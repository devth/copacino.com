package com.cf.model
{
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.cf.util.Settings;
	
	import flash.utils.Dictionary;
	
	import flashpress.vo.WpPostCategoryVO;
	import flashpress.vo.WpPostWithTagAndCatVO;

	public class SiteContentProxy extends RemotingInitProxy implements IInitProxy
	{
		public static const NAME:String		= "siteContentProxy";
		
		// DATA
		private var _siteContent:Dictionary = new Dictionary();
		private var _surfaceContent:Dictionary = new Dictionary();
		
		
		public function SiteContentProxy(gatewayUrl:String, classMethod:String=null, ...args)
		{
			super(NAME, gatewayUrl, classMethod, args);
		}
		
		
		//
		// OVERRIDES
		//
		protected override function handleResult(result:Object) : void
		{
			var posts:Array = result as Array;
			
			var isSurface:Boolean = false;
			var section:String = "";
			
			// LOOP all content posts and parse using categories
			for ( var i:int = 0; i < posts.length; i++ )
			{
				var p:WpPostWithTagAndCatVO = posts[i] as WpPostWithTagAndCatVO;
				
				// CHECK the categories
				for ( var ci:int = 0; ci < p.categories.length; ci++ )
				{
					var c:WpPostCategoryVO = p.categories[ ci ] as WpPostCategoryVO;
					
					// SECTION
					if ( c.slug == Settings.WP_CAT_WE_ARE ) section = Settings.WP_CAT_WE_ARE;
					else if ( c.slug == Settings.WP_CAT_WE_ARE_NOT ) section = Settings.WP_CAT_WE_ARE_NOT;
					
					// IS SURFACE?
					if ( c.slug == Settings.WP_CAT_SURFACE_LEVEL ) isSurface = true;
				}
				
				// ENSURE the arrays are initialized
				if ( _surfaceContent[ section ] == null ) _surfaceContent[ section ] = [];
				if ( _siteContent[ section ] == null ) _siteContent[ section ] = [];
				
				// CATALOG the results (siteContent gets everything, surfaceContent is a sub-set) 
				if ( isSurface ) (_surfaceContent[ section ] as Array).push( p );
				(_siteContent[ section ] as Array).push( p );
				
				// DEFAULT isSurface for the next recursion
				isSurface = false;
				section = "";
			}
		}
		
		
		//
		// PUBLIC API
		//
		public function getSurfaceContent( section:String ):Array
		{
			return _surfaceContent[ section ] as Array;
		}
		public function getSiteContent( section:String ):Array
		{
			return _siteContent[ section ] as Array;
		}
	}
}