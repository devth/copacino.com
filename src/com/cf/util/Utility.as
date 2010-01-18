package com.cf.util
{
	import com.cf.model.vo.NavData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.puremvc.as3.utilities.statemachine.State;

	public class Utility
	{
		//
		// MATHS
		//
		public static function getDistanceBetweenPoints(p1:Point, p2:Point):Number
		{
			var dx:Number = p2.x-p1.x;
 			var dy:Number = p2.y-p1.y;
 			return  Math.sqrt(dx*dx + dy*dy);
		}
		
		public static function getAngleRadiansBetweenPoints(p1:Point, p2:Point):Number
		{
			return ( - Math.atan2( (p1.x - p2.x), (p1.y - p2.y)));
		}
		
		public static function degreesToRadians(d:Number):Number
		{
			return ( d * Math.PI / 180 );
		}
		
		public static function radiansToDegrees(r:Number):Number
		{
			return ( r * 180 / Math.PI );
		}
		
		public static function roundUpToEvenInt(n:Number):int
		{
			n = int(n);
			
			if ((n % 2) == 0) return n;
			else return (n+1);
		}
		
		public static function snapToNearest(value:Number, min:Number, max:Number):Number
		{
			return 0;
		}
		
		public static function boundNumber( value:Number, min:Number, max:Number):Number
		{
			return Math.max( Math.min( value, max ), min );
		}
		
		
		//
		// BITMAP / COLOR
		//
		public static function getMaskShape(width:Number=10, height:Number=10):Bitmap
		{
			var b:Bitmap = new Bitmap(new BitmapData(10,10,false,0x00FF00));
			// SET width/height here incase they are zero
			b.width = width;
			b.height = height;
			return b;
		}
		public static function getRandomPositiveColor():uint
		{
			return getColorForAngle( Math.random() * 360 );
		}
		public static function getColorForAngle( degrees:Number ):uint
		{
			var radians:Number = Utility.degreesToRadians( degrees );
			
			var nR:Number = Math.cos(radians)                   * (20 + (Math.random() * 70)) + 128 << 16;
			var nG:Number = Math.cos(radians + 2 * Math.PI / 3) * (20 + (Math.random() * 70)) + 128 << 8;
			var nB:Number = Math.cos(radians + 4 * Math.PI / 3) * (20 + (Math.random() * 70)) + 128;
			
			// OR the individual color channels together.
			var nColor:Number = nR | nG | nB;
			
			return nColor;
		}
		public static function contrainImageSize(currentSize:Point, bounds:Point):Point
		{
			// TODO: CONSTRIAN
			
			
			return new Point();
		}
		public static function getEquilateralTriangle( color:uint, length:int ):Shape
		{
			var triangle:Shape = new Shape();
			triangle.graphics.beginFill( color, 1 );
			triangle.graphics.moveTo( length >> 1, 0 );
			triangle.graphics.lineTo( length, length );
			triangle.graphics.lineTo( 0, length );
			triangle.graphics.lineTo( length >> 1, 0 );
			triangle.graphics.endFill();
			
			return triangle;
		}
		public static function addInvisibleHitArea( sprite:Sprite, padding:int = 0 ):void
		{
			sprite.graphics.beginFill(0x00FF00, 0);
			sprite.graphics.drawRect(-padding,-padding, sprite.width + (2*padding), sprite.height + (2*padding));
			sprite.graphics.endFill();
		}
		
		
		//
		// DATE
		//
		public static function parseDate( str : String ) : Date
		{
		    var matches : Array = str.match(/(\d\d\d\d)-(\d\d)-(\d\d)/);
		    var d : Date = new Date();
		    d.setFullYear( int(matches[1]), int(matches[2]) - 1, int(matches[3]));
		    return d;
		}
		public static function parseDateMillisecondsEllapsed( str : String ) : Number
		{
			var matches : Array = str.match(/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/);
			
			var d : Date = new Date();
			d.setFullYear(int(matches[1]), int(matches[2]) - 1, int(matches[3]));
			d.setHours( int(matches[4]), int(matches[5]), int(matches[6]), 0);  
	
			return d.valueOf()
		}
		
		
		//
		// FSM
		//
		public static function changingNote(state:String):String
		{
			return State.STATE_CHANGED + state;
		}
		public static function exitingNote(state:String):String
		{
			return State.STATE_EXITING + state;
		}
		public static function enteringNote(state:String):String
		{
			return State.STATE_ENTERING + state;
		}
		
		
		//
		// DEBUGGING
		//
		public static function debug(source:*, ...params):void
		{
			MonsterDebugger.trace( source, formatMesage(params) ); 
		}
		public static function debugColor(source:*, color:uint, ...params):void
		{
			MonsterDebugger.trace( source, formatMesage(params), color );
		}
		public static function formatMesage(params:Array):String
		{
			var retString:String = "";
			for each (var p:String in params)
			{				
				retString += "\t" + p;
			}
			
			return retString;
		}
		
		
		//
		// FORMATTING
		//
		public static function formatAsSlug(string:String):String
		{
			string = string.toLowerCase();
			string = string.replace(/[^a-zA-Z0-9 ]/g, "" ); // REMOVE punctuation
			string = string.replace(/ /g, "-"); // REPLACE all spaces with hyphens
			return string;
		}
		
		//
		// URLs
		//
		public static function isMainNav( segment:String ):Boolean
		{
			for (var i:int = 0; i < Settings.NAV_MAIN.length; i++)
			{
				var nd:NavData = Settings.NAV_MAIN[i] as NavData;
				if ( nd.segments[1] == segment ) return true;
			}
			if ( segment == Settings.URL_WE_ARE_NOT ) return true;
			
			return false;
		}
		
		
	}
}