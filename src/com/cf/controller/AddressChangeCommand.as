
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


package com.cf.controller
{
	
	import com.cf.ApplicationFacade;
	import com.cf.model.SWFAddressProxy;
	import com.cf.util.Settings;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;


	public class AddressChangeCommand extends SimpleCommand implements ICommand{
		 
		override public function execute(notification:INotification):void {
			super.execute(notification);
			
			var uri:String = notification.getBody() as String;
			
			MonsterDebugger.trace(this, uri, 0xFF0000);
			
			// UPDATE swfaddress proxy
			var mySWFAddressProxy:SWFAddressProxy = facade.retrieveProxy( SWFAddressProxy.NAME ) as SWFAddressProxy;
			mySWFAddressProxy.requestURI(uri);
			
			// CHANGE TITLE for basic states
			var t:Object = Settings.TITLES;
			var title:String = Settings.TITLES[uri];
			if (title != null) sendNotification( ApplicationFacade.TITLE_CHANGE, title );
			
		}
		
	}
	
}
