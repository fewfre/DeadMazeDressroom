package GUI.buttons
{
	import GUI.*;
	import flash.display.*;
	import flash.events.*;
	
	public class ButtonBase extends Sprite
	{
		// Button State
		public static const BUTTON_STATE_UP:String = "button_state_up";
		public static const BUTTON_STATE_DOWN:String = "button_state_down";
		public static const BUTTON_STATE_OVER:String = "button_state_over";
		//public static const BUTTON_STATE_CLICK:String = "button_state_click";
		
		// Button Events
		public static const UP:String = "button_up";
		public static const DOWN:String = "button_down";
		public static const OVER:String = "button_over";
		public static const OUT:String = "button_out";
		public static const CLICK:String = "button_click";
	
		// Storage
		protected var _state		: String;
		protected var _flagEnabled	: Boolean;
		protected var _returnData	: *;
		protected var _bg			: RoundedRectangle;
		
		// Properties
		public function get Width():Number { return _bg.Width; }
		public function get Height():Number { return _bg.Height; }
		public function get data():Number { return _returnData; }
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number[optional], height:Number[optional], data:*[optional] }
		public function ButtonBase(pData:Object)
		{
			super();
			_state = BUTTON_STATE_UP;
			if(pData.width) { _bg = addChild(new RoundedRectangle(0, 0, pData.width, pData.height)); }
			
			this.x = pData.x;
			this.y = pData.y;
			
			_returnData = pData.data;
			
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			enable();
			
			_addEventListeners();
		}
		
		/****************************
		* Events
		*****************************/
		protected function _addEventListeners() : void {
			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			addEventListener(MouseEvent.CLICK, _onMouseUp);//MOUSE_UP
			addEventListener(MouseEvent.ROLL_OVER, _onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, _onMouseOut);
		}

		protected function _onMouseDown(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_DOWN;
			_renderDown();
			_dispatch(DOWN);
		}

		protected function _onMouseUp(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_UP;
			_renderUp();
			_dispatch(UP);
			_dispatch(CLICK);
		}

		protected function _onMouseOver(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_OVER;
			_renderOver();
			_dispatch(OVER);
		}

		protected function _onMouseOut(pEvent:MouseEvent) : void
		{
			if(!_flagEnabled) { return; }
			_state = BUTTON_STATE_UP;
			_renderOut();
			_dispatch(OUT);
		}

		/****************************
		* Render
		*****************************/
		protected function _renderUp() : void {
			_bg.draw(ConstantsApp.COLOR_BUTTON_BLUE, 7, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}
		
		protected function _renderDown() : void
		{
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_DOWN);
		}
		
		protected function _renderOver() : void {
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_OVER, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_OVER);
		}
		
		protected function _renderOut() : void {
			_renderUp();
		}
		
		protected function _renderDisabled() : void {
			_bg.draw(0x555555, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, 0x555555);
		}

		/****************************
		* Methods
		*****************************/
		public function _dispatch(pEvent:String) : void {
			if(!_returnData) { dispatchEvent(new Event(pEvent)); }
			else {
				dispatchEvent(new Event(pEvent)); // [TODO] Return data
			}
		}
		
		public function enable() : ButtonBase {
			_flagEnabled = true;
			_state = BUTTON_STATE_UP;
			_renderUp();
			return this;
		}

		/**********************************************************
		@description
		 **********************************************************/
		public function disable() : ButtonBase {
			_flagEnabled = false;
			_renderDisabled();
			return this;
		}
	}
}
