package dressroom.ui 
{
	import dressroom.data.*;
	import dressroom.ui.*;
	import dressroom.ui.buttons.*;
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
			
			var tXSpacing:Number = 0;//55;
			var tX:Number = 5-tXSpacing;
			var tYSpacing:Number = 43;//0;
			var tY:Number = 10-tYSpacing;
			var tWidth:Number = 50;
			var tHeight:Number = 38;
			
			tabs = new Array();
			
			_addTab("Config", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, "config");
			_addTab("Skin", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.SKIN);
			_addTab("Hair", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.HAIR);
			_addTab("Head", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.HEAD);
			_addTab("Shirts", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.SHIRT);
			_addTab("Pants", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.PANTS);
			_addTab("Shoes", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.SHOES);
			_addTab("Objects", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.OBJECT);
			_addTab("Pose", tX += tXSpacing, tY += tYSpacing, tWidth, tHeight, ITEM.POSE);
			
			tabs[0].ToggleOn();
		}
		
		private function _addTab(pText:String, pX:Number, pY:Number, pWidth:Number, pHeight:Number, pEvent:String) : PushButton {
			var tBttn:PushButton = new PushButton({ x:pX, y:pY, width:pWidth, height:pHeight, text:pText, allowToggleOff:false });
			tabs.push(addChild(tBttn));
			tBttn.addEventListener(PushButton.STATE_CHANGED_BEFORE, function(tBttn){ return function(){ untoggle(tBttn, pEvent); }; }(tBttn));//, false, 0, true
			return tBttn;
		}

		public function UnpressAll() : void {
			untoggle();
		}
		
		private function untoggle(pTab:PushButton=null, pEvent:String=null) : void {
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
