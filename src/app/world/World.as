package app.world
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.RoundedRectangle;
	import app.ui.panes.*;
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
	
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.*;
	import flash.external.ExternalInterface;
	
	import flash.display.*;
	import flash.events.*
	import flash.ui.Keyboard;
	import app.ui.panes.base.ButtonGridSidePane;
	import ext.ParentApp;
	import flash.utils.setTimeout;
	import flash.net.URLVariables;
	import app.world.events.ItemDataEvent;
	
	public class World extends Sprite
	{
		// Storage
		private var character          : Character;
		private var _panes             : WorldPaneManager;

		private var shopTabs           : ShopTabList;
		private var _toolbox           : Toolbox;
		
		private var _shareScreen       : ShareScreen;
		private var trashConfirmScreen : TrashConfirmScreen;
		private var _langScreen        : LangScreen;
		private var _aboutScreen       : AboutScreen;

		private var currentlyColoringType:ItemType=null;
		private var configCurrentlyColoringType:String;
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			ConstantsApp.ANIMATION_DOWNLOAD_ENABLED = !!Fewf.assets.getData("config").spritesheet2gif_url && (Fewf.isExternallyLoaded || (ExternalInterface.available && ExternalInterface.call("eval", "window.location.href") == null));
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownListener);
		}
		
		private function _buildWorld(pStage:Stage) : void {
			/* GameAssets.init(); */

			/////////////////////////////
			// Create Character
			/////////////////////////////
			var parms:String = null;
			if(!Fewf.isExternallyLoaded) {
				try {
					var urlPath:String = ExternalInterface.call("eval", "window.location.href");
					if(urlPath && urlPath.indexOf("?") > 0) {
						urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					}
					parms = urlPath;
				} catch (error:Error) { };
			}

			this.character = new Character(new <ItemData>[
				GameAssets.skins[GameAssets.defaultSkinIndex],
				GameAssets.poses[GameAssets.defaultPoseIndex],
				GameAssets.faces[GameAssets.defaultFaceIndex],
			], parms, 2.5).move(180, 375).setDragBounds(18, 73+15, 375-18-10, ConstantsApp.APP_HEIGHT-(73+15)-25).appendTo(this);

			/////////////////////////////
			// Setup UI
			/////////////////////////////
			this.shopTabs = new ShopTabList(70, ConstantsApp.SHOP_HEIGHT).move(375, 10).appendTo(this).on(ShopTabList.TAB_CLICKED, _onTabClicked);
			_populateShopTabs();
			
			var tShop:RoundRectangle = new RoundRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.SHOP_HEIGHT).move(450, 10)
				.appendTo(this).drawAsTray();
			_panes = new WorldPaneManager().appendTo(tShop.root) as WorldPaneManager;

			/////////////////////////////
			// Top Area
			/////////////////////////////
			_toolbox = new Toolbox(character, _onShareCodeEntered).move(188, 28).appendTo(this)
				.on(Toolbox.SAVE_CLICKED, _onSaveClicked)
				.on(Toolbox.GIF_CLICKED, function(e:Event):void{ _saveAsAnimation(); })
				.on(Toolbox.WEBP_CLICKED, function(e:Event):void{ _saveAsAnimation('webp'); })
				.on(Toolbox.SHARE_CLICKED, _onShareButtonClicked)
				.on(Toolbox.CLIPBOARD_CLICKED, _onClipboardButtonClicked)
				
				.on(Toolbox.SCALE_SLIDER_CHANGE, _onScaleSliderChange)
				
				.on(Toolbox.ANIMATION_TOGGLED, _onPlayerAnimationToggle)
				.on(Toolbox.RANDOM_CLICKED, _onRandomizeDesignClicked)
				.on(Toolbox.TRASH_CLICKED, _onTrashButtonClicked);
			
			/////////////////////////////
			// Bottom Left Area
			/////////////////////////////
			var tLangButton:SpriteButton = LangScreen.createLangButton({ width:30, height:25, origin:0.5 })
				.move(22, pStage.stageHeight-17).appendTo(this)
				.onButtonClick(_onLangButtonClicked) as SpriteButton;
			
			// About Screen Button
			var aboutButton:SpriteButton = new SpriteButton({ size:25, origin:0.5 }).appendTo(this)
				.move(tLangButton.x+(tLangButton.Width/2)+2+(25/2), ConstantsApp.APP_HEIGHT - 17)
				.onButtonClick(_onAboutButtonClicked) as SpriteButton;
			new TextBase("?", { size:22, color:0xFFFFFF, bold:true, origin:0.5 }).move(0, -1).appendTo(aboutButton)
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton({ obj:new $BackArrow(), obj_scale:0.5, origin:0.5 }).appendTo(this)
					.move(22, ConstantsApp.APP_HEIGHT-17-28)
					.onButtonClick(function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			/////////////////////////////
			// Screens
			/////////////////////////////
			_shareScreen = new ShareScreen().on(Event.CLOSE, _onShareScreenClosed);
			_langScreen = new LangScreen().on(Event.CLOSE, _onLangScreenClosed);
			_aboutScreen = new AboutScreen().on(Event.CLOSE, _onAboutScreenClosed);
			
			trashConfirmScreen = new TrashConfirmScreen().move(337, 65)
				.on(TrashConfirmScreen.CONFIRM, _onTrashConfirmScreenConfirm)
				.on(Event.CLOSE, _onTrashConfirmScreenClosed);

			/////////////////////////////
			// Static Panes
			/////////////////////////////
			// Item color picker
			_panes.addPane(WorldPaneManager.COLOR_PANE, new ColorPickerTabPane({ hide_default:true }))
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged)
				// .on(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked)
				.on(Event.CLOSE, _onColorPickerBackClicked)
				.on(ColorPickerTabPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorPickerBackClicked(e);
					// If item removed we want to fully backout of all color panes
					_onDyeBackClicked(e);
					_removeItem(_panes.colorPickerPane.infobar.itemData.type);
				});
			
			// Dye Picker Pane
			_panes.addPane(WorldPaneManager.DYE_PANE, new DyePane())
				.on(DyePane.EVENT_COLOR_PICKED, _onDyeChanged)
				.on(Event.CLOSE, _onDyeBackClicked)
				.on(Infobar.ITEM_PREVIEW_CLICKED, function(e){
					_onDyeBackClicked(e);
					_removeItem(_panes.dyePane.infobar.itemData.type);
				})
				.on(DyePane.EVENT_OPEN_COLORPICKER, _onDyeCustomPickerClicked);
			
			// Config Pane
			_panes.addPane(WorldPaneManager.CONFIG_PANE, new ConfigTabPane(character))
				.on(ConfigTabPane.EVENT_OPEN_COLORPICKER, function(e:FewfEvent):void{ _configColorButtonClicked(e.data.type, e.data.color); })
				.on(ConfigTabPane.EVENT_SEX_CHANGE, _onSexChanged)
				.on(ConfigTabPane.EVENT_FACING_CHANGE, _onFacingChanged)
				.on(ConfigTabPane.EVENT_COLOR_CHANGE, _onConfigColorChanged)
				.on(ConfigTabPane.EVENT_SHOW_EXTRA, _onShowExtraToggled);

			// Config color picker
			_panes.addPane(WorldPaneManager.CONFIG_COLOR_PANE, new ColorPickerTabPane({ hide_default:true, hideItemPreview:true }))
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged)
				.on(Event.CLOSE, function(e:Event):void{ _panes.openPane(WorldPaneManager.CONFIG_PANE); });
			
			// Color Finder Pane
			_panes.addPane(WorldPaneManager.COLOR_FINDER_PANE, new ColorFinderPane())
				.on(Event.CLOSE, _onColorFinderBackClicked)
				.on(ColorFinderPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorFinderBackClicked(e);
					_removeItem(_panes.colorFinderPane.infobar.itemData.type);
				});

			/////////////////////////////
			// Create item panes
			/////////////////////////////
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				_panes.addPane(WorldPaneManager.itemTypeToId(tType), _setupItemPane(tType));
				// _setupDirtyPanePopulation(tType);
			}
			Fewf.dispatcher.addEventListener(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _onSaveItemDataAsImage);

			// Select First Pane
			shopTabs.toggleOnFirstTab();
		}
		
		// private function _setupDirtyPanePopulation(tType:String) : void {
		// 	_panes.getPane(tType).populateFunction = function():void{
		// 		_setupPaneButtons(_panes.getPane(tType), GameAssets.getItemDataListByType(tType));
		// 		//_removeItem(tType);
				
		// 		var tPane = _panes.getPane(tType);
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
			
			tPane.infobar.on(Infobar.COLOR_WHEEL_CLICKED, function(){ _dyeButtonClicked(pType); });
			tPane.infobar.on(Infobar.ITEM_PREVIEW_CLICKED, function(){ _removeItem(pType); });
			tPane.infobar.on(Infobar.EYE_DROPPER_CLICKED, function(){ _eyeDropButtonClicked(pType); });
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_LOCK_CLICKED, function(e:FewfEvent){
				character.setItemTypeLock(pType, e.data.locked);
				_updateTabListLockByItemType(pType);
			});
			tPane.infobar.on(Infobar.QUALITY_CLICKED, function(e:FewfEvent):void{ _qualityButtonClicked(pType, e.data.pushed); });
			tPane.infobar.updateQualityButton();
			
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
		private function getShopPane(pType:ItemType) : ShopCategoryPane { return _panes.getShopPane(pType); }

		private function _populateShopTabs() : void {
			shopTabs.reset(); // Reset so we start with an empty list
			
			var tHideTypeMap:Object = {};
			tHideTypeMap[ItemType.SKIN] = !GameAssets.showAll;
			tHideTypeMap[ItemType.FACE] = !GameAssets.showAll;
			tHideTypeMap[ItemType.BEARD] = GameAssets.sex == Sex.FEMALE;
			
			shopTabs.addTab("tab_config", WorldPaneManager.CONFIG_PANE);
			for each(var type:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				if(tHideTypeMap[type]) continue;
				var tPluralI18n : Boolean = [ItemType.POSE, ItemType.SKIN, ItemType.BEARD, ItemType.SHIRT, ItemType.OBJECT].indexOf(type) > -1;
				var i18nStr : String = type.toString() + (tPluralI18n ? "s" : "");
				shopTabs.addTab("tab_"+i18nStr, WorldPaneManager.itemTypeToId(type));
				_updateTabListLockByItemType(type);
				_updateTabListItemIndicatorByType(type);
			}
		}
		private function _updateTabListLockByItemType(pType:ItemType) {
			shopTabs.getTabButton(WorldPaneManager.itemTypeToId(pType)).setLocked(character.isItemTypeLocked(pType));
		}
		private function _updateTabListItemIndicatorByType(pType:ItemType) {
			var tItemData:ItemData = character.getItemData(pType);
			var tHadIndicator:Boolean = !!tItemData && !tItemData.matches(GameAssets.defaultSkin) && !tItemData.matches(GameAssets.defaultPose);
			if(shopTabs.getTabButton(WorldPaneManager.itemTypeToId(pType))) shopTabs.getTabButton(WorldPaneManager.itemTypeToId(pType)).setItemIndicator(tHadIndicator);
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
				character.clampCoordsToDragBounds();
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN){
				var pane:SidePane = _panes.getOpenPane();
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
			character.clampCoordsToDragBounds();
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
				for each(var tItem:ItemType in ItemType.LAYERING) {
					if(!character.isItemTypeLocked((tItem))) _removeItem(tItem);
				}
				_removeItem(ItemType.POSE);
				
				// Now update pose
				character.parseParams(params);
				character.updatePose();
				
				// now update the infobars
				_populateShopTabs();
				_updateUIBasedOnCharacter();
				_panes.configPane.updateButtonsBasedOnCurrentData();
				
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
		
		private function _saveAsAnimation(pFormat:String=null) : void {
			if(!ConstantsApp.ANIMATION_DOWNLOAD_ENABLED) return _onSaveClicked(null);
			
			// FewfDisplayUtils.saveAsSpriteSheet(this.character.copy().outfit.pose, "spritesheet", this.character.outfit.scaleX);
			_toolbox.downloadButtonEnable(false);
			FewfDisplayUtils.saveAsAnimatedGif(this.character.copy().outfit.pose, "character", this.character.outfit.scaleX, pFormat, function(){
				_toolbox.downloadButtonEnable(true);
			});
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

		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			var tPane:ShopCategoryPane;
			for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
				tPane = getShopPane(tType)
				tPane.toggleOnButtonForCurrentData();
			}
		}

		private function _onItemToggled(e:ItemDataEvent) : void {
			var tItemData:ItemData = e.itemData;
			
			var tPane:ShopCategoryPane = getShopPane(tItemData.type), tInfobar:Infobar = tPane.infobar;
			var tButton:PushButton = tPane.getButtonWithItemData(tItemData);
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				this.character.setItemData(tItemData);
				tInfobar.addInfo( tItemData, GameAssets.getColoredItemImage(tItemData) );
				tInfobar.showColorWheel(tItemData.colorable);
			} else {
				_removeItem(tItemData.type);
			}
			_updateTabListItemIndicatorByType(tItemData.type);
		}

		private function _removeItem(pType:ItemType) : void {
			var tPane:ShopCategoryPane = getShopPane(pType);
			if(!tPane) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(pType == ItemType.SKIN || pType == ItemType.POSE || pType == ItemType.FACE) {
				if(tPane.infobar.hasData) {
					var tDefaultIndex = 0;//(pType == ItemType.POSE ? GameAssets.defaultPoseIndex : GameAssets.defaultSkinIndex);
					if(tPane.buttons[tDefaultIndex]) tPane.buttons[tDefaultIndex].toggleOn();
				}
			} else {
				var tOldData:ItemData = this.character.getItemData(pType);
				this.character.removeItem(pType);
				if(tPane.infobar.hasData) {
					tPane.infobar.removeInfo();
					if(tOldData) tPane.getButtonWithItemData(tOldData).toggleOff();
				}
			}
			_updateTabListItemIndicatorByType(pType);
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_panes.openPane(pEvent.data.toString());
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
			if(character.isItemTypeLocked(pType) || !pane.buttons.length) { return; }
			
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

		//{REGION Screen Logic
			private function _onShareButtonClicked(e:Event) : void {
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

				_shareScreen.open(tURL, character);
				addChild(_shareScreen);
			}
			private function _onShareScreenClosed(e:Event) : void { removeChild(_shareScreen); }

			private function _onTrashButtonClicked(e:Event) : void { addChild(trashConfirmScreen); }
			private function _onTrashConfirmScreenClosed(e:Event) : void { removeChild(trashConfirmScreen); }

			private function _onLangButtonClicked(e:Event) : void { _langScreen.open(); addChild(_langScreen); }
			private function _onLangScreenClosed(e:Event) : void { removeChild(_langScreen); }

			private function _onAboutButtonClicked(e:Event) : void { _aboutScreen.open(); addChild(_aboutScreen); }
			private function _onAboutScreenClosed(e:Event) : void { removeChild(_aboutScreen); }

			private function _onTrashConfirmScreenConfirm(e:Event) : void {
				for each(var tItem:ItemType in ItemType.LAYERING) { _removeItem(tItem); }
				_removeItem(ItemType.POSE);
				
				// Refresh panes
				for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) {
					var pane:ShopCategoryPane = getShopPane(tType);
					pane.infobar.unlockRandomizeButton(); // this will also update `character.setItemTypeLock()`
				}
			}
		//}END Screen Logic

		//{REGION Color Finder Tab
			private function _eyeDropButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getShopPane(pType).infobar.itemData;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = GameAssets.getColoredItemImage(tData);
				_panes.colorFinderPane.infobar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				_panes.colorFinderPane.setItem(tItem2);
				_panes.openPane(WorldPaneManager.COLOR_FINDER_PANE);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_panes.openPane(WorldPaneManager.itemTypeToId(_panes.colorFinderPane.infobar.itemData.type));
			}
		//}END Color Finder Tab

		//{REGION Dye Tab
			private function _dyeButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getShopPane(pType).infobar.itemData;
				_panes.dyePane.infobar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				_panes.dyePane.setColor(tData.color);
				_panes.openPane(WorldPaneManager.DYE_PANE);
			}
			
			private function _onDyeChanged(pEvent:DataEvent):void {
				var tVal:uint = uint(pEvent.data);
				this.character.getItemData(this.currentlyColoringType).color = tVal;//s[getColorPickerPane().selectedSwatch] = tVal;
				_refreshSelectedItemColor(this.currentlyColoringType);
			}
			
			private function _onDyeColorPickChanged(pEvent:DataEvent):void {
				_panes.dyePane.setColor( uint(pEvent.data) );
			}
			
			private function _onDyeCustomPickerClicked(pEvent:Event):void {
				_colorButtonClicked(_panes.dyePane.infobar.itemData.type);
			}
			
			private function _onDyeBackClicked(pEvent:Event):void {
				_panes.openPane(WorldPaneManager.itemTypeToId(_panes.dyePane.infobar.itemData.type));
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
					_panes.dyePane.setColor(tColor);
				// }
				_refreshSelectedItemColor(this.currentlyColoringType);
			}

			// private function _onDefaultsButtonClicked(pEvent:Event) : void
			// {
			// 	/* this.character.getItemData(this.currentlyColoringType).setColorsToDefault(); */
			// 	this.character.getItemData(this.currentlyColoringType).color = -1;
			// 	_refreshSelectedItemColor(this.currentlyColoringType);
			// 	/* getColorPickerPane().setupSwatches( this.character.getColors(this.currentlyColoringType) ); */
			// 	_panes.openPane(getColorPickerPane().infoBar.data.type);
			// }
			
			private function _refreshSelectedItemColor(pType:ItemType, pForceReplace:Boolean=false) : void {
				character.updatePose();
				
				var tPane:ShopCategoryPane = getShopPane(pType);
				var tItemData:ItemData = this.character.getItemData(pType);
				if(!tItemData) { return; }
				
				_refreshButtonCustomizationForItemData(tItemData);
				tPane.infobar.refreshItemImageUsingCurrentItemData();
				_panes.colorPickerPane.infobar.refreshItemImageUsingCurrentItemData();
				_panes.dyePane.infobar.refreshItemImageUsingCurrentItemData();
			}
			
			private function _refreshButtonCustomizationForItemData(pItemData:ItemData) : void {
				if(!pItemData) { return; }
				var tPane:ShopCategoryPane = getShopPane(pItemData.type);
				tPane.refreshButtonImage(pItemData);
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getShopPane(pType).infobar.itemData;
				_panes.colorPickerPane.infobar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				_panes.colorPickerPane.init( tData.uniqId(), new <uint>[ tData.color ], null );
				_panes.openPane(WorldPaneManager.COLOR_PANE);
				_refreshSelectedItemColor(pType);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				// _panes.openPane(WorldPaneManager.itemTypeToId(getColorPickerPane().infobar.itemData.type));
				_panes.openPane(WorldPaneManager.DYE_PANE);
			}
		//}END Color Tab

		//{REGION Config Tab
			private function _onConfigColorPickChanged(pEvent:FewfEvent):void {
				var tVal:uint = uint(pEvent.data.color);
				_panes.configPane.updateCustomColor(configCurrentlyColoringType, tVal);
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
				_panes.configColorPickerPane.init( "config-"+pConfigType, new <uint>[ pColor ], null );
				_panes.openPane(WorldPaneManager.CONFIG_COLOR_PANE);
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
						/* _setupPaneButtons(_panes.getPane(tType), GameAssets.getItemDataListByType(tType)); */
					}
				}
				_panes.dirtyAllPanes();
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
							/* _setupPaneButtons(_panes.getPane(tType), GameAssets.getItemDataListByType(tType)); */
						}
					}
				}
				
				_panes.dirtyAllPanes();
				character.updatePose();
				_populateShopTabs();
			}
		//}END Config Tab
	}
}
