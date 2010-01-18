package com.devth.media
{
	import choppingblock.video.YouTubeLoader;
	
	public class YoutubeController extends YouTubeLoader implements IMediaController
	{
		private var _status:Number = 0;
		
		public function YoutubeController()
		{
			super();
		}
		
		public function load(url:String):void
		{
		}
		
		public function play( percent:Number = 0 ):void
		{
			seekTo( percent * getDuration() );
		}
		
		public function getPercentLoaded():Number
		{
			return this.getBytesLoaded() / this.getBytesTotal();
		}
		
		public function getPercentPlayed():Number
		{
			return this.getCurrentTime() / this.getDuration(); 
		}
		
		public function get status():Number
		{
			return _status;
		}
		
		//
		// OVERRIDES
		//
		public override function setVolume(newVolume:Number) : void
		{
			super.setVolume( newVolume * 100 );
		}
		protected override function playerStateUpdateHandler(state:Number) : void
		{
			super.playerStateUpdateHandler( state );
			
			switch ( _state )
			{
				case "playing":
					_status = MediaStatus.STATUS_PLAYING;
					break;
				case "paused":
					_status = MediaStatus.STATUS_PAUSED;
					break;
				default:
					_status = MediaStatus.STATUS_STOPPED;
					break;
			}
		}
		
	}
}