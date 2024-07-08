package app.ui.screens
{
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.RoundedRectangle;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import fl.transitions.easing.Elastic;
	import fl.transitions.Tween;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class LinkTray extends Sprite
	{
		// Storage
		private var _bg					: RoundedRectangle;
		
		public var _text				: TextField;
		public var _textCopiedMessage	: TextTranslated;
		public var _textCopyTween		: Tween;
		
		// Constructor
		// pData = { x:Number, y:Number }
		public function LinkTray(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			
			/****************************
			* Click Tray
			*****************************/
			var tClickTray:Sprite = addChild(new Sprite()) as Sprite;
			tClickTray.x = -5000;
			tClickTray.y = -5000;
			tClickTray.graphics.beginFill(0x000000, 0.2);
			tClickTray.graphics.drawRect(0, 0, -tClickTray.x*2, -tClickTray.y*2);
			tClickTray.graphics.endFill();
			tClickTray.addEventListener(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			_bg = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();

			/****************************
			* Header
			*****************************/
			new TextTranslated("share_header", { size:25, y:-63 }).appendToT(this);
			
			/****************************
			* Selectable text field
			*****************************/
			_text = _newCopyInput({ x:0, y:0 }, this);
			
			/****************************
			* Copy Button and message
			*****************************/
			var tCopyButton:SpriteButton = new SpriteButton({ x:tWidth*0.5-(80/2)-20, y:52, text:"share_copy", width:80, height:25, origin:0.5 }).appendTo(this)
				.on(ButtonBase.CLICK, function():void{ _copyToClipboard(); }) as SpriteButton;
			
			_textCopiedMessage = new TextTranslated("share_link_copied", { size:17, originX:1, x:tCopyButton.x - tCopyButton.Width/2 - 10, y:tCopyButton.y, alpha:0 }).appendToT(this);
			
			/****************************
			* Close Button
			*****************************/
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:new $WhiteX() })) as ScaleButton;
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
		}
		
		public function open(pURL:String) : void {
			_text.text = pURL;
			_textCopiedMessage.alpha = 0;
		}
		
		private function _clearCopiedMessages() : void {
			if(_textCopyTween) _textCopyTween.stop();
			_textCopiedMessage.alpha = 0;
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _copyToClipboard() : void {
			_clearCopiedMessages();
			_text.setSelection(0, _text.text.length)
			System.setClipboard(_text.text);
			_textCopiedMessage.alpha = 0;
			if(_textCopyTween) _textCopyTween.start(); else _textCopyTween = new Tween(_textCopiedMessage, "alpha", Elastic.easeOut, 0, 1, 1, true);
		}
		
		private function _newCopyInput(pData:Object, pParent:Sprite) : TextField {
			var tTFWidth:Number = _bg.width-50, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			var tTextBackground:RoundedRectangle = new RoundedRectangle(tTFWidth+tTFPaddingX*2, tTFHeight+tTFPaddingY*2, { origin:0.5 }).setXY(pData.x, pData.y)
				.appendTo(pParent).draw(0xFFFFFF, 7, 0x444444);
			
			var tTextField:TextField = tTextBackground.addChild(new TextField()) as TextField;
			tTextField.type = TextFieldType.DYNAMIC;
			tTextField.multiline = false;
			tTextField.width = tTFWidth;
			tTextField.height = tTFHeight;
			tTextField.x = tTFPaddingX - tTextBackground.Width*0.5;
			tTextField.y = tTFPaddingY - tTextBackground.Height*0.5;
			tTextField.addEventListener(MouseEvent.CLICK, function(pEvent:Event):void{
				_clearCopiedMessages();
				tTextField.setSelection(0, tTextField.text.length);
			});
			return tTextField;
		}
	}
}
