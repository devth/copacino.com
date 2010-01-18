package com.cf.view.component.container
{
	import com.cf.util.Component;
	import com.cf.util.Settings;
	import com.cf.util.Utility;
	import com.cf.view.component.Mask;
	import com.cf.view.component.OpacityLines;
	import com.cf.view.component.list.ListBase;
	import com.cf.view.component.shape.ShapeBase;
	import com.cf.view.component.shape.ShapePlus;
	import com.cf.view.component.tile.Tile;
	import com.cf.view.event.UIEvent;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashpress.vo.WpPostWithTagAndCatVO;
	
	import gs.TweenLite;
	import gs.TweenMax;
	import gs.easing.Strong;

	public class ContainerBase extends Component
	{
		// EVENTS
		public static const CONTAINER_READY:String				= "event/container/ready";
		
		// STATES
		public static const STATE_LOADING:String				= "stateLoading";
		public static const STATE_OPEN:String					= "stateOpen";
		public static const STATE_LIST:String					= "stateList";
		public static const STATE_MINIMIZED:String				= "stateMinimized";
		public static const STATE_MINIMIZED_LIST:String			= "stateMinimizedList";
		public static const STATE_MINIMIZED_FULLSCREEN:String	= "stateMinimizedFullscreen";
		
		// PROTECTED MEMBERS
		
		protected var _background:Sprite;
		protected var _backgroundMask:Mask;
		protected var _opacityLines:OpacityLines;
		protected var _shape:ShapeBase;
		protected var _list:ListBase;
		protected var _mask:Sprite;
		
		protected var _tileData:Array;
		protected var _listData:Array;
		
		// LIST scrolling
		protected var _shapeStartDrag:Point;
		
		// PRIVATE MEMBERS
		private var _linesAreInitialized:Boolean = false;
		private var _shapeType:Class;
		private var _listType:Class;
		
		// PUBLIC
		public var url:String;
		
		public function ContainerBase(shapeType:Class, listType:Class )
		{
			_shapeType = shapeType;
			_listType = listType;
			
			super();
		}
		
		
		//
		// OVERRIDES
		//
		override protected function init():void
		{
			super.init();
			
			// MASK
			_mask = new Sprite;
			_mask.addChild( Utility.getMaskShape() );
			_mask.width = stage.stageWidth;
			_mask.height = stage.stageHeight;
			addChild( _mask );
			this.mask = _mask;
			
			// BACKGROUND
			_background = new Sprite();
			addChild( _background );
			
			setupBackground();
			
			// BG MASK - children can choose to add a mask, but it's not required
			if (_backgroundMask != null)
			{
				addChild( _backgroundMask );
				_background.mask = _backgroundMask;
			}
			
			// OPACITY lines
			_opacityLines = new OpacityLines();
			addChild( _opacityLines );
			_opacityLines.alpha = Settings.INIT_LINE_CONTAINER_OPACITY;
			_opacityLines.addEventListener(OpacityLines.LINES_INIT, lines_init);
			_opacityLines.blendMode = BlendMode.OVERLAY;
			
			// ADD content
			_shape = new _shapeType();
			addChild( _shape );
			
			
			drawOpacityLines();
			
			// POSITION
			position();
			
			
			// WIRE EVENTS
			_shape.addEventListener( MouseEvent.CLICK, shape_click );
			_shape.addEventListener( MouseEvent.MOUSE_DOWN, shape_mouse_down );
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouse_up );
			this.addEventListener( Event.ENTER_FRAME, enter_frame );
			
		}
		override protected function onStageResize(e:Event):void
		{
			super.onStageResize(e);
		}
		
		
		//
		// METHODS
		//
		protected function setupBackground():void
		{
			throw new Error("Abstract method");
		}
		override protected function position():void
		{
			// MASK
			_mask.width = stage.stageWidth;
			_mask.height = stage.stageHeight;
			
			// POSITION shape based on current state
			var expectedShapePos:Point = getExpectedShapePosition( _state );
			_shape.x = expectedShapePos.x;
			_shape.y = expectedShapePos.y;
			
			
			//if ( _state != STATE_LOADING )
			//{
				// SIZE opacity lines
				_opacityLines.setMinHeight( stage.stageHeight );
				_opacityLines.setWidth( stage.stageWidth );
				
				// SIZE BG TO STAGE
				_background.width = stage.stageWidth;
				_background.height = stage.stageHeight;
			//}
		}
		
		protected function getExpectedShapePosition( state:String ):Point
		{
			var point:Point = new Point(0,0);
			switch ( state )
			{
				case STATE_MINIMIZED:
				
					point.x = (stage.stageWidth >> 1) - (_shape.originPoint.x * Settings.SHAPE_MINIMIZED_SCALE);
					
					if (this._shapeType == ShapePlus) point.y = ((Settings.SHAPE_MINIMIZED_SCALE * Settings.BAR_WIDTH) >> 1) - Settings.FIRST_LINE_HEIGHT;
					else point.y = (Settings.TRAY_HEIGHT >> 1) - (_shape.originPoint.y * Settings.SHAPE_MINIMIZED_SCALE);
				
				break;
				case STATE_LOADING:
				case STATE_OPEN:
				default:
					
					point.x = (stage.stageWidth >> 1) - (_shape.originPoint.x);
					point.y = ((stage.stageHeight - Settings.TRAY_HEIGHT) >> 1) - (_shape.originPoint.y);
					// SNAP to NEXT line
					point.y -= (point.y % (Settings.TILE_HEIGHT + Settings.TILE_MARGIN)) - 5;
					point.y += (Settings.TILE_ROW_HEIGHT);
					
				break;
				case STATE_MINIMIZED_LIST:
				
					point.x = (stage.stageWidth >> 1) - (_shape.originPoint.x * Settings.SHAPE_MINIMIZED_SCALE);
					point.y = (Settings.TRAY_HEIGHT_LIST >> 1) - (_shape.originPoint.y * Settings.SHAPE_MINIMIZED_SCALE);
				
				break;
				/*case STATE_LIST:
					
					point.x = ( stage.stageWidth * (1 - Settings.LIST_WIDTH_PERCENT) * .5) - ( Settings.TILE_HEIGHT / 2 ); 
					point.y = Settings.LIST_PLUS_TOP;
				
				break;*/
				
			}
			return point;
		}
		
		
		protected function createTiles( autoReveal:Boolean=true ):void
		{
			// ADD tiles
			for each (var post:WpPostWithTagAndCatVO in _tileData)
			{
				_shape.addTile(new Tile(post.postTitle.toLowerCase(), 0x000000, autoReveal, post));
			}
			
			// ARRANGE tiles
			_shape.arrangeTiles();
		}
		protected function initList():void
		{
			if (_list == null)
			{
				_list = new _listType( _listData, _shape, url);
				addChild(_list);
				//_list.x = Settings.LIST_MARGIN_LEFT;
				//_list.y = Settings.LIST_MARGIN_TOP;
			}
		}
		private function lines_init(e:Event):void
		{
			_linesAreInitialized = true;	
		}
		private function drawOpacityLines():void
		{
			if (!_linesAreInitialized)
			{
				_opacityLines.initLines();
				//TweenMax.to(opacityLinesLayer, 1.5, { width:stage.stageWidth, ease: Strong.easeOut } );		
			}
			else _opacityLines.setWidth(stage.stageWidth); 
			
			_linesAreInitialized = true;
		}
		
		
		//
		// HANDLERS
		//
		private function shape_click(e:MouseEvent):void
		{
			if (state != STATE_LIST && state != STATE_LOADING)
			{
				dispatchEvent( new UIEvent( UIEvent.SHAPE_CLICK, _shape.name, _shape.url ) );
			}
		}
		private function shape_mouse_down(e:MouseEvent):void
		{
			if (state == STATE_LIST)
			{
				// START DRAGGING
				var bounds:Rectangle = new Rectangle( _shape.x, Settings.LIST_PLUS_TOP, 0, stage.stageHeight - Settings.LIST_PLUS_TOP);
				//_shape.startDrag(true, bounds);
				//_shape.isDragging = true;
				//_shapeStartDrag = new Point(_shape.x, _shape.y);

				
			}
		}
		private function stage_mouse_up(e:MouseEvent):void
		{
			//_shape.stopDrag();
			//_shape.isDragging = false;
		}
		private function enter_frame(e:Event):void
		{
			if (state == STATE_LIST && _shape.isDragging)
			{
				// TODO move list based on distance gradient
				if (_shape.y > _shapeStartDrag.y)
				{
				//	_list.y -= 10;
				}
				else
				{
				//	_list.y = Math.min( _list.y + 10, Settings.LIST_MARGIN_TOP );
				}
			}
		}
		
		
		//
		// PUBLIC API
		//
		public function loadComplete():void
		{
			dispatchEvent( new Event( ContainerBase.CONTAINER_READY, true, true ) );
			//throw new IllegalOperationError("Abstract method, must override");
		}
		public function toListState( isCloudDisplay:Boolean = false ):void
		{
			if ( state == STATE_LIST && 
				(
					(isCloudDisplay == true && _list.state == ListBase.STATE_CLOUD_DISPLAY) ||
					(isCloudDisplay == false && _list.state == ListBase.STATE_REVEALED)
				))	
				return;
			
			// FADE OUT LINES
			TweenLite.to( _opacityLines, 2, { alpha:0 });
			
			// COLLAPSE SHAPE
			_shape.collapseList();
			
			// MOVE SHAPE
			var expectedPointPos:Point = getExpectedShapePosition( STATE_LIST );
			TweenMax.to(_shape, 2, { delay:1, x:expectedPointPos.x, ease: Strong.easeInOut });
			TweenMax.to(_shape, 2, { delay:1, y: expectedPointPos.y, ease: Strong.easeInOut });
			
			// OPEN LIST
			_list.reveal( .5, isCloudDisplay );
			
			// SET STATE
			Utility.debugColor( this, 0x245a0a, "from:", state, "to:", STATE_LIST );
			state = STATE_LIST;
		}
		public function toOpenState():void
		{
			if ( state == STATE_OPEN ) return;
			
			// FADE IN LINES
			TweenLite.to( _opacityLines, 2, { delay:1, alpha:1 });
			
			
			// IF it's coming from loading, don't do anything since it's a special case
			//if (state != STATE_LOADING)
			//{
				// MOVE SHAPE
				var expectedPointPos:Point = getExpectedShapePosition( STATE_OPEN );
				TweenMax.to(_shape, 2, { delay: 0, x: expectedPointPos.x, y: expectedPointPos.y, ease: Strong.easeInOut });
				
				// EXPAND SHAPE
				_shape.expand();
				
				if ( state == STATE_LIST )
				{
					// COLLAPSE LIST
					_list.hide( 0 );
				}
				else if ( state == STATE_MINIMIZED )
				{
				}
			//}
			
			Utility.debugColor( this, 0x245a0a, "from:", state, "to:", STATE_OPEN );
			state = STATE_OPEN;
		}
		public function toMinimizedState():void
		{
			if ( state == STATE_MINIMIZED ) return;
			
			if ( state == STATE_LIST )
			{
				// ADDITIONAL cleanup for transitioning from list to minimized
				_list.hide( 0 );
				
				// REVEAL
				_shape.reveal();
			}
			
			// FADE OUT LINES
			TweenLite.to( _opacityLines, 2, { alpha:0 });
			
			// COLLAPSE SHAPE
			_shape.collapse();
			
			
			// MOVE SHAPE
			var expectedPointPos:Point = getExpectedShapePosition( STATE_MINIMIZED );
			TweenMax.to(_shape, 2, { delay:1, x:expectedPointPos.x , y: expectedPointPos.y, ease: Strong.easeInOut });
			
			
			Utility.debugColor( this, 0x245a0a, "from:", state, "to:", STATE_MINIMIZED );
			state = STATE_MINIMIZED;
		}
		public function toMinimizedListState():void
		{
			if ( state == STATE_OPEN || state == STATE_LIST ) toMinimizedListState();
			
			// MOVE SHAPE
			var expectedPointPos:Point = getExpectedShapePosition( STATE_MINIMIZED_LIST );
			TweenMax.to(_shape, 1, { x:expectedPointPos.x , y: expectedPointPos.y, ease: Strong.easeInOut });
			
			state = STATE_MINIMIZED_LIST;
		}
		public function toMinimizedFullscreenState():void
		{
			// if ( state != STATE_MINIMIZED_FULLSCREEN ) 
			toMinimizedListState();
			
			state = STATE_MINIMIZED_FULLSCREEN;
		}
		
		
		
		//
		// GETTERS / SETTERS
		//
		public function set tileData(data:Array):void
		{
			_tileData = data;
		}
		public function set listData(data:Array):void
		{
			_listData = data;
			
			if (_list == null) initList();
			else _list.data = data;
		}
		public function get shape():ShapeBase
		{
			return _shape;
		}
		public function get list():ListBase
		{
			return _list;
		}
		
	}
}