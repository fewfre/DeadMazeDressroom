package 
{
	import GUI.*;
	import GUI.panes.*;
	import GUI.buttons.*;
	import data.*;
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class Main extends MovieClip
	{
		// Settings
		private const _LOAD_LOCAL:Boolean = true;
		
		// Storage
		private const TAB_OTHER:String = "other";
		public static var assets	: AssetManager;
		public static var costumes	: Costumes;
		
		internal var character		: Character;
		internal var loadingSpinner:MovieClip;
		
		internal var shop			: RoundedRectangle;
		internal var shopTabs		: GUI.ShopTabContainer;
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
			btn.addEventListener(ButtonBase.CLICK, function():void { saveScreenshot(); });
			
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
			var tTypes = [ ItemType.OBJECT, ItemType.SKIN, ItemType.HAIR, ItemType.HEAD, ItemType.SHIRT, ItemType.PANTS, ItemType.SHOES, ItemType.POSE ];
			for(var i:int = 0; i < tTypes.length; i++) {
				tabPanes.push( tabPanesMap[tTypes[i]] = _setupPane(tTypes[i]) );
			}
			tTypes = null;
			// Select Default Skin
			tabPanesMap[ItemType.SKIN].infoBar.addInfo(costumes.skins[costumes.defaultSkinIndex], _getDefaultPoseSetup({ skin:costumes.skins[costumes.defaultSkinIndex], scale:"infobar" }));
			tabPanesMap[ItemType.SKIN].buttons[costumes.defaultSkinIndex].ToggleOn();
			// Select Default Pose
			tabPanesMap[ItemType.POSE].infoBar.addInfo(costumes.poses[costumes.defaultPoseIndex], _getDefaultPoseSetup({ pose:costumes.poses[costumes.defaultPoseIndex], scale:"infobar" }));
			tabPanesMap[ItemType.POSE].buttons[costumes.defaultPoseIndex].ToggleOn();
			
			// Select First Pane
			this.shop.addChild(tabPanes[0]).active = true;
		}
		
		private function _setupPane(pType:String) : TabPane {
			var tPane:TabPane = new TabPane(), isSkin:Boolean = pType == ItemType.SKIN, isPose:Boolean = pType == ItemType.POSE;
			_setupPaneButtons(tPane, costumes.getArrayByType(pType), function(pEvent){ if(isSkin) toggleItemSelectionSkin(pEvent.target); else if(isPose) toggleItemSelectionPose(pEvent.target); else toggleItemSelection(pType, pEvent.target, false); }, isSkin, isPose);
			tPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, function(){ _removeItem(pType); });
			tPane.infoBar.colorWheelEnabled = !isSkin && !isPose;
			return tPane;
		}
		
		private function _setupPaneButtons(pPane:TabPane, pItemArray:Array, pChangeListener:Function, pIsSkin:Boolean=false, pIsPose:Boolean=false) : int {
			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			
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
			if(pIsSkin || pIsPose) {
					buttonPerRow = 4;
					var space = 5;
					radius = Math.floor((385 - (space * (buttonPerRow-1))) / buttonPerRow);
					spacing = radius + space;
					scale = 0.8;
			}
			
			while (i < pItemArray.length) 
			{
				if(pIsSkin) {
					shopItem = _getDefaultPoseSetup({ skin:costumes.skins[i] });
				} else if(pIsPose) {
					shopItem = _getDefaultPoseSetup({ pose:costumes.poses[i] });
				} else {
					shopItem = new pItemArray[i].itemClass();
					costumes.colorDefault(shopItem);
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
		
		// pData = { pose:ShopItemData[optional], skin:SkinData[optional] }
		private function _getDefaultPoseSetup(pData:Object) : Pose {
			var tPoseData = pData.pose ? pData.pose : costumes.poses[costumes.defaultPoseIndex];
			var tSkinData = pData.skin ? pData.skin : costumes.skins[costumes.defaultSkinIndex];
			
			tPose = new Pose(tPoseData.itemClass);
			if(tSkinData.gender == GENDER.MALE) {
				tPose.apply({ skin:tSkinData, items:[
					costumes.shirts[1],
					costumes.pants[1],
					costumes.shoes[0]
				] });
			} else {
				tPose.apply({ skin:tSkinData, items:[
					costumes.shirts[0],
					costumes.pants[0],
					costumes.shoes[0]
				] });
			}
			tPose.stopAtLastFrame();
			
			if(pData.scale) {
				tPose.scaleX = tPose.scaleY = (pData.scale == "infobar" ? 0.6 : pData.scale);
			}
			
			return tPose;
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

		function saveScreenshot() : void
		{
			var tRect:flash.geom.Rectangle = this.character.getBounds(this.character);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(this.character.width, this.character.height, true, 16777215);
			tBitmap.draw(this.character, new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top));
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), "mouse.png" );
		}
		
		function onTabClicked(pEvent:flash.events.DataEvent) : void {
			_selectTab( getTabByType(pEvent.data) );
		}

		public function buttonHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.PAW, this.button_hand, costumes.hand);
		}

		public function buttonBackClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.BACK, this.button_back, costumes.fromage);
		}

		public function buttonBackHandClickAfter(pEvent:Event):void {
			toggleItemSelectionOneOff(ItemType.PAW_BACK, this.button_backHand, costumes.backHand);
		}
		
		private function toggleItemSelection(pType:String, pTarget:PushButton, pColorDefault:Boolean=false) : void {
			var tButton:PushButton = null;
			var tData:ShopItemData = null;
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
						tInfoBar.addInfo( tData, costumes.copyColor(tButton.Image, new tData.itemClass()) );
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
		
		private function toggleItemSelectionOneOff(pType:String, pButton:PushButton, pClass:Class) : void {
			if (pButton.Pushed) {
				this.character.addItem( pType, costumes.copyColor(pButton.Image, new pClass()) );
			} else {
				this.character.removeItem(pType);
			}
		}

		public function toggleItemSelectionSkin(pTarget:PushButton):void {
			var pType:String = ItemType.SKIN;
			var pInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButton:PushButton = null;
			var tToggleOnDefaultSkin:Boolean = false;
			
			var tData:ShopItemData = null;
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
					
					pInfoBar.addInfo( tData, _getDefaultPoseSetup({ skin:tData, scale:"infobar" }) );
					pInfoBar.colorWheelActive = false;//tDataArray[tButton.id].id == -1;
				} else {
					tData = tDataArray[costumes.defaultSkinIndex];
					this.character.setItemData(pType, tData);
					getInfoBarByType(pType).addInfo( tData, _getDefaultPoseSetup({ skin:tData, scale:"infobar" }) );
					tToggleOnDefaultSkin = true;
				}
				i++;
			}
			if(tToggleOnDefaultSkin) { tButtons[costumes.defaultSkinIndex].ToggleOn(); }
		}

		public function toggleItemSelectionPose(pTarget:PushButton):void {
			var pType:String = ItemType.POSE;
			var pInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButton:PushButton = null;
			var tToggleOnDefaultSkin:Boolean = false;
			
			var tData:ShopItemData = null;
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
					
					pInfoBar.addInfo( tData, _getDefaultPoseSetup({ pose:tData, scale:"infobar" }) );
					pInfoBar.colorWheelActive = false;
				} else {
					tData = tDataArray[costumes.defaultPoseIndex];
					this.character.setItemData(pType, tData);
					pInfoBar.addInfo( tData, _getDefaultPoseSetup({ pose:tData, scale:"infobar" }) );
					tToggleOnDefaultSkin = true;
				}
				i++;
			}
			if(tToggleOnDefaultSkin) { tButtons[costumes.defaultPoseIndex].ToggleOn(); }
		}
		
		private function _removeItem(pType:String) : void {
			if(pType == ItemType.SKIN) { return removeSkinClicked(null); }
			if(pType == ItemType.POSE) { return removePoseClicked(null); }
			if(getInfoBarByType(pType).hasData == false) { return; }
			this.character.removeItem(pType);
			getInfoBarByType(pType).removeInfo();
			getButtonArrayByType(pType)[ getCurItemID(pType) ].ToggleOff();
		}
		public function removeSkinClicked(pEvent:Event):void {
			var tType = ItemType.SKIN;
			var tData = costumes.skins[costumes.defaultSkinIndex];
			var tTabPane = getTabByType(tType);
			
			this.character.setItemData(tType, tData);
			tTabPane.infoBar.addInfo( tData, _getDefaultPoseSetup({ skin:tData, scale:"infobar" }) );
			tTabPane.buttons[getCurItemID(ItemType.SKIN)].ToggleOff();
			tTabPane.buttons[costumes.defaultSkinIndex].ToggleOn();
		}
		public function removePoseClicked(pEvent:Event):void {
			var tType = ItemType.POSE;
			var tData = costumes.poses[costumes.defaultPoseIndex];
			var tTabPane = getTabByType(tType);
			
			this.character.setItemData(tType, tData);
			tTabPane.infoBar.addInfo( tData, _getDefaultPoseSetup({ pose:tData, scale:"infobar" }) );
			tTabPane.buttons[getCurItemID(ItemType.POSE)].ToggleOff();
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
		
		private function getCurItemID(pType:String) : int {
			return getTabByType(pType).selectedButton;
		}
		
		private function setCurItemID(pType:String, pID:int) : void {
			getTabByType(pType).selectedButton = pID;
		}
		
		private function getTabByType(pType:String) : TabPane {
			return tabPanesMap[pType];
		}
		
		private function getInfoBarByType(pType:String) : GUI.ShopInfoBar {
			return getTabByType(pType).infoBar;
		}
		
		private function getButtonArrayByType(pType:String) : Array {
			return getTabByType(pType).buttons;
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
			var tData:ShopItemData = getInfoBarByType(pType).data;
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
