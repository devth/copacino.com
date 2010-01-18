package com.cf.model
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	
	import com.afw.puremvc.initmonitor.model.bulkloader.BulkLoaderInitProxy;
	import com.afw.puremvc.initmonitor.model.minimalremoting.RemotingInitProxy;
	import com.cf.util.AssetManager;
	
	import flash.events.ErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import flashpress.vo.WpMediaVO;

	public class InitAssetsProxy extends BulkLoaderInitProxy
	{
		public static const NAME:String = "InitAssetsProxy";
		
		private var _initRemoteData:RemotingInitProxy;
		
		
		public function InitAssetsProxy( initRemoteData:RemotingInitProxy )
		{
			super( NAME );
			_initRemoteData = initRemoteData;
					
		}
		
		//
		// OVERRIDES
		//
		public override function load():void
		{
			if (busy) return;
			_busy = true;
			_loader.removeAll();
			
			var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
			
			for each (var media:WpMediaVO in _initRemoteData.getData())
			{
				//Utility.debug("load:", media.url);
				_loader.add(media.url, { id: media.post_title, context:context } );
			}
			
			//_loader.logLevel = BulkLoader.LOG_VERBOSE;
			_loader.addEventListener(BulkProgressEvent.COMPLETE, _loader_complete );
			_loader.addEventListener(BulkLoader.ERROR, _loader_error );
			_loader.start();
		}
		
		public override function finish():void
		{
			super.finish();
			
			// SAVE a static reference to this loader for easy access from view components
			AssetManager.InitLoader = _loader;
		} 
		
		
		//
		// EVENT HANDLERS
		//
		private function _loader_complete( e:BulkProgressEvent ):void
		{
			finish();
		}
		private function _loader_error( e:ErrorEvent = null):void
		{
			stop();
			fail();
		}
		
	}
}