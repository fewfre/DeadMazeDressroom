package
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;

	import dressroom.ui.*;
	import dressroom.ui.panes.*;
	import dressroom.ui.buttons.*;
	import dressroom.data.*;
	import dressroom.world.data.*;
	import dressroom.world.elements.*;

	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;

	public class Main extends MovieClip
	{
		// Storage
		public static var assets	: AssetManager;
		public static var costumes	: Costumes;

		internal var character		: Character;
		internal var loaderDisplay	: LoaderDisplay;
		internal var _paneManager	: PaneManager;

		internal var shopTabs		: ShopTabContainer;
		internal var _toolbox		: Toolbox;
		internal var linkTray		: LinkTray;

		internal var currentlyColoringType:String="";
		internal var configCurrentlyColoringType:String;
		
		// Constants
		public static const COLOR_PANE_ID = "colorPane";
		public static const CONFIG_PANE_ID = "configPane";
		public static const CONFIG_COLOR_PANE_ID = "configColorPane";

		// Constructor
		public function Main() {
			super();
			Fewf.init();
			
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 10;
			
			BrowserMouseWheelPrevention.init(stage);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			
			// Start preload
			Fewf.assets.load([
				"resources/config.json",
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onPreloadComplete);

			loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 }) );
		}
		
		internal function _onPreloadComplete(event:Event) : void {
			Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, _onPreloadComplete);
			ConstantsApp.lang = Fewf.assets.getData("config").language;
			
			// Start main load
			Fewf.assets.load([
				"resources/resources.swf",
				"resources/resources2.swf",
				"resources/i18n/"+ConstantsApp.lang+".json",
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
		}

		internal function _onLoadComplete(event:Event) : void {
			Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
			loaderDisplay.destroy();
			removeChild( loaderDisplay );
			loaderDisplay = null;
			
			Fewf.i18n.parseFile(Fewf.assets.getData(ConstantsApp.lang));
			
			_init();
		}
		
		private function _init() : void {
			costumes = new Costumes();
			costumes.init();

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
				skin:costumes.skins[costumes.defaultSkinIndex],
				pose:costumes.poses[costumes.defaultPoseIndex],
				params:parms,
				scale:2.5
			}));

			/****************************
			* Setup UI
			*****************************/
			var tShop:RoundedRectangle = addChild(new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT }));
			tShop.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			_paneManager = tShop.addChild(new PaneManager());
			
			this.shopTabs = addChild(new ShopTabContainer({ x:380, y:10, width:60, height:ConstantsApp.APP_HEIGHT,
				tabs:[
					{ text:"tab_config", event:CONFIG_PANE_ID },
					{ text:"tab_skins", event:ITEM.SKIN },
					{ text:"tab_face", event:ITEM.FACE },
					{ text:"tab_hair", event:ITEM.HAIR },
					{ text:"tab_head", event:ITEM.HEAD },
					{ text:"tab_shirts", event:ITEM.SHIRT },
					{ text:"tab_pants", event:ITEM.PANTS },
					{ text:"tab_shoes", event:ITEM.SHOES },
					{ text:"tab_objects", event:ITEM.OBJECT },
					{ text:"tab_poses", event:ITEM.POSE }
				]
			}));
			this.shopTabs.addEventListener(ShopTabContainer.EVENT_SHOP_TAB_CLICKED, _onTabClicked);

			// Toolbox
			_toolbox = addChild(new Toolbox({
				x:188, y:28, character:character,
				onSave:_onSaveClicked, onAnimate:_onPlayerAnimationToggle, onRandomize:_onRandomizeDesignClicked,
				onShare:_onShareButtonClicked, onScale:_onScaleSliderChange
			}));
			linkTray = new LinkTray({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 });
			linkTray.addEventListener(LinkTray.CLOSE, _onShareTrayClosed);

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

			tPane = _paneManager.addPane(CONFIG_COLOR_PANE_ID, new ColorPickerTabPane({ hide_default:true }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, function(pEvent:Event){ _paneManager.openPane(CONFIG_PANE_ID); });


			// Create the panes
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.FACE, ITEM.HAIR, ITEM.HEAD, ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.POSE ], tData:ItemData, tType:String;
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
					//var tIndex:int = FewfUtils.getIndexFromArrayWithKeyVal(costumes.getArrayByType(tType), "id", tData.id);
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
				_setupPaneButtons(_paneManager.getPane(tType), costumes.getArrayByType(tType));
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
			tPane.addInfoBar( new ShopInfoBar({}) );
			_setupPaneButtons(tPane, costumes.getArrayByType(pType));
			tPane.infoBar.colorWheel.addEventListener(ButtonBase.CLICK, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.imageCont.addEventListener(MouseEvent.CLICK, function(){ _removeItem(pType); });
			tPane.infoBar.refreshButton.addEventListener(ButtonBase.CLICK, function(){ _randomItemOfType(pType); });
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
				/*scale = costumes.sex == SEX.MALE ? 0.8 : 0.7;*/
			}

			var grid:Grid = pPane.grid;
			if(!grid) { grid = pPane.addGrid( new Grid({ x:15, y:5, width:385, columns:buttonPerRow, margin:5 }) ); }
			grid.reset();

			var shopItem : Sprite;
			var shopItemButton : PushButton;
			var i = -1;
			pPane.buttons = [];
			while (i < pItemArray.length-1) { i++;
				if(pItemArray[i].sex != costumes.sex && pItemArray[i].sex != null) { continue; }
				if(tType == ITEM.SKIN && i == pItemArray.length-1) {
					shopItem = new TextBase({ size:15, color:0xC2C2DA, text:"skin_invisible" });
				} else {
					shopItem = costumes.getItemImage(pItemArray[i]);
					shopItem.scaleX = shopItem.scaleY = scale;
				}

				shopItemButton = new PushButton({ width:grid.radius, height:grid.radius, obj:shopItem, id:i, data:{ type:tType, id:i, data:pItemArray[i], index:pPane.buttons.length } });
				pPane.buttons.push(shopItemButton);
				grid.add(shopItemButton)
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			pPane.UpdatePane();
		}

		private function handleMouseWheel(pEvent:MouseEvent) : void {
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
			Main.costumes.saveMovieClipAsBitmap(this.character, "character");
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType = pEvent.data.type;
			var tItemArray:Array = costumes.getArrayByType(tType);
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

				tInfoBar.addInfo( tData, costumes.getItemImage(tData) );
				tInfoBar.showColorWheel(costumes.getNumOfCustomColors(tButton.Image) > 0);
			} else {
				_removeItem(tType);
			}
		}

		private function _removeItem(pType:String) : void {
			var tTabPane = getTabByType(pType);
			if(tTabPane.infoBar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			if(pType == ITEM.SKIN || pType == ITEM.POSE) {
				var tDefaultIndex = 0;//(pType == ITEM.POSE ? costumes.defaultPoseIndex : costumes.defaultSkinIndex);
				tTabPane.buttons[tDefaultIndex].toggleOn();
			} else {
				this.character.removeItem(pType);
				tTabPane.infoBar.removeInfo();
				tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
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
			var tButtons = getButtonArrayByType(pType);
			var tLength = tButtons.length; if(pType == ITEM.SKIN) { /* Don't select "transparent" */ tLength--; }
			tButtons[ Math.floor(Math.random() * tLength) ].toggleOn();
		}

		private function _onShareButtonClicked(pEvent:Event) : void {
			var tURL = "";
			try {
				tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
				tURL += "?"+this.character.getParams();
			} catch (error:Error) {
				tURL = "<error creating link>";
			};

			linkTray.open(tURL);
			addChild(linkTray);
		}

		private function _onShareTrayClosed(pEvent:Event) : void {
			removeChild(linkTray);
		}

		private function _onSexChanged(pEvent:Event) : void {
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.FACE, ITEM.HAIR, ITEM.HEAD, ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.POSE ];
			for(var i in tTypes) { tType = tTypes[i];
				if(_paneManager.getPane(tType)) {
					_setupPaneButtons(_paneManager.getPane(tType), costumes.getArrayByType(tType));
					_removeItem(tType);
				}
			}
			_paneManager.dirtyAllPanes();
			character.updatePose();
		}

		private function _onFacingChanged(pEvent:Event) : void {
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
			private function _onColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);

				this.character.colorItem(this.currentlyColoringType, _paneManager.getPane(COLOR_PANE_ID).selectedSwatch, tVal.toString(16));
				var tItem:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tItem != null) {
					costumes.copyColor( tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
					costumes.copyColor(tItem, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
				}
			}

			private function _onConfigColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				_paneManager.getPane(CONFIG_PANE_ID).updateCustomColor(configCurrentlyColoringType, tVal);
			}

			private function _onDefaultsButtonClicked(pEvent:Event) : void
			{
				var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null)
				{
					costumes.colorDefault(tMC);
					costumes.copyColor( tMC, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tMC, getInfoBarByType(this.currentlyColoringType).Image);
					costumes.copyColor(tMC, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
					_paneManager.getPane(COLOR_PANE_ID).setupSwatches( this.character.getColors(this.currentlyColoringType) );
				}
			}

			private function _colorButtonClicked(pType:String) : void {
				if(this.character.getItemFromIndex(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				_paneManager.getPane(COLOR_PANE_ID).infoBar.addInfo( tData, costumes.getItemImage(tData) );
				this.currentlyColoringType = pType;
				_paneManager.getPane(COLOR_PANE_ID).setupSwatches( this.character.getColors(pType) );
				_paneManager.openPane(COLOR_PANE_ID);
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
