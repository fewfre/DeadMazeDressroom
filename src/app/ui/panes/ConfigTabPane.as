package app.ui.panes
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.TextBase;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
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
		public var facingButtons:Array;
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

			i = 0; xx = 70; yy = 50; spacing = 75; sizex = 60; sizey = 35;
			addChild(new TextBase({ text:"label_sex", x:35, y:yy+3, size:17, originY:0 }));
			sexButtons = [
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_female", allowToggleOff:false, data:{ id:SEX.FEMALE } }) ),
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_male", allowToggleOff:false, data:{ id:SEX.MALE } }) )
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }) )
			];
			_registerClickHandler(sexButtons, _onSexButtonClicked);
			sexButtons[ Costumes.instance.sex == SEX.MALE ? 1 : 0].toggleOn();
			
			/*i = 0; xx = 285;
			addChild(new TextBase({ text:"label_face_dir", x:250, y:yy+3, size:17, originY:0 }));
			facingButtons = [
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_face_front", allowToggleOff:false, data:{ id:true } }) ),
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_face_back", allowToggleOff:false, data:{ id:false } }) )
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }) )
			];
			_registerClickHandler(facingButtons, _onFacingButtonClicked);
			facingButtons[ Costumes.instance.facingForward == false ? 1 : 0].toggleOn();*/

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Costumes.instance.hairColors.length+0.5)*0.5; yy = yy+90; sizex = 30; sizey = 30;
			addChild(new TextBase({ text:"label_hair_color", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40, size:17, originY:0 }));
			hairColorButtons = [];
			for(i = 0; i < Costumes.instance.hairColors.length; i++) {
				clr = Costumes.instance.hairColors[i];
				hairColorButtons.push( addChild( new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
			}
			hairColorButtons.push( addChild( hairColorPickerButton = new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:new $ColorWheel(), obj_scale:0.7, id:Costumes.instance.hairColor }) ) );
			hairColorPickerButtonBox = hairColorPickerButton.addChild(_colorSpriteBox({ color:hairColorPickerButton.id, size:MINI_BOX_SIZE, x:(sizex-MINI_BOX_SIZE)*0.5, y:(sizey-MINI_BOX_SIZE)*0.5 }));
			_registerClickHandler(hairColorButtons, _onHairColorButtonClicked);
			hairColorPickerButtonBox.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onColorPickerButtonClicked);
			tIndex = Costumes.instance.hairColors.indexOf(Costumes.instance.hairColor);
			hairColorButtons[tIndex > -1 ? tIndex : (hairColorButtons.length-1)].toggleOn();

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Costumes.instance.skinColors.length+0.5)*0.5; yy = yy+90; sizex = 30; sizey = 30;
			addChild(new TextBase({ text:"label_skin_color", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40, size:17, originY:0 }));
			skinColorButtons = [];
			for(i = 0; i < Costumes.instance.skinColors.length; i++) {
				clr = Costumes.instance.skinColors[i];
				skinColorButtons.push( addChild( new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
			}
			skinColorButtons.push( addChild( skinColorPickerButton = new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:new $ColorWheel(), obj_scale:0.7, id:Costumes.instance.skinColor }) ) );
			skinColorPickerButtonBox = skinColorPickerButton.addChild(_colorSpriteBox({ color:skinColorPickerButton.id, size:MINI_BOX_SIZE, x:(sizex-MINI_BOX_SIZE)*0.5, y:(sizey-MINI_BOX_SIZE)*0.5 }));
			_registerClickHandler(skinColorButtons, _onSkinColorButtonClicked);
			skinColorPickerButton.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onColorPickerButtonClicked);
			tIndex = Costumes.instance.skinColors.indexOf(Costumes.instance.skinColor);
			skinColorButtons[tIndex > -1 ? tIndex : (skinColorButtons.length-1)].toggleOn();

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(Costumes.instance.secondaryColors.length+0.5)*0.5; yy = yy+90; sizex = 30; sizey = 30;
			addChild(new TextBase({ text:"label_other_color", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-40, size:17, originY:0 }));
			secondaryColorButtons = [];
			for(i = 0; i < Costumes.instance.secondaryColors.length; i++) {
				clr = Costumes.instance.secondaryColors[i];
				secondaryColorButtons.push( addChild( new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
			}
			secondaryColorButtons.push( addChild( secondaryColorPickerButton = new PushButton({ x:xx + (spacing*i), y:yy, width:sizex, height:sizey, obj:new $ColorWheel(), obj_scale:0.7, id:Costumes.instance.secondaryColor }) ) );
			secondaryColorPickerButtonBox = secondaryColorPickerButton.addChild(_colorSpriteBox({ color:secondaryColorPickerButton.id, size:MINI_BOX_SIZE, x:(sizex-MINI_BOX_SIZE)*0.5, y:(sizey-MINI_BOX_SIZE)*0.5 }));
			_registerClickHandler(secondaryColorButtons, _onSecondaryColorButtonClicked);
			secondaryColorPickerButton.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onColorPickerButtonClicked);
			tIndex = Costumes.instance.secondaryColors.indexOf(Costumes.instance.secondaryColor);
			secondaryColorButtons[tIndex > -1 ? tIndex : (secondaryColorButtons.length-1)].toggleOn();
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

		private function _onSexButtonClicked(pEvent:FewfEvent) {
			_untoggle(sexButtons, pEvent.target);
			Costumes.instance.sex = pEvent.data.id;
			character.updatePose();
			dispatchEvent(new Event("sex_change"));
		}

		private function _onFacingButtonClicked(pEvent:FewfEvent) {
			_untoggle(facingButtons, pEvent.target);
			Costumes.instance.facingForward = pEvent.data.id;
			character.updatePose();
			dispatchEvent(new Event("facing_change"));
		}

		private function _onHairColorButtonClicked(pEvent:Event) {
			_untoggle(hairColorButtons, pEvent.target);
			Costumes.instance.hairColor = pEvent.target.id;
			character.updatePose();
			dispatchEvent(new FewfEvent("color_changed", { type:"hair" }));
		}

		private function _onSkinColorButtonClicked(pEvent:Event) {
			_untoggle(skinColorButtons, pEvent.target);
			Costumes.instance.skinColor = pEvent.target.id;
			character.updatePose();
			dispatchEvent(new FewfEvent("color_changed", { type:"skin" }));
		}

		private function _onSecondaryColorButtonClicked(pEvent:Event) {
			_untoggle(secondaryColorButtons, pEvent.target);
			Costumes.instance.secondaryColor = pEvent.target.id;
			character.updatePose();
			dispatchEvent(new FewfEvent("color_changed", { type:"secondary" }));
		}
		
		// Unlike the default color buttons, "allowToggleOff" is set to true
		// since need to be able to click even after selected.
		// This simply forces it to show as selected even when toggled off.
		private function _onColorPickerButtonClicked(pEvent:Event) {
			pEvent.target.toggleOff(false);
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
					Costumes.instance.hairColor = tColor;
					hairColorPickerButton.id = tColor;
					_colorSpriteBox({ color:tColor, box:hairColorPickerButtonBox, size:MINI_BOX_SIZE });
					character.updatePose();
					break;
				}
				case "skin": {
					Costumes.instance.skinColor = tColor;
					skinColorPickerButton.id = tColor;
					_colorSpriteBox({ color:tColor, box:skinColorPickerButtonBox, size:MINI_BOX_SIZE });
					character.updatePose();
					break;
				}
				case "secondary": {
					Costumes.instance.secondaryColor = tColor;
					secondaryColorPickerButton.id = tColor;
					_colorSpriteBox({ color:tColor, box:secondaryColorPickerButtonBox, size:MINI_BOX_SIZE });
					character.updatePose();
					break;
				}
			}
			dispatchEvent(new FewfEvent("color_changed", { type:pType }));
		}
	}
}
