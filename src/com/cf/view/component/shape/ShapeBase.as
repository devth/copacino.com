package com.cf.view.component.shape
{
	import com.cf.util.AssetManager;
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.component.TitleTextSwipe;
	import com.cf.view.component.tile.Tile;
	import com.cf.view.event.UIEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import gs.TweenMax;
	import gs.easing.Strong;

	public class ShapeBase extends Component
	{
		
		// STATIC
		public static const UIEVENT_TILE_CLICK:String	= "uievent/tile/click";
		
		protected static const STATE_EXPANDED:String		= "stateExpanded";
		protected static const STATE_COLLAPSED:String		= "stateCollapsed";
		protected static const STATE_LIST_COLLAPSED:String	= "stateListCollapsed";
		
		
		// MEMBERS
		protected var _shapeContainer:Sprite;
		protected var _copyContainer:Sprite;
		protected var _tileContainer:Sprite;
		protected var _maskShape:Sprite;
		protected var _maskBitmap:Bitmap;
		
		protected var title:Component;
		
		protected var currentTitle:TitleTextSwipe;
		protected var minXForRows:Dictionary = new Dictionary(); // LEFT side
		protected var maxXForRows:Dictionary = new Dictionary(); // RIGHT side
		
		protected var leftRowWeights:Array = new Array(); // of RowData
		protected var rightRowWeights:Array = new Array(); // of RowData
		
		protected var tilesForRow:Dictionary = new Dictionary();
		protected var tilePositions:Dictionary = new Dictionary();
		
		protected var titleMask:Bitmap;
		
		protected var _saturationOffset:Number = 70;
		
		protected var _shapeSmall:Sprite;
		
		
		// PUBLIC
		public var isDragging:Boolean = false;
		public var tiles:Array = new Array();;
		public var url:String;
		public var originPoint:Point;
		//public var originX:Number;
		//public var originY:Number;
		
		
		public function ShapeBase()
		{
			super();
			
			// CREATE CONTAINERS
			_shapeContainer = new Sprite();
			addChild( _shapeContainer );
			
			_tileContainer = new Sprite();
			addChild( _tileContainer );
			
			_shapeSmall = new Sprite();
		}
		
		//
		// OVERRIDES
		//
		override protected function init():void
		{
			// CREATE SHAPE
			createShape();
			
			// ADD COPY CONTAINER after createShape() so it's on top
			_copyContainer = new Sprite();
			_shapeContainer.addChild( _copyContainer );
			
			// MASK
			_maskShape = new Sprite();
			_maskBitmap = new Bitmap(new BitmapData(50,50,false,0x000000));
			
			_maskBitmap.width = 0; // this.width;
			_maskBitmap.height = this.height;
			_maskBitmap.x = -this.halfWidth;
			_maskBitmap.y = -this.halfHeight;
			_maskShape.addChild( _maskBitmap );			
			
			//_maskShape.width = 0;
			addChild( _maskShape );
			_shapeContainer.mask = _maskShape;
			
			// CAPTURE origin (0,0)
			originPoint = new Point(0, 0);
			
			// INIT MIN/MAX
			initMinMaxValues();
			
			// INIT ROW WEIGHTs
			initRowWeights();
		}
		
		
		//
		// PROTECTED
		//
		protected function createShape():void
		{
			throw new IllegalOperationError("Abstract method: " + this);
		}
		protected function initMinMaxValues():void
		{
			throw new IllegalOperationError("Abstract method: " + this);
		}
		
		//
		// PUBLIC API
		//
		public function get shapeSmall():Sprite
		{
			return _shapeSmall;
		}
		public function reveal( delay:Number = 1):void
		{
			TweenMax.to( _maskBitmap, 1, { delay:delay, width:Settings.BAR_WIDTH });
		}
		public function hide( delay:Number = 0 ):void
		{
			TweenMax.killTweensOf( _maskBitmap );
			TweenMax.to( _maskBitmap, 1, { delay:delay, width:0 });
		}
		public function addTile(tile:Tile):void
		{
			tiles.push(tile);
			_tileContainer.addChild(tile);
			tile.addEventListener( MouseEvent.MOUSE_DOWN, tile_mouse_down );
		}
		
		
		// RANDOMLY arrange tiles
		public function arrangeTiles():void
		{
			/*
			1. Build a collection for each side that stores current width for every row
			2. Widths can be initially offset to weight particular rows (such as: smaller init width toward center and larger init widths toward upper and lower edges)
			3. To find the next row, sort the collection, lowest to highest.  The row that returns at the top of the sort gets the tile.
			4. The loop flips between -1 and 1 for currentHorzPos to alternate between left and right
			*/ 
			
			initMinMaxValues();
			
			var currentVertPos:int = 0;
			var currentHorzPos:int = -1; // CAN BE -1 or 1
			var currentRD:RowData;
			
			// var direction:int = 1; // 1 is up, -1 is down
			
			// LOOP thru tiles and position spirally
			for each (var tile:Tile in tiles)
			{			
				// GET NEXT ROW INDEX
				currentRD = getNextRow( currentHorzPos );
				currentVertPos = currentRD.row;
				
				//if ( tilePositions[positionPoint] == undefined ) tilePositions[ positionPoint ] = new Array();
				// var currTilePosition:Array = (tilePositions[positionPoint]) as Array;
				
				// GET reference to row
				if (tilesForRow[currentVertPos] == undefined) tilesForRow[currentVertPos] = new Array();
				var currentRowArray:Array = (tilesForRow[currentVertPos] as Array);
				
				// ENFORCE maximum tiles per vertical edge
				/*if ((direction == 1 && currentVertPos == Settings.MAX_VERTICAL_LINES_FROM_CENTER) || (direction == -1 && currentVertPos == -(Settings.MAX_VERTICAL_LINES_FROM_CENTER+1)))
				{
					if ((currentRowArray.length >= Settings.MAX_TILES_PER_VERTICAL_EDGE))
					{
						// FLIP and move
						currentHorzPos = direction;
						direction *= -1;
						currentVertPos += direction;
					}
				}*/
				
				
				
				
				// X
				var tileSpace:Number = (tile.width + Settings.TILE_MARGIN + getRandomSpacer(currentVertPos));
				// ADD weight
				currentRD.weight += tileSpace; 
					
				if (currentHorzPos <= 0) // left of center
				{
					
					// DEFAULT if null
					if (minXForRows[currentVertPos] == undefined) minXForRows[currentVertPos] = originPoint.x - 1;
					// POSITION as far left as possible
					tile.right = minXForRows[currentVertPos];
					// SUBTRACT width to the min
					minXForRows[currentVertPos] -= tileSpace;
					
				}
				else if (currentHorzPos > 0) // right of center
				{
					// DEFAULT if null
					if (maxXForRows[currentVertPos] == undefined) maxXForRows[currentVertPos] = originPoint.x;
					// POSITION as far right as possible
					tile.left = maxXForRows[currentVertPos];
					// ADD width to the max
					maxXForRows[currentVertPos] += tileSpace;
					
				}
				
				
				// Y
				tile.bottom = originPoint.y - (currentVertPos * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
				
				// SAVE TILE in dictionary for this row
				currentRowArray.push(tile);
				
				
				// AT THE TOP OR BOTTOM, flip direction
				/*if ((direction == 1 && currentVertPos == Settings.MAX_VERTICAL_LINES_FROM_CENTER) || (direction == -1 && currentVertPos == -(Settings.MAX_VERTICAL_LINES_FROM_CENTER+1)))
				{
					currentHorzPos = direction;
					direction *= -1;
				}
				else
				{
					// PROGRESS position in current direction
					currentVertPos += direction;
				}*/
				
				
				// SWAP SIDES
				currentHorzPos *= -1;
				
				// COLOR
				tile.BgColor = getTileColor(tile);
						
			}
		}
		private function getNextRow( currentHorzPos:int ):RowData
		{
			var rows:Array;
			if ( currentHorzPos < 0 ) rows = leftRowWeights;
			else rows = rightRowWeights;
			
			
			var sortedArr:Array = rows.sortOn( "weight", Array.NUMERIC ) 
			for (var i:int = 0; i < sortedArr.length; i++)
			{
				//trace( (sortedArr[i] as RowData).weight );
			}
			
			return (sortedArr[0] as RowData); 
		}
		
		// THIS works but it's not used in the current psudo-random algorithm
		private function getNextRandomPosition():Point
		{
			var p:Point = new Point();
			p.x = -1 + (2 * Math.round( Math.random() ) );
			p.y = -Settings.MAX_VERTICAL_LINES_FROM_CENTER + ( Math.random() * 2 * Settings.MAX_VERTICAL_LINES_FROM_CENTER );
			
			
			return p;
		}

		public function arrangeTilesOrganized():void
		{
			initMinMaxValues();
			
			var currentVertPos:int = 0;
			
			var currentHorzPos:int = -1;
			
			var direction:int = 1; // 1 is up, -1 is down
			
			// LOOP thru tiles and position spirally
			for each (var tile:Tile in tiles)
			{
				
				// GET reference to row
				if (tilesForRow[currentVertPos] == undefined) tilesForRow[currentVertPos] = new Array();
				var currentRowArray:Array = (tilesForRow[currentVertPos] as Array);
				
				// ENFORCE maximum tiles per vertical edge
				if ((direction == 1 && currentVertPos == Settings.MAX_VERTICAL_LINES_FROM_CENTER) || (direction == -1 && currentVertPos == -(Settings.MAX_VERTICAL_LINES_FROM_CENTER+1)))
				{
					if ((currentRowArray.length >= Settings.MAX_TILES_PER_VERTICAL_EDGE))
					{
						// FLIP and move
						currentHorzPos = direction;
						direction *= -1;
						currentVertPos += direction;
					}
				}
				
				// X
				if (currentHorzPos < 0) // left of center
				{
					// DEFAULT if null
					if (minXForRows[currentVertPos] == undefined) minXForRows[currentVertPos] = originPoint.x - 1;
					// POSITION as far left as possible
					tile.right = minXForRows[currentVertPos];
					// SUBTRACT width to the min
					minXForRows[currentVertPos] -= (tile.width + Settings.TILE_MARGIN + getRandomSpacer(currentVertPos));
				}
				else if (currentHorzPos > 0) // right of center
				{
					// DEFAULT if null
					if (maxXForRows[currentVertPos] == undefined) maxXForRows[currentVertPos] = originPoint.x;
					// POSITION as far right as possible
					tile.left = maxXForRows[currentVertPos];
					// ADD width to the max
					maxXForRows[currentVertPos] += (tile.width + Settings.TILE_MARGIN + getRandomSpacer(currentVertPos));
				}
				
				// Y
				tile.bottom = originPoint.y - (currentVertPos * (Settings.TILE_HEIGHT + Settings.TILE_MARGIN));
				
				
				// SAVE TILE in dictionary for this row
				currentRowArray.push(tile);
				
				
				
				// AT THE TOP OR BOTTOM, flip direction
				if ((direction == 1 && currentVertPos == Settings.MAX_VERTICAL_LINES_FROM_CENTER) || (direction == -1 && currentVertPos == -(Settings.MAX_VERTICAL_LINES_FROM_CENTER+1)))
				{
					currentHorzPos = direction;
					direction *= -1;
				}
				else
				{
					// PROGRESS position in current direction
					currentVertPos += direction;
				}
				
				
				// COLOR
				tile.BgColor = getTileColor(tile);
						
			}
		}
		
		public function collapse():void
		{
			this.isTransitioning = true;
			
			if ( this.state == STATE_LIST_COLLAPSED ) this.reveal();
			
			this.useHandCursor = this.buttonMode = true;
			_copyContainer.mouseChildren = _copyContainer.mouseEnabled = false;
			
			closeTiles();
			
			TweenMax.to( _shapeContainer, 1.2, { ease:Strong.easeOut, delay:1, scaleX: Settings.SHAPE_MINIMIZED_SCALE, scaleY:Settings.SHAPE_MINIMIZED_SCALE });
			TweenMax.to( _maskShape, 1.2, { ease:Strong.easeOut, delay:1, scaleX: Settings.SHAPE_MINIMIZED_SCALE, scaleY:Settings.SHAPE_MINIMIZED_SCALE, onComplete: function():void{
				isTransitioning = false;
			} });
			
			/* DON'T scale copy container any more
			TweenMax.to( _copyContainer, 1.2, { ease:Strong.easeOut, delay:1, scaleX: Settings.SHAPE_MINIMIZED_SCALE, scaleY:Settings.SHAPE_MINIMIZED_SCALE, onComplete: function():void{
				isTransitioning = false;
			} });*/
			
			state = STATE_COLLAPSED;
		}
		public function expand( delay:Number = 0):void
		{
			this.isTransitioning = true;
			
			this.useHandCursor = this.buttonMode = false;
			_copyContainer.mouseChildren = _copyContainer.mouseEnabled = true;
			
			openTiles();
			reveal();
			
			TweenMax.to( _shapeContainer, 1.2, { delay:delay, ease:Strong.easeOut, scaleX: 1, scaleY:1 });
			TweenMax.to( _maskShape, 1.2, { delay:delay, ease:Strong.easeOut, scaleX: 1, scaleY:1, onComplete: function():void {
				isTransitioning = false;
			} });
			/*TweenMax.to( _copyContainer, 1.2, { delay:delay, ease:Strong.easeOut, scaleX: 1, scaleY:1, onComplete: function():void {
				isTransitioning = false;
			} });*/
			
			state = STATE_EXPANDED;
		}
		public function collapseList():void
		{
			// collapse();
			
			closeTiles();
			hide();
			
			state = STATE_LIST_COLLAPSED;
		}
		
		//
		// EVENT HANLDERS
		//
		private function tile_mouse_down(e:MouseEvent):void
		{
			var tile:Tile = e.target as Tile;
			dispatchEvent( new UIEvent( UIEVENT_TILE_CLICK, tile.tileData.postTitle.toLowerCase(), this.url + "/" + Utility.formatAsSlug( tile.tileData.postTitle ), true, true ) );
		}
		
		//
		// PIVATE
		//
		private function initRowWeights():void
		{
			var i:int = 0;
			var weight:Number = 0;
			for (i = -Settings.MAX_VERTICAL_LINES_FROM_CENTER - 1; i <= Settings.MAX_VERTICAL_LINES_FROM_CENTER; i++)
			{
				weight = Math.abs( i ) * 10;
				// weight = 0;
				
				// INIT them symetrically
				leftRowWeights.push( new RowData( i, weight ) );
				rightRowWeights.push( new RowData( i, weight ) );
			}
			
		}
		private function closeTiles():void
		{
			for each (var tile:Tile in tiles)
			{
				tile.unWipe();
			}
		}
		private function openTiles():void
		{
			for each (var tile:Tile in tiles)
			{
				tile.wipe(Math.random() * 2);
			}
		}
		
		// 
		// UTIL
		//
		protected function getTileColor(tile:Tile):uint
		{
			//
			// CALCULATE the tile's color based on location
			//
			
			var tilePoint:Point = new Point(tile.centerX, tile.centerY);
			
			// ANGLE
			var radians:Number = Utility.getAngleRadiansBetweenPoints( tilePoint, originPoint );
			
			// DISTANCE
			var dist:Number = Utility.getDistanceBetweenPoints( tilePoint, originPoint );
			
			// OFSET angle
			radians += Utility.degreesToRadians(100);
			
			// CALCULATE the RGB channels based on the angle of the line being drawn.
			// var sat:Number = 30 + (Math.random() * 60); // random saturation
			var nR:Number = Math.cos(radians)                   * (dist/10 + (Math.random() * _saturationOffset)) + 128 << 16;
			var nG:Number = Math.cos(radians + 2 * Math.PI / 3) * (dist/10 + (Math.random() * _saturationOffset)) + 128 << 8;
			var nB:Number = Math.cos(radians + 4 * Math.PI / 3) * (dist/10 + (Math.random() * _saturationOffset)) + 128;
			
			// OR the individual color channels together.
			var nColor:Number = nR | nG | nB;
			
			// RETURN color
			return nColor;
		}
		protected function getRandomSpacer(verticalPosition:int):Number
		{
			// CHANCE that any margin will return
			if ((Math.random() * 100) > (400 / (Settings.MAX_VERTICAL_LINES_FROM_CENTER - Math.abs(verticalPosition))))
				return 5 + Math.random() * 30; // * (verticalPosition - Settings.MAX_VERTICAL_LINES_FROM_CENTER);
			else
				return 0;
		}
	}
}