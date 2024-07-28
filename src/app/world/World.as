package app.world
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.RoundedRectangle;
	import app.ui.panes.*;
	import app.ui.panes.base.PaneManager;
	import app.ui.panes.base.SidePane;
	import app.ui.panes.ColorFinderPane;
	import app.ui.panes.colorpicker.ColorPickerTabPane;
	import app.ui.panes.ColorPickerTabPane;
	import app.ui.panes.ConfigTabPane;
	import app.ui.panes.DyePane;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	import app.ui.screens.*;
	import app.world.data.*;
	import app.world.elements.*;
	
	import com.adobe.images.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import com.piterwilson.utils.*;
	
	import flash.display.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.ui.Keyboard;
	import app.ui.panes.base.ButtonGridSidePane;
	import ext.ParentApp;
	
	public class World extends MovieClip
	{
		// Storage
		private var character    : Character;
		private var _paneManager : PaneManager;

		private var shopTabs           : ShopTabList;
		private var _toolbox           : Toolbox;
		
		private var _shareScreen       : ShareScreen;
		private var trashConfirmScreen : TrashConfirmScreen;
		private var _langScreen        : LangScreen;
		private var _aboutScreen       : AboutScreen;

		private var currentlyColoringType:ItemType=null;
		private var configCurrentlyColoringType:String;
		
		// Constants
		public static const COLOR_PANE_ID:String = "colorPane";
		public static const CONFIG_PANE_ID:String = "configPane";
		public static const CONFIG_COLOR_PANE_ID:String = "configColorPane";
		public static const COLOR_FINDER_PANE_ID:String = "colorFinderPane";
		public static const DYE_PANE_ID:String = "colorDyePane";
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownListener);
		}
		
		private function _buildWorld(pStage:Stage) : void {
			/* GameAssets.init(); */

			/////////////////////////////
			// Create Character
			/////////////////////////////
			var parms:flash.net.URLVariables = null;
			if(!Fewf.isExternallyLoaded) {
				try {
					var urlPath:String = ExternalInterface.call("eval", "window.location.href");
					if(urlPath && urlPath.indexOf("?") > 0) {
						urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
						parms = new flash.net.URLVariables();
						parms.decode(urlPath);
					}
				} catch (error:Error) { };
			}

			this.character = addChild(new Character({ x:180, y:375,
				skin:GameAssets.skins[GameAssets.defaultSkinIndex],
				pose:GameAssets.poses[GameAssets.defaultPoseIndex],
				face:GameAssets.faces[GameAssets.defaultFaceIndex],
				params:parms,
				scale:2.5
			})) as Character;

			/////////////////////////////
			// Setup UI
			/////////////////////////////
			var tShop:RoundedRectangle = new RoundedRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.APP_HEIGHT).setXY(450, 10)
				.appendTo(this).drawAsTray();
			_paneManager = tShop.addChild(new PaneManager()) as PaneManager;
			
			this.shopTabs = new ShopTabList(70, ConstantsApp.APP_HEIGHT).setXY(375, 10).appendTo(this);
			this.shopTabs.addEventListener(ShopTabList.TAB_CLICKED, _onTabClicked);
			_populateShopTabs();

			// Toolbox
			_toolbox = new Toolbox(character, _onShareCodeEntered).setXY(188, 28).appendTo(this)
				.on(Toolbox.SAVE_CLICKED, _onSaveClicked)
				.on(Toolbox.SHARE_CLICKED, _onShareButtonClicked)
				.on(Toolbox.CLIPBOARD_CLICKED, _onClipboardButtonClicked).on(Toolbox.IMGUR_CLICKED, _onImgurButtonClicked)
				
				.on(Toolbox.SCALE_SLIDER_CHANGE, _onScaleSliderChange)
				
				.on(Toolbox.ANIMATION_TOGGLED, _onPlayerAnimationToggle)
				.on(Toolbox.RANDOM_CLICKED, _onRandomizeDesignClicked)
				.on(Toolbox.TRASH_CLICKED, _onTrashButtonClicked);
			
			var tLangButton = addChild(new LangButton({ x:22, y:pStage.stageHeight-17, width:30, height:25, origin:0.5 }));
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			// About Screen Button
			var aboutButton:SpriteButton = new SpriteButton({ size:25, origin:0.5 }).appendTo(this)
				.setXY(tLangButton.x+(tLangButton.Width/2)+2+(25/2), pStage.stageHeight - 17)
				.on(ButtonBase.CLICK, _onAboutButtonClicked) as SpriteButton;
			new TextBase("?", { size:22, color:0xFFFFFF, bold:true, origin:0.5 }).setXY(0, -1).appendTo(aboutButton)
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton({ obj:new $BackArrow(), obj_scale:0.5, origin:0.5 }).appendTo(this)
				.setXY(22, pStage.stageHeight-17-28)
					.on(ButtonBase.CLICK, function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			/////////////////////////////
			// Screens
			/////////////////////////////
			_shareScreen = new ShareScreen().on(Event.CLOSE, _onShareScreenClosed);
			_langScreen = new LangScreen().on(Event.CLOSE, _onLangScreenClosed);
			_aboutScreen = new AboutScreen().on(Event.CLOSE, _onAboutScreenClosed);
			
			trashConfirmScreen = new TrashConfirmScreen().setXY(337, 65)
				.on(TrashConfirmScreen.CONFIRM, _onTrashConfirmScreenConfirm)
				.on(Event.CLOSE, _onTrashConfirmScreenClosed);

			/////////////////////////////
			// Static Panes
			/////////////////////////////
			// Item color picker
			_paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({ hide_default:true }))
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged)
				// .on(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked)
				.on(Event.CLOSE, _onColorPickerBackClicked)
				.on(ColorPickerTabPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorPickerBackClicked(e);
					// If item removed we want to fully backout of all color panes
					_onDyeBackClicked(e);
					_removeItem(getColorPickerPane().infoBar.itemData.type);
				});
			
			// Dye Picker Pane
			_paneManager.addPane(DYE_PANE_ID, new DyePane())
				.on(DyePane.EVENT_COLOR_PICKED, _onDyeChanged)
				.on(Event.CLOSE, _onDyeBackClicked)
				.on(Infobar.ITEM_PREVIEW_CLICKED, function(e){
					_onDyeBackClicked(e);
					_removeItem(getDyePane().infoBar.itemData.type);
				})
				.on(DyePane.EVENT_OPEN_COLORPICKER, _onDyeCustomPickerClicked);
			
			// Config Pane
			_paneManager.addPane(CONFIG_PANE_ID, new ConfigTabPane(character))
				.on(ConfigTabPane.EVENT_OPEN_COLORPICKER, function(e:FewfEvent):void{ _configColorButtonClicked(e.data.type, e.data.color); })
				.on(ConfigTabPane.EVENT_SEX_CHANGE, _onSexChanged)
				.on(ConfigTabPane.EVENT_FACING_CHANGE, _onFacingChanged)
				.on(ConfigTabPane.EVENT_COLOR_CHANGE, _onConfigColorChanged)
				.on(ConfigTabPane.EVENT_SHOW_EXTRA, _onShowExtraToggled);

			// Config color picker
			_paneManager.addPane(CONFIG_COLOR_PANE_ID, new ColorPickerTabPane({ hide_default:true, hideItemPreview:true }))
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged)
				.on(Event.CLOSE, function(pEvent:Event):void{ _paneManager.openPane(CONFIG_PANE_ID); });
			
			// Color Finder Pane
			_paneManager.addPane(COLOR_FINDER_PANE_ID, new ColorFinderPane({ }))
				.on(Event.CLOSE, _onColorFinderBackClicked)
				.on(ColorFinderPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorFinderBackClicked(e);
					_removeItem(getColorFinderPane().infoBar.itemData.type);
				});

			/////////////////////////////
			// Create item panes
			/////////////////////////////
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				_paneManager.addPane(tType.toString(), _setupItemPane(tType));
				// _setupDirtyPanePopulation(tType);
			}
			Fewf.dispatcher.addEventListener(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _onSaveItemDataAsImage);

			// Select First Pane
			shopTabs.tabs[0].toggleOn();
		}
		
		// private function _setupDirtyPanePopulation(tType:String) : void {
		// 	_paneManager.getPane(tType).populateFunction = function():void{
		// 		_setupPaneButtons(_paneManager.getPane(tType), GameAssets.getItemDataListByType(tType));
		// 		//_removeItem(tType);
				
		// 		var tPane = _paneManager.getPane(tType);
		// 		var tData = character.getItemData(tType);
		// 		if(tData) {
		// 			for(var b = 0; b < tPane.buttons.length; b++) {
		// 				if(tPane.buttons[b].data.data.id == tData.id) {
		// 					tPane.buttons[b].toggleOn();
		// 					break;
		// 				}
		// 			}
		// 		}
		// 		tData = null;
		// 		tPane = null;
		// 	}
		// }

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType, character);
			tPane.on(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			
			tPane.infoBar.on(Infobar.COLOR_WHEEL_CLICKED, function(){ _dyeButtonClicked(pType); });
			tPane.infoBar.on(Infobar.ITEM_PREVIEW_CLICKED, function(){ _removeItem(pType); });
			tPane.infoBar.on(Infobar.EYE_DROPPER_CLICKED, function(){ _eyeDropButtonClicked(pType); });
			tPane.infoBar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			tPane.infoBar.on(Infobar.QUALITY_CLICKED, function(e:FewfEvent):void{ _qualityButtonClicked(pType, e.data.pushed); });
			tPane.infoBar.updateQualityButton();
			
			// // Based on what the character is wearing at start, toggle on the appropriate buttons.
			// var tData:ItemData = character.getItemData(pType);
			// if(tData) {
			// 	for(var b = 0; b < tPane.buttons.length; b++) {
			// 		if(tPane.buttons[b].data.data.id == tData.id) {
			// 			tPane.buttons[b].toggleOn();
			// 			break;
			// 		}
			// 	}
			// 	//var tIndex:int = FewfUtils.getIndexFromArrayWithKeyVal(GameAssets.getItemDataListByType(tType), "id", tData.id);
			// 	//tPane.buttons[ tIndex ].toggleOn();
			// }
			return tPane;
		}
		
		private function _populateShopTabs() : void {
			var tTabs:Vector.<Object> = new <Object>[
				{ text:"tab_config", event:CONFIG_PANE_ID },
				{ text:"tab_skins", event:ItemType.SKIN.toString() },
				{ text:"tab_face", event:ItemType.FACE.toString() },
				{ text:"tab_hair", event:ItemType.HAIR.toString() },
				{ text:"tab_beards", event:ItemType.BEARD.toString() },
				{ text:"tab_head", event:ItemType.HEAD.toString() },
				{ text:"tab_shirts", event:ItemType.SHIRT.toString() },
				{ text:"tab_pants", event:ItemType.PANTS.toString() },
				{ text:"tab_shoes", event:ItemType.SHOES.toString() },
				{ text:"tab_mask", event:ItemType.MASK.toString() },
				{ text:"tab_belt", event:ItemType.BELT.toString() },
				{ text:"tab_gloves", event:ItemType.GLOVES.toString() },
				{ text:"tab_bag", event:ItemType.BAG.toString() },
				{ text:"tab_objects", event:ItemType.OBJECT.toString() },
				{ text:"tab_poses", event:ItemType.POSE.toString() }
			];
			// Remove extra tabs
			for(var i:int=tTabs.length-1; i >= 0; i--) {
				if(!GameAssets.showAll && (tTabs[i].event == ItemType.SKIN || tTabs[i].event == ItemType.FACE)) {
					tTabs.splice(i, 1);
				}
				else if(GameAssets.sex == Sex.FEMALE && tTabs[i].event == ItemType.BEARD) {
					tTabs.splice(i, 1);
				}
			}
			this.shopTabs.populate(tTabs);
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN){
				var pane:SidePane = _paneManager.getOpenPane();
				if(pane && pane is ButtonGridSidePane) {
					(pane as ButtonGridSidePane).handleKeyboardDirectionalInput(e.keyCode);
				}
				else if(pane && pane is ColorPickerTabPane) {
					if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) {
						(pane as ColorPickerTabPane).nextSwatch(e.keyCode == Keyboard.DOWN);
					}
				}
			}
		}

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.value;
		}

		private function _onShareCodeEntered(pCode:String, pProgressCallback:Function):void {
			if(!pCode || pCode == "") { return; pProgressCallback("placeholder"); }
			if(pCode.indexOf("?") > -1) {
				pCode = pCode.substr(pCode.indexOf("?") + 1, pCode.length);
			}
			
			try {
				var params = new flash.net.URLVariables();
				params.decode(pCode);
				
				// First remove old stuff to prevent conflicts
				for each(var tItem:ItemType in ItemType.LAYERING) { _removeItem(tItem); }
				_removeItem(ItemType.POSE);
				
				// Now update pose
				character.parseParams(params);
				character.updatePose();
				
				// now update the infobars
				_populateShopTabs();
				_updateUIBasedOnCharacter();
				getConfigPane().updateButtonsBasedOnCurrentData();
				
				// Now tell code box that we are done
				pProgressCallback("success");
			}
			catch (err:Error) {
				trace(err);
				pProgressCallback("invalid");
			};
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
		
		private function _onSaveItemDataAsImage(pEvent:FewfEvent) : void {
			if(!pEvent.data) { return; }
			var itemData:ItemData = pEvent.data as ItemData;
			var tName:String = "shop-"+itemData.type+itemData.id;
			FewfDisplayUtils.saveAsPNG(GameAssets.getColoredItemImage(itemData), tName, ConstantsApp.ITEM_SAVE_SCALE);
		}

		private function _onClipboardButtonClicked(e:Event) : void {
			try {
				FewfDisplayUtils.copyToClipboard(character);
				_toolbox.updateClipboardButton(false, true);
			} catch(e) {
				_toolbox.updateClipboardButton(false, false);
			}
			setTimeout(function(){ _toolbox.updateClipboardButton(true); }, 750);
		}

		private function _onImgurButtonClicked(e:Event) : void {
			Fewf.dispatcher.addEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			ImgurApi.uploadImage(character);
			_toolbox.imgurButtonEnable(false);
		}
		private function _onImgurDone(e:*) : void {
			Fewf.dispatcher.removeEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			_toolbox.imgurButtonEnable(true);
		}

		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			var tPane:ShopCategoryPane;
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				tPane = getShopPane(tType)
				tPane.toggleOnButtonForCurrentData();
			}
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType = pEvent.data.type;
			var tItemArray:Vector.<ItemData> = GameAssets.getItemDataListByType(tType);
			var tInfoBar:Infobar = getInfoBarByType(tType);

			// De-select all buttons that aren't the clicked one.
			var tButtons:Vector.<PushButton> = getButtonArrayByType(tType);
			for(var i:int = 0; i < tButtons.length; i++) {
				if(tButtons[i].data.id != pEvent.data.id) {
					if (tButtons[i].pushed)  { tButtons[i].toggleOff(); }
				}
			}

			var tPane:ShopCategoryPane = getShopPane(tType);
			var tButton:PushButton = tPane.getButtonWithItemData(pEvent.data.itemData);
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				var tData:ItemData = tItemArray[pEvent.data.id];
				/*setCurItemID(tType, tButton.id);*/
				setCurItemID(tType, pEvent.data.index);
				this.character.setItemData(tData);

				tInfoBar.addInfo( tData, GameAssets.getColoredItemImage(tData) );
				tInfoBar.showColorWheel(tData.colorable);
			} else {
				_removeItem(tType);
			}
		}

		private function _removeItem(pType:ItemType) : void {
			var tTabPane = getShopPane(pType);
			if(!tTabPane) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(pType == ItemType.SKIN || pType == ItemType.POSE || pType == ItemType.FACE) {
				if(tTabPane.infoBar.hasData) {
					var tDefaultIndex = 0;//(pType == ItemType.POSE ? GameAssets.defaultPoseIndex : GameAssets.defaultSkinIndex);
					if(tTabPane.buttons[tDefaultIndex]) tTabPane.buttons[tDefaultIndex].toggleOn();
				}
			} else {
				this.character.removeItem(pType);
				if(tTabPane.infoBar.hasData) {
					tTabPane.infoBar.removeInfo();
					tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
				}
			}
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_paneManager.openPane(pEvent.data.toString());
		}

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for each(var itemType:ItemType in ItemType.LAYERING) {
				if(getShopPane(itemType)) {
					if(itemType == ItemType.SHIRT || itemType == ItemType.PANTS || itemType == ItemType.SHOES || itemType == ItemType.OBJECT) {
						_randomItemOfType(itemType);
					} else {
						_randomItemOfType(itemType, Math.random() <= 0.65);
					}
				}
			}
			_randomItemOfType(ItemType.POSE, Math.random() <= 0.5);
		}

		private function _randomItemOfType(pType:ItemType, pSetToDefault:Boolean=false) : void {
			var pane:ShopCategoryPane = getShopPane(pType);
			if(pane.infoBar.isRefreshLocked || !pane.buttons.length) { return; }
			
			if(!pSetToDefault) {
				pane.chooseRandomItem();
				// var tButtons = getButtonArrayByType(pType);
				// if(tButtons.length == 0) { return; }
				// var tLength = tButtons.length; if(pType == ItemType.SKIN) { /* Don't select "transparent" */ tLength--; }
				// tButtons[ Math.floor(Math.random() * tLength) ].toggleOn();
			} else {
				_removeItem(pType);
			}
		}
		
		private function _qualityButtonClicked(pType:ItemType, pPushed:Boolean) : void {
			GameAssets.tornStates[pType] = pPushed;
			character.updatePose();
		}

		private function _onShareButtonClicked(pEvent:Event) : void {
			var tURL = "";
			try {
				if(Fewf.isExternallyLoaded) {
					tURL = this.character.getParams();
				} else {
					tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
					tURL += "?"+this.character.getParams();
				}
			} catch (error:Error) {
				tURL = "<error creating link>";
			};

			_shareScreen.open(tURL);
			addChild(_shareScreen);
		}

		private function _onShareScreenClosed(pEvent:Event) : void {
			removeChild(_shareScreen);
		}

		private function _onTrashButtonClicked(pEvent:Event) : void {
			addChild(trashConfirmScreen);
		}

		private function _onTrashConfirmScreenConfirm(pEvent:Event) : void {
			removeChild(trashConfirmScreen);
			for each(var tItem:ItemType in ItemType.LAYERING) { _removeItem(tItem); }
			_removeItem(ItemType.POSE);
		}

		private function _onTrashConfirmScreenClosed(pEvent:Event) : void {
			removeChild(trashConfirmScreen);
		}

		private function _onLangButtonClicked(pEvent:Event) : void {
			_langScreen.open();
			addChild(_langScreen);
		}

		private function _onLangScreenClosed(pEvent:Event) : void {
			removeChild(_langScreen);
		}

		private function _onAboutButtonClicked(e:Event) : void {
			_aboutScreen.open();
			addChild(_aboutScreen);
		}

		private function _onAboutScreenClosed(e:Event) : void {
			removeChild(_aboutScreen);
		}

		//{REGION Get TabPane data
			private function getShopPane(pType:ItemType) : ShopCategoryPane {
				return _paneManager.getPane(pType.toString()) as ShopCategoryPane;
			}

			private function getInfoBarByType(pType:ItemType) : Infobar {
				return getShopPane(pType).infoBar;
			}

			private function getButtonArrayByType(pType:ItemType) : Vector.<PushButton> {
				return getShopPane(pType).buttons;
			}

			private function getCurItemID(pType:ItemType) : int {
				return getShopPane(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:ItemType, pID:int) : void {
				getShopPane(pType).selectedButtonIndex = pID;
			}
			
			private function getColorPickerPane() : ColorPickerTabPane { return _paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane; }
			private function getConfigColorPickerPane() : ColorPickerTabPane { return _paneManager.getPane(CONFIG_COLOR_PANE_ID) as ColorPickerTabPane; }
			private function getColorFinderPane() : ColorFinderPane { return _paneManager.getPane(COLOR_FINDER_PANE_ID) as ColorFinderPane; }
			private function getDyePane() : DyePane { return _paneManager.getPane(DYE_PANE_ID) as DyePane; }
			private function getConfigPane() : ConfigTabPane { return _paneManager.getPane(CONFIG_PANE_ID) as ConfigTabPane; }
		//}END Get TabPane data
			
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

		//{REGION Color Finder Tab
			private function _eyeDropButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).itemData;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = GameAssets.getColoredItemImage(tData);
				getColorFinderPane().infoBar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				getColorFinderPane().setItem(tItem2);
				_paneManager.openPane(COLOR_FINDER_PANE_ID);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_paneManager.openPane(getColorFinderPane().infoBar.itemData.type.toString());
			}
		//}END Color Finder Tab

		//{REGION Dye Tab
			private function _dyeButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).itemData;
				getDyePane().infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				getDyePane().setColor(tData.color);
				_paneManager.openPane(DYE_PANE_ID);
			}
			
			private function _onDyeChanged(pEvent:DataEvent):void {
				var tVal:uint = uint(pEvent.data);
				this.character.getItemData(this.currentlyColoringType).color = tVal;//s[getColorPickerPane().selectedSwatch] = tVal;
				_refreshSelectedItemColor(this.currentlyColoringType);
			}
			
			private function _onDyeColorPickChanged(pEvent:DataEvent):void {
				getDyePane().setColor( uint(pEvent.data) );
			}
			
			private function _onDyeCustomPickerClicked(pEvent:Event):void {
				_colorButtonClicked(getDyePane().infoBar.itemData.type);
			}
			
			private function _onDyeBackClicked(pEvent:Event):void {
				_paneManager.openPane(getDyePane().infoBar.itemData.type.toString());
			}
		//}END Dye Tab

		//{REGION Color Tab
			private function _onColorPickChanged(e:FewfEvent):void {
				// if(e.data.allUpdated) {
				// 	this.character.getItemData(this.currentlyColoringType).colors = e.data.allColors;
				// } else {
					var tColor:uint = uint(e.data.color);
					// this.character.getItemData(this.currentlyColoringType).colors[e.data.colorIndex] = uint(e.data.color);
					this.character.getItemData(this.currentlyColoringType).color = tColor;
					getDyePane().setColor(tColor);
				// }
				_refreshSelectedItemColor(this.currentlyColoringType);
			}

			// private function _onDefaultsButtonClicked(pEvent:Event) : void
			// {
			// 	/* this.character.getItemData(this.currentlyColoringType).setColorsToDefault(); */
			// 	this.character.getItemData(this.currentlyColoringType).color = -1;
			// 	_refreshSelectedItemColor(this.currentlyColoringType);
			// 	/* getColorPickerPane().setupSwatches( this.character.getColors(this.currentlyColoringType) ); */
			// 	_paneManager.openPane(getColorPickerPane().infoBar.data.type);
			// }
			
			private function _refreshSelectedItemColor(pType:ItemType, pForceReplace:Boolean=false) : void {
				character.updatePose();
				
				var tItemData = this.character.getItemData(pType);
				if(pType != ItemType.SKIN && !pForceReplace) {
					var tItem:MovieClip = GameAssets.getColoredItemImage(tItemData);
					GameAssets.copyColor(tItem, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image as MovieClip );
					GameAssets.copyColor(tItem, getInfoBarByType(pType).Image );
					GameAssets.copyColor(tItem, getColorPickerPane().infoBar.Image);
				} else {
					_replaceImageWithNewImage(getButtonArrayByType(pType)[ getCurItemID(pType) ], GameAssets.getColoredItemImage(tItemData));
					/*_replaceImageWithNewImage(getInfoBarByType(pType), GameAssets.getColoredItemImage(tItemData));*/
					getInfoBarByType(pType).ChangeImage(GameAssets.getColoredItemImage(tItemData));
					_replaceImageWithNewImage(getColorPickerPane().infoBar, GameAssets.getColoredItemImage(tItemData));
				}
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).itemData;
				getColorPickerPane().infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				getColorPickerPane().init( tData.uniqId(), new <uint>[ tData.color ], null );
				_paneManager.openPane(COLOR_PANE_ID);
				_refreshSelectedItemColor(pType);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				// _paneManager.openPane(getColorPickerPane().infoBar.itemData.type.toString());
				_paneManager.openPane(DYE_PANE_ID);
			}
		//}END Color Tab

		//{REGION Config Tab
			private function _onConfigColorPickChanged(pEvent:FewfEvent):void {
				var tVal:uint = uint(pEvent.data.color);
				getConfigPane().updateCustomColor(configCurrentlyColoringType, tVal);
			}
			
			// When any color type changes, be it via color picker or just button.
			private function _onConfigColorChanged(pEvent:FewfEvent) {
				switch(pEvent.data.type) {
					case "hair":
						getShopPane(ItemType.HAIR).makeDirty();
						getShopPane(ItemType.BEARD).makeDirty();
						break;
					case "skin":
						getShopPane(ItemType.SKIN).makeDirty();
						getShopPane(ItemType.POSE).makeDirty();
						break;
					case "secondary":
						getShopPane(ItemType.SKIN).makeDirty();
						break;
				}
			}

			private function _configColorButtonClicked(pConfigType:String, pColor:int) : void {
				this.configCurrentlyColoringType = pConfigType;
				getConfigColorPickerPane().init( "config-"+pConfigType, new <uint>[ pColor ], null );
				_paneManager.openPane(CONFIG_COLOR_PANE_ID);
			}
				

			private function _onSexChanged(pEvent:Event) : void {
				var tTypes:Vector.<ItemType> = new <ItemType>[ ItemType.OBJECT, ItemType.SKIN, ItemType.FACE, ItemType.BEARD, ItemType.HAIR, ItemType.HEAD, ItemType.SHIRT, ItemType.PANTS, ItemType.SHOES, ItemType.POSE, ItemType.MASK, ItemType.BELT, ItemType.GLOVES, ItemType.BAG ];
				var tType:ItemType, tData, tNewSexIsMale;
				for(var i in tTypes) { tType = tTypes[i];
					if(getShopPane(tType)) {
						tData = character.getItemData(tType);
						if(!tData || tData.sex != null) {
							_removeItem(tType);
							if(!tData) { continue; }
							tNewSexIsMale = tData.sex == Sex.FEMALE;
							tData = GameAssets.getItemFromTypeID(tType, tData.id.slice(0, -1)+(tNewSexIsMale ? "M" : "F"));
							if(tData) { character.setItemData(tData); }
						}
						/* _setupPaneButtons(_paneManager.getPane(tType), GameAssets.getItemDataListByType(tType)); */
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
				
				var tType:ItemType, tTypes:Vector.<ItemType> = ItemType.LAYERING; tTypes.push(ItemType.POSE);
				if(!GameAssets.showAll) {
					for(var i in tTypes) { tType = tTypes[i];
						if(getShopPane(tType)) {
							if(!character.getItemData(tType) || character.getItemData(tType).tags.indexOf("extra") != -1) _removeItem(tType);
							/* _setupPaneButtons(_paneManager.getPane(tType), GameAssets.getItemDataListByType(tType)); */
						}
					}
				}
				
				_paneManager.dirtyAllPanes();
				character.updatePose();
				_populateShopTabs();
			}
		//}END Config Tab
	}
}
