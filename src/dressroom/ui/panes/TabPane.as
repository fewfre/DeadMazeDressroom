package dressroom.ui.panes
{
	import dressroom.data.*;
	import dressroom.ui.*;
	import dressroom.ui.buttons.*;
	import fl.containers.*;
	import flash.display.*;

	public class TabPane extends MovieClip
	{
		// Storage
		public var active : Boolean;
		public var infoBar : ShopInfoBar;
		public var buttons : Array;
		public var grid : Grid;
		public var selectedButtonIndex : int;

		protected var _scrollPane : ScrollPane;
		var content:MovieClip;
		var contentBack:MovieClip;//For scrollwheel to work, it has to hit a child element of the ScrollPane source.

		// Constructor
		public function TabPane() {
			super();
			active = false;
			infoBar = null;
			buttons = [];
			selectedButtonIndex = -1;
			this.content = new MovieClip();
			this.contentBack = addItem(new MovieClip());
		}

		public function addItem(pItem:Sprite) : Sprite {
			return this.content.addChild(pItem);
		}

		public function addInfoBar(pBar:ShopInfoBar) : void {
			this.infoBar = this.addChild(pBar);
		}

		public function addGrid(pGrid:Grid) : Grid {
			return this.grid = addItem(pGrid);
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
				_scrollPane = new fl.containers.ScrollPane();
				_scrollPane.setStyle("upSkin", tStyle);
				_scrollPane.setSize(ConstantsApp.PANE_WIDTH, 330);//350);
				_scrollPane.move(0, this.infoBar==null ? 0 : 60);
				_scrollPane.verticalLineScrollSize = 25;
				_scrollPane.verticalPageScrollSize = 25;
			}
			_scrollPane.source = this.content;

			addChild(_scrollPane);
		}
	}
}
