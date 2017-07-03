package app.data
{
	import com.adobe.images.*;
	import com.fewfre.utils.*;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;

	public class Costumes
	{
		private static var _instance:Costumes;
		public static function get instance() : Costumes {
			if(!_instance) { _instance = new Costumes(); }
			return _instance;
		}
		
		private const _MAX_COSTUMES_TO_CHECK_TO:Number = 500;//999;
		
		public var faces:Array;
		public var hair:Array;
		public var head:Array;
		public var shirts:Array;
		public var pants:Array;
		public var shoes:Array;
		public var objects:Array;

		public var skins:Array;
		public var poses:Array;

		//public var defaultSkinIndex:int;
		//public var defaultPoseIndex:int;
		public function get defaultSkinIndex():int { return sex == SEX.MALE ? 0/*1*/ : 0; }
		public function get defaultPoseIndex():int { return sex == SEX.MALE ? 0/*1*/ : 0; }

		public var hairColors:Array;
		public var skinColors:Array;
		public var secondaryColors:Array;

		// Current
		public var sex:String;
		public var hairColor:int;
		public var skinColor:int;
		public var secondaryColor:int;
		public var facingForward:Boolean;

		/*public function get sexNum():String {
			return sex == SEX.MALE ? "_2" : "_1"; // Default to female
		}

		public function get sexChar():String {
			return sex == SEX.MALE ? "H" : "F"; // Default to female
		}*/

		public function Costumes() {
			if(_instance){ throw new Error("Singleton class; Call using Costumes.instance"); }
			
			hairColors = [ 0x211e24, 0xdcb33a, 0xe98537, 0xe0ae5b, 0xf9d28a, 0xc16333, 0xe98537, 0xab6e37, 0x89541c, 0xf5d3ae ];
			skinColors = [ 0xf5d3ae, 0xf3d9c1, 0xf9d28a, 0xf9d28a, 0xe0b484, 0xd3b18e, 0xd19a5e, 0x8a5a38, 0x4b3a2b, 0x563312 ];
			secondaryColors = [ 0xf5ece5, 0x2a312a, 0x076586, 0x87475a, 0x8a5a38, 0xd63343, 0xe98537, 0xf6c549, 0x50a341, 0x7841a2, 0x13a4b7 ];

			sex = SEX.FEMALE;
			skinColor = skinColors[0];
			hairColor = hairColors[0];
			secondaryColor = secondaryColors[0];
			facingForward = true;
			
			var i:int;
			var tSkinParts = [ "B", "JI1", "JI2", "JS1", "JS2", "P1", "P2", "M1", "M2", "BI1", "BI2", "BS1", "BS2", "TS", "T", "CH" ];

			this.hair = _setupCostumeArray({ base:"M_1", type:ITEM.HAIR, pad:4, after:"_", map:tSkinParts });
			this.head = _setupCostumeArray({ base:"M_2", type:ITEM.HEAD, pad:4, after:"_", map:tSkinParts });
			this.shirts = _setupCostumeArray({ base:"M_3", type:ITEM.SHIRT, pad:4, after:"_", map:tSkinParts, sex:true });
			this.pants = _setupCostumeArray({ base:"M_4", type:ITEM.PANTS, pad:4, after:"_", map:tSkinParts, sex:true });
			this.shoes = _setupCostumeArray({ base:"M_5", type:ITEM.SHOES, pad:4, after:"_", map:tSkinParts });
			this.faces = _setupCostumeArray({ base:"M_5", type:ITEM.FACE, pad:3, after:"_", map:tSkinParts, sex:true });
			this.objects = _setupCostumeArray({ base:"dmo_", type:ITEM.OBJECT, itemClassToClassMap:"_Arme" });

			this.skins = new Array();

			for(i = 0; i < _MAX_COSTUMES_TO_CHECK_TO; i++) {
				/*if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1_1" ) != null) {
					this.skins.push( new SkinData( i, SEX.FEMALE ) );
				}
				if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1_2" ) != null) {
					this.skins.push( new SkinData( i, SEX.MALE ) );
				}*/
				/*if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1_1" ) != null) {*/
				if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1" ) != null) {
					this.skins.push( new SkinData( i, null ) );
				}
			}
			this.skins.push( new SkinData( "inv", null ) );
			this.skins[this.skins.length-1].classMap = {};
			this.skins[this.skins.length-1].hair = new ItemData({ type:ITEM.HAIR, classMap:{} });
			/*this.defaultSkinIndex = 0;//FewfUtils.getIndexFromArrayWithKeyVal(this.skins, "id", ConstantsApp.DEFAULT_SKIN_ID);*/
			//this.defaultSkinIndexMale = 1;//FewfUtils.getIndexFromArrayWithKeyVal(this.skins, "id", ConstantsApp.DEFAULT_SKIN_ID);

			this.poses = [];
			var tPoseClasses = [
				"Statique",//_{0}",
				"Mort",//_{0}",
				"Manip",//_{0}",
				/*"Manger",//_{0}",*/
				"Course",//_{0}",
				"Stun",
				"Sort_1", "Sort_2",
				//"Combat_{0}",
				"Boire",//_{0}",
				/*"Attaque_{0}_1", "Attaque_{0}_2", "Attaque_{0}_3",*/
				"Attaque_1", "Attaque_2", "Attaque_3",
				/*"AttaqueMN_{0}_1", "AttaqueMN_{0}_2", "AttaqueMN_{0}_3",*/
				"AttaqueMN_1", "AttaqueMN_2", "AttaqueMN_3",
				"Arc",
				"Pistolet",
				
				"ZombieStatique",
				"ZombieMort",
				"ZombieCourse",
				"ZombieStun",
				"ZombieTouche",
				"ZombieAttaque",
			];
			var tClass:Class, tClassName:String;
			for(i = 0; i < tPoseClasses.length; i++) {
				/*if((tClass = Fewf.assets.getLoadedClass( "$Anim"+(tClassName=strReplace(tPoseClasses[i], "{0}", "F")) )) != null) {
					this.poses.push(new PoseData({ id:tClassName, type:ITEM.POSE, itemClass:tClass, sex:SEX.FEMALE }));
				}
				if((tClass = Fewf.assets.getLoadedClass( "$Anim"+(tClassName=strReplace(tPoseClasses[i], "{0}", "H")) )) != null) {
					this.poses.push(new PoseData({ id:tClassName, type:ITEM.POSE, itemClass:tClass, sex:SEX.MALE }));
				}*/
				/*if((tClass = Fewf.assets.getLoadedClass( "$Anim"+strReplace(tPoseClasses[i], "{0}", "F") )) != null) {*/
				if((tClass = Fewf.assets.getLoadedClass( "$Anim"+tPoseClasses[i] )) != null) {
					this.poses.push(new PoseData({ id:tPoseClasses[i], assetID:tPoseClasses[i], type:ITEM.POSE, itemClass:tClass, sex:null }));
				}
			}
			/*this.defaultPoseIndex = 0;//FewfUtils.getIndexFromArrayWithKeyVal(this.poses, "id", ConstantsApp.DEFAULT_POSE_ID);*/
			//this.defaultPoseIndexMale = 1;//FewfUtils.getIndexFromArrayWithKeyVal(this.poses, "id", ConstantsApp.DEFAULT_POSE_ID);
		}
		function strReplace(str:String, search:String, replace:String):String {
			return str.split(search).join(replace);
		}

		// pData = { base:String, type:String, after:String, pad:int, map:Array, sex:Boolean, itemClassToClassMap:String OR Array }
		private function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			var tSexSpecificParts:int;
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				if(pData.map) {
					for(var g:int = 0; g < (pData.sex ? 1/*2*/ : 1); g++) {
						var tClassMap = {  }, tClassSuccess = null;
						tSexSpecificParts = 0;
						for(var j = 0; j < pData.map.length; j++) {
							tClass = Fewf.assets.getLoadedClass( tClassName = pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "")+pData.map[j] );
							if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; }
							else if(pData.sex){
								tClass = Fewf.assets.getLoadedClass( tClassName+"_"+(g==0?1:2) );
								if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; tSexSpecificParts++; }
							}
						}
						if(tClassSuccess) {
							var tIsSexSpecific = pData.sex && tSexSpecificParts > 0;
							tArray.push( new ItemData({ id:i+(tIsSexSpecific ? ""/*(g==1 ? "M" : "F")*/ : ""), assetID:pData.base+(pData.pad ? zeroPad(i, pData.pad) : i), type:pData.type, classMap:tClassMap, itemClass:tClassSuccess, sex:(tIsSexSpecific ? null/*(g==1?SEX.MALE:SEX.FEMALE)*/ : null) }) );
						}
						if(tSexSpecificParts == 0) {
							break;
						}
					}
				} else {
					tClass = Fewf.assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
					if(tClass != null) {
						tArray.push( new ItemData({ id:i, type:pData.type, itemClass:tClass}) );
						if(pData.itemClassToClassMap) {
							tArray[tArray.length-1].classMap = {};
							if(pData.itemClassToClassMap is Array) {
								for(var c:int = 0; c < pData.itemClassToClassMap.length; c++) {
									tArray[tArray.length-1].classMap[pData.itemClassToClassMap[c]] = tClass;
								}
							} else {
								tArray[tArray.length-1].classMap[pData.itemClassToClassMap] = tClass;
							}
						}
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
				case ITEM.FACE:		return faces;
				case ITEM.HAIR:		return hair;
				case ITEM.HEAD:		return head;
				case ITEM.SHIRT:	return shirts;
				case ITEM.PANTS:	return pants;
				case ITEM.SHOES:	return shoes;
				case ITEM.OBJECT:	return objects;

				case ITEM.SKIN:		return skins;
				case ITEM.POSE:		return poses;
				default: trace("[Costumes](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}

		public function getItemFromTypeID(pType:String, pID:String) : ItemData {
			return FewfUtils.getFromArrayWithKeyVal(getArrayByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
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

			// pData = { obj:DisplayObject, color:String OR int, ?swatch:int, ?name:String }
			public function colorItem(pData:Object) : void {
				if (pData.obj == null) { return; }

				var tHex:int = pData.color is Number ? pData.color : int("0x" + pData.color);

				var tChild:DisplayObject;
				var i:int=0;
				while (i < pData.obj.numChildren) {
					tChild = pData.obj.getChildAt(i);
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

			public function getNumOfCustomColors(pMC:DisplayObject) : int {
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

		/****************************
		* Asset Creation
		*****************************/
			public function getItemImage(pData:ItemData) : MovieClip {
				var tItem:MovieClip;
				switch(pData.type) {
					case ITEM.SKIN:
						tItem = getDefaultPoseSetup({ skin:pData });
						break;
					case ITEM.POSE:
						tItem = getDefaultPoseSetup({ pose:pData });
						break;
					case ITEM.SHIRT:
					case ITEM.PANTS:
					case ITEM.SHOES:
					case ITEM.HAIR:
						tItem = new Pose(poses[defaultPoseIndex]).apply({ items:[ pData ], removeBlanks:true, facingForward:true });
						break;
					default:
						tItem = new pData.itemClass();
						colorDefault(tItem);
						break;
				}
				return tItem;
			}

			// pData = { ?pose:ItemData, ?skin:SkinData }
			public function getDefaultPoseSetup(pData:Object) : Pose {
				var tPoseData = pData.pose ? pData.pose : poses[defaultPoseIndex];
				var tSkinData = pData.skin ? pData.skin : skins[defaultSkinIndex];

				tPose = new Pose(tPoseData);
				/*if(tSkinData.sex == SEX.MALE) {
					tPose.apply({ items:[
						tSkinData,
						shirts[1],
						pants[1],
						shoes[0]
					] });
				} else {*/
					tPose.apply({ items:[
						tSkinData,
						shirts[0],
						pants[0],
						shoes[0],
						faces[0]
					], facingForward:true });
				/*}*/
				tPose.stopAtLastFrame();

				return tPose;
			}

		// Converts the image to a PNG bitmap and prompts the user to save.
		public function saveMovieClipAsBitmap(pObj:DisplayObject, pName:String="character", pScale:Number=1) : void
		{
			if(!pObj){ return; }

			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);

			tBitmap.draw(pObj, tMatrix);
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), pName+".png" );
		}
	}
}
