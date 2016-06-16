package 
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.display.*;
	
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
		private const TAB_OTHER:String = "other";
		public static var assets	: AssetManager;
		public static var costumes	: Costumes;
		
		internal var character		: Character;
		internal var loadingSpinner:MovieClip;
		
		internal var shop			: RoundedRectangle;
		internal var shopTabs		: ShopTabContainer;
		internal var scaleSlider	: FancySlider;
		
		internal var button_hand	: PushButton;
		internal var button_back	: PushButton;
		internal var button_backHand: PushButton;
		
		internal var currentlyColoringType:String="";
		internal var configCurrentlyColoringType:String;
		
		internal var tabPanes:Array;
		internal var tabPanesMap:Object;
		internal var tabColorPane:TabPane;
		internal var configColorTabPane:TabPane;
		
		// Constructor
		public function Main()
		{
			super();
			
			assets = new AssetManager();
			assets.load([
				"resources/resources.swf",
				"resources/resources-other.swf"
			]);
			assets.addEventListener(AssetManager.LOADING_FINISHED, creatorLoaded);
			
			loadingSpinner = addChild( new $Loader() );
			loadingSpinner.x = 900 * 0.5;
			loadingSpinner.y = 425 * 0.5;
			loadingSpinner.scaleX = 2;
			loadingSpinner.scaleY = 2;
			
			stage.align = flash.display.StageAlign.TOP;
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			stage.frameRate = 10;
			
			addEventListener("enterFrame", this.Update);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}
		
		internal function creatorLoaded(event:Event):*
		{
			removeChild( loadingSpinner );
			loadingSpinner = null;
				
			costumes = new Costumes( assets );
			costumes.init();
			
			/****************************
			* Create Character
			*****************************/
			this.character = addChild(new Character({ x:180, y:375,
				skin:costumes.skins[costumes.defaultSkinIndex],
				pose:costumes.poses[costumes.defaultPoseIndex]
			}));
			
			/****************************
			* Setup UI
			*****************************/
			this.shop = addChild(new RoundedRectangle(450, 10, ConstantsApp.SHOP_WIDTH, ConstantsApp.APP_HEIGHT));//ShopTabContainer(450, 10, 440, ConstantsApp.APP_HEIGHT);
			this.shop.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 0x6A8fA2, 0x11171C, 0x324650);
			
			this.shopTabs = addChild(new ShopTabContainer(380, 10, 60, ConstantsApp.APP_HEIGHT));
			this.shopTabs.addEventListener(ConstantsApp.EVENT_SHOP_TAB_CLICKED, this.onTabClicked);
			
			// Toolbox
			var tools:RoundedRectangle = addChild(new RoundedRectangle(5, 10, 365, 35));
			tools.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 0x6A8fA2, 0x11171C, 0x324650);
			
			var btn:ButtonBase, tButtonSize = 28, tButtonSizeSpace=5;
			btn = tools.addChild(new SpriteButton({ x:tButtonSizeSpace, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.4, obj:new $LargeDownload(), id:1 }));
			btn.addEventListener(ButtonBase.CLICK, _onSaveClicked);
			
			btn = tools.addChild(new PushButton({ x:tButtonSizeSpace+(tButtonSize+tButtonSizeSpace), y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.4, obj:new $PlayButton(), id:1 }));
			btn.ToggleOn();
			btn.addEventListener(PushButton.STATE_CHANGED_AFTER, _onPlayerAnimationToggle);
			
			btn = tools.addChild(new SpriteButton({ x:tools.Width-tButtonSizeSpace-tButtonSize, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.35, obj:new $GitHubIcon(), id:1 }));
			btn.addEventListener(ButtonBase.CLICK, function():void { navigateToURL(new URLRequest(ConstantsApp.SOURCE_URL), "_blank");  });
			
			var tSliderWidth = 315 - (tButtonSize+tButtonSizeSpace)*2.5;
			this.scaleSlider = tools.addChild(new FancySlider({ x:tools.Width*0.5-tSliderWidth*0.5+(tButtonSize+tButtonSizeSpace)*0.5, y:tools.Height*0.5, value: character.outfit.scaleX*10, min:10, max:50, width:tSliderWidth }));
			this.scaleSlider.addEventListener(FancySlider.CHANGE, _onScaleSliderChange);
			
			/****************************
			* Create tabs and panes
			*****************************/
			this.tabPanes = new Array();
			this.tabPanesMap = new Object();
			
			tabColorPane = new ColorPickerTabPane({});
			tabColorPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tabColorPane.addEventListener(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked);
			tabColorPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);
			
			tabPanes.push( tabPanesMap["config"] = new ConfigTabPane(character) );
			tabPanesMap["config"].hairColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("hair", pEvent.target.id); });
			tabPanesMap["config"].skinColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("skin", pEvent.target.id); });
			tabPanesMap["config"].secondaryColorPickerButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _configColorButtonClicked("secondary", pEvent.target.id); });
			
			configColorTabPane = new ColorPickerTabPane({ hide_default:true });
			configColorTabPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onConfigColorPickChanged);
			configColorTabPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, function(pEvent:Event){ _selectTab(getTabByType("config")); });
			
			
			// Create the panes
			var tTypes = [ ITEM.OBJECT, ITEM.SKIN, ITEM.HAIR, ITEM.HEAD, ITEM.SHIRT, ITEM.PANTS, ITEM.SHOES, ITEM.POSE ];
			for(var i:int = 0; i < tTypes.length; i++) {
				tabPanes.push( tabPanesMap[tTypes[i]] = _setupPane(tTypes[i]) );
			}
			tTypes = null;
			// Select Default Skin
			tabPanesMap[ITEM.SKIN].infoBar.addInfo(costumes.skins[costumes.defaultSkinIndex], costumes.getItemImage(costumes.skins[costumes.defaultSkinIndex]));
			tabPanesMap[ITEM.SKIN].buttons[costumes.defaultSkinIndex].ToggleOn();
			// Select Default Pose
			tabPanesMap[ITEM.POSE].infoBar.addInfo(costumes.poses[costumes.defaultPoseIndex], costumes.getItemImage(costumes.poses[costumes.defaultPoseIndex]));
			tabPanesMap[ITEM.POSE].buttons[costumes.defaultPoseIndex].ToggleOn();
			
			// Select First Pane
			this.shop.addChild(tabPanes[0]).active = true;
		}
		
		private function _setupPane(pType:String) : TabPane {
			var tPane:TabPane = new TabPane(), isSkin:Boolean = pType == ITEM.SKIN, isPose:Boolean = pType == ITEM.POSE;
			_setupPaneButtons(tPane, costumes.getArrayByType(pType), function(pEvent){ if(isSkin) toggleItemSelectionSkin(pEvent.target); else if(isPose) toggleItemSelectionPose(pEvent.target); else toggleItemSelection(pType, pEvent.target, false); });
			tPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, function(){ _removeItem(pType); });
			tPane.infoBar.colorWheelEnabled = !isSkin && !isPose;
			return tPane;
		}
		
		private function _setupPaneButtons(pPane:TabPane, pItemArray:Array, pChangeListener:Function) : int {
			var tType:String = pItemArray[0].type;
			
			pPane.addInfoBar( new ShopInfoBar({}) );
			
			var xoff = 15;
			var yoff = 5;//15;
			var wCtr = 0;
			var w = 0;
			var h = 0;
			var i = 0;
			
			var radius = 60;
			var spacing = 65;
			var buttonPerRow = 6;
			var scale = 1;
			if(tType == ITEM.SKIN || tType == ITEM.POSE) {
					buttonPerRow = 4;
					var space = 5;
					radius = Math.floor((385 - (space * (buttonPerRow-1))) / buttonPerRow);
					spacing = radius + space;
					scale = 0.8;
			}
			
			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			while (i < pItemArray.length) 
			{
				shopItem = costumes.getItemImage(pItemArray[i]);
				if(tType == ITEM.SKIN && i == pItemArray.length-1) {
					shopItem = new MovieClip();
					var tText = shopItem.addChild(new TextField());
					tText.defaultTextFormat = new flash.text.TextFormat("Verdana", 15, 0xC2C2DA);
					tText.autoSize = flash.text.TextFieldAutoSize.CENTER;
					tText.text = "Invisible";
					tText.x = (shopItemButton.Width - tText.textWidth) * 0.5 - 2;
					tText.y = (shopItemButton.Height - tText.textHeight) * 0.5 - 2;
				}
				shopItem.scaleX = shopItem.scaleY = scale;
					
				shopItemButton = new PushButton({ x:xoff + spacing * w, y:yoff + spacing * h, width:radius, height:radius, obj:shopItem, id:i });
				pPane.addItem(shopItemButton);
				pPane.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, pChangeListener);
				++wCtr;
				++w;
				if (wCtr >= buttonPerRow) 
				{
					w = 0;
					wCtr = 0;
					++h;
				}
				++i;
			}
			pPane.UpdatePane();
			return h;
		}
		
		/****************************
		* Get Info
		*****************************/
			private function getCurItemID(pType:String) : int {
				return getTabByType(pType).selectedButton;
			}
			
			private function setCurItemID(pType:String, pID:int) : void {
				getTabByType(pType).selectedButton = pID;
			}
			
			private function getTabByType(pType:String) : TabPane {
				return tabPanesMap[pType];
			}
			
			private function getInfoBarByType(pType:String) : ShopInfoBar {
				return getTabByType(pType).infoBar;
			}
			
			private function getButtonArrayByType(pType:String) : Array {
				return getTabByType(pType).buttons;
			}
		
		/****************************
		* Events
		*****************************/
			private function Update(pEvent:Event):void
			{
				if(loadingSpinner != null) {
					loadingSpinner.rotation += 10;
				}
			}
			
			private function handleMouseWheel(pEvent:MouseEvent) : void {
				if(this.mouseX < this.shopTabs.x) {
					scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
					character.scale = scaleSlider.getValueAsScale();
				}
			}
			
			private function _onScaleSliderChange(pEvent:Event):void
			{
				character.scale = scaleSlider.getValueAsScale();
			}

			private function _onColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				
				this.character.colorItem(this.currentlyColoringType, this.tabColorPane.selectedSwatch, tVal.toString(16));
				var tItem:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tItem != null) {
					costumes.copyColor( tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
					costumes.copyColor(tItem, this.tabColorPane.infoBar.Image);
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
					costumes.copyColor(tMC, this.tabColorPane.infoBar.Image);
					this.tabColorPane.setupSwatches( this.character.getColors(this.currentlyColoringType) );
				}
			}
			
			private function _onColorPickerBackClicked(pEvent:Event):void {
				_selectTab( getTabByType( this.tabColorPane.infoBar.data.type ) );
			}
			
			private function _onPlayerAnimationToggle(pEvent:Event):void {
				character.animatePose = pEvent.target.Pushed;
				if(character.animatePose) {
					character.outfit.play();
				} else {
					character.outfit.stop();
				}
			}
			
			private function _onSaveClicked(pEvent:Event) : void {
				Main.costumes.saveMovieClipAsBitmap(this.character, "character");
			}
		
		function onTabClicked(pEvent:flash.events.DataEvent) : void {
			_selectTab( getTabByType(pEvent.data) );
		}
		
		private function toggleItemSelection(pType:String, pTarget:PushButton, pColorDefault:Boolean=false) : void {
			var tButton:PushButton = null;
			var tData:ItemData = null;
			var tItemArray:Array = costumes.getArrayByType(pType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButtons:Array = getButtonArrayByType(pType);
			var i:int=0;
			while (i < tButtons.length) 
			{
				tButton = tButtons[i] as PushButton;
				tData = tItemArray[tButton.id];
				
				if (tButton.id != pTarget.id) {
					if (tButton.Pushed)  { tButton.ToggleOff(); }
				}
				else if (tButton.Pushed) {
					setCurItemID(pType, tButton.id);
					this.character.addItem( pType, tData );
					
					//pTabButt.ChangeImage( costumes.copyColor(tButton.Image, new tData.itemClass()) );
					
					if(tInfoBar != null) {
						tInfoBar.addInfo( tData, costumes.copyColor(tButton.Image, costumes.getItemImage(tData)) );
						tInfoBar.colorWheelActive = costumes.getNumOfCustomColors(tButton.Image) > 0;
					}
					
					if(pColorDefault) { this.character.colorDefault(pType); }
				} else {
					this.character.removeItem(pType);
					//pTabButt.ChangeImage(new $Cadeau());
					
					if(tInfoBar != null) { tInfoBar.removeInfo(); }
				}
				i++ ;
			}
		}

		public function toggleItemSelectionSkin(pTarget:PushButton):void {
			var pType:String = ITEM.SKIN;
			var pInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButton:PushButton = null;
			var tToggleOnDefaultSkin:Boolean = false;
			
			var tData:ItemData = null;
			var tDataArray:Array = costumes.getArrayByType(pType);
			
			var tButtons:Array = getButtonArrayByType(pType);
			var i:int = 0;
			while (i < tButtons.length) {
				tButton = tButtons[i] as PushButton;
				tData = tDataArray[tButton.id];
				
				if (tButton.id != pTarget.id) {
					if (tButton.Pushed) {
						tButton.ToggleOff();
					}
				}
				else if (tButton.Pushed) {
					setCurItemID(pType, tButton.id);
					this.character.addItem( pType, tData );
					
					pInfoBar.addInfo( tData, costumes.getItemImage(tData) );
					pInfoBar.colorWheelActive = false;//tDataArray[tButton.id].id == -1;
				} else {
					tData = tDataArray[costumes.defaultSkinIndex];
					this.character.setItemData(pType, tData);
					getInfoBarByType(pType).addInfo( tData, costumes.getItemImage(tData) );
					tToggleOnDefaultSkin = true;
				}
				i++;
			}
			if(tToggleOnDefaultSkin) { tButtons[costumes.defaultSkinIndex].ToggleOn(); }
		}

		public function toggleItemSelectionPose(pTarget:PushButton):void {
			var pType:String = ITEM.POSE;
			var pInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButton:PushButton = null;
			var tToggleOnDefaultSkin:Boolean = false;
			
			var tData:ItemData = null;
			var tDataArray:Array = costumes.getArrayByType(pType);
			
			var tButtons:Array = getButtonArrayByType(pType);
			var i:int = 0;
			while (i < tButtons.length) {
				tButton = tButtons[i] as PushButton;
				tData = tDataArray[tButton.id];
				
				if (tButton.id != pTarget.id) {
					if (tButton.Pushed) {
						tButton.ToggleOff();
					}
				}
				else if (tButton.Pushed) {
					setCurItemID(pType, tButton.id);
					this.character.updatePose(tData.itemClass);
					
					pInfoBar.addInfo( tData, costumes.getItemImage(tData) );
					pInfoBar.colorWheelActive = false;
				} else {
					tData = tDataArray[costumes.defaultPoseIndex];
					this.character.setItemData(pType, tData);
					pInfoBar.addInfo( tData, costumes.getItemImage(tData) );
					tToggleOnDefaultSkin = true;
				}
				i++;
			}
			if(tToggleOnDefaultSkin) { tButtons[costumes.defaultPoseIndex].ToggleOn(); }
		}
		
		private function _removeItem(pType:String) : void {
			if(pType == ITEM.SKIN) { return removeSkinClicked(null); }
			if(pType == ITEM.POSE) { return removePoseClicked(null); }
			if(getInfoBarByType(pType).hasData == false) { return; }
			this.character.removeItem(pType);
			getInfoBarByType(pType).removeInfo();
			getButtonArrayByType(pType)[ getCurItemID(pType) ].ToggleOff();
		}
		public function removeSkinClicked(pEvent:Event):void {
			var tType = ITEM.SKIN;
			var tData = costumes.skins[costumes.defaultSkinIndex];
			var tTabPane = getTabByType(tType);
			
			this.character.setItemData(tType, tData);
			tTabPane.infoBar.addInfo( tData, costumes.getItemImage(tData) );
			tTabPane.buttons[getCurItemID(ITEM.SKIN)].ToggleOff();
			tTabPane.buttons[costumes.defaultSkinIndex].ToggleOn();
		}
		public function removePoseClicked(pEvent:Event):void {
			var tType = ITEM.POSE;
			var tData = costumes.poses[costumes.defaultPoseIndex];
			var tTabPane = getTabByType(tType);
			
			this.character.setItemData(tType, tData);
			tTabPane.infoBar.addInfo( tData, costumes.getItemImage(tData) );
			tTabPane.buttons[getCurItemID(ITEM.POSE)].ToggleOff();
			tTabPane.buttons[costumes.defaultPoseIndex].ToggleOn();
		}
		
		private function _selectTab(pTab:TabPane) : void {
			this.HideAllTabs();
			pTab.active = true;
			this.shop.addChild(pTab);
		}
		
		private function _hideTab(pTab:TabPane) : void {
			if(!pTab.active) { return; }
			
			pTab.active = false;
			try {
				this.shop.removeChild(pTab);
			} catch (e:Error) { };
		}

		public function HideAllTabs() : void
		{
			for(var i = 0; i < this.tabPanes.length; i++) {
				_hideTab(this.tabPanes[ i ]);
			}
			_hideTab(this.tabColorPane);
			_hideTab(this.configColorTabPane);
		}
		
		private function _colorButtonClicked(pType:String) : void {
			if(this.character.getItemFromIndex(pType) == null) { return; }
			if(getInfoBarByType(pType).colorWheelActive == false) { return; }
			
			this.HideAllTabs();
			this.tabColorPane.active = true;
			var tData:ItemData = getInfoBarByType(pType).data;
			this.tabColorPane.infoBar.addInfo( tData, costumes.copyColor(this.character.getItemFromIndex(pType), new tData.itemClass()) );
			this.currentlyColoringType = pType;
			this.tabColorPane.setupSwatches( this.character.getColors(pType) );
			this.shop.addChild(this.tabColorPane);
		}
		
		private function _configColorButtonClicked(pType:String, pColor:int) : void {
			this.HideAllTabs();
			this.configColorTabPane.active = true;
			
			this.configCurrentlyColoringType = pType;
			this.configColorTabPane.setupSwatches( [ pColor ] );
			this.shop.addChild(this.configColorTabPane);
		}
	}
}
