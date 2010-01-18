package com.afw.util {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author AllFlashWebsite.com
	 */
	public class MovieClipUtil {
		public static function getClass(mc:MovieClip, classStr:String):Class {
			return mc.loaderInfo.applicationDomain.getDefinition(classStr) as Class;
		}
	}
	
}