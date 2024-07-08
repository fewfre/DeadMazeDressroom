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
		public var type			: String;
		public var sex			: String;
		public var itemClass	: Class;
		public var classMap		: Object;
		public var stopFrame	: int;
		
		public var tags			: Vector.<String>;
		public var colorable	: Boolean;
		public var colorLastFrame: Boolean;
		public var color		: int;

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
			color = -1;
			colorLastFrame = true;
			colorable = _isColorable();
			tags = new Vector.<String>();
		}
		
		private function _isColorable() : Boolean {
			if(type == ITEM.HEAD || type == ITEM.SHIRT || type == ITEM.PANTS || type == ITEM.SHOES
			|| type == ITEM.MASK || type == ITEM.BELT || type == ITEM.GLOVES || type == ITEM.BAG) {
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
		
		// pOptions = { ?facingForward:Boolean=true, ?sex:SEX }
		public function getPart(pID:String, pOptions:Object=null) : Class {
			if(type != ITEM.OBJECT) {
				var facingForward = GameAssets.facingForward;
				var sex = GameAssets.sex;
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
