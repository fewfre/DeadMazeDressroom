package 
{
	import GUI.*;
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
		internal var psColorPick	: com.piterwilson.utils.ColorPicker;
		public var scaleSlider		: fl.controls.Slider;
		
		internal var button_hand	: GUI.SpritePushButton;
		internal var button_back	: GUI.SpritePushButton;
		internal var button_backHand: GUI.SpritePushButton;
		
		internal var currentlyColoringType:String="";
		
		internal var selectedSwatch:int=0;
		internal var colorSwatches:Array;
		
		internal var tabPanes:Array;
		internal var tabPanesMap:Object;
		internal var tabColorPane:GUI.Tab;
		
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
			this.character = addChild(new Character({
				skin:costumes.skins[costumes.defaultSkinIndex],
				pose:costumes.poses[costumes.defaultPoseIndex]
			}));
			this.character.x = 180;
			this.character.y = 375;//180;
			this.character.scaleX = 1;
			this.character.scaleY = 1;
			
			/****************************
			* Setup UI
			*****************************/
			this.shop = addChild(new GUI.RoundedRectangle(450, 10, ConstantsApp.SHOP_WIDTH, ConstantsApp.APP_HEIGHT));//GUI.ShopTabContainer(450, 10, 440, ConstantsApp.APP_HEIGHT);
			this.shop.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 0x6A8fA2, 0x11171C, 0x324650);
			
			this.shopTabs = addChild(new GUI.ShopTabContainer(380, 10, 60, ConstantsApp.APP_HEIGHT));
			
			// Toolbox
			var tools:GUI.RoundedRectangle = addChild(new GUI.RoundedRectangle(5, 10, 365, 35));
			tools.drawSimpleGradient([ 0x112528, 0x1E3D42 ], 15, 0x6A8fA2, 0x11171C, 0x324650);
			
			var tButtonSize = 28;
			var btn:SpriteButton = tools.addChild(new SpriteButton(5, 4, tButtonSize, tButtonSize, new $LargeDownload(), 1));
			btn.doMouseover = true;
			btn.Image.scaleX = btn.Image.scaleY = 0.4;
			btn.addEventListener(flash.events.MouseEvent.MOUSE_UP, function():void { saveScreenshot(); });
			
			btn = tools.addChild(new SpriteButton(tools.Width-5-tButtonSize, 4, tButtonSize, tButtonSize, new $GitHubIcon(), 1));
			btn.doMouseover = true;
			btn.Image.scaleX = btn.Image.scaleY = 0.35;
			btn.addEventListener(flash.events.MouseEvent.MOUSE_UP, function():void { navigateToURL(new URLRequest("https://github.com/fewfre/DeadMazeDressroom"), "_blank");  });
			
			this.scaleSlider = tools.addChild(new fl.controls.Slider());
			this.__setProp_scaleSlider_Scene1_Layer1_0();
			this.scaleSlider.addEventListener(fl.events.SliderEvent.CHANGE, onSliderChange);
			this.scaleSlider.addEventListener(fl.events.SliderEvent.THUMB_DRAG, onSliderChange);
			this.scaleSlider.value = this.character.outfit.scaleX*10
			this.scaleSlider.width  = 250;
			this.scaleSlider.x = tools.Width*0.5-this.scaleSlider.width*0.5;
			this.scaleSlider.y = tools.Height*0.5;
			
			/****************************
			* Create tabs and panes
			*****************************/
			_setupColorPickerPane();
			
			this.shopTabs.addEventListener(ConstantsApp.EVENT_SHOP_TAB_CLICKED, this.onTabClicked);
			
			this.tabPanes = new Array();
			this.tabPanesMap = new Object();
			
			tabPanes.push( tabPanesMap["config"] = new GUI.ConfigTab(character) );
			
			
			// Create the panes
			var tTypes = [ ItemType.OBJECT, ItemType.SKIN, ItemType.HAIR, ItemType.HEAD, ItemType.SHIRT, ItemType.PANTS, ItemType.SHOES, ItemType.POSE ];
			for(var i:int = 0; i < tTypes.length; i++) {
				tabPanes.push( tabPanesMap[tTypes[i]] = _setupPane(tTypes[i]) );
			}
			tTypes = null;
			// Select Default Skin
			tabPanesMap[ItemType.SKIN].infoBar.addInfo(costumes.skins[costumes.defaultSkinIndex], new Skin( costumes.skins[costumes.defaultSkinIndex] ));
			tabPanesMap[ItemType.SKIN].buttons[costumes.defaultSkinIndex].ToggleOn();
			// Select Default Pose
			tabPanesMap[ItemType.POSE].infoBar.addInfo(costumes.poses[costumes.defaultPoseIndex], new MovieClip());
			tabPanesMap[ItemType.POSE].buttons[costumes.defaultPoseIndex].ToggleOn();
			
			// Select First Pane
			this.shop.addChild(tabPanes[0]).active = true;
		}
		
		private function _setupPane(pType:String) : GUI.Tab {
			var tPane:GUI.Tab = new GUI.Tab(), isFur:Boolean = pType == ItemType.SKIN, isPose:Boolean = pType == ItemType.POSE;
			_setupPaneButtons(tPane, costumes.getArrayByType(pType), function(pEvent){ if(isFur) toggleItemSelectionSkin(pEvent.target); else if(isPose) toggleItemSelectionPose(pEvent.target); else toggleItemSelection(pType, pEvent.target, false); }, isFur, isPose);
			tPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, function(){ _colorClicked(pType); });
			tPane.infoBar.imageCont.addEventListener(MouseEvent.MOUSE_UP, function(){ _removeItem(pType); });
			tPane.infoBar.colorWheelEnabled = !isFur && !isPose;
			return tPane;
		}
		
		private function _setupPaneButtons(pPane:GUI.Tab, pItemArray:Array, pChangeListener:Function, pIsFur:Boolean=false, pIsPose:Boolean=false) : int {
			var shopItem : MovieClip;
			var shopItemButton : GUI.SpritePushButton;
			
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
			if(pIsFur) {
					buttonPerRow = 5;
					var space = 5;
					radius = Math.floor((385 - (space * (buttonPerRow-1))) / buttonPerRow);
					spacing = radius + space;
					scale = 1.25;
			}
			
			while (i < pItemArray.length) 
			{
				if(pIsFur) {
					shopItem = new Skin(costumes.skins[i]);
					
				} else if(pIsPose) {
					shopItem = new MovieClip();//Skin(costumes.skins[i]);
					
				} else {
					shopItem = new pItemArray[i].itemClass();
					costumes.colorDefault(shopItem);
				}
				shopItem.scaleX = shopItem.scaleY = scale;
					
				shopItemButton = new GUI.SpritePushButton(xoff + spacing * w, yoff + spacing * h, radius, radius, shopItem, i);
				pPane.addItem(shopItemButton);
				pPane.buttons.push(shopItemButton);
				shopItemButton.addEventListener(SpritePushButton.STATE_CHANGED_AFTER, pChangeListener);
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
		
		private function _setupColorPickerPane() : void {
			this.tabColorPane = new GUI.Tab();
			this.tabColorPane.addInfoBar( new ShopInfoBar({ showBackButton:true }) );
			// this.tabColorPane.infoBar.colorWheelEnabled = false;
			this.tabColorPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, this.colorPickerBackClicked);
			
			this.psColorPick = new com.piterwilson.utils.ColorPicker();
			this.psColorPick.x = 105;
			this.psColorPick.y = 5;
			this.psColorPick.addEventListener(com.piterwilson.utils.ColorPicker.COLOR_PICKED, this.colorPickChanged);
			this.tabColorPane.addItem(this.psColorPick);
			
			colorSwatches = new Array();
			var swatch:GUI.ColorSwatch;
			for(var i:int = 0; i < 9; i++) {
				swatch = _createColorSwatch(i, 5, 45 + (i * 30));
				colorSwatches.push(swatch);
				this.tabColorPane.addItem(colorSwatches[i]);
			}
			
			var defaults_btn:GUI.Clickable;
			//defaults_btn = new GUI.Clickable(6, 325, 100, 22, "Defaults");
			defaults_btn = new GUI.Clickable(6, 10, 100, 22, "Defaults");
			defaults_btn.addEventListener("button_click", this.defaults_btnClicked);
			this.tabColorPane.addItem(defaults_btn);
			this.tabColorPane.UpdatePane(false);
		}
		
		private function _createColorSwatch(pNum:int, pX:int, pY:int) : GUI.ColorSwatch {
			var swatch:GUI.ColorSwatch = new GUI.ColorSwatch();
			swatch.addEventListener(GUI.ColorSwatch.ENTER_PRESSED, function(){ selectSwatch(pNum); });
			swatch.addEventListener(GUI.ColorSwatch.BUTTON_CLICK, function(){ selectSwatch(pNum); });
			swatch.x = pX;
			swatch.y = pY;
			return swatch;
		}
		
		/****************************
		* Events
		*****************************/
			function Update(pEvent:Event):void
			{
				if(loadingSpinner != null) {
					loadingSpinner.rotation += 10;
				}
			}
			
			function handleMouseWheel(pEvent:MouseEvent) : void {
				if(this.mouseX < this.shopTabs.x) {
					scaleSlider.value += pEvent.delta * 0.2;
					character.outfit.scaleX = scaleSlider.value*0.1;
					character.outfit.scaleY = scaleSlider.value*0.1;
				}
			}
			
			function onSliderChange(pEvent:Event):void
			{
				character.outfit.scaleX = scaleSlider.value*0.1;
				character.outfit.scaleY = scaleSlider.value*0.1;
			}

			function colorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				
				colorSwatches[this.selectedSwatch].Value = tVal;
				
				this.character.colorItem(this.currentlyColoringType, this.selectedSwatch, tVal.toString(16));
				var tItem:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tItem != null) {
					costumes.copyColor( tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
					costumes.copyColor(tItem, this.tabColorPane.infoBar.Image);
				}
				return;
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
		
		private function toggleItemSelection(pType:String, pTarget:GUI.SpritePushButton, pColorDefault:Boolean=false) : void {
			var tButton:GUI.SpritePushButton = null;
			var tData:ShopItemData = null;
			var tItemArray:Array = costumes.getArrayByType(pType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButtons:Array = getButtonArrayByType(pType);
			var i:int=0;
			while (i < tButtons.length) 
			{
				tButton = tButtons[i] as GUI.SpritePushButton;
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
		
		private function toggleItemSelectionOneOff(pType:String, pButton:GUI.SpritePushButton, pClass:Class) : void {
			if (pButton.Pushed) {
				this.character.addItem( pType, costumes.copyColor(pButton.Image, new pClass()) );
			} else {
				this.character.removeItem(pType);
			}
		}

		public function toggleItemSelectionSkin(pTarget:GUI.SpritePushButton):void {
			var pType:String = ItemType.SKIN;
			var pInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButton:GUI.SpritePushButton = null;
			var tToggleOnDefaultSkin:Boolean = false;
			
			var tData:ShopItemData = null;
			var tDataArray:Array = costumes.getArrayByType(pType);
			
			var tButtons:Array = getButtonArrayByType(pType);
			var i:int = 0;
			while (i < tButtons.length) {
				tButton = tButtons[i] as GUI.SpritePushButton;
				tData = tDataArray[tButton.id];
				
				if (tButton.id != pTarget.id) {
					if (tButton.Pushed) {
						tButton.ToggleOff();
					}
				}
				else if (tButton.Pushed) {
					setCurItemID(pType, tButton.id);
					this.character.addItem( pType, tData );
					
					pInfoBar.addInfo( tData, new Skin(tData) );
					pInfoBar.colorWheelActive = false;//tDataArray[tButton.id].id == -1;
				} else {
					this.character.setSkin(tDataArray[costumes.defaultSkinIndex]);
					getInfoBarByType(pType).addInfo( tDataArray[costumes.defaultSkinIndex], new Skin(tDataArray[costumes.defaultSkinIndex]) );
					tToggleOnDefaultSkin = true;
				}
				i++;
			}
			if(tToggleOnDefaultSkin) { tButtons[costumes.defaultSkinIndex].ToggleOn(); }
		}

		public function toggleItemSelectionPose(pTarget:GUI.SpritePushButton):void {
			var pType:String = ItemType.POSE;
			var pInfoBar:ShopInfoBar = getInfoBarByType(pType);
			
			var tButton:GUI.SpritePushButton = null;
			var tToggleOnDefaultSkin:Boolean = false;
			
			var tData:ShopItemData = null;
			var tDataArray:Array = costumes.getArrayByType(pType);
			
			var tButtons:Array = getButtonArrayByType(pType);
			var i:int = 0;
			while (i < tButtons.length) {
				tButton = tButtons[i] as GUI.SpritePushButton;
				tData = tDataArray[tButton.id];
				
				if (tButton.id != pTarget.id) {
					if (tButton.Pushed) {
						tButton.ToggleOff();
					}
				}
				else if (tButton.Pushed) {
					setCurItemID(pType, tButton.id);
					this.character.updatePose(tData.itemClass);
					
					pInfoBar.addInfo( tData, new MovieClip() );
					pInfoBar.colorWheelActive = false;
				} else {
					this.character.updatePose(tDataArray[costumes.defaultPoseIndex].itemClass);
					pInfoBar.addInfo( tDataArray[costumes.defaultPoseIndex], new MovieClip() );
					tToggleOnDefaultSkin = true;
				}
				i++;
			}
			if(tToggleOnDefaultSkin) { tButtons[costumes.defaultPoseIndex].ToggleOn(); }
		}
		
		private function _removeItem(pType:String) : void {
			if(pType == ItemType.SKIN) { return removeFurClicked(null); }
			if(pType == ItemType.POSE) { return removePoseClicked(null); }
			if(getInfoBarByType(pType).hasData == false) { return; }
			this.character.removeItem(pType);
			getInfoBarByType(pType).removeInfo();
			getButtonArrayByType(pType)[ getCurItemID(pType) ].ToggleOff();
		}
		public function removeFurClicked(pEvent:Event):void {
			this.character.setSkin(costumes.defaultSkinIndex);
			getInfoBarByType(ItemType.SKIN).addInfo( costumes.skins[costumes.defaultSkinIndex], new Skin(costumes.skins[costumes.defaultSkinIndex]) );
			getButtonArrayByType(ItemType.SKIN)[ getCurItemID(ItemType.SKIN) ].ToggleOff();
			getButtonArrayByType(ItemType.SKIN)[costumes.defaultSkinIndex].ToggleOn();
		}
		public function removePoseClicked(pEvent:Event):void {
			this.character.setSkin(costumes.defaultPoseIndex);
			getInfoBarByType(ItemType.POSE).addInfo( costumes.poses[costumes.defaultPoseIndex], new Skin(costumes.poses[costumes.defaultPoseIndex]) );
			getButtonArrayByType(ItemType.POSE)[ getCurItemID(ItemType.POSE) ].ToggleOff();
			getButtonArrayByType(ItemType.POSE)[costumes.defaultPoseIndex].ToggleOn();
		}
		
		private function _selectTab(pTab:GUI.Tab) : void {
			this.HideAllTabs();
			pTab.active = true;
			this.shop.addChild(pTab);
		}
		
		private function _hideTab(pTab:GUI.Tab) : void {
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
		
		private function getTabByType(pType:String) : GUI.Tab {
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
		}
		
		/****************************
		* Color Picker Stuff
		*****************************/
			internal function setupSwatches(pSwatches:Array):*
			{
				var tLength:int = pSwatches.length;
				
				for(var i = 0; i < colorSwatches.length; i++) {
					colorSwatches[i].alpha = 0;
					
					if (tLength > i) {
						this.colorSwatches[i].alpha = 1;
						this.colorSwatches[i].Value = pSwatches[i];
						if (this.selectedSwatch == i) {
							this.psColorPick.setCursor(this.colorSwatches[i].TextValue);
						}
					}
				}
				if (tLength > 9) {
					trace("!!! more than 9 colors !!!");
				}
			}
			
			private function _colorClicked(pType:String) : void {
				if(this.character.getItemFromIndex(pType) == null) { return; }
				if(getInfoBarByType(pType).colorWheelActive == false) { return; }
				
				this.selectSwatch(0, false);
				this.HideAllTabs();
				this.tabColorPane.active = true;
				var tData:ShopItemData = getInfoBarByType(pType).data;
				this.tabColorPane.infoBar.addInfo( tData, costumes.copyColor(this.character.getItemFromIndex(pType), new tData.itemClass()) );
				this.currentlyColoringType = pType;
				this.setupSwatches( this.character.getColors(pType) );
				this.shop.addChild(this.tabColorPane);
			}

			internal function defaults_btnClicked(pEvent:Event) : void
			{
				var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null) 
				{
					costumes.colorDefault(tMC);
					costumes.copyColor( tMC, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					costumes.copyColor(tMC, getInfoBarByType(this.currentlyColoringType).Image);
					costumes.copyColor(tMC, this.tabColorPane.infoBar.Image);
					this.setupSwatches( this.character.getColors(this.currentlyColoringType) );
				}
			}
			
			function colorPickerBackClicked(pEvent:Event):void {
				_selectTab( getTabByType( this.tabColorPane.infoBar.data.type ) );
			}
			
			internal function selectSwatch(pNum:int, pSetCursor:Boolean=true) : void {
				for(var i = 0; i < colorSwatches.length; i++) {
					colorSwatches[i].unselect();
				}
				this.selectedSwatch = pNum;
				colorSwatches[pNum].select();
				if(pSetCursor) { this.psColorPick.setCursor(this.colorSwatches[pNum].TextValue); }
			}
		
		internal function __setProp_scaleSlider_Scene1_Layer1_0():*
		{
			try {
				this.scaleSlider["componentInspectorSetting"] = true;
			}
			catch (e:Error) { };
			
			this.scaleSlider.direction = "horizontal";
			this.scaleSlider.enabled = true;
			this.scaleSlider.liveDragging = false;
			this.scaleSlider.maximum = 50;
			this.scaleSlider.minimum = 10;
			this.scaleSlider.snapInterval = 0;
			this.scaleSlider.tickInterval = 0;
			//this.scaleSlider.value = 6;
			this.scaleSlider.visible = true;
			
			try {
				this.scaleSlider["componentInspectorSetting"] = false;
			}
			catch (e:Error) { };
		}
	}
}
