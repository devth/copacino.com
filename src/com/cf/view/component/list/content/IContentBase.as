package com.cf.view.component.list.content
{
	import com.cf.model.vo.AssetInfo;
	import com.cf.view.component.list.content.items.ContentItemBase;
	
	import flashpress.vo.WpPostVO;

	public interface IContentBase
	{
		function delargify():void;
		function largify():void;
		
		function hide():void;
		function show():void;
		
		function setActiveSegment( index:Number ):void;
		function addLoadedAsset( ai:AssetInfo ):void;
		function load_complete():void;
		
		function get currentActiveContent():ContentItemBase;
		function get contentWidth():Number
		function set assetInfoArray(assetInfoArray:Array ):void;
		function set postData(val:WpPostVO):void;
		
			
	}
}