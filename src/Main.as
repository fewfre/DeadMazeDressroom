package
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
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

		internal var shop			: RoundedRectangle;
		internal var shopTabs		: ShopTabContainer;
		internal var animateButton	: SpriteButton;
		internal var linkTray		: LinkTray;
		internal var scaleSlider	: FancySlider;

		internal var currentlyColoringType:String="";
		internal var configCurrentlyColoringType:String;

		internal var tabPanes:Array; // Must contain all TabPanes to be able to close them properly.
		internal var tabPanesMap:Object; // Tab pane should be stored in here to easy access the one you desire.
		internal var colorTabPane:TabPane;
		internal var configColorTabPane:TabPane;

		// Constructor
		public function Main()
		{
			super();

			assets = new AssetManager();
			assets.load([
				"resources/resources.swf",
				"resources/resources2.swf"
			]);
			assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);

			loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5, assetManager:assets }) );

			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 10;

			addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}

		internal function _onLoadComplete(event:Event) : void
		{
			loaderDisplay.destroy();
			removeChild( loaderDisplay );
			loaderDisplay = null;

			costumes = new Costumes( assets );
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
			this.shop = addChild(new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT }));
			this.shop.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);

			this.shopTabs = addChild(new ShopTabContainer({ x:380, y:10, width:60, height:ConstantsApp.APP_HEIGHT,
				tabs:[
					{ text:"Config", event:"config" },
					{ text:"Skin", event:ITEM.SKIN },
					{ text:"Hair", event:ITEM.HAIR },
					/*{ text:"Head", event:ITEM.HEAD },*/
					{ text:"Shirts", event:ITEM.SHIRT },
					{ text:"Pants", event:ITEM.PANTS },
					{ text:"Shoes", event:ITEM.SHOES },
					{ text:"Objects", event:ITEM.OBJECT },
					{ text:"Pose", event:ITEM.POSE }
				]
			}));
			this.shopTabs.addEventListener(ShopTabContainer.EVENT_SHOP_TAB_CLICKED, _onTabClicked);

			// Toolbox
			var tools:RoundedRectangle = addChild(new RoundedRectangle({ x:5, y:10, width:365, height:35 }));
			tools.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);

			var btn:ButtonBase, tButtonSize = 28, tButtonSizeSpace=5;
			btn = tools.addChild(new SpriteButton({ x:tButtonSizeSpace, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.4, obj:new $LargeDownload() }));
			btn.addEventListener(ButtonBase.CLICK, _onSaveClicked);

			animateButton = tools.addChild(new SpriteButton({ x:tButtonSizeSpace+(tButtonSize+tButtonSizeSpace), y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $PauseButton() }));
			animateButton.addEventListener(ButtonBase.CLICK, _onPlayerAnimationToggle);

			btn = tools.addChild(new SpriteButton({ x:tButtonSizeSpace+(tButtonSize+tButtonSizeSpace)*2, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $Refresh() }));
			btn.addEventListener(ButtonBase.CLICK, _onRandomizeDesignClicked);

			btn = tools.addChild(new SpriteButton({ x:tButtonSizeSpace+(tButtonSize+tButtonSizeSpace)*3, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link() }));
			btn.addEventListener(ButtonBase.CLICK, _onShareButtonClicked);
			linkTray = new LinkTray({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 });
			linkTray.addEventListener(LinkTray.CLOSE, _onShareTrayClosed);

			btn = tools.addChild(new SpriteButton({ x:tools.width-tButtonSizeSpace-tButtonSize, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.35, obj:new $GitHubIcon() }));
			btn.addEventListener(ButtonBase.CLICK, function():void { navigateToURL(new URLRequest(ConstantsApp.SOURCE_URL), "_blank");  });

			var tSliderWidth = 315 - (tButtonSize+tButtonSizeSpace)*4.5;
			this.scaleSlider = tools.addChild(new FancySlider({
				x:tools.width*0.5-tSliderWidth*0.5+(tButtonSize+tButtonSizeSpace)*1.5, y:tools.Height*0.5,
				value: character.outfit.scaleX*10, min:10, max:40, width:tSliderWidth
			}));
			this.scaleSlider.addEventListener(FancySlider.CHANGE, _onScaleSliderChange);

			/****************************
			* Create tabs and panes
			*****************************/
			this.tabPanes = new Array();
			this.tabPanesMap = new Object();

			tabPanes.push( colorTabPane = new ColorPickerTabPane({}) );
			colorTabPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			colorTabPane.addEventListener(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked);
			colorTabPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);

			tabPanes.push( tabPanesMap["config"] = new ConfigTabPane(character) );
			tabPanesMap["config"].hairColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("hair", pEvent.target.id); });
			tabPanesMap["config"].skinColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("skin", pEvent.target.id); });
			tabPanesMap["config"].secondaryColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("secondary", pEvent.target.id); });
			tabPanesMap["config"].addEventListener("sex_change", _onSexChanged);

			tabPanes.push( configColorTabPane = new ColorPickerTabPane({ hide_default:true }) );
			configColorTabPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged);
			configColorTabPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, function(pEvent:Event){ _selectTab(getTabByType("config")); });


			// Create the panes
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.HAIR, /*ITEM.HEAD,*/ ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.POSE ], tData:ItemData, tType:String;
			for(var i:int = 0; i < tTypes.length; i++) { tType = tTypes[i];
				tabPanes.push( tabPanesMap[tType] = _setupPane(tType) );
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				tData = character.getItemData(tType);
				if(tData) {
					for(var b = 0; b < tabPanesMap[tType].buttons.length; b++) {
						if(tabPanesMap[tType].buttons[b].data.data.id == tData.id) {
							tabPanesMap[tType].buttons[b].toggleOn();
							break;
						}
					}
					//var tIndex:int = FewfUtils.getIndexFromArrayWithKeyVal(costumes.getArrayByType(tType), "id", tData.id);
					//tabPanesMap[tType].buttons[ tIndex ].toggleOn();
				}
			}

			// Select First Pane
			shopTabs.tabs[0].toggleOn();
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
			var tType:String = pItemArray[0].type;

			var buttonPerRow = 6;
			var scale = 1;
			if(tType == ITEM.SKIN || tType == ITEM.POSE) {
					buttonPerRow = 4;
					scale = 0.8;
			} else if(tType == ITEM.HAIR) {
				/*scale = costumes.sex == GENDER.MALE ? 0.8 : 0.7;*/
			}

			var grid:Grid = pPane.grid;
			if(!grid) {
				grid = pPane.addGrid( new Grid({ x:15, y:5, width:385, columns:buttonPerRow, margin:5 }) );
			}
			grid.reset();

			var shopItem : Sprite;
			var shopItemButton : PushButton;
			var i = -1;
			pPane.buttons = [];
			while (i < pItemArray.length-1) { i++;
				if(pItemArray[i].gender != costumes.sex && pItemArray[i].gender != null) { continue; }
				if(tType == ITEM.SKIN && i == pItemArray.length-1) {
					shopItem = new TextBase({ size:15, color:0xC2C2DA, text:"Invisible" });
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

		public function update(pEvent:Event):void
		{
			if(loaderDisplay != null) { loaderDisplay.update(0.1); }
		}

		private function handleMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = scaleSlider.getValueAsScale();
			}
		}

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = scaleSlider.getValueAsScale();
		}

		private function _onPlayerAnimationToggle(pEvent:Event):void {
			character.animatePose = !character.animatePose;
			if(character.animatePose) {
				character.outfit.play();
				animateButton.ChangeImage(new $PauseButton());
			} else {
				character.outfit.stop();
				animateButton.ChangeImage(new $PlayButton());
			}
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

		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
				if(tabPanesMap[ITEM.LAYERING[i]]) _randomItemOfType(ITEM.LAYERING[i]);
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
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.HAIR, ITEM.HEAD, ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.POSE ];
			for(var i in tTypes) { tType = tTypes[i];
				if(tabPanesMap[tType]) {
					_setupPaneButtons(tabPanesMap[tType], costumes.getArrayByType(tType));
					_removeItem(tType);
				}
			}
		}

		//{REGION Get TabPane data
			private function getTabByType(pType:String) : TabPane {
				return tabPanesMap[pType];
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

		//{REGION TabPane Management
			private function _onTabClicked(pEvent:flash.events.DataEvent) : void {
				_selectTab( getTabByType(pEvent.data) );
			}

			private function _selectTab(pTab:TabPane) : void {
				_hideAllTabs();
				this.shop.addChild(pTab).active = true;
			}

			private function _hideTab(pTab:TabPane) : void {
				if(!pTab.active) { return; }
				this.shop.removeChild(pTab).active = false;
			}

			private function _hideAllTabs() : void {
				for(var i = 0; i < this.tabPanes.length; i++) {
					_hideTab(this.tabPanes[ i ]);
				}
			}
		//}END TabPane Management

		//{REGION Color Tab
			private function _onColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);

				this.character.colorItem(this.currentlyColoringType, this.colorTabPane.selectedSwatch, tVal.toString(16));
				var tItem:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tItem != null) {
					costumes.copyColor( tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
					costumes.copyColor(tItem, this.colorTabPane.infoBar.Image);
				}
				return;
			}

			private function _onConfigColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				tabPanesMap["config"].updateCustomColor(configCurrentlyColoringType, tVal);
				return;
			}

			private function _onDefaultsButtonClicked(pEvent:Event) : void
			{
				var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null)
				{
					costumes.colorDefault(tMC);
					costumes.copyColor( tMC, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tMC, getInfoBarByType(this.currentlyColoringType).Image);
					costumes.copyColor(tMC, this.colorTabPane.infoBar.Image);
					this.colorTabPane.setupSwatches( this.character.getColors(this.currentlyColoringType) );
				}
			}

			private function _colorButtonClicked(pType:String) : void {
				if(this.character.getItemFromIndex(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				this.colorTabPane.infoBar.addInfo( tData, costumes.getItemImage(tData) );
				this.currentlyColoringType = pType;
				this.colorTabPane.setupSwatches( this.character.getColors(pType) );
				_selectTab(this.colorTabPane);
			}

			private function _configColorButtonClicked(pType:String, pColor:int) : void {
				this.configCurrentlyColoringType = pType;
				this.configColorTabPane.setupSwatches( [ pColor ] );
				_selectTab(this.configColorTabPane);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_selectTab( getTabByType( this.colorTabPane.infoBar.data.type ) );
			}
		//}END Color Tab
	}
}
