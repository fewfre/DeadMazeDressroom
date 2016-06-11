package GUI 
{
	import flash.display.*;
	import flash.display.Shape;
	import flash.events.*;
	
	public class ShopTabContainer extends RoundedRectangle
	{
		// Storage
		public var DefaultX:Number;
		public var DefaultY:Number;
		
		var tabs:Array;
		
		// Constructor
		public function ShopTabContainer(pX:Number, pY:Number, pWidth:Number, pHeight:Number)
		{
			super(pX, pY, pWidth, pHeight);
			this.DefaultX = pX;
			this.DefaultY = pY;
			
			this.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 0x6a8fa2, 0x11171c, 0x324650);
			
			// _drawLine(5, 29, this.Width);
			
			var tXSpacing:Number = 0;//55;
			var tX:Number = 5-tXSpacing;
			var tYSpacing:Number = 43;//0;
			var tY:Number = 10-tYSpacing;
			var tWidth:Number = 50;
			var tHeight:Number = 38;
			
			tabs = new Array();
			
			_addTab("Config", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, "config");
			_addTab("Objects", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.OBJECT);
			_addTab("Skin", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.SKIN);
			_addTab("Hair", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.HAIR);
			_addTab("Head", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.HEAD);
			_addTab("Shirts", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.SHIRT);
			_addTab("Pants", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.PANTS);
			_addTab("Shoes", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.SHOES);
			_addTab("Pose", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ItemType.POSE);
			
			tabs[0].ToggleOn();
		}
		
		private function _addTab(pText:String, pX:Number, pY:Number, pWidth:Number, pHeight:Number, pEvent:String) : GUI.PushButton {
			var tBttn:GUI.PushButton = new GUI.PushButton(pX, pY, pWidth, pHeight, pText);
			tabs.push(addChild(tBttn));
			tBttn.addEventListener(MouseEvent.MOUSE_UP, function(tBttn){ return function(){ untoggle(tBttn, pEvent); }; }(tBttn));//, false, 0, true
			return tBttn;
		}
		
		private function _drawLine(pX:Number, pY:Number, pWidth:Number) : void {
			var tLine:Shape = new Shape();
			tLine.x = pX;
			tLine.y = pY;
			addChild(tLine);
			
			tLine.graphics.lineStyle(1, 0x11181C, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth - 10, 0);
			
			tLine.graphics.lineStyle(1, 0x608599, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth - 10, 1);
		}

		public function UnpressAll() : void {
			untoggle();
		}
		
		private function untoggle(pTab:GUI.PushButton=null, pEvent:String=null) : void {
			if (pTab != null && pTab.Pushed) { return; }
			
			for(var i:int = 0; i < tabs.length; i++) {
				if (tabs[i].Pushed && tabs[i] != pTab) {
					tabs[i].ToggleOff();
				}
			}
			
			if(pEvent!=null) { dispatchEvent(new DataEvent(ConstantsApp.EVENT_SHOP_TAB_CLICKED, false, false, pEvent)); }
		}
	}
}
