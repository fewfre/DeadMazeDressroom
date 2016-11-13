package dressroom.world.data
{
	import dressroom.data.*;
	import flash.display.*;
	import flash.geom.*;

	public class ItemData
	{
		public var id			: String;
		protected var _assetID	: String; // Actual ID, not display id.
		public var type			: String;
		public var sex			: String;
		public var itemClass	: Class;
		public var classMap		: Object;

		// pData = { id:String, type:String(ITEM), itemClass:Class, ?sex:String, ?classMap:String -> Class, ?assetID:String }
		public function ItemData(pData:Object) {
			super();
			id = pData.id;
			_assetID = pData.assetID != null ? pData.assetID : id;
			type = pData.type;
			sex = pData.sex;
			itemClass = pData.itemClass;
			classMap = pData.classMap;
		}
		
		// pOptions = { ?facingForward:Boolean=true, ?sex:SEX }
		public function getPart(pID:String, pOptions:Object=null) : Class {
			if(type != ITEM.OBJECT) {
				var facingForward = Main.costumes.facingForward;
				var sex = Main.costumes.sex;
				if(pOptions != null) {
					if(pOptions.facingForward) { facingForward = pOptions.facingForward; }
					if(pOptions.sex) { sex = pOptions.sex; }
				}
				var tSex = sex == SEX.MALE ? "_2" : "_1";
				var tFacing = facingForward ? "" : "_dos";
				
				var tClass = Main.assets.getLoadedClass( _assetID+"_"+pID+tFacing+tSex );
				return tClass;
			}
			return !classMap ? null : (classMap[pID] ? classMap[pID] : null);
		}
	}
}
