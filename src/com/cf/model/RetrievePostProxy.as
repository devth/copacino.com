package com.cf.model
{
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class RetrievePostProxy extends Proxy implements IProxy
	{
		public function RetrievePostProxy(proxyName:String=null, data:Object=null)
		{
			super(proxyName, data);
		}
		
		public function getProxyName():String
		{
			return null;
		}
		
		public function setData(data:Object):void
		{
		}
		
		public function getData():Object
		{
			return null;
		}
		
		public function onRegister():void
		{
		}
		
		public function onRemove():void
		{
		}
		
	}
}