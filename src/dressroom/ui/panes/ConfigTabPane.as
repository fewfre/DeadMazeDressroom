package dressroom.ui.panes
{
	import dressroom.data.*;
	import dressroom.ui.*;
	import dressroom.ui.buttons.*;
	import dressroom.world.elements.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	
	public class ConfigTabPane extends TabPane
	{
		private static const MINI_BOX_SIZE:Number = 12;
		
		// Storage
		public var character:Character;
		public var sexButtons:Array;
		public var hairColorButtons:Array;
		public var skinColorButtons:Array;
		public var secondaryColorButtons:Array;
		
		public var hairColorPickerButton:PushButton;
		public var hairColorPickerButtonBox:Sprite;
		public var skinColorPickerButton:PushButton;
		public var skinColorPickerButtonBox:Sprite;
		public var secondaryColorPickerButton:PushButton;
		public var secondaryColorPickerButtonBox:Sprite;
		
		// Constructor
		public function ConfigTabPane(pCharacter:Character)
		{
			super();
			character = pCharacter;
			
			var i:int, xx:Number, yy:Number, spacing:Number, sizex:Number, sizey:Number, clr:int, tIndex:int;
			
			i = 0; xx = 100; yy = 50; spacing = 100; sizex = 80; sizey = 35;
			_newTextField({ text:"Items", x:36, y:yy+3 });
			sexButtons = [
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"Female", allowToggleOff:false }) ),
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"Male", allowToggleOff:false }) ),
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }) )
			];
			_registerClickHandler(sexButtons, _onSexButtonClicked);
			sexButtons[0].toggleOn();
			
			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Main.costumes.hairColors.length+0.5)*0.5; yy = 140; sizex = 30; sizey = 30;
			_newTextField({ text:"Hair", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40 });
			hairColorButtons = [];
			for(i = 0; i < Main.costumes.hairColors.length; i++) {
				clr = Main.costumes.hairColors[i];
				hairColorButtons.push( addChild( new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
			}
			hairColorButtons.push( addChild( hairColorPickerButton = new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:new $ColorWheel(), obj_scale:0.7, id:Main.costumes.hairColor, allowToggleOff:false }) ) );
			hairColorPickerButtonBox = hairColorPickerButton.addChild(_colorSpriteBox({ color:hairColorPickerButton.id, size:MINI_BOX_SIZE, x:(sizex-MINI_BOX_SIZE)*0.5, y:(sizey-MINI_BOX_SIZE)*0.5 }));
			_registerClickHandler(hairColorButtons, _onHairColorButtonClicked);
			tIndex = Main.costumes.hairColors.indexOf(Main.costumes.hairColor);
			hairColorButtons[tIndex > -1 ? tIndex : (hairColorButtons.length-1)].toggleOn();
			
			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Main.costumes.skinColors.length+0.5)*0.5; yy = 230; sizex = 30; sizey = 30;
			_newTextField({ text:"Skin", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40 });
			skinColorButtons = [];
			for(i = 0; i < Main.costumes.skinColors.length; i++) {
				clr = Main.costumes.skinColors[i];
				skinColorButtons.push( addChild( new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
			}
			skinColorButtons.push( addChild( skinColorPickerButton = new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:new $ColorWheel(), obj_scale:0.7, id:Main.costumes.skinColor, allowToggleOff:false }) ) );
			skinColorPickerButtonBox = skinColorPickerButton.addChild(_colorSpriteBox({ color:skinColorPickerButton.id, size:MINI_BOX_SIZE, x:(sizex-MINI_BOX_SIZE)*0.5, y:(sizey-MINI_BOX_SIZE)*0.5 }));
			_registerClickHandler(skinColorButtons, _onSkinColorButtonClicked);
			tIndex = Main.costumes.skinColors.indexOf(Main.costumes.skinColor);
			skinColorButtons[tIndex > -1 ? tIndex : (skinColorButtons.length-1)].toggleOn();
			
			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Main.costumes.secondaryColors.length+0.5)*0.5; yy = 320; sizex = 30; sizey = 30;
			_newTextField({ text:"Other", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40 });
			secondaryColorButtons = [];
			for(i = 0; i < Main.costumes.secondaryColors.length; i++) {
				clr = Main.costumes.secondaryColors[i];
				secondaryColorButtons.push( addChild( new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
			}
			secondaryColorButtons.push( addChild( secondaryColorPickerButton = new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:new $ColorWheel(), obj_scale:0.7, id:Main.costumes.secondaryColor, allowToggleOff:false }) ) );
			secondaryColorPickerButtonBox = secondaryColorPickerButton.addChild(_colorSpriteBox({ color:secondaryColorPickerButton.id, size:MINI_BOX_SIZE, x:(sizex-MINI_BOX_SIZE)*0.5, y:(sizey-MINI_BOX_SIZE)*0.5 }));
			_registerClickHandler(secondaryColorButtons, _onSecondaryColorButtonClicked);
			tIndex = Main.costumes.secondaryColors.indexOf(Main.costumes.secondaryColor);
			secondaryColorButtons[tIndex > -1 ? tIndex : (secondaryColorButtons.length-1)].toggleOn();
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
		
		// pData = { color:int, box:Sprite[optional], size:Number=20, x:Number[optional], y:Number[optional] }
		private function _colorSpriteBox(pData:Object) : Sprite {
			var tBox:Sprite = pData.box ? pData.box : new Sprite();
			var tSize:Number = pData.size ? pData.size : 20;
			tBox.graphics.beginFill(pData.color, 1);
			tBox.graphics.drawRect(0, 0, tSize, tSize);
			tBox.graphics.endFill();
			if(pData.x) tBox.x = pData.x;
			if(pData.y) tBox.y = pData.y;
			return tBox;
		}
		
		private function _registerClickHandler(pArray:Array, pCallback:Function) : void {
			for(var i:int = 0; i < pArray.length; i++) {
				pArray[i].addEventListener(PushButton.STATE_CHANGED_BEFORE, pCallback);
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
		
		private function _untoggle(pList:Array, pButton:PushButton=null) : void {
			if (pButton != null && pButton.pushed) { return; }
			
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}
		
		public function updateCustomColor(pType:String, tColor:int) {
			switch(pType) {
				case "hair": {
					Main.costumes.hairColor = tColor;
					hairColorPickerButton.id = tColor;
					_colorSpriteBox({ color:tColor, box:hairColorPickerButtonBox, size:MINI_BOX_SIZE });
					character.updatePose();
					break;
				}
				case "skin": {
					Main.costumes.skinColor = tColor;
					skinColorPickerButton.id = tColor;
					_colorSpriteBox({ color:tColor, box:skinColorPickerButtonBox, size:MINI_BOX_SIZE });
					character.updatePose();
					break;
				}
				case "secondary": {
					Main.costumes.secondaryColor = tColor;
					secondaryColorPickerButton.id = tColor;
					_colorSpriteBox({ color:tColor, box:secondaryColorPickerButtonBox, size:MINI_BOX_SIZE });
					character.updatePose();
					break;
				}
			}
		}
	}
}
