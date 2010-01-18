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
 package com.afw.puremvc.initmonitor.model.bulkloader
{
	import flash.events.Event;
	//import com.afw.puremvc.initmonitor.model.bulkloader.SwfAssetInitProxy;
	import com.afw.puremvc.initmonitor.model.IInitProxy;
	
	/**
	 * This class extends SwfAssetInitProxy to load one SWF File containing font asset(s). <br />
	 * The SWF file should automatically register the fonts once it's loaded. <br />
	 * <br />
	 * NOTE: Only relative paths should be used unless you use a font loader. For additional info see:
	 * http://www.allflashwebsite.com/article/embedding-fonts-in-flash-cs3-the-good-way<br />
	 * <br />
	 * NOTE: This class is totally uncessary considering SwfAssetInitProxy can do the same exact thing.
	 * 			(todo) should probably remove this class from the package?
	 *  <br />
	 * example: <br />
	 * <pre>facade.registerProxy(new FontAssetProxy("MyProxyName", "assets/FontFile.swf")); </pre>
	 * 
	 * @see com.afw.puremvc.initmonitor.model.bulkloader.SwfAssetInitProxy
	 * @author Gil Birman [AllFlashWebsite.com]
	 */
    public class FontAssetInitProxy extends SwfAssetInitProxy implements IInitProxy {
		/**
		 * 
		 * @param	proxyName
		 * @param	fontUrl
		 */
        public function FontAssetInitProxy(proxyName:String, fontUrl:String ) {
			super(proxyName, fontUrl );
        }
    }
}