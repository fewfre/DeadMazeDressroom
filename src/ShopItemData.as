package
{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.geom.*;
	
	public class ShopItemData
	{
		public var id:String;
		public var type:String;
		public var gender:String;
		public var itemClass:Class;
		public var itemClass2:Class; // Needed for the "back" of hair one.
		public var classMap:Object; // Needed for the "back" of hair one.
		
		// pData = { id:String, type:String, itemClass:Class, gender:String[optional], itemClass2:Class[optional], classMap:Object<Class>[optional] }
		public function ShopItemData(pData:Object) {
			super();
			id = pData.id;
			type = pData.type;
			gender = pData.gender;
			itemClass = pData.itemClass;
			itemClass2 = pData.itemClass2;
			classMap = pData.classMap;
		}
		
		public function getPart(pID:String) : Class {
			return !classMap ? MovieClip : (classMap[pID] ? classMap[pID] : MovieClip);
		}
	}
}