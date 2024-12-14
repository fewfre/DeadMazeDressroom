package app.ui.screens
{
	import app.data.GameAssets;
	import app.ui.buttons.ScaleButton;
	import app.ui.common.FancyCopyField;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.utils.Fewf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import app.data.ConstantsApp;

	public class ShareScreen extends Sprite
	{
		// Storage
		private var _copyField : FancyCopyField;
		
		// Constructor
		public function ShareScreen() {
			this.x = ConstantsApp.CENTER_X;
			this.y = ConstantsApp.CENTER_Y;
			
			GameAssets.createScreenBackdrop().appendTo(this).on(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 200;
			// Background
			new RoundRectangle(tWidth, tHeight).toOrigin(0.5).drawAsTray().appendTo(this);
			
			// Header
			new TextTranslated("share_header", { size:25 }).move(0, -55).appendTo(this);
			
			// Copy Field
			_copyField = new FancyCopyField(tWidth-50).appendTo(this).centerOrigin().move(0, 35);
			
			// Close Button
			ScaleButton.withObject(new $WhiteX()).move(tWidth/2 - 5, -tHeight/2 + 5).appendTo(this).onButtonClick(_onCloseClicked);
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
