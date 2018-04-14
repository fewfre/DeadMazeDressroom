package app.ui.panes
{
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.*;
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	public class DyePane extends TabPane
	{
		private static const BUTTON_SCALE:Number = 1.6;
		private static const MINI_BOX_SIZE:Number = 12*BUTTON_SCALE;

		// Storage
		public var character:Character;
		public var _colors:Array;

		public var colorButtons:Array;

		public var colorPickerButton:PushButton;
		public var colorPickerButtonBox:Sprite;

		// Constructor
		public function DyePane(pData:Object)
		{
			super();
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showRefreshButton:false }) );
			this.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, _onColorPickerBackClicked);
			this.UpdatePane(false);

			character = pData.character;
			_colors = Fewf.assets.getData("config").colors.dye.concat();

			var defaults_btn:SpriteButton;
			defaults_btn = this.addItem( new SpriteButton({ x:ConstantsApp.PANE_WIDTH*0.5, y:15, width:100, height:22, text:"btn_color_defaults", obj:new MovieClip(), origin:0.5 }) ) as SpriteButton;
			defaults_btn.addEventListener(ButtonBase.CLICK, _onDefaultButtonClicked);

			var i, xx:Number, yy:Number, spacing:Number, sizex:Number, sizey:Number, clr:int, tIndex:int, columns:int=7;
			i = 0; spacing = 34*BUTTON_SCALE; sizex = sizey = 30*BUTTON_SCALE;
			xx = 0; yy = 215 - Math.ceil((_colors.length+1) / columns) * spacing * 0.5;

			colorButtons = [];
			var btn:PushButton;
			for(i in _colors) {
				if(i%columns==0) {
					columns = i + columns < _colors.length ? columns : _colors.length%columns + 1;//((_colors.length - i)%columns)+1;
					xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(columns-1)*0.5;
					yy += spacing;
				}
				clr = _colors[i] = parseInt(_colors[i]);
				colorButtons.push( addChild( btn = new PushButton({ x:xx + (spacing*(i%columns)), y:yy, width:sizex, height:sizey, origin:0.5, obj:_colorSpriteBox({ color:clr }), id:clr, allowToggleOff:false }) ) );
				btn.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onDyeButtonClicked);
			}
			colorButtons.push( addChild( colorPickerButton = new PushButton({ x:xx + (spacing*((i+1)%columns)), y:yy, width:sizex, height:sizey, origin:0.5, obj:new $ColorWheel(), obj_scale:0.7*BUTTON_SCALE, id:-2 }) ) );
			colorPickerButtonBox = colorPickerButton.addChild(_colorSpriteBox({ color:colorPickerButton.id, size:MINI_BOX_SIZE })) as Sprite;
			colorPickerButtonBox.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onColorPickerButtonClicked);
		}

		// pData = { color:int, box:Sprite[optional], size:Number=20, x:Number[optional], y:Number[optional] }
		private function _colorSpriteBox(pData:Object) : Sprite {
			var tBox:Sprite = pData.box ? pData.box : new Sprite();
			var tSize:Number = pData.size ? pData.size : 20*BUTTON_SCALE;
			tBox.graphics.clear();
			tBox.graphics.beginFill(pData.color, 1);
			tBox.graphics.drawRect(-tSize*0.5, -tSize*0.5, tSize, tSize);
			tBox.graphics.endFill();
			
			if(pData.x) tBox.x = pData.x;
			if(pData.y) tBox.y = pData.y;
			return tBox;
		}

		public function setColor(pColor:int) : void {
			_untoggle(colorButtons);
			if(pColor != -1) {
				var tIndex = _colors.indexOf(pColor);
				colorButtons[tIndex > -1 ? tIndex : (colorButtons.length-1)].toggleOn();
			} else {
				// No dye set
			}
			colorPickerButton.id = pColor;
			_colorSpriteBox({ color:pColor, box:colorPickerButtonBox, size:MINI_BOX_SIZE });
		}

		private function _onDyeButtonClicked(pEvent:Event) {
			_untoggle(colorButtons, pEvent.target as PushButton);
			updateCustomColor(pEvent.target.id);
		}
		
		// Unlike the default color buttons, "allowToggleOff" is set to true
		// since need to be able to click even after selected.
		// This simply forces it to show as selected even when toggled off.
		private function _onColorPickerButtonClicked(pEvent:Event) {
			pEvent.target.toggleOff(false);
		}
		
		private function _onDefaultButtonClicked(pEvent:Event) : void {
			// dispatchEvent(new Event(ColorPickerTabPane.EVENT_DEFAULT_CLICKED));
			_untoggle(colorButtons);
			updateCustomColor(-1);
		}

		private function _untoggle(pList:Array, pButton:PushButton=null) : void {
			if (pButton != null && pButton.pushed) { return; }

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
		}

		public function updateCustomColor(tColor:int) {
			// GameAssets.hairColor = tColor;
			colorPickerButton.id = tColor;
			_colorSpriteBox({ color:tColor, box:colorPickerButtonBox, size:MINI_BOX_SIZE });
			// character.updatePose();
			
			// dispatchEvent(new FewfEvent("color_changed", { type:pType }));
			dispatchEvent(new DataEvent(ColorPickerTabPane.EVENT_COLOR_PICKED, false, false, String(tColor)));
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickChanged(pEvent:DataEvent) : void {
			// _colorSwatches[_selectedSwatch].value = uint(pEvent.data);
			// dispatchEvent(new DataEvent(ColorPickerTabPane.EVENT_COLOR_PICKED, false, false, pEvent.data));
			updateCustomColor(int(pEvent.data));
		}
		
		private function _onColorPickerBackClicked(pEvent:Event) : void {
			dispatchEvent(new Event(ColorPickerTabPane.EVENT_EXIT));
		}
	}
}
