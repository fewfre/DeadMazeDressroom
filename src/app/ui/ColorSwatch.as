package app.ui
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import com.fewfre.display.TextBase;
	import app.ui.buttons.*;
	import app.ui.buttons.ScaleButton;
	
	public class ColorSwatch extends Sprite
	{
		// Constants
		public static const BUTTON_CLICK:String="button_click";
		public static const ENTER_PRESSED:String="enter_pressed";
		public static const USER_MODIFIED_TEXT:String="user_modified_text";
		
		private static const SWATCH_SIZE:Number = 18;
		private static const TEXT_WIDTH:Number = 56;
		
		// Storage
		public var selected:Boolean=false;
		private var _swatch:Sprite;
		private var _border:Sprite;
		private var _text:TextField;
		private var _textBorder:Sprite;
		private var _historyBtn:ScaleButton;
		private var _lockIcon:ScaleButton;
		private var _locked:Boolean = false;
		
		// Properties
		public function get textValue():String { return _text.text; }
		public function get intValue():uint { return int("0x" + _text.text); }
		public function set value(pColor:uint) : void
		{
			_swatch.graphics.clear();
			_swatch.graphics.beginFill(pColor);
			_swatch.graphics.drawRoundRect(1, 1, 18, 18, 5);
			_swatch.graphics.endFill();
			_text.text = pColor.toString(16);
		}
		public function get historyButton():ScaleButton { return _historyBtn; }
		public function get lockIcon():ScaleButton { return _lockIcon; }
		public function get locked():Boolean { return _locked; }
		
		// Constructor
		public function ColorSwatch() {
			super();
			_swatch = addChild(new Sprite()) as Sprite;
			_swatch.x = 5;
			_swatch.buttonMode = true;
			_swatch.graphics.beginFill(0);
			_swatch.graphics.drawRoundRect(1, 1, SWATCH_SIZE, SWATCH_SIZE, 5);
			_swatch.graphics.endFill();
			_swatch.addEventListener(flash.events.MouseEvent.CLICK, _onSwatchClicked);
			
			_border = addChild(new Sprite()) as Sprite;
			_border.x = 5;
			_border.graphics.lineStyle(1.5, 0);
			_border.graphics.drawRoundRect(0, 0, SWATCH_SIZE+2, SWATCH_SIZE+2, 5);
			
			_text = addChild(new TextField()) as TextField;
			_text.defaultTextFormat = new TextFormat("Verdana", 11, 0xc2c2da);
			_text.x = _swatch.x + SWATCH_SIZE+2 + 6 + 3;
			_text.y = 1;
			_text.height = SWATCH_SIZE;
			_text.width = TEXT_WIDTH;
			_text.type = TextFieldType.INPUT;
			_text.text = "000000";
			_text.maxChars = 6;
			_text.restrict = "0-9a-f";
			_text.addEventListener(flash.events.KeyboardEvent.KEY_UP, _onTextInputKeyUp);
			_text.addEventListener(flash.events.MouseEvent.CLICK, _onSwatchClicked);
			
			_textBorder = addChild(new Sprite()) as Sprite;
			_textBorder.x = _border.x + SWATCH_SIZE+2 + 6;
			_drawTextBorder();
			
			var tHistoryHitbox = new Sprite(), hitboxSize = SWATCH_SIZE*1.65;
			tHistoryHitbox.graphics.beginFill(0, 0);
			tHistoryHitbox.graphics.drawRect(-hitboxSize*0.5, -hitboxSize*0.5, hitboxSize, hitboxSize);
			tHistoryHitbox.graphics.endFill();
			tHistoryHitbox.addChild(new $UndoArrow());
			_historyBtn = addChild(new ScaleButton({ x:100, y:SWATCH_SIZE*0.5+1.5, obj:tHistoryHitbox, obj_scale:0.5 })) as ScaleButton;
			_historyBtn.visible = false;
			
			var tLockHitbox = new Sprite(), hitboxSize = SWATCH_SIZE*2;
			tLockHitbox.graphics.beginFill(0, 0);
			tLockHitbox.graphics.drawRect(-hitboxSize*0.5, -hitboxSize*0.5, hitboxSize, hitboxSize);
			tLockHitbox.graphics.endFill();
			tLockHitbox.addChild(new $Lock());
			_lockIcon = addChild(new ScaleButton({ obj:tLockHitbox })) as ScaleButton;
			unlock();
		}

		private function _onTextInputKeyUp(pEvent:KeyboardEvent) : void {
			if(_text.text != "") {
				dispatchEvent(new Event(USER_MODIFIED_TEXT));
			}
			if(_text.text != "" && pEvent.charCode == 13) {
				dispatchEvent(new Event(ENTER_PRESSED));
			}
		}
		private function _onSwatchClicked(pEvent:MouseEvent) : void {
			dispatchEvent(new flash.events.Event(BUTTON_CLICK));
		}

		public function select() : void
		{
			if(selected) { return; }
			
			selected = true;
			_border.graphics.clear();
			_border.graphics.lineStyle(0.5, 0x888888);
			_border.graphics.drawRoundRect(-1.5, -1.5, SWATCH_SIZE+2+3, SWATCH_SIZE+2+3, 5);
			_border.graphics.lineStyle(1.5, 0);
			_border.graphics.drawRoundRect(0, 0, SWATCH_SIZE+2, SWATCH_SIZE+2, 5);
			
			_drawTextBorder();
		}

		public function unselect() : void
		{
			selected = false;
			_border.graphics.clear();
			_border.graphics.lineStyle(1.5, 0);
			_border.graphics.drawRoundRect(0, 0, SWATCH_SIZE+2, SWATCH_SIZE+2, 5);
			
			_drawTextBorder();
		}
		
		private function _drawTextBorder() : void {
			_textBorder.graphics.clear();
			if(selected) {
				_textBorder.graphics.lineStyle(0.5, 0x888888);
				_textBorder.graphics.drawRoundRect(-1.5, -1.5, TEXT_WIDTH+2+3, SWATCH_SIZE+2+3, 5);
			}
			_textBorder.graphics.lineStyle(1.5, 0);
			_textBorder.graphics.drawRoundRect(0, 0, TEXT_WIDTH+2, SWATCH_SIZE+2, 5);
		}
		
		public function showHistoryButton() {
			_historyBtn.visible = true;
		}
		
		public function lock() {
			_lockIcon.alpha = 0.7;
			_lockIcon.setScale(0.65);
			_lockIcon.x = _swatch.x + SWATCH_SIZE*0.5 + 0.5 + 1;
			_lockIcon.y = _swatch.y + SWATCH_SIZE*0.5 + 0.5;
			_locked = true;
		}
		
		public function unlock() {
			_lockIcon.alpha = 0.5;
			_lockIcon.setScale(0.5);
			_lockIcon.x = -1;
			_lockIcon.y = SWATCH_SIZE*0.5;
			_locked = false;
		}
	}
}
