package com.devth.media
{
	import flash.events.IEventDispatcher;

	public interface IMediaController extends IEventDispatcher
	{
		function load( url:String ):void;
		function pause():void;
		function play( percent:Number = 0 ):void;
		function resume():void;
		function setVolume( percent:Number ):void;
		function getPercentLoaded():Number;
		function getPercentPlayed():Number;
		
		function get status():Number;
	}
}