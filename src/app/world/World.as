package app.world
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;

	import app.ui.*;
	import app.ui.panes.*;
	import app.ui.lang.*;
	import app.ui.buttons.*;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;

	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class World extends MovieClip
	{
		// Storage
		internal var character		: Character;
		internal var _paneManager	: PaneManager;

		internal var shopTabs		: ShopTabContainer;
		internal var _toolbox		: Toolbox;
		internal var linkTray		: LinkTray;
		internal var _langScreen	: LangScreen;

		internal var currentlyColoringType:String="";
		internal var configCurrentlyColoringType:String;
		
		// Constants
		public static const COLOR_PANE_ID = "colorPane";
		public static const CONFIG_PANE_ID = "configPane";
		public static const CONFIG_COLOR_PANE_ID = "configColorPane";
		public static const COLOR_FINDER_PANE_ID = "colorFinderPane";
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}
		
		private function _buildWorld(pStage:Stage) {
			GameAssets.init();

			/****************************
			* Create Character
			*****************************/
			var parms:flash.net.URLVariables = null;
			try {
				var urlPath:String = ExternalInterface.call("eval", "window.location.href");
				if(urlPath && urlPath.indexOf("?") > 0) {
					urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					parms = new flash.net.URLVariables();
					parms.decode(urlPath);
				}
			} catch (error:Error) { };

			this.character = addChild(new Character({ x:180, y:375,
				skin:GameAssets.skins[GameAssets.defaultSkinIndex],
				pose:GameAssets.poses[GameAssets.defaultPoseIndex],
				face:GameAssets.faces[GameAssets.defaultFaceIndex],
				params:parms,
				scale:2.5
			}));

			/****************************
			* Setup UI
			*****************************/
			var tShop:RoundedRectangle = addChild(new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT }));
			tShop.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			_paneManager = tShop.addChild(new PaneManager());
			
			this.shopTabs = addChild(new ShopTabContainer({ x:375, y:10, width:70, height:ConstantsApp.APP_HEIGHT }));
			_populateShopTabs();
			this.shopTabs.addEventListener(ShopTabContainer.EVENT_SHOP_TAB_CLICKED, _onTabClicked);

			// Toolbox
			_toolbox = addChild(new Toolbox({
				x:188, y:28, character:character,
				onSave:_onSaveClicked, onAnimate:_onPlayerAnimationToggle, onRandomize:_onRandomizeDesignClicked,
				onShare:_onShareButtonClicked, onScale:_onScaleSliderChange
			}));
			
			var tLangButton = addChild(new LangButton({ x:22, y:pStage.stageHeight-17, width:30, height:25, origin:0.5 }));
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			addChild(new AppInfoBox({ x:tLangButton.x+(tLangButton.Width*0.5)+(25*0.5)+2, y:pStage.stageHeight-17 }));
			
			/****************************
			* Screens
			*****************************/
			linkTray = new LinkTray({ x:pStage.stageWidth * 0.5, y:pStage.stageHeight * 0.5 });
			linkTray.addEventListener(LinkTray.CLOSE, _onShareTrayClosed);
			
			_langScreen = new LangScreen({  });
			_langScreen.addEventListener(LangScreen.CLOSE, _onLangScreenClosed);


			/****************************
			* Create tabs and panes
			*****************************/
			var tPane = null;
			
			tPane = _paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({}));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);
			
			tPane = _paneManager.addPane(CONFIG_PANE_ID, new ConfigTabPane(character));
			tPane.hairColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("hair", pEvent.target.id); });
			tPane.skinColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("skin", pEvent.target.id); });
			tPane.secondaryColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("secondary", pEvent.target.id); });
			tPane.addEventListener("sex_change", _onSexChanged);
			tPane.addEventListener("facing_change", _onFacingChanged);
			tPane.addEventListener("color_changed", _onConfigColorChanged);
			tPane.addEventListener("show_extra", _onShowExtraToggled);

			tPane = _paneManager.addPane(CONFIG_COLOR_PANE_ID, new ColorPickerTabPane({ hide_default:true }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, function(pEvent:Event){ _paneManager.openPane(CONFIG_PANE_ID); });
			
			tPane = _paneManager.addPane(COLOR_FINDER_PANE_ID, new ColorFinderPane({ }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorFinderBackClicked);


			// Create the panes
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.FACE, ITEM.BEARD, ITEM.HAIR, ITEM.HEAD, ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.MASK, ITEM.GLOVES, ITEM.BAG, ITEM.POSE ], tData:ItemData, tType:String;
			for(var i:int = 0; i < tTypes.length; i++) { tType = tTypes[i];
				tPane = _paneManager.addPane(tType, _setupPane(tType));
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				tData = character.getItemData(tType);
				if(tData) {
					for(var b = 0; b < tPane.buttons.length; b++) {
						if(tPane.buttons[b].data.data.id == tData.id) {
							tPane.buttons[b].toggleOn();
							break;
						}
					}
					//var tIndex:int = FewfUtils.getIndexFromArrayWithKeyVal(GameAssets.getArrayByType(tType), "id", tData.id);
					//tPane.buttons[ tIndex ].toggleOn();
				}
				_setupDirtyPanePopulation(tType);
			}

			// Select First Pane
			shopTabs.tabs[0].toggleOn();
			
			tPane = null;
			tTypes = null;
			tData = null;
		}
		
		private function _setupDirtyPanePopulation(tType:String) : void {
			_paneManager.getPane(tType).populateFunction = function(){
				_setupPaneButtons(_paneManager.getPane(tType), GameAssets.getArrayByType(tType));
				//_removeItem(tType);
				
				var tPane = _paneManager.getPane(tType);
				var tData = character.getItemData(tType);
				if(tData) {
					for(var b = 0; b < tPane.buttons.length; b++) {
						if(tPane.buttons[b].data.data.id == tData.id) {
							tPane.buttons[b].toggleOn();
							break;
						}
					}
				}
				tData = null;
				tPane = null;
			}
		}

		private function _setupPane(pType:String) : TabPane {
			var tPane:TabPane = new TabPane();
			tPane.addInfoBar( new ShopInfoBar({ showEyeDropButton:pType!=ITEM.POSE, showQualityButton:pType==ITEM.SHIRT||pType==ITEM.PANTS }) );
			_setupPaneButtons(tPane, GameAssets.getArrayByType(pType));
			tPane.infoBar.colorWheel.addEventListener(ButtonBase.CLICK, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.imageCont.addEventListener(MouseEvent.CLICK, function(){ _removeItem(pType); });
			tPane.infoBar.refreshButton.addEventListener(ButtonBase.CLICK, function(){ _randomItemOfType(pType); });
			if(tPane.infoBar.eyeDropButton) {
				tPane.infoBar.eyeDropButton.addEventListener(ButtonBase.CLICK, function(){ _eyeDropButtonClicked(pType); });
			}
			if(tPane.infoBar.qualityButton) {
				tPane.infoBar.qualityButton.toggle(!!GameAssets.tornStates[pType], false);
				tPane.infoBar.qualityButton.addEventListener(ButtonBase.CLICK, function(){ _qualityButtonClicked(pType); });
			}
			return tPane;
		}

		private function _setupPaneButtons(pPane:TabPane, pItemArray:Array) : void {
			if(pItemArray == null || pItemArray.length <= 0) { trace("[Main](_setupPaneButtons) Item array is null"); return; }
			var tType:String = pItemArray[0].type;

			var buttonPerRow = 6;
			var scale = 1;
			if(tType == ITEM.SKIN || tType == ITEM.POSE) {
					buttonPerRow = 4;
					scale = 0.8;
			} else if(tType == ITEM.HAIR) {
				/*scale = GameAssets.sex == SEX.MALE ? 0.8 : 0.7;*/
			}

			var grid:Grid = pPane.grid;
			if(!grid) { grid = pPane.addGrid( new Grid({ x:15, y:5, width:385, columns:buttonPerRow, margin:5 }) ); }
			grid.reset();

			var shopItem : Sprite;
			var shopItemButton : PushButton;
			var i = -1;
			pPane.buttons = [];
			while (i < pItemArray.length-1) { i++;
				if(pItemArray[i].sex != GameAssets.sex && pItemArray[i].sex != null) { continue; }
				if(!GameAssets.showAll && pItemArray[i].tags.indexOf("extra") != -1) { continue; }
				if(tType == ITEM.SKIN && i == pItemArray.length-1) {
					shopItem = new TextBase({ size:15, color:0xC2C2DA, text:"skin_invisible" });
				} else {
					shopItem = GameAssets.getItemImage(pItemArray[i]);
					shopItem.scaleX = shopItem.scaleY = scale;
				}

				shopItemButton = new PushButton({ width:grid.radius, height:grid.radius, obj:shopItem, id:i, data:{ type:tType, id:i, data:pItemArray[i], index:pPane.buttons.length } });
				pPane.buttons.push(shopItemButton);
				grid.add(shopItemButton)
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			// Guitar state button
			if(tType == ITEM.OBJECT) {
				var tIndex = FewfUtils.getIndexFromArrayWithKeyVal(pItemArray, "id", 41);
				var tButton = pPane.buttons[tIndex];
				var tMiniButton = tButton.parent.addChild(new ScaleButton({ x:tButton.x + 50, y:tButton.y + 12, obj:new $PlayButton(), obj_scale:0.5 }));
				tMiniButton.addEventListener(ButtonBase.CLICK, function(){
					tButton.toggleOn();
					// Mod over total frame (note that frame go to 1 -> max frames, not 0 -> max frames-1)
					pItemArray[tIndex].stopFrame++;
					pItemArray[tIndex].stopFrame %= (pPane.buttons[tIndex].Image.totalFrames+1);
					pItemArray[tIndex].stopFrame = Math.max(pItemArray[tIndex].stopFrame, 1);
					_refreshSelectedItemColor(tType, true);
				});
			}
			pPane.UpdatePane();
		}
		
		private function _populateShopTabs() : void {
			var tTabs = [
				{ text:"tab_config", event:CONFIG_PANE_ID },
				{ text:"tab_skins", event:ITEM.SKIN },
				{ text:"tab_face", event:ITEM.FACE },
				{ text:"tab_hair", event:ITEM.HAIR },
				{ text:"tab_beards", event:ITEM.BEARD },
				{ text:"tab_head", event:ITEM.HEAD },
				{ text:"tab_shirts", event:ITEM.SHIRT },
				{ text:"tab_pants", event:ITEM.PANTS },
				{ text:"tab_shoes", event:ITEM.SHOES },
				{ text:"tab_mask", event:ITEM.MASK },
				{ text:"tab_gloves", event:ITEM.GLOVES },
				{ text:"tab_bag", event:ITEM.BAG },
				{ text:"tab_objects", event:ITEM.OBJECT },
				{ text:"tab_poses", event:ITEM.POSE }
			];
			// Remove extra tabs
			for(var i:int=tTabs.length-1; i >= 0; i--) {
				if(!GameAssets.showAll && (tTabs[i].event == ITEM.SKIN || tTabs[i].event == ITEM.FACE)) {
					tTabs.splice(i, 1);
				}
				else if(GameAssets.sex == SEX.FEMALE && tTabs[i].event == ITEM.BEARD) {
					tTabs.splice(i, 1);
				}
			}
			this.shopTabs.populate(tTabs);
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.getValueAsScale();
			}
		}

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.getValueAsScale();
		}

		private function _onPlayerAnimationToggle(pEvent:Event):void {
			character.animatePose = !character.animatePose;
			if(character.animatePose) {
				character.outfit.play();
			} else {
				character.outfit.stop();
			}
			_toolbox.toggleAnimateButtonAsset(character.animatePose);
		}

		private function _onSaveClicked(pEvent:Event) : void {
			FewfDisplayUtils.saveAsPNG(this.character, "character");
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType = pEvent.data.type;
			var tItemArray:Array = GameAssets.getArrayByType(tType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(tType);

			// De-select all buttons that aren't the clicked one.
			var tButtons:Array = getButtonArrayByType(tType);
			for(var i:int = 0; i < tButtons.length; i++) {
				if(tButtons[i].data.id != pEvent.data.id) {
					if (tButtons[i].pushed)  { tButtons[i].toggleOff(); }
				}
			}

			var tButton:PushButton = pEvent.target;//tButtons[pEvent.data.id];
			var tData:ItemData;
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				tData = tItemArray[pEvent.data.id];
				/*setCurItemID(tType, tButton.id);*/
				setCurItemID(tType, pEvent.data.index);
				this.character.setItemData(tData);

				tInfoBar.addInfo( tData, GameAssets.getColoredItemImage(tData) );
				tInfoBar.showColorWheel(GameAssets.getNumOfCustomColors(tButton.Image) > 0);
			} else {
				_removeItem(tType);
			}
		}

		private function _removeItem(pType:String) : void {
			var tTabPane = getTabByType(pType);
			if(tTabPane.infoBar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(pType == ITEM.SKIN || pType == ITEM.POSE || pType == ITEM.FACE) {
				var tDefaultIndex = 0;//(pType == ITEM.POSE ? GameAssets.defaultPoseIndex : GameAssets.defaultSkinIndex);
				if(tTabPane.buttons[tDefaultIndex]) tTabPane.buttons[tDefaultIndex].toggleOn();
			} else {
				this.character.removeItem(pType);
				tTabPane.infoBar.removeInfo();
				if(tTabPane.buttons[tDefaultIndex]) tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
			}
		}
		
		private function _onTabClicked(pEvent:flash.events.DataEvent) : void {
			_paneManager.openPane(pEvent.data);
		}

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
				if(_paneManager.getPane(ITEM.LAYERING[i])) _randomItemOfType(ITEM.LAYERING[i]);
			}
			_randomItemOfType(ITEM.POSE);
		}

		private function _randomItemOfType(pType:String) : void {
			if(getInfoBarByType(pType).isRefreshLocked) { return; }
			var tButtons = getButtonArrayByType(pType);
			if(tButtons.length == 0) { return; }
			var tLength = tButtons.length; if(pType == ITEM.SKIN) { /* Don't select "transparent" */ tLength--; }
			tButtons[ Math.floor(Math.random() * tLength) ].toggleOn();
		}

		private function _onShareButtonClicked(pEvent:Event) : void {
			var tURL = "";
			try {
				tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
				tURL += "?"+this.character.getParams().toString().replace(/%5f/gi, "_");
			} catch (error:Error) {
				tURL = "<error creating link>";
			};

			linkTray.open(tURL);
			addChild(linkTray);
		}

		private function _onShareTrayClosed(pEvent:Event) : void {
			removeChild(linkTray);
		}

		private function _onLangButtonClicked(pEvent:Event) : void {
			_langScreen.open();
			addChild(_langScreen);
		}

		private function _onLangScreenClosed(pEvent:Event) : void {
			removeChild(_langScreen);
		}

		private function _onSexChanged(pEvent:Event) : void {
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.FACE, ITEM.BEARD, ITEM.HAIR, ITEM.HEAD, ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.POSE, ITEM.MASK, ITEM.GLOVES, ITEM.BAG ];
			var tData, tNewSexIsMale;
			for(var i in tTypes) { tType = tTypes[i];
				if(_paneManager.getPane(tType)) {
					tData = character.getItemData(tType);
					if(!tData || tData.sex != null) {
						_removeItem(tType);
						if(!tData) { continue; }
						tNewSexIsMale = tData.sex == SEX.FEMALE;
						tData = GameAssets.getItemFromTypeID(tType, tData.id.slice(0, -1)+(tNewSexIsMale ? "M" : "F"));
						if(tData) { character.setItemData(tData); }
					}
					/* _setupPaneButtons(_paneManager.getPane(tType), GameAssets.getArrayByType(tType)); */
				}
			}
			_paneManager.dirtyAllPanes();
			character.updatePose();
			_populateShopTabs();
		}

		private function _onFacingChanged(pEvent:Event) : void {
			character.updatePose();
		}

		private function _onShowExtraToggled(pEvent:Event) : void {
			GameAssets.showAll = !GameAssets.showAll;
			
			var tTypes = ITEM.LAYERING; tTypes.push(ITEM.POSE);
			if(!GameAssets.showAll) {
				for(var i in tTypes) { tType = tTypes[i];
					if(_paneManager.getPane(tType)) {
						if(!character.getItemData(tType) || character.getItemData(tType).tags.indexOf("extra") != -1) _removeItem(tType);
						/* _setupPaneButtons(_paneManager.getPane(tType), GameAssets.getArrayByType(tType)); */
					}
				}
			}
			
			_paneManager.dirtyAllPanes();
			character.updatePose();
			_populateShopTabs();
		}
		
		private function _qualityButtonClicked(pType:String) : void {
			GameAssets.tornStates[pType] = getInfoBarByType(pType).qualityButton.pushed;
			character.updatePose();
		}

		//{REGION Get TabPane data
			private function getTabByType(pType:String) : TabPane {
				return _paneManager.getPane(pType);
			}

			private function getInfoBarByType(pType:String) : ShopInfoBar {
				return getTabByType(pType).infoBar;
			}

			private function getButtonArrayByType(pType:String) : Array {
				return getTabByType(pType).buttons;
			}

			private function getCurItemID(pType:String) : int {
				return getTabByType(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:String, pID:int) : void {
				getTabByType(pType).selectedButtonIndex = pID;
			}
		//}END Get TabPane data

		//{REGION Color Tab
			private function _eyeDropButtonClicked(pType:String) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = GameAssets.getColoredItemImage(tData);
				_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				_paneManager.getPane(COLOR_FINDER_PANE_ID).setItem(tItem2);
				_paneManager.openPane(COLOR_FINDER_PANE_ID);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.data.type);
			}
			
			private function _onColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				this.character.getItemData(this.currentlyColoringType).colors[_paneManager.getPane(COLOR_PANE_ID).selectedSwatch] = tVal;
				_refreshSelectedItemColor(this.currentlyColoringType);
			}

			private function _onDefaultsButtonClicked(pEvent:Event) : void
			{
				this.character.getItemData(this.currentlyColoringType).setColorsToDefault();
				_refreshSelectedItemColor(this.currentlyColoringType);
				_paneManager.getPane(COLOR_PANE_ID).setupSwatches( this.character.getColors(this.currentlyColoringType) );
			}
			
			private function _refreshSelectedItemColor(pType:String, pForceReplace:Boolean=false) : void {
				character.updatePose();
				
				var tItemData = this.character.getItemData(pType);
				if(pType != ITEM.SKIN && !pForceReplace) {
					var tItem:MovieClip = GameAssets.getColoredItemImage(tItemData);
					GameAssets.copyColor(tItem, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image );
					GameAssets.copyColor(tItem, getInfoBarByType(pType).Image );
					GameAssets.copyColor(tItem, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
				} else {
					_replaceImageWithNewImage(getButtonArrayByType(pType)[ getCurItemID(pType) ], GameAssets.getColoredItemImage(tItemData));
					/*_replaceImageWithNewImage(getInfoBarByType(pType), GameAssets.getColoredItemImage(tItemData));*/
					getInfoBarByType(pType).ChangeImage(GameAssets.getColoredItemImage(tItemData));
					_replaceImageWithNewImage(_paneManager.getPane(COLOR_PANE_ID).infoBar, GameAssets.getColoredItemImage(tItemData));
				}
			}
			
			private function _replaceImageWithNewImage(pOldSource:Object, pNew:MovieClip) : void {
				pNew.x = pOldSource.Image.x;
				pNew.y = pOldSource.Image.y;
				pNew.scaleX = pOldSource.Image.scaleX;
				pNew.scaleY = pOldSource.Image.scaleY;
				pOldSource.Image.parent.addChild(pNew);
				pOldSource.Image.parent.removeChild(pOldSource.Image);
				pOldSource.Image = null;
				pOldSource.Image = pNew;
			}

			private function _colorButtonClicked(pType:String) : void {
				if(this.character.getItemFromIndex(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				_paneManager.getPane(COLOR_PANE_ID).infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				_paneManager.getPane(COLOR_PANE_ID).setupSwatches( this.character.getColors(pType) );
				_paneManager.openPane(COLOR_PANE_ID);
			}

			private function _onConfigColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				_paneManager.getPane(CONFIG_PANE_ID).updateCustomColor(configCurrentlyColoringType, tVal);
			}
			
			// When any color type changes, be it via color picker or just button.
			private function _onConfigColorChanged(pEvent:FewfEvent) {
				switch(pEvent.data.type) {
					case "hair":
						_paneManager.getPane(ITEM.HAIR).makeDirty();
						_paneManager.getPane(ITEM.BEARD).makeDirty();
						break;
					case "skin":
						_paneManager.getPane(ITEM.SKIN).makeDirty();
						_paneManager.getPane(ITEM.POSE).makeDirty();
						break;
					case "secondary":
						_paneManager.getPane(ITEM.SKIN).makeDirty();
						break;
				}
			}

			private function _configColorButtonClicked(pType:String, pColor:int) : void {
				this.configCurrentlyColoringType = pType;
				_paneManager.getPane(CONFIG_COLOR_PANE_ID).setupSwatches( [ pColor ] );
				_paneManager.openPane(CONFIG_COLOR_PANE_ID);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type);
			}
		//}END Color Tab
	}
}
