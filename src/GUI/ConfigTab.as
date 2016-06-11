package GUI 
{
	import fl.containers.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.*;
	
	public class ConfigTab extends Tab
	{
		// Storage
		public var character:Character;
		public var sexButtons:Array;
		public var hairColorButtons:Array;
		public var skinColorButtons:Array;
		public var secondaryColorButtons:Array;
		
		// Constructor
		public function ConfigTab(pCharacter:Character)
		{
			super();
			character = pCharacter;
			
			var i:int, xx:Number, yy:Number, spacing:Number, sizex:Number, sizey:Number, clr:int;
			
			i = 0; xx = 100; yy = 50; spacing = 100; sizex = 80; sizey = 35;
			_newTextField({ text:"Sex", x:36, y:yy+3 });
			sexButtons = [
				//addChild( new PushButton(xx + (spacing*i++), yy, sizex, sizey, "Female") ),
				//addChild( new PushButton(xx + (spacing*i++), yy, sizex, sizey, "Male") ),
				addChild( new PushButton(xx + (spacing*i++), yy, sizex, sizey, "Both") )
			];
			_registerClickHandler(sexButtons, _onSexButtonClicked);
			sexButtons[0].ToggleOn();
			
			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Main.costumes.hairColors.length+0.5)*0.5; yy = 140; sizex = 30; sizey = 30;
			_newTextField({ text:"Hair", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40 });
			hairColorButtons = [];
			for(i = 0; i < Main.costumes.hairColors.length; i++) {
				clr = Main.costumes.hairColors[i];
				hairColorButtons.push( addChild( new SpritePushButton(xx + (spacing*i), yy, sizex, sizey, _newColorBox(clr), clr) ) );
			}
			hairColorButtons.push( addChild( new SpritePushButton(xx + (spacing*i), yy, sizex, sizey, new $ColorWheel(), null) ) );
			hairColorButtons[hairColorButtons.length-1].Image.scaleX = hairColorButtons[hairColorButtons.length-1].Image.scaleY = 0.7;
			_registerClickHandler(hairColorButtons, _onHairColorButtonClicked);
			hairColorButtons[0].ToggleOn();
			hairColorButtons[hairColorButtons.length-1].alpha = 0.2;
			
			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Main.costumes.skinColors.length+0.5)*0.5; yy = 230; sizex = 30; sizey = 30;
			_newTextField({ text:"Skin", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40 });
			skinColorButtons = [];
			for(i = 0; i < Main.costumes.skinColors.length; i++) {
				clr = Main.costumes.skinColors[i];
				skinColorButtons.push( addChild( new SpritePushButton(xx + (spacing*i), yy, sizex, sizey, _newColorBox(clr), clr) ) );
			}
			skinColorButtons.push( addChild( new SpritePushButton(xx + (spacing*i), yy, sizex, sizey, new $ColorWheel(), null) ) );
			skinColorButtons[skinColorButtons.length-1].Image.scaleX = skinColorButtons[skinColorButtons.length-1].Image.scaleY = 0.7;
			_registerClickHandler(skinColorButtons, _onSkinColorButtonClicked);
			skinColorButtons[0].ToggleOn();
			skinColorButtons[skinColorButtons.length-1].alpha = 0.2;
			
			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Main.costumes.secondaryColors.length+0.5)*0.5; yy = 320; sizex = 30; sizey = 30;
			_newTextField({ text:"Other", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40 });
			secondaryColorButtons = [];
			for(i = 0; i < Main.costumes.secondaryColors.length; i++) {
				clr = Main.costumes.secondaryColors[i];
				secondaryColorButtons.push( addChild( new SpritePushButton(xx + (spacing*i), yy, sizex, sizey, _newColorBox(clr), clr) ) );
			}
			secondaryColorButtons.push( addChild( new SpritePushButton(xx + (spacing*i), yy, sizex, sizey, new $ColorWheel(), null) ) );
			secondaryColorButtons[secondaryColorButtons.length-1].Image.scaleX = secondaryColorButtons[secondaryColorButtons.length-1].Image.scaleY = 0.7;
			_registerClickHandler(secondaryColorButtons, _onSecondaryColorButtonClicked);
			secondaryColorButtons[0].ToggleOn();
			secondaryColorButtons[secondaryColorButtons.length-1].alpha = 0.2;
		}
		
		// pData = { text:String, x:Number, y:Number, size:int, color:int }
		private function _newTextField(pData:Object) : TextField {
			var tText = addChild(new TextField());
			tText.defaultTextFormat = new flash.text.TextFormat("Verdana", pData.size ? pData.size : 17, pData.color ? pData.color : 0xC2C2DA);
			
			tText.text = pData.text;
			tText.x = pData.x;
			tText.y = pData.y;
			return tText;
		}
		
		private function _newColorBox(pColor:int, pSize:Number=20) : DisplayObject {
			var tBox:Sprite = new Sprite();
			tBox.graphics.beginFill(pColor, 1);
			tBox.graphics.drawRect(0, 0, pSize, pSize);
			tBox.graphics.endFill();
			return tBox;
		}
		
		private function _registerClickHandler(pArray:Array, pCallback:Function) : void {
			for(var i:int = 0; i < pArray.length; i++) {
				pArray[i].addEventListener(MouseEvent.MOUSE_UP, pCallback);
			}
		}
		
		private function _onSexButtonClicked(pEvent:Event) {
			
		}
		
		private function _onHairColorButtonClicked(pEvent:Event) {
			_untoggle(hairColorButtons, pEvent.target);
			Main.costumes.hairColor = pEvent.target.id;
			character.updatePose();
		}
		
		private function _onSkinColorButtonClicked(pEvent:Event) {
			_untoggle(skinColorButtons, pEvent.target);
			Main.costumes.skinColor = pEvent.target.id;
			character.updatePose();
		}
		
		private function _onSecondaryColorButtonClicked(pEvent:Event) {
			_untoggle(secondaryColorButtons, pEvent.target);
			Main.costumes.secondaryColor = pEvent.target.id;
			character.updatePose();
		}
		
		private function _untoggle(pList:Array, pButton:SpritePushButton=null) : void {
			if (pButton != null && pButton.Pushed) { return; }
			
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].Pushed && pList[i] != pButton) {
					pList[i].ToggleOff();
				}
			}
		}
	}
}
