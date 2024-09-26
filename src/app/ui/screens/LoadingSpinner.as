package app.ui.screens
{
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class LoadingSpinner extends Sprite
	{
		private var _loadingSpinner	: Sprite;
		
		// pData = { x, y, scale }
		public function LoadingSpinner(pData:Object=null) {
			pData = pData || {};
			if(pData.x) { this.x = pData.x; }
			if(pData.y) { this.y = pData.y; }
			var scale:Number = pData.scale ? pData.scale : 2;
			
			_loadingSpinner = addChild( new $Loader() ) as Sprite;
			_loadingSpinner.scaleX = scale;
			_loadingSpinner.scaleY = scale;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		public function setXY(pX:Number, pY:Number) : LoadingSpinner { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): LoadingSpinner { target.addChild(this); return this; }
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, update);
			_loadingSpinner = null;
		}
		
		public function update(pEvent:Event):void {
			var dt:Number = 0.1;
			if(_loadingSpinner != null) {
				_loadingSpinner.rotation += 360 * dt;
			}
		}
	}
}