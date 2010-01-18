package com.cf.view.component.container
{
	import com.cf.model.event.StateEvent;
	import com.cf.util.AssetManager;
	import com.cf.util.Settings;
	import com.cf.view.component.PianoKeyMask;
	import com.cf.view.component.list.WeAreList;
	import com.cf.view.component.shape.ShapePlus;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	
	import net.hires.controllers.VideoController;

	public class WeAre extends ContainerBase
	{
		private var isLoaded:Boolean = false;
		
		private var _weAreList:WeAreList;
		private var _videoController:VideoController;
		
		public function WeAre()
		{
			// INIT in loading state
			state = STATE_LOADING;
			url = Settings.URL_WE_ARE;
			super( ShapePlus, WeAreList );
			
			//this.addEventListener( StateEvent.STATE_CHANGED, state_changed
		}
		
		protected override function init():void
		{	
			super.init();
		}
		
		protected override function state_changed(e:StateEvent):void
		{	
		}
		
		//
		// OVERRIDES
		//
		override protected function getExpectedShapePosition(state:String) : Point
		{
			var point:Point = super.getExpectedShapePosition( state );
			if ( state == STATE_MINIMIZED )
			{
				point.y += (Settings.TILE_HEIGHT * 1);
			}
			return point;
		}
		override protected function setupBackground():void
		{
			// BG MASK
			_backgroundMask = new PianoKeyMask(stage.stageWidth, stage.stageHeight);
			
		}
		override protected function position():void
		{
			super.position();
			
			( _backgroundMask as PianoKeyMask ).setDesiredSize( stage.stageWidth, stage.stageHeight );
		}
		public override function loadComplete():void
		{
			// ADD BG ASSET
			var bg:Bitmap = new Bitmap( AssetManager.InitLoader.getBitmapData( Settings.ASSET_WE_ARE_BG ) );
			_background.addChild( bg );
			
			// BACKGROUND VIDEO
			/*_videoController = new VideoController( stage.stageWidth, stage.stageHeight );
			_background.addChild( _videoController );
			_videoController.addEventListener( VideoController.COMPLETE, video_complete );
			_videoController.load( AssetManager.bgVideoURL );
			_videoController.resume();*/
			
			// SIZE BG
			_background.width = stage.stageWidth;
			_background.height = stage.stageHeight;
			
			// REVEAL BG
			_backgroundMask.reveal();
			
			// FADE LINES TO NORMAL
			// TweenMax.to(_opacityLines, 1, { delay:1, alpha:Settings.NORMAL_LINE_CONTAINER_OPACITY, ease:Strong.easeOut });
			
			
			// CREATE TILES!
			createTiles( false );
			( _shape as ShapePlus).load_complete();
			
			
			// READY
			super.loadComplete();
			
			// SET DELAY TIMER to load tiles
//			var timer:Timer = new Timer(1500, 1);
//			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
//			timer.start();
			
		}
		
		
		//
		// HANDLERS
		//
		private function timer_complete(e:TimerEvent):void
		{
			
			//createTiles();
		}
		
		
		//
		// PUBLIC API
		//
		public function load_update(percent:Number):void
		{
			( _shape as ShapePlus ).addLoadingTile(percent * 100);
		}
		public function get weAreList():WeAreList
		{
			return _weAreList;
		}

	}
}