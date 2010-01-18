/*
 Copyright (c) 2008 AllFlashWebsite.com
 All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 @ignore
 */
package com.afw.swfaddress
{
	import com.cf.util.Utility;
	
	
    public class SWFAddressUtil
    {
    	public static const URL_SEPARATOR_PRIMARY:String		= "/";
    	public static const URL_SEPARATOR_SECONDARY:String		= "+";
    	public static const URL_SEPARATOR_TERTIARY:String		= ":";
    	
    	
    	
		// Convert URI String to an Array
		public static function segmentURI(uri:String):Array
		{
			//var q = uri.indexOf("?");
			// TODO Possibly handle ? differently
			if (uri == "") return [];
			var arr:Array = uri.split("/");
			if (arr.length > 1 && arr[0] == "") arr.shift();
			return (arr);
		}
		
		public static function segmentPrimary(uri:String):Array
		{
			var arr:Array = segmentURI(uri);
			var returnArr:Array = new Array();
			
			for each (var seg:String in arr)
			{
				if (seg.charAt(0) != URL_SEPARATOR_SECONDARY && seg.charAt(0) != URL_SEPARATOR_TERTIARY)
				{
					returnArr.push(seg);
				}
			}
			//trace("segmentPrimary:", uri + " = ", returnArr);
			
			return returnArr;
		}
		public static function segmentSecondary(uri:String):Array
		{
			var arr:Array = segmentURI(uri);
			var returnArr:Array = new Array();
			
			for each (var seg:String in arr)
			{
				if (seg.charAt(0) == URL_SEPARATOR_SECONDARY)
				{
					returnArr.push(seg.substr( 1, seg.length-1) ); // ADD to array without the secondary separator
				}
			}
			//trace("segmentSecondary:", uri + " = ", returnArr);
			return returnArr;
		}
		
		
		// Convert URI Array to URI String
		public static function joinURI(uriSegments:Array):String {
			
			//if (uriSegments[uriSegments.length-1] == "") uriSegments.shift(); 
			var ret:String = "/"+uriSegments.join("/");
			
			if (ret.charAt(ret.length-1) == "/") ret = ret.substr(0, ret.length - 1);
			
			//Utility.debug( Utility, "joinURI", uriSegments, ret);
			return ret;
		}
		
		
		public static function joinURISecondary(uriSegments:Array):String {
			var separator:String = ("/+");
			return separator + uriSegments.join(separator);
		}
		
		
		
//		public static function joinURISecondary(uriSegments:Array):String
//		{
//			return "/" + Settings.URL_PARAM + uriSegments.join("/");
//		}
		
		// Build a title from a URI Array
		// Either customize this function, or have the Mediator build the title
		public static function formatTitleSeg(uriSegments:Array):String {
			return formatTitle(joinURI(uriSegments));
		}
		
		// Build a title from a URI String
		// Either customize this function, or have the Mediator build the title
		public static function formatTitle(title:String):String {
			return 'Copacino + Fujikado' + (title != '/' ? ' / ' + toTitleCase(replace(title.substr(1, title.length - 2), '/', ' / ')) : '');
		}
		
		private static function toTitleCase(str:String):String {
			return str.substr(0,1).toUpperCase() + str.substr(1);
		}
		
		private static function replace(str:String, find:String, replace:String):String {
			return str.split(find).join(replace);
		}
    }
}