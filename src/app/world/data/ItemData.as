package app.world.data
{
	import com.fewfre.utils.Fewf;
	import app.data.*;
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
		public var stopFrame	: int;

		// pData = { id:String, type:String(ITEM), itemClass:Class, ?sex:String, ?classMap:String -> Class, ?assetID:String }
		public function ItemData(pData:Object) {
			super();
			id = pData.id;
			_assetID = pData.assetID != null ? pData.assetID : id;
			type = pData.type;
			sex = pData.sex;
			itemClass = pData.itemClass;
			classMap = pData.classMap;
			stopFrame = 1;
		}
		
		// pOptions = { ?facingForward:Boolean=true, ?sex:SEX }
		public function getPart(pID:String, pOptions:Object=null) : Class {
			if(type != ITEM.OBJECT) {
				var facingForward = Costumes.instance.facingForward;
				var sex = Costumes.instance.sex;
				if(pOptions != null) {
					if(pOptions.facingForward) { facingForward = pOptions.facingForward; }
					if(pOptions.sex) { sex = pOptions.sex; }
				}
				var tSex = sex == SEX.MALE ? "_2" : "_1";
				var tFacing = facingForward ? "" : "_dos";
				
				var tClass = Fewf.assets.getLoadedClass( _assetID+"_"+pID+tFacing+tSex );
				if(tClass == null) { tClass = Fewf.assets.getLoadedClass( _assetID+"_"+pID+tFacing ); }
				return tClass;
			}
			return !classMap ? null : (classMap[pID] ? classMap[pID] : null);
		}
	}
}
