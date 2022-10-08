package app.ui.panes
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import fl.containers.ScrollPane;
	import flash.display.*;

	public class TabPane extends MovieClip
	{
		// Storage
		protected var _flagOpen : Boolean;
		protected var _flagDirty : Boolean;
		public var infoBar : ShopInfoBar;
		public var buttons : Array;
		public var grid : Grid;
		public var selectedButtonIndex : int;
		public var populateFunction : Function;

		protected var _scrollPane : ScrollPane;
		private var content:MovieClip;
		protected var contentBack:MovieClip;//For scrollwheel to work, it has to hit a child element of the ScrollPane source.
		
		// Properties
		public function get flagOpen() : Boolean { return _flagOpen; }
		
		// Constructor
		public function TabPane() {
			super();
			_flagOpen = false;
			_flagDirty = true;
			infoBar = null;
			buttons = [];
			selectedButtonIndex = -1;
			this.content = new MovieClip();
			this.contentBack = addItem(new MovieClip()) as MovieClip;
		}
		
		public function open() : void {
			_flagOpen = true;
			if(_flagDirty && populateFunction != null) {
				_flagDirty = false;
				populateFunction();
			}
		}
		
		public function close() : void {
			_flagOpen = false;
		}
		
		public function makeDirty() : void {
			_flagDirty = true;
		}

		public function addItem(pItem:Sprite) : Sprite {
			return this.content.addChild(pItem) as Sprite;
		}

		public function addItemDO(pItem:DisplayObject) : DisplayObject {
			return this.content.addChild(pItem) as DisplayObject;
		}

		public function removeItem(pItem:Sprite) : Sprite {
			return this.content.removeChild(pItem) as Sprite;
		}

		public function containsItem(pItem:DisplayObject) : Boolean {
			return this.content.contains(pItem);
		}

		public function addInfoBar(pBar:ShopInfoBar) : void {
			this.infoBar = this.addChild(pBar) as ShopInfoBar;
		}

		public function addGrid(pGrid:Grid) : Grid {
			return this.grid = addItem(pGrid) as Grid;
		}

		public function UpdatePane(pItemPane:Boolean=true) : void {
			this.x = 5;
			this.y = 5;//40;
			if (pItemPane)
			{
				contentBack.graphics.clear();
				contentBack.graphics.beginFill(0, 0);
				contentBack.graphics.drawRect(0, 0, this.content.width, this.content.height);
				contentBack.graphics.endFill();
			}
			var tStyle:*=new MovieClip();
			tStyle.graphics.clear();
			if(!_scrollPane) {
				_scrollPane = new ScrollPaneWithDragFix();
				_scrollPane.setStyle("upSkin", tStyle);
				_scrollPane.setSize(ConstantsApp.PANE_WIDTH, this.infoBar!=null ? 325 : 325+60);//350);
				_scrollPane.move(0, this.infoBar==null ? 0 : 60);
				_scrollPane.verticalLineScrollSize = 25;
				_scrollPane.verticalPageScrollSize = 25;
				_scrollPane.scrollDrag = true;
			}
			_scrollPane.source = this.content;

			addChild(_scrollPane);
		}
	}
}

import fl.containers.ScrollPane;
import flash.events.MouseEvent;
// https://stackoverflow.com/a/14332350/1411473
class ScrollPaneWithDragFix extends ScrollPane
{
    protected override function endDrag(event:MouseEvent):void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
        }
    }
}