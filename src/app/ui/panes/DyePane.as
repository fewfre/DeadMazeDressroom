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
	import app.ui.panes.base.SidePane;
	import app.ui.panes.infobar.Infobar;
	import app.ui.panes.base.SidePaneWithInfobar;

	public class DyePane extends SidePaneWithInfobar
	{
		// Constants
		public static const EVENT_COLOR_PICKED     : String = "event_color_picked"; // DataEvent
		public static const EVENT_OPEN_COLORPICKER : String= "open_colorpicker";
		
		private static const BUTTON_SCALE:Number = 1.6;
		private static const MINI_BOX_SIZE:Number = 12*BUTTON_SCALE;

		// Storage
		// private var _character : Character;
		private var _colors    : Array;

		public var colorButtons:Array;

		public var colorPickerButton:PushButton;
		public var colorPickerButtonBox:Sprite;

		// Constructor
		public function DyePane() {
			super();
			this.addInfoBar( new Infobar({ showBackButton:true, showRefreshButton:false }) )
				.on(Infobar.BACK_CLICKED, _onColorPickerBackClicked)
				.on(Infobar.ITEM_PREVIEW_CLICKED, function(e){ dispatchEvent(new Event(Infobar.ITEM_PREVIEW_CLICKED)); });

			// _character = pCharacter;
			_colors = Fewf.assets.getData("config").colors.dye.concat();

			new SpriteButton({ x:ConstantsApp.PANE_WIDTH*0.5-5, y:80, width:100, height:22, text:"btn_color_defaults", obj:new MovieClip(), origin:0.5 }).appendTo(this)
				.on(ButtonBase.CLICK, _onDefaultButtonClicked);

			var i, xx:Number, yy:Number, spacing:Number, sizex:Number, sizey:Number, clr:int, tIndex:int, columns:int=7, columnI:int=0;
			i = 0; spacing = 34*BUTTON_SCALE; sizex = sizey = 30*BUTTON_SCALE;
			xx = 0; yy = 215 - Math.ceil((_colors.length+1) / columns) * spacing * 0.5;

			colorButtons = [];
			var btn:ColorButton;
			for(i in _colors) {
				if(i%columns==0) {
					columns = i + columns < _colors.length ? columns : _colors.length%columns + 1;//((_colors.length - i)%columns)+1;
					xx = ConstantsApp.PANE_WIDTH*0.5 - spacing*(columns-1)*0.5;
					yy += spacing;
					columnI = 0;
				}
				clr = _colors[i] = parseInt(_colors[i]);
				colorButtons.push( addChild( btn = new ColorButton({ color:clr, x:xx + (spacing*columnI), y:yy, width:sizex, height:sizey }) ) );
				btn.addEventListener(ButtonBase.CLICK, _onDyeButtonClicked);
				columnI++;
			}
			colorButtons.push( colorPickerButton = new PushButton({ x:xx + (spacing*columnI), y:yy, width:sizex, height:sizey, origin:0.5, obj:new $ColorWheel(), obj_scale:0.7*BUTTON_SCALE, id:-2 }).appendTo(this) as PushButton );
			colorPickerButton.on(ButtonBase.CLICK, function(e):void{ dispatchEvent(new Event(EVENT_OPEN_COLORPICKER)) });
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
				var btn = colorButtons[tIndex > -1 ? tIndex : (colorButtons.length-1)];
				btn is PushButton ? btn.toggleOn() : (btn.selected = true);
			} else {
				// No dye set
			}
			colorPickerButton.id = pColor;
			_colorSpriteBox({ color:pColor, box:colorPickerButtonBox, size:MINI_BOX_SIZE });
		}

		private function _onDyeButtonClicked(pEvent:Event) {
			var btn = pEvent.target as ColorButton;
			_untoggle(colorButtons, btn);
			btn.selected = true;
			updateCustomColor(btn.color);
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

		private function _untoggle(pList:Array, pButton:ButtonBase=null) : void {
			if (pButton != null && (
				pButton is PushButton && (pButton as PushButton).pushed || 
				pButton is ColorButton && (pButton as ColorButton).selected
			)) { return; }

			for(var i:int = 0; i < pList.length; i++) {
				if(pList[i] is PushButton) {
					if (pList[i].pushed && pList[i] != pButton) {
						pList[i].toggleOff();
					}
				} else {
					if (pList[i].selected && pList[i] != pButton) {
						pList[i].selected = false;
					}
				}
			}
		}

		public function updateCustomColor(tColor:int) {
			// GameAssets.hairColor = tColor;
			colorPickerButton.id = tColor;
			_colorSpriteBox({ color:tColor, box:colorPickerButtonBox, size:MINI_BOX_SIZE });
			// _character.updatePose();
			
			// dispatchEvent(new FewfEvent(ConfigTabPane.EVENT_COLOR_CHANGE, { type:pType }));
			dispatchEvent(new DataEvent(EVENT_COLOR_PICKED, false, false, String(tColor)));
		}
		
		/****************************
		* Events
		*****************************/
		private function _onColorPickerBackClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
