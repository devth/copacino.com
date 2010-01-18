/**
 * Hi-ReS! VideoController v1.4
 * Copyright (c) 2008 Mr.doob @ hi-res.net
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * How to use:
 * 
 * 	var vc:VideoController = new VideoController( 320, 240, { smoothing:true, loop:true, autoSize:true } );
 * 	vc.load( "video.flv" );
 * 	vc.play();		
 * 
 * version log:
 * 
 *
 *  08.03.22		1.4		Mr.doob		Bugfix: AutoSize wasn't working
 *  08.03.17		1.3		Mr.doob		VideoController.BUFFER_FULL
 *  08.01.27		1.2		Mr.doob		Added getPercentLoaded() method
 * 										Added getPercentPlayed() method
 * 										Added jupmTime() method
 *  08.01.26		1.1		Mr.doob		Dispatching VideoController.METADATA when its loaded
 * 										Also videoWidth and videoHeight updates onMetaData :S
 * 										Status variable from private to public :S :S
 *  07.12.13		1.0		Mr.doob		First version
 **/

package com.devth.media
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoController extends Sprite implements IMediaController
	{
		
		public var videoWidth			:Number = 0;
		public var videoHeight			:Number = 0;
		public var videoFPS				:Number;
		public var videoDuration		:Number;
		
		public var loop					:Boolean = false;
		public var autoSize				:Boolean = false;
		
		private var video				:Video;
		private var sound				:Sound;

		private var connection			:NetConnection;
		private var stream				:NetStream;
		private var listener			:Object;
		
		private var _status				:Number;
		public static var PLAYING		:Number = 0;
		public static var PAUSED		:Number = 1;
		public static var STOPPED		:Number = 2;		
		
		// Events
		/*public static var PLAY			:String = "play";
		public static var BUFFER_FULL	:String = "buffer_full";
		public static var METADATA		:String = "metadata";
		public static var COMPLETE		:String = "complete";*/
		
		
		/**
		 * Creates a Video Controller
		 *
		 * @param		width				width of the VideoController
		 * @param		height				height of the VideoController
		 * @param		(last param)		Object containing the specified parameters in any order
		 * @param		.loop				Boolean				If ture the video will loop once finished
		 * @param		.autoSize			Boolean				If true the container will resize to the video size
		 */
		
		public function VideoController( width:Number = 320, height:Number = 240, initObj:Object = null )
		{
			video = new Video(width, height);
			
			
			videoWidth = width;
			videoHeight = height;
			
			// video.smoothing = true;
			
			// applying all the initObj values to the class
			if (initObj)
				for (var param:* in initObj)
						this[param] = initObj[param];
			
			addChild(video);
			
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.connect( null );
			
			stream = new NetStream( connection );
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			video.attachNetStream( stream );
			
			listener = new Object();
			listener.onMetaData = onMetaData;
			stream.client = listener;
		}
		
		
		// .. CONTROL METHODS .............................................................................
		
		public function setVolume( volPercent:Number ):void
		{
			stream.soundTransform = new SoundTransform( volPercent );
		}
		
		public function load( url:String ):void
		{
			stream.play(url);
			_status = VideoController.STOPPED;
		}
		
		public function play( percent:Number = 0 ):void
		{
			var position:Number = percent * videoDuration;
			stream.seek(position);
			//stream.play();
			_status = VideoController.PLAYING;
		}		
		
		public function resume():void
		{
			stream.resume();
			_status = VideoController.PLAYING;
		}
		
		public function pause():void
		{
			stream.pause();
			_status = VideoController.PAUSED;
		}
		
		public function close():void
		{
			stream.close();
			_status = VideoController.STOPPED;
		}
		
		public function jumpTime( amount:Number ) :void
		{
			stream.seek( stream.time + amount );
		}
		
		// .. GET DATA METHODS .............................................................................
		
		
		public function getPercentLoaded():Number
		{
			return stream.bytesLoaded / stream.bytesTotal;
		}
		
		public function getPercentPlayed():Number
		{
			return stream.time / videoDuration;
		}
		
		public function get status():Number
		{
			return _status;
		}
		
		
		// .. PROPERTIES ..........................................................................................
		
		
		public function get smoothing():Boolean
		{
			return video.smoothing;
		}
		
		public function set smoothing(value:Boolean) :void
		{
			video.smoothing = value;
		}		
		
		public function setSize(width:Number, height:Number) :void
		{
			video.width = width;
			video.height = height;
		}
		
		
		// .. EVENTS ..............................................................................................
		
		
		
		public function onMetaData( metadata:Object ) :void
		{	
			/*
			for (var i:String in metadata)
				trace(i + ": " + metadata[i]);
			*/
			videoDuration = metadata.duration;
			videoFPS = metadata.framerate;
			
			// Stoping the video once loaded
			if (status == VideoController.STOPPED)
				stream.pause()
			
			if (!autoSize)
			{
				setSize(videoWidth, videoHeight);
			}
			else
			{
				videoWidth = metadata.width;
				videoHeight = metadata.height;
				setSize(videoWidth, videoHeight);
			}
			
			dispatchEvent( new Event( MediaEvent.METADATA ) );
		}
		
		public function netStatusHandler( event:NetStatusEvent ) :void
		{
			//trace("netStatus: " + event.info.code);
			
			switch(event.info.code)
			{
				case "NetStream.Play.Start":
				
					dispatchEvent( new Event( MediaEvent.PLAY ) );
				
				break;
				case "NetStream.Play.Stop":
				
					if (loop)
						stream.seek(0);
					
					dispatchEvent( new Event( MediaEvent.COMPLETE ) );
				
				break;
				case "NetStream.Buffer.Full":
					//trace("come on");
					dispatchEvent( new Event( MediaEvent.BUFFER_FULL ) );
				
				break;
			}
			
		}
	}
}