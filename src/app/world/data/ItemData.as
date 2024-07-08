package app.world.data
{
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.display.MovieClip;

	public class ItemData
	{
		public var id			: String;
		protected var _assetID	: String; // Actual ID, not display id.
		public var type			: ItemType;
		public var sex			: String;
		public var itemClass	: Class;
		public var classMap		: Object;
		public var stopFrame	: int;
		
		public var tags			: Vector.<String>;
		public var colorable	: Boolean;
		public var colorLastFrame: Boolean;
		public var color		: int;

		// pData = { itemClass:Class, ?sex:Sex, ?classMap:String -> Class, ?assetID:String }
		public function ItemData(pType:ItemType, pId:String, pData:Object) {
			super();
			type = pType;
			id = pId;
			_assetID = pData.assetID != null ? pData.assetID : id;
			sex = pData.sex;
			itemClass = pData.itemClass;
			classMap = pData.classMap;
			stopFrame = 1;
			color = -1;
			colorLastFrame = true;
			colorable = _isColorable();
			tags = new Vector.<String>();
		}
		
		private function _isColorable() : Boolean {
			if(type == ItemType.HEAD || type == ItemType.SHIRT || type == ItemType.PANTS || type == ItemType.SHOES
			|| type == ItemType.MASK || type == ItemType.BELT || type == ItemType.GLOVES || type == ItemType.BAG) {
				if(classMap != null) {
					for(var i:String in classMap) {
						if(_partProvesItemIsColorable( new classMap[i]() )) { return true; }
					}
				} else {
					return _partProvesItemIsColorable( new itemClass() );
				}
			}
			return false;
		}
		private function _partProvesItemIsColorable(part:MovieClip) : Boolean {
			if(part.totalFrames > 1) {
				if(part.$2 != null) { colorLastFrame = false; return true; } // Items that use underwear color trigger this.
				part.gotoAndPlay(part.totalFrames);
				return part.$2 != null;
			}
			return false;
		}
		
		public function matches(compare:ItemData) : Boolean {
			return !!compare && type == compare.type && id == compare.id;
		}
		
		public function uniqId() : String {
			return this.type + '--' + this.id;
		}
		
		public function hasTag(tag:String) : Boolean {
			return tags.indexOf(tag) != -1
		}
		
		// pOptions = { ?facingForward:Boolean=true, ?sex:Sex }
		public function getPart(pID:String, pOptions:Object=null) : Class {
			if(type != ItemType.OBJECT) {
				var facingForward = GameAssets.facingForward;
				var sex = GameAssets.sex;
				if(pOptions != null) {
					if(pOptions.facingForward) { facingForward = pOptions.facingForward; }
					if(pOptions.sex) { sex = pOptions.sex; }
				}
				var tSex = sex == Sex.MALE ? "_2" : "_1";
				var tFacing = facingForward ? "" : "_dos";
				
				var tClass = Fewf.assets.getLoadedClass( _assetID+"_"+pID+tFacing+tSex );
				if(tClass == null) { tClass = Fewf.assets.getLoadedClass( _assetID+"_"+pID+tFacing ); }
				return tClass;
			}
			return !classMap ? null : (classMap[pID] ? classMap[pID] : null);
		}
	}
}
