package app.ui.screens
{
	import flash.display.Sprite;
	import app.ui.common.RoundedRectangle;
	import app.ui.common.FancyCopyField;
	import com.fewfre.utils.Fewf;
	import app.data.GameAssets;
	import flash.events.MouseEvent;
	import com.fewfre.display.TextTranslated;
	import flash.events.Event;
	import app.ui.buttons.ScaleButton;
	import com.fewfre.display.ButtonBase;

	public class ShareScreen extends Sprite
	{
		// Storage
		private var _bg        : RoundedRectangle;
		private var _copyField : FancyCopyField;
		
		// Constructor
		public function ShareScreen() {
			// Center Screen
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 200;
			// Background
			_bg = new RoundedRectangle(tWidth, tHeight, { origin:0.5 }).appendTo(this).drawAsTray();
			
			// Header
			new TextTranslated("share_header", { size:25, y:-55 }).appendToT(this);
			
			// Copy Field
			_copyField = new FancyCopyField(_bg.width-50).appendTo(this).centerOrigin().move(0, 35);
			
			// Close Button
			new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:new $WhiteX() }).appendTo(this).on(ButtonBase.CLICK, _onCloseClicked);
		}
		public function on(type:String, listener:Function): ShareScreen { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): ShareScreen { this.removeEventListener(type, listener); return this; }
		
		public function open(pURL:String) : void {
			_copyField.text = pURL;
		}
		
		private function _onCloseClicked(e:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
