package app.data
{
	public class ItemType
	{
		public static const POSE       : ItemType = new ItemType("pose");
		public static const SKIN       : ItemType = new ItemType("skin");
		public static const HAIR       : ItemType = new ItemType("hair");
		public static const BEARD      : ItemType = new ItemType("beard");
		public static const FACE       : ItemType = new ItemType("face");
		public static const HEAD       : ItemType = new ItemType("head");
		public static const MASK       : ItemType = new ItemType("mask");
		public static const SHIRT      : ItemType = new ItemType("shirt");
		public static const PANTS      : ItemType = new ItemType("pants");
		public static const BELT       : ItemType = new ItemType("belt");
		public static const GLOVES     : ItemType = new ItemType("gloves");
		public static const SHOES      : ItemType = new ItemType("shoes");
		public static const BAG        : ItemType = new ItemType("bag");
		public static const OBJECT     : ItemType = new ItemType("object");
		
		public static const ALL : Vector.<ItemType> = new <ItemType>[
			POSE, SKIN, HAIR, BEARD, FACE, HEAD, MASK, SHIRT, PANTS, BELT, GLOVES, SHOES, BAG, OBJECT ];
		
		// Order of item layering when occupying the same spot.
		public static const LAYERING : Vector.<ItemType> = new <ItemType>[
			SKIN, FACE, BEARD, HAIR, SHIRT, MASK, HEAD, PANTS, BELT, GLOVES, BAG, SHOES, OBJECT ];
		
		// Certain layers require a different sort order
		public static const LAYERING_BY_LAYER	: Object = {
			TS: new <ItemType>[ SKIN, FACE, BEARD, HAIR, HEAD, SHIRT, MASK, PANTS, BELT, GLOVES, BAG, SHOES, OBJECT ]
		};
		
		// Which ones have panes, and the order the tabs appear in
		public static const TYPES_WITH_SHOP_PANES : Vector.<ItemType> = new <ItemType>[
			SKIN, FACE, HAIR, BEARD, HEAD, SHIRT, PANTS, SHOES, MASK, BELT, GLOVES, BAG, OBJECT, POSE ];
		
		// Enum Storage + Constructor
		private var _value: String;
		function ItemType(pValue:String) { _value = pValue }
		
		// This is required for proper auto string convertion on `trace`/`Dictionary` and such - enums should always have
		public function toString() : String { return _value.toString(); }
		public static function fromString(pValue:String) : ItemType {
			if(!pValue) return null;
			for each(var type:ItemType in ALL) {
				if(type.toString() == pValue) {
					return type;
				}
			}
			return null;
		}
	}
}
