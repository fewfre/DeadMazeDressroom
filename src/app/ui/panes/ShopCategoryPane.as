package app.ui.panes
{	
	import app.data.ConstantsApp;
	import app.data.FavoriteItemsLocalStorageManager;
	import app.data.GameAssets;
	import app.data.ITEM;
	import app.ui.buttons.PushButton;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.common.FancyInput;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.world.data.ItemData;
	import app.world.events.ItemDataEvent;
	import com.fewfre.display.Grid;
	import com.fewfre.display.TextTranslated;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextFormat;
	import app.world.elements.Character;
	import app.data.ItemType;

	public class ShopCategoryPane extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _itemDataVector: Vector.<ItemData>;
		private var _character : Character;
		
		private var _flagWaveInput: FancyInput;
		public function get flagWaveInput() : FancyInput { return _flagWaveInput; }
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED'; // ItemDataEvent
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType, pCharacter:Character) {
			this._type = pType;
			this._character = pCharacter;
			var buttonPerRow:int = 6;
			if(_type == ItemType.SKIN || _type == ItemType.POSE) { buttonPerRow = 4; }
			super(buttonPerRow);
			
			// don't reverse by default for DeadMaze
			// grid.reverse();
			
			this.addInfobar( new Infobar({ showEyeDropper:_type!=ItemType.POSE, showDownload:true, showQualityButton:pType==ItemType.SHIRT||pType==ItemType.PANTS, gridManagement:true }) );
			
			// We don't want data added right away, add when pane opened
			// _setupGrid(GameAssets.getItemDataListByType(_type));
			makeDirty();
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		protected override function _onDirtyOpen() : void {
			_setupGrid(GameAssets.getItemDataListByType(_type))
			
			toggleOnButtonForCurrentData();
		}
		
		public function toggleOnButtonForCurrentData() : void {
			var tData:ItemData = _character.getItemData(_type);
			if(tData) {
				for(var b = 0; b < buttons.length; b++) {
					if((buttons[b].data.itemData as ItemData).matches(tData)) {
						buttons[b].toggleOn();
						break;
					}
				}
			}
			var cell:DisplayObject = getCellWithItemData(tData);
			if(_flagOpen && cell) scrollItemIntoView(cell);
			tData = null;
		}
		
		public function getCellWithItemData(itemData:ItemData) : DisplayObject {
			return !itemData ? null : FewfUtils.vectorFind(grid.cells, function(c:DisplayObject){ return itemData.matches(_findPushButtonInCell(c).data.itemData) });
		}
		
		public function getButtonWithItemData(itemData:ItemData) : PushButton {
			return _findPushButtonInCell(getCellWithItemData(itemData));
		}
		
		public function toggleGridButtonWithData(pData:ItemData, pScrollIntoView:Boolean=false) : PushButton {
			var cell:DisplayObject = getCellWithItemData(pData);
			if(cell) {
				var btn:PushButton = _findPushButtonInCell(cell);
				btn.toggleOn();
				if(pScrollIntoView && _flagOpen) scrollItemIntoView(cell);
				return btn;
			}
			return null;
		}
		
		public function chooseRandomItem() : void {
			var tLength = grid.cells.length;
			if(_type == ItemType.SKIN || _type == ItemType.FACE) { /* Don't select "invisible" */ tLength--; }
			var cell:DisplayObject = grid.cells[ Math.floor(Math.random() * tLength) ];
			var btn:PushButton = _findPushButtonInCell(cell);
			btn.toggleOn();
			if(_flagOpen) scrollItemIntoView(cell);
		}
		
		public function refreshButtonImage(pItemData:ItemData) : void {
			if(!pItemData || pItemData.type == ItemType.POSE) { return; }
			
			var btn:PushButton = this.getButtonWithItemData(pItemData);
			btn.ChangeImage(GameAssets.getColoredItemImage(pItemData));
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			if(pItemList == null || pItemList.length <= 0) { trace("[ShopCategoryPane](_setupGrid) Item vector is empty"); return; }
			_itemDataVector = pItemList;


			resetGrid();

			var scale = _type == ItemType.SKIN || _type == ItemType.POSE ? 0.8 : 1;
			for(var i:int = 0; i < pItemList.length; i++) {
				if(pItemList[i].sex != GameAssets.sex && pItemList[i].sex != null) { continue; }
				if(!GameAssets.showAll && pItemList[i].hasTag("extra")) { continue; }
				
				_addButton(pItemList[i], 1, i);
			}
			
			refreshScrollbox();
		}
		
		private function _addButton(itemData:ItemData, pScale:Number, i:int) : void {
			var shopItem : Sprite;
			if(itemData.hasTag('invisible')) {
				shopItem = new TextTranslated("skin_invisible", { size:15, color:0xC2C2DA });
			} else {
				shopItem = GameAssets.getItemImage(itemData);
				shopItem.scaleX = shopItem.scaleY = pScale;
			}
			var cell:Sprite = new Sprite();

			var shopItemButton:PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:shopItem, data:{ type:_type, itemID:itemData.id, data:itemData, itemData:itemData, index:buttons.length } }).appendTo(cell) as PushButton;
			// shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			
			_addGuitarFrameStepperIfNeeded(itemData, cell, shopItemButton);
			
			// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
			addToGrid(cell);
		}
		
		private function _addGuitarFrameStepperIfNeeded(itemData:ItemData, cell:Sprite, parentButton:PushButton) : void {
			if(_type != ItemType.OBJECT) { return; }
			if(!GameAssets.getItemFromTypeID(ItemType.OBJECT, "41").matches(itemData)) { return; }
			
			new ScaleButton({ obj:new $PlayButton(), obj_scale:0.5 }).move(50, 12).appendTo(cell)
			.onButtonClick(function():void{
				// Mod over total frame (note that frame go to 1 -> max frames, not 0 -> max frames-1)
				itemData.stopFrame++;
				itemData.stopFrame %= ((parentButton.Image as MovieClip).totalFrames+1);
				itemData.stopFrame = Math.max(itemData.stopFrame, 1);
				(parentButton.Image as MovieClip).gotoAndStop(itemData.stopFrame);
				// Toggle on at end to force infobar and stuff to rerender with new stopFrame
				parentButton.toggleOn();
			});
		}
		
		/****************************
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			super._onCellPushButtonToggled(e);
			dispatchEvent(new ItemDataEvent(ITEM_TOGGLED, e.data.itemData));
		}
	}
}
