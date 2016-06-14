package GUI.buttons
{
	import GUI.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.geom.*;
	
	public class PushButton extends ButtonBase
	{
		// Storage
		public var id:int;
		public var Pushed:Boolean;
		public var Text:flash.text.TextField;
		public var Image:flash.display.DisplayObject;
		
		// Constants
		public static const STATE_CHANGED_BEFORE:String="state_changed_before";
		public static const STATE_CHANGED_AFTER:String="state_changed_after";
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number, obj:DisplayObject[optional], obj_scale:Number[optional], text:String[optional], id:int[optional] }
		public function PushButton(pData:Object)
		{
			super(pData);
			if(pData.id) { id = pData.id; }
			
			if(pData.text) {
				this.Text = new flash.text.TextField();
				this.Text.defaultTextFormat = new flash.text.TextFormat("Verdana", 11, 0xC2C2DA);
				this.Text.autoSize = flash.text.TextFieldAutoSize.CENTER;
				this.Text.text = pData.text;
				addChild(this.Text);
			}
			
			if(pData.obj) {
				var tBounds:Rectangle = pData.obj.getBounds(pData.obj);
				var tOffset:Point = tBounds.topLeft;
				
				var tScale:Number = pData.obj_scale ? pData.obj_scale : 1;
				this.Image = pData.obj;
				this.Image.x = pData.width / 2 - (tBounds.width / 2 + tOffset.x)*tScale * this.Image.scaleX;
				this.Image.y = pData.height / 2 - (tBounds.height / 2 + tOffset.y)*tScale * this.Image.scaleY;
				this.Image.scaleX *= tScale;
				this.Image.scaleY *= tScale;
				addChild(this.Image);
			}
			
			this.Pushed = false;
			this.Unpressed();
		}
		
		public function Unpressed():*
		{
			super._renderUp();
			
			if(this.Text) {
				this.Text.x = (this.Width - this.Text.textWidth) / 2 - 2;
				this.Text.y = (this.Height - this.Text.textHeight) / 2 - 2;
			}
		}

		public function Pressed():*
		{
			super._renderDown();
			
			if(this.Text) {
				this.Text.x = (this.Width - this.Text.textWidth) / 2;
				this.Text.y = (this.Height - this.Text.textHeight) / 2;
			}
		}

		public function Toggle():*
		{
			dispatchEvent( new flash.events.Event(STATE_CHANGED_BEFORE) );
			this.Pushed = !this.Pushed;
			if (this.Pushed) {
				this.Pressed();
			} else {
				this.Unpressed();
			}
			dispatchEvent( new flash.events.Event(STATE_CHANGED_AFTER) );
		}

		public function ToggleOn():*
		{
			this.Pushed = true;
			this.Pressed();
			if(this.Text) this.Text.textColor = 0xFFD800;
		}

		public function ToggleOff():*
		{
			this.Pushed = false;
			this.Unpressed();
			if(this.Text) this.Text.textColor = 0xC2C2DA;
		}
		
		override protected function _onMouseUp(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			dispatchEvent( new flash.events.Event(STATE_CHANGED_BEFORE) );
			if (this.Pushed == false) {
				this.ToggleOn();
			} else {
				this.ToggleOff();
			}
			dispatchEvent( new flash.events.Event(STATE_CHANGED_AFTER) );
			super._onMouseUp(pEvent);
		}
		
		override protected function _renderUp() : void {
			if (this.Pushed == false) {
				super._renderUp();
			}
		}
		
		override protected function _renderDown() : void {
			if (this.Pushed == false) {
				if(this.Text) this.Text.textColor = this.Pushed ? 0xFFD800 : 0xC2C2DA;
				super._renderDown();
			}
		}
		
		override protected function _renderOver() : void {
			if (this.Pushed == false) {
				if(this.Text) this.Text.textColor = 74565;
				super._renderOver();
			}
		}
		
		override protected function _renderOut() : void {
			if(this.Text) this.Text.textColor = this.Pushed ? 0xFFD800 : 0xC2C2DA;
			if(this.Pushed == false) {
				super._renderOut();
			}
		}
	}
}
