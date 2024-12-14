package app.world
{
	import app.data.ItemType;
	import app.ui.panes.*;
	import app.ui.panes.base.*;
	import app.ui.panes.colorpicker.ColorPickerTabPane;

	public class WorldPaneManager extends PaneManager
	{
		// Pane IDs
		public static const COLOR_PANE:String = "colorPane";
		public static const COLOR_FINDER_PANE:String = "colorFinderPane";
		
		public static const CONFIG_COLOR_PANE:String = "configColorPane";
		public static const DYE_PANE:String = "colorDyePane";
		
		public static const CONFIG_PANE:String = "config";
		
		// Constructor
		public function WorldPaneManager() {
			super();
		}
		
		// ShopCategoryPane methods
		public function openShopPane(pType:ItemType) : ShopCategoryPane { return openPane(itemTypeToId(pType)) as ShopCategoryPane; }
		public function getShopPane(pType:ItemType) : ShopCategoryPane { return getPane(itemTypeToId(pType)) as ShopCategoryPane; }
		
		// Shortcuts to get panes with correct typing
		public function get colorPickerPane() : ColorPickerTabPane { return getPane(COLOR_PANE) as ColorPickerTabPane; }
		public function get configColorPickerPane() : ColorPickerTabPane { return getPane(CONFIG_COLOR_PANE) as ColorPickerTabPane; }
		public function get colorFinderPane() : ColorFinderPane { return getPane(COLOR_FINDER_PANE) as ColorFinderPane; }
		public function get dyePane() : DyePane { return getPane(DYE_PANE) as DyePane; }
		public function get configPane() : ConfigTabPane { return getPane(CONFIG_PANE) as ConfigTabPane; }
		
		
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function itemTypeToId(pType:ItemType) : String { return pType.toString(); }
	}
}