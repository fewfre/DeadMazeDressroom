package
{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.geom.*;
	
	public class Costumes
	{
		private const _MAX_COSTUMES_TO_CHECK_TO:Number = 999;
		
		public var assets:AssetManager;
		
		public var hair:Array;
		public var head:Array;
		public var shirts:Array;
		public var pants:Array;
		public var shoes:Array;
		public var objects:Array;
		
		public var skins:Array;
		public var poses:Array;
		
		public var defaultSkinIndex:int;
		public var defaultPoseIndex:int;
		
		public var skinColors:Array;
		public var hairColors:Array;
		public var secondaryColors:Array;
		
		public var sex:String;
		public var skinColor:int;
		public var hairColor:int;
		public var secondaryColor:int;
		
		public function Costumes(pAssets:AssetManager) {
			super();
			assets = pAssets;
			
			skinColors = [ 0xf5d3ae, 0xf3d9c1, 0xf9d28a, 0xf9d28a, 0xe0b484, 0xd3b18e, 0xd19a5e, 0x8a5a38, 0x4b3a2b, 0x563312 ];
			hairColors = [ 0x211e24, 0xdcb33a, 0xe98537, 0xe0ae5b, 0xf9d28a, 0xc16333, 0xe98537, 0xab6e37, 0x89541c, 0xf5d3ae ];
			secondaryColors = [ 0xf5ece5, 0x2a312a, 0x076586, 0x87475a, 0x8a5a38, 0xd63343, 0xe98537, 0xf6c549, 0x50a341, 0x7841a2, 0x13a4b7 ];
			
			sex = GENDER.FEMALE;
			skinColor = skinColors[0];
			hairColor = hairColors[0];
			secondaryColor = secondaryColors[0];
		}
		
		public function init() : Costumes {
			var i:int;
			var tSkinParts = [ "B", "JI1", "JI2", "JS1", "JS2", "P1", "P2", "M1", "M2", "BI1", "BI2", "BS1", "BS2", "TS", "T", "CH" ];
			
			this.hair = _setupCostumeArray({ base:"M_1", type:ItemType.HAIR, pad:3, after:"_", map:tSkinParts });
			this.head = _setupCostumeArray({ base:"M_2", type:ItemType.HEAD, pad:3, after:"_", map:tSkinParts });
			this.shirts = _setupCostumeArray({ base:"M_3", type:ItemType.SHIRT, pad:3, after:"_", map:tSkinParts, sex:true });
			this.pants = _setupCostumeArray({ base:"M_4", type:ItemType.PANTS, pad:3, after:"_", map:tSkinParts, sex:true });
			this.shoes = _setupCostumeArray({ base:"M_5", type:ItemType.SHOES, pad:3, after:"_", map:tSkinParts });
			this.objects = _setupCostumeArray({ base:"dmo_", type:ItemType.OBJECT });
			
			this.skins = new Array();
			
			for(i = 0; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(assets.getLoadedClass( "M_"+i+"_BS1_1" ) != null) {
					this.skins.push( new SkinData( i, GENDER.FEMALE ) );
				}
				if(assets.getLoadedClass( "M_"+i+"_BS1_2" ) != null) {
					this.skins.push( new SkinData( i, GENDER.MALE ) );
				}
			}
			this.defaultSkinIndex = 0;//getIndexFromArrayWithID(this.skins, ConstantsApp.DEFAULT_SKIN_ID);
			
			this.poses = [];
			var tPoseClasses = [ "Statique", "Statique2", "Pousse", "Mort", "Manipulation", "CourseArme", "Course", "Attaque1", "Attaque2", "Attaque3" ];
			for(i = 0; i < tPoseClasses.length; i++) {
				this.poses.push(new ShopItemData({ id:tPoseClasses[i], type:ItemType.POSE, itemClass:assets.getLoadedClass( "$Anim"+tPoseClasses[i] ) }));
			}
			this.defaultPoseIndex = 0;//getIndexFromArrayWithID(this.poses, ConstantsApp.DEFAULT_POSE_ID);
			
			return this;
		}
		
		// pData = { base:String, type:String, after:String, pad:int, map:Array, sex:Boolean }
		private function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(pData.map) {
					for(var g:int = 0; g < (pData.sex ? 2 : 1); g++) {
						var tClassMap = {  }, tClassSuccess = null;
						for(var j = 0; j <= pData.map.length; j++) {
							tClass = assets.getLoadedClass( tClassName = pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "")+pData.map[j] );
							if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; }
							else if(pData.sex){
								tClass = assets.getLoadedClass( tClassName+"_"+(g==0?1:2) );
								if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; }
							}
						}
						if(tClassSuccess) {
							tArray.push( new ShopItemData({ id:i, type:pData.type, classMap:tClassMap, itemClass:tClassSuccess }) );
						}
					}
				} else {
					tClass = assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
					if(tClass != null) {
						tArray.push( new ShopItemData({ id:i, type:pData.type, itemClass:tClass}) );
					}
				}
			}
			return tArray;
		}
		
		public function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}
		
		public function getArrayByType(pType:String) : Array {
			switch(pType) {
				case ItemType.HAIR:		return hair;
				case ItemType.HEAD:		return head;
				case ItemType.SHIRT:	return shirts;
				case ItemType.PANTS:	return pants;
				case ItemType.SHOES:	return shoes;
				case ItemType.OBJECT:	return objects;
				
				case ItemType.SKIN:		return skins;
				case ItemType.POSE:		return poses;
				default: trace("[Costumes](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}
		
		public function getItemFromTypeID(pType:String, pID:int) : ShopItemData {
			var tArray:Array = getArrayByType(pType);
			return tArray[getIndexFromArrayWithID(tArray, pID)];
		}
		
		public function getIndexFromArrayWithID(pArray:Array, pID:int) : int {
			for(var i = 0; i < pArray.length; i++) {
				if(pArray[i].id == pID) {
					return i;
				}
			}
			return null;
		}

		public function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return; }
			var tChild1:*=null;
			var tChild2:*=null;
			var i:int = 0;
			while (i < copyFromMC.numChildren) 
			{
				tChild1 = copyFromMC.getChildAt(i);
				tChild2 = copyToMC.getChildAt(i);
				if (tChild1.name.indexOf("Couleur") == 0 && tChild1.name.length > 7) 
				{
					tChild2.transform.colorTransform = tChild1.transform.colorTransform;
				}
				++i;
			}
			return copyToMC;
		}

		public function colorDefault(pMC:MovieClip) : MovieClip {
			if (pMC == null) { return; }
			
			var tChild:*=null;
			var tHex:int=0;
			var loc1:*=0;
			while (loc1 < pMC.numChildren) 
			{
				tChild = pMC.getChildAt(loc1);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) 
				{
					tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
					applyColorToObject(tChild, tHex);
				}
				++loc1;
			}
			return pMC;
		}
		
		// pData = { mc:DisplayObject, color:String OR int, swatch:int[optional], name:String[optional] }
		public function colorItem(pData:Object) : void {
			if (pData.mc == null) { return; }
			
			var tHex:int = pData.color is Number ? pData.color : int("0x" + pData.color);
			
			var tChild:DisplayObject;
			var i:int=0;
			while (i < pData.mc.numChildren) {
				tChild = pData.mc.getChildAt(i);
				if (tChild.name == pData.name || (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)) {
					if (!pData.swatch || pData.swatch == tChild.name.charAt(7)) {
						applyColorToObject(tChild, tHex);
					}
				}
				i++;
			}
		}
		
		// pColor is an int hex value. ex: 0x000000
		public function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}
		
		public function getNumOfCustomColors(pMC:MovieClip) : int {
			var tChild:*=null;
			var num:int = 0;
			var i:int = 0;
			while (i < pMC.numChildren) 
			{
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) 
				{
					num++;
				}
				++i;
			}
			return num;
		}
	}
}