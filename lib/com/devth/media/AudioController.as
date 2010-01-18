package com.devth.media
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;		

	public class AudioController extends EventDispatcher implements IMediaController
	{

		static public const EVENT_TIME_CHANGE:String = 'Mp3Player.TimeChange';
		static public const EVENT_VOLUME_CHANGE:String = 'Mp3Player.VolumeChange';
		static public const EVENT_PAN_CHANGE:String = 'Mp3Player.PanningChange';
		static public const EVENT_PAUSE:String = 'Mp3Player.Pause';
		static public const EVENT_UNPAUSE:String = 'Mp3Player.Unpause';
		static public const EVENT_PLAY:String = 'Mp3Player.Play';
		
		//
		public var playing:Boolean;
		public var playlist:Array;
		public var currentUrl:String;
		public var playlistIndex:int = -1;
		
		
		//
		protected var _status	:int = 0;
		protected var sound:Sound;
		protected var soundChannel:SoundChannel;
		protected var soundTrans:SoundTransform;
		protected var progressInt:Number;

		public function load( url:String ):void
		{
			clearInterval(progressInt);
			if ( sound ) {
				soundChannel.stop();
			}
			currentUrl = url;
			sound = new Sound();
			sound.addEventListener(Event.COMPLETE, onLoadSong);
			sound.addEventListener(Event.ID3, onId3Info);

			sound.load(new URLRequest(currentUrl));

			soundChannel = sound.play();
			if ( soundTrans ) {
				soundChannel.soundTransform = soundTrans;
			} else {
				soundTrans = soundChannel.soundTransform;
			}
			soundChannel.addEventListener(Event.COMPLETE, onSongEnd);
			playing = true;
			clearInterval(progressInt);
			progressInt = setInterval(updateProgress, 30);
			dispatchEvent(new Event(EVENT_PLAY));
			
			_status = MediaStatus.STATUS_PLAYING;
		}
		public function play( percent:Number = 0 ):void
		{
			seek( percent );
		}
		public function pause():void {
			if ( soundChannel ) {
				soundChannel.stop();
				dispatchEvent(new Event(EVENT_PAUSE));
				playing = false;
				
				_status = MediaStatus.STATUS_PAUSED;
			}
		}
		public function resume():void {
			if ( playing ) return;
			if ( soundChannel.position < sound.length ) {
				soundChannel = sound.play(soundChannel.position);
				soundChannel.soundTransform = soundTrans;
			} else {
				soundChannel = sound.play();
			}
			dispatchEvent(new Event(EVENT_UNPAUSE));
			playing = true;
			_status = MediaStatus.STATUS_PLAYING;
		}
		public function seek( percent:Number ):void {
			soundChannel.stop();
			soundChannel = sound.play(sound.length * percent);
			_status = MediaStatus.STATUS_PLAYING;
		}
		public function prev():void {
			playlistIndex--;
			if ( playlistIndex < 0 ) playlistIndex = playlist.length - 1;
			play(playlist[playlistIndex]);
		}
		public function next():void {
			playlistIndex++;
			if ( playlistIndex == playlist.length ) playlistIndex = 0;
			play(playlist[playlistIndex]);
		}
		public function get volume():Number {
			if (!soundTrans) return 0;
			return soundTrans.volume;
		}
		public function setVolume( n:Number ):void {
			if ( !soundTrans ) return;
			soundTrans.volume = n;
			soundChannel.soundTransform = soundTrans;
			dispatchEvent(new Event(EVENT_VOLUME_CHANGE));
		}
		public function get pan():Number {
			if (!soundTrans) return 0;
			return soundTrans.pan;
		}
		public function set pan( n:Number ):void {
			if ( !soundTrans ) return;
			soundTrans.pan = n;
			soundChannel.soundTransform = soundTrans;
			dispatchEvent(new Event(EVENT_PAN_CHANGE));
		}
		public function get length():Number {
			return sound.length;
		}
		public function get time():Number {
			return soundChannel.position;
		}
		
		
		public function getPercentLoaded():Number
		{
			return sound.bytesLoaded / sound.bytesTotal;
		}
		public function getPercentPlayed():Number
		{
			return time / length;
		}
		
		
		public function get status():Number
		{
			return _status;
		}
		
		
		
		public function get timePretty():String {
			var secs:Number = soundChannel.position / 1000;
			var mins:Number = Math.floor(secs / 60);
			secs = Math.floor(secs % 60);
			return mins + ":" + (secs < 10 ? "0" : "") + secs;
		}
		public function get timePercent():Number {
			if ( !sound.length ) return 0;
			return soundChannel.position / sound.length;
		}
		protected function onLoadSong( e:Event ):void {
		}
		protected function onSongEnd( e:Event ):void {
			if ( playlist )
				next();
		}
		protected function onId3Info( e:Event ):void {
			dispatchEvent(new Event(Event.ID3, e.target.id3));
		}
		protected function updateProgress():void {
			dispatchEvent(new Event(EVENT_TIME_CHANGE));
			if ( timePercent >= .99 ) {
				onSongEnd(new Event(Event.COMPLETE));
				clearInterval(progressInt);
			}
		}
	}
}