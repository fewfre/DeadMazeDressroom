package app.ui.panes
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.display.TextTranslated;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import app.ui.panes.base.SidePane;

	public class ConfigTabPane extends SidePane
	{
		// Constants
		public static const EVENT_SHOW_EXTRA : String= "show_extra";
		public static const EVENT_SEX_CHANGE : String= "sex_change";
		public static const EVENT_FACING_CHANGE : String= "facing_change";
		public static const EVENT_COLOR_CHANGE : String= "color_changed"; // FewfEvent<{ type:string }>
		public static const EVENT_OPEN_COLORPICKER : String= "open_colorpicker"; // FewfEvent<{ type:string, color:int }>
		
		private static const MINI_BOX_SIZE:Number = 12;

		// Storage
		public var character:Character;
		public var sexButtons:Vector.<PushButton>;
		// public var facingButtons:Vector.<PushButton>;
		public var hairColorButtons:Vector.<ColorButton>;
		public var skinColorButtons:Vector.<ColorButton>;
		public var secondaryColorButtons:Vector.<ColorButton>;
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

			i = 0; xx = 70; yy = 30; spacing = 95; sizex = 80; sizey = 35;
			new TextTranslated("label_sex", { x:35, y:yy+3, size:17, originY:0 }).appendToT(this);
			sexButtons = new <PushButton>[
				new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_female", allowToggleOff:false, data:{ id:Sex.FEMALE } }).appendTo(this) as PushButton,
				new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_male", allowToggleOff:false, data:{ id:Sex.MALE } }).appendTo(this) as PushButton
				//new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }).appendTo(this) as PushButton
			];
			_registerClickHandler(sexButtons, PushButton.TOGGLE, _onSexButtonClicked);
			sexButtons[ GameAssets.sex == Sex.MALE ? 1 : 0].toggleOn();
			
			/*i = 0; xx = 285;
			new TextLocalized("label_face_dir", { x:250, y:yy+3, size:17, originY:0 }).appendToT(this);
			facingButtons = [
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_face_front", allowToggleOff:false, data:{ id:true } }) ),
				addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_face_back", allowToggleOff:false, data:{ id:false } }) )
				//addChild( new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"All", allowToggleOff:false }) )
			];
			_registerClickHandler(facingButtons, PushButton.STATE_CHANGED_BEFORE, _onFacingButtonClicked);
			facingButtons[ GameAssets.facingForward == false ? 1 : 0].toggleOn();*/

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(10+0.5)*0.5; yy = yy+80; sizex = 30; sizey = 30;
			var cbo = spacing/2-3;
			new TextTranslated("label_hair_color", { x:ConstantsApp.PANE_WIDTH*0.5, y:yy-35, size:17, originY:0 }).appendToT(this);
			hairColorButtons = new Vector.<ColorButton>();
			for(i = 0; i < GameAssets.hairColors.length; i++) {
				if(i%10 == 0 && i >= 10) {
					yy += spacing;
				}
				clr = GameAssets.hairColors[i];
				hairColorButtons.push( new ColorButton({ color:clr, x:xx+cbo + (spacing*(i%10)), y:yy+cbo, width:sizex, height:sizey }).appendTo(this) );
			}
			hairColorButtons.push( hairColorPickerButton = _newColorPickerButton(GameAssets.hairColor, xx+cbo + (spacing*10), yy+cbo-(spacing*0.5), sizex).appendTo(this) as ColorButton );
			_registerClickHandler(hairColorButtons, ButtonBase.CLICK, _onHairColorButtonClicked);
			hairColorPickerButton.onButtonClick(function(pEvent:Event):void{ dispatchEvent(new FewfEvent(EVENT_OPEN_COLORPICKER, { type:"hair", color:pEvent.target.color })); });
			tIndex = GameAssets.hairColors.indexOf(GameAssets.hairColor);
			hairColorButtons[tIndex > -1 ? tIndex : (hairColorButtons.length-1)].selected = true;

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(GameAssets.skinColors.length+0.5)*0.5; yy = yy+80; sizex = 30; sizey = 30;
			new TextTranslated("label_skin_color", { x:ConstantsApp.PANE_WIDTH*0.5, y:yy-35, size:17, originY:0 }).appendToT(this);
			skinColorButtons = new Vector.<ColorButton>();
			for(i = 0; i < GameAssets.skinColors.length; i++) {
				clr = GameAssets.skinColors[i];
				skinColorButtons.push( new ColorButton({ color:clr, x:xx+cbo + (spacing*i), y:yy+cbo, width:sizex, height:sizey }).appendTo(this) );
			}
			skinColorButtons.push( skinColorPickerButton = _newColorPickerButton(GameAssets.skinColor, xx+cbo + (spacing*i), yy+cbo, sizex).appendTo(this) as ColorButton );
			_registerClickHandler(skinColorButtons, ButtonBase.CLICK, _onSkinColorButtonClicked);
			skinColorPickerButton.onButtonClick(function(pEvent:Event):void{ dispatchEvent(new FewfEvent(EVENT_OPEN_COLORPICKER, { type:"skin", color:pEvent.target.color })); });
			tIndex = GameAssets.skinColors.indexOf(GameAssets.skinColor);
			skinColorButtons[tIndex > -1 ? tIndex : (skinColorButtons.length-1)].selected = true;

			i = 0; spacing = 34; xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(GameAssets.secondaryColors.length+0.5)*0.5; yy = yy+80; sizex = 30; sizey = 30;
			new TextTranslated("label_other_color", { x:ConstantsApp.PANE_WIDTH*0.5, y:yy-35, size:17, originY:0 }).appendToT(this);
			secondaryColorButtons = new Vector.<ColorButton>();
			for(i = 0; i < GameAssets.secondaryColors.length; i++) {
				clr = GameAssets.secondaryColors[i];
				secondaryColorButtons.push( new ColorButton({ color:clr, x:xx+cbo + (spacing*i), y:yy+cbo, width:sizex, height:sizey }).appendTo(this) );
			}
			secondaryColorButtons.push( secondaryColorPickerButton = _newColorPickerButton(GameAssets.secondaryColor, xx+cbo + (spacing*i), yy+cbo, sizex).appendTo(this) as ColorButton );
			_registerClickHandler(secondaryColorButtons, ButtonBase.CLICK, _onSecondaryColorButtonClicked);
			secondaryColorPickerButton.onButtonClick(function(pEvent:Event):void{ dispatchEvent(new FewfEvent(EVENT_OPEN_COLORPICKER, { type:"secondary", color:pEvent.target.color })); });
			tIndex = GameAssets.secondaryColors.indexOf(GameAssets.secondaryColor);
			secondaryColorButtons[tIndex > -1 ? tIndex : (secondaryColorButtons.length-1)].selected = true;
			
			// Advanced
			i = 0; spacing = 39; xx = 90; yy = yy+50; sizex = 80; sizey = 25;
			new TextTranslated("label_advanced", { x:45, y:yy+3, size:12, originY:0 }).appendToT(this);
			advancedButton = new PushButton({ x:xx + (spacing*i++), y:yy, width:sizex, height:sizey, text:"btn_extras" }).appendTo(this) as PushButton;
			advancedButton.Text.size = 11;
			advancedButton.toggle(GameAssets.showAll);
			advancedButton.addEventListener(PushButton.TOGGLE, function(pEvent:Event){
				dispatchEvent(new Event(EVENT_SHOW_EXTRA));
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

		private function _registerClickHandler(pVector:Object, pEventName:String, pCallback:Function) : void {
			for(var i:int = 0; i < pVector.length; i++) {
				pVector[i].addEventListener(pEventName, pCallback);
			}
		}

		private function _onSexButtonClicked(pEvent:FewfEvent) {
			var btn = pEvent.target as PushButton;
			_untoggle(sexButtons, btn);
			GameAssets.sex = pEvent.data.id;
			character.updatePose();
			dispatchEvent(new Event(EVENT_SEX_CHANGE));
		}

		// private function _onFacingButtonClicked(pEvent:FewfEvent) {
		// 	var btn = pEvent.target as PushButton;
		// 	_untoggle(facingButtons, btn);
		// 	GameAssets.facingForward = pEvent.data.id;
		// 	character.updatePose();
		// 	dispatchEvent(new Event(EVENT_FACING_CHANGE));
		// }

		private function _onHairColorButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggleColor(hairColorButtons, btn);
			btn.selected = true;
			GameAssets.hairColor = btn.color;
			character.updatePose();
			dispatchEvent(new FewfEvent(EVENT_COLOR_CHANGE, { type:"hair" }));
			
			hairColorPickerButton.color = GameAssets.hairColor;
		}

		private function _onSkinColorButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggleColor(skinColorButtons, btn);
			btn.selected = true;
			GameAssets.skinColor = btn.color;
			character.updatePose();
			dispatchEvent(new FewfEvent(EVENT_COLOR_CHANGE, { type:"skin" }));
			
			skinColorPickerButton.color = GameAssets.skinColor;
		}

		private function _onSecondaryColorButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggleColor(secondaryColorButtons, btn);
			btn.selected = true;
			GameAssets.secondaryColor = btn.color;
			character.updatePose();
			dispatchEvent(new FewfEvent(EVENT_COLOR_CHANGE, { type:"secondary" }));
			
			secondaryColorPickerButton.color = GameAssets.secondaryColor;
		}

		private function _untoggle(pList:Vector.<PushButton>, pButton:PushButton=null) : void {
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}

		private function _untoggleColor(pList:Vector.<ColorButton>, pButton:ColorButton=null) : void {
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
			dispatchEvent(new FewfEvent(EVENT_COLOR_CHANGE, { type:pType }));
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			var tIndex:int, tColor:int;
			_untoggle(sexButtons);
			sexButtons[ GameAssets.sex == Sex.MALE ? 1 : 0].toggleOn(false);
			
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
