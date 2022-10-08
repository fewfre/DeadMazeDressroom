package app.ui.panes
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
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
		public var advancedButton:PushButton;

		public var hairColorPickerButton:ColorButton;
		public var skinColorPickerButton:ColorButton;
		public var secondaryColorPickerButton:ColorButton;

		// Constructor
		public function ConfigTabPane(pCharacter:Character)
		{
			super();
			character = pCharacter;
			
			var i:int, xx:Number, yy:Number, spacing:Number, sizex:Number, sizey:Number, clr:int, tIndex:int;

			i = 0; xx = 70; yy = 30; spacing = 75; sizex = 60; sizey = 35;
			addChild(new TextBase({ text:"label_sex", x:35, y:yy+3, size:17, originY:0 }));
			sexButtons = [
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_female", allowToggleOff:false, data:{ id:SEX.FEMALE } }) ),
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_male", allowToggleOff:false, data:{ id:SEX.MALE } }) )
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }) )
			];
			_registerClickHandler(sexButtons, PushButton.STATE_CHANGED_BEFORE, _onSexButtonClicked);
			sexButtons[ GameAssets.sex == SEX.MALE ? 1 : 0].toggleOn();
			
			/*i = 0; xx = 285;
			addChild(new TextBase({ text:"label_face_dir", x:250, y:yy+3, size:17, originY:0 }));
			facingButtons = [
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_face_front", allowToggleOff:false, data:{ id:true } }) ),
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_face_back", allowToggleOff:false, data:{ id:false } }) )
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }) )
			];
			_registerClickHandler(facingButtons, PushButton.STATE_CHANGED_BEFORE, _onFacingButtonClicked);
			facingButtons[ GameAssets.facingForward == false ? 1 : 0].toggleOn();*/

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(10+0.5)*0.5; yy = yy+80; sizex = 30; sizey = 30;
			var cbo = spacing/2-3;
			addChild(new TextBase({ text:"label_hair_color", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-35, size:17, originY:0 }));
			hairColorButtons = [];
			for(i = 0; i < GameAssets.hairColors.length; i++) {
				if(i%10 == 0 && i >= 10) {
					yy += spacing;
				}
				clr = GameAssets.hairColors[i];
				hairColorButtons.push( addChild( new ColorButton({ color:clr, x:xx+cbo + (spacing*(i%10)), y:yy+cbo, width:sizex, height:sizey }) ) );
			}
			hairColorButtons.push( addChild( hairColorPickerButton = _newColorPickerButton(GameAssets.hairColor, xx+cbo + (spacing*10), yy+cbo-(spacing*0.5), sizex) ) );
			_registerClickHandler(hairColorButtons, ButtonBase.CLICK, _onHairColorButtonClicked);
			tIndex = GameAssets.hairColors.indexOf(GameAssets.hairColor);
			hairColorButtons[tIndex > -1 ? tIndex : (hairColorButtons.length-1)].selected = true;

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(GameAssets.skinColors.length+0.5)*0.5; yy = yy+80; sizex = 30; sizey = 30;
			addChild(new TextBase({ text:"label_skin_color", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-35, size:17, originY:0 }));
			skinColorButtons = [];
			for(i = 0; i < GameAssets.skinColors.length; i++) {
				clr = GameAssets.skinColors[i];
				skinColorButtons.push( addChild( new ColorButton({ color:clr, x:xx+cbo + (spacing*i), y:yy+cbo, width:sizex, height:sizey }) ) );
			}
			skinColorButtons.push( addChild( skinColorPickerButton = _newColorPickerButton(GameAssets.skinColor, xx+cbo + (spacing*i), yy+cbo, sizex) ) );
			_registerClickHandler(skinColorButtons, ButtonBase.CLICK, _onSkinColorButtonClicked);
			tIndex = GameAssets.skinColors.indexOf(GameAssets.skinColor);
			skinColorButtons[tIndex > -1 ? tIndex : (skinColorButtons.length-1)].selected = true;

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(GameAssets.secondaryColors.length+0.5)*0.5; yy = yy+80; sizex = 30; sizey = 30;
			addChild(new TextBase({ text:"label_other_color", x:ConstantsApp.PANE_WIDTH*0.5, y:yy-35, size:17, originY:0 }));
			secondaryColorButtons = [];
			for(i = 0; i < GameAssets.secondaryColors.length; i++) {
				clr = GameAssets.secondaryColors[i];
				secondaryColorButtons.push( addChild( new ColorButton({ color:clr, x:xx+cbo + (spacing*i), y:yy+cbo, width:sizex, height:sizey }) ) );
			}
			secondaryColorButtons.push( addChild( secondaryColorPickerButton = _newColorPickerButton(GameAssets.secondaryColor, xx+cbo + (spacing*i), yy+cbo, sizex) ) );
			_registerClickHandler(secondaryColorButtons, ButtonBase.CLICK, _onSecondaryColorButtonClicked);
			tIndex = GameAssets.secondaryColors.indexOf(GameAssets.secondaryColor);
			secondaryColorButtons[tIndex > -1 ? tIndex : (secondaryColorButtons.length-1)].selected = true;
			
			// Advanced
			i = 0; spacing = 34; xx = 90; yy = yy+50; sizex = 45; sizey = 25;
			addChild(new TextBase({ text:"label_advanced", x:45, y:yy+3, size:12, originY:0 }));
			advancedButton = addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_extras" }) ) as PushButton;
			advancedButton.Text.size = 11;
			advancedButton.toggle(GameAssets.showAll);
			advancedButton.addEventListener(PushButton.STATE_CHANGED_BEFORE, function(pEvent:Event){
				dispatchEvent(new Event("show_extra"));
			});
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
		
		private function _newColorPickerButton(color:int, xx:Number, yy:Number, size:Number) : ColorButton {
			var btn = new ColorButton({ color:color, x:xx, y:yy, width:size, height:size });
			var wheel = new $ColorWheel();
			wheel.scaleX = wheel.scaleY = 0.5;
			btn.addChild(wheel);
			return btn;
		}

		private function _registerClickHandler(pArray:Array, pEventName:String, pCallback:Function) : void {
			for(var i:int = 0; i < pArray.length; i++) {
				pArray[i].addEventListener(pEventName, pCallback);
			}
		}

		private function _onSexButtonClicked(pEvent:FewfEvent) {
			var btn = pEvent.target as PushButton;
			_untoggle(sexButtons, btn);
			GameAssets.sex = pEvent.data.id;
			character.updatePose();
			dispatchEvent(new Event("sex_change"));
		}

		private function _onFacingButtonClicked(pEvent:FewfEvent) {
			var btn = pEvent.target as PushButton;
			_untoggle(facingButtons, btn);
			GameAssets.facingForward = pEvent.data.id;
			character.updatePose();
			dispatchEvent(new Event("facing_change"));
		}

		private function _onHairColorButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggleColor(hairColorButtons, btn);
			btn.selected = true;
			GameAssets.hairColor = btn.color;
			character.updatePose();
			dispatchEvent(new FewfEvent("color_changed", { type:"hair" }));
			
			hairColorPickerButton.color = GameAssets.hairColor;
		}

		private function _onSkinColorButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggleColor(skinColorButtons, btn);
			btn.selected = true;
			GameAssets.skinColor = btn.color;
			character.updatePose();
			dispatchEvent(new FewfEvent("color_changed", { type:"skin" }));
			
			skinColorPickerButton.color = GameAssets.skinColor;
		}

		private function _onSecondaryColorButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggleColor(secondaryColorButtons, btn);
			btn.selected = true;
			GameAssets.secondaryColor = btn.color;
			character.updatePose();
			dispatchEvent(new FewfEvent("color_changed", { type:"secondary" }));
			
			secondaryColorPickerButton.color = GameAssets.secondaryColor;
		}

		private function _untoggle(pList:Array, pButton:PushButton=null) : void {
			if (pButton != null && pButton.pushed) { return; }

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}

		private function _untoggleColor(pList:Array, pButton:ColorButton=null) : void {
			if (pButton != null && pButton.selected) { return; }

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].selected && pList[i] != pButton) {
					pList[i].selected = false;
				}
			}
		}

		public function updateCustomColor(pType:String, tColor:int) {
			switch(pType) {
				case "hair": {
					GameAssets.hairColor = tColor;
					hairColorPickerButton.color = tColor;
					character.updatePose();
					break;
				}
				case "skin": {
					GameAssets.skinColor = tColor;
					skinColorPickerButton.color = tColor;
					character.updatePose();
					break;
				}
				case "secondary": {
					GameAssets.secondaryColor = tColor;
					secondaryColorPickerButton.color = tColor;
					character.updatePose();
					break;
				}
			}
			dispatchEvent(new FewfEvent("color_changed", { type:pType }));
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			var tIndex:int, tColor:int;
			_untoggle(sexButtons);
			sexButtons[ GameAssets.sex == SEX.MALE ? 1 : 0].toggleOn(false);
			
			tColor = GameAssets.hairColor;
			tIndex = GameAssets.hairColors.indexOf(tColor);
			_untoggleColor(hairColorButtons);
			hairColorButtons[tIndex > -1 ? tIndex : (hairColorButtons.length-1)].selected = true;
			hairColorPickerButton.color = tColor;
			
			tColor = GameAssets.skinColor;
			tIndex = GameAssets.skinColors.indexOf(tColor);
			_untoggleColor(skinColorButtons);
			skinColorButtons[tIndex > -1 ? tIndex : (skinColorButtons.length-1)].selected = true;
			skinColorPickerButton.color = tColor;
			
			tColor = GameAssets.secondaryColor;
			tIndex = GameAssets.secondaryColors.indexOf(tColor);
			_untoggleColor(secondaryColorButtons);
			secondaryColorButtons[tIndex > -1 ? tIndex : (secondaryColorButtons.length-1)].selected = true;
			secondaryColorPickerButton.color = tColor;
			
			advancedButton.toggle(GameAssets.showAll, false);
		}
	}
}
