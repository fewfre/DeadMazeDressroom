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
	import flash.utils.setTimeout;
	import flash.display.MovieClip;

	public class GameAssets
	{
		private static const _CHECK_DEFAULT:Number = 125;
		private static const _CHECK_HAIR:Number = 100;
		private static const _CHECK_MISC:Number = 50;
		private static const _CHECK_SURVIVOR:Number = 20;
		private static const _CHECK_SKINS:Number = 5;
		private static const _CHECK_OBJECTS:Number = 999;
		
		public static var faces:Array;
		public static var hair:Array;
		public static var beards:Array;
		public static var head:Array;
		public static var masks:Array;
		public static var shirts:Array;
		public static var pants:Array;
		public static var belts:Array;
		public static var gloves:Array;
		public static var shoes:Array;
		public static var bags:Array;
		public static var objects:Array;

		public static var skins:Array;
		public static var poses:Array;

		//public static var defaultSkinIndex:int;
		//public static var defaultPoseIndex:int;
		public static function get defaultSkinIndex():int { return 0; sex == SEX.MALE ? 1 : 0; }
		public static function get defaultPoseIndex():int { return 0; }//sex == SEX.MALE ? 1 : 0; }
		public static function get defaultFaceIndex():int { return sex == SEX.MALE ? 1 : 0; }

		public static var hairColors:Array;
		public static var skinColors:Array;
		public static var secondaryColors:Array;

		// Current
		public static var sex:String;
		public static var hairColor:int;
		public static var skinColor:int;
		public static var secondaryColor:int;
		public static var facingForward:Boolean;
		public static var tornStates:Object; // ITEM Ossoc array that contains a boolean about clothing's torn state. False by default
		
		public static var showAll:Boolean = false;

		/*public static function get sexNum():String {
			return sex == SEX.MALE ? "_2" : "_1"; // Default to female
		}

		public static function get sexChar():String {
			return sex == SEX.MALE ? "H" : "F"; // Default to female
		}*/

		public static function init(pCallback:Function) : void {
			// hairColors = [ 0x211e24, 0xdcb33a, 0xe98537, 0xe0ae5b, 0xf9d28a, 0xc16333, 0xe98537, 0xab6e37, 0x89541c, 0xf5d3ae ];
			hairColors = [
				0xd64f0d, 0xddb43b, 0xab2009, 0x597817,
				0xeaa3b7, 0xd16382, 0x458f6a, 0x5d5a88,
				0xa3cedc, 0xfff99b, 0x282828, 0x19202f,
				0xe08637, 0xe0ae5b, 0xfed78c, 0xac703b,
				0xc16234, 0xf6883d, 0x86521c, 0xdfceaf
			];
			// skinColors = [ 0xf5d3ae, 0xf3d9c1, 0xf9d28a, 0xf9d28a, 0xe0b484, 0xd3b18e, 0xd19a5e, 0x8a5a38, 0x4b3a2b, 0x563312 ];
			skinColors = [ 0xf6d4af, 0xf5dac0, 0xf8da8a, 0xf6c88a, 0xe0b484, 0xd6b392, 0xd19a5e, 0x935d37, 0x503d2a, 0x573719 ];
			// secondaryColors = [ 0xf5ece5, 0x2a312a, 0x076586, 0x87475a, 0x8a5a38, 0xd63343, 0xe98537, 0xf6c549, 0x50a341, 0x7841a2, 0x13a4b7 ];
			secondaryColors = [ 0xebebeb, 0x303030, 0x206075, 0x87465b, 0x81583e, 0xd63343, 0xe88133, 0xf6c549, 0x4ca241, 0x7841a2, 0x13a4b8 ];
			tornStates = {}; tornStates[ITEM.PANTS] = false; tornStates[ITEM.SHIRT] = false;
			
			sex = SEX.FEMALE;
			skinColor = skinColors[0];
			hairColor = hairColors[0];
			secondaryColor = secondaryColors[0];
			facingForward = true;
			
			var i:int;
			var tSkinParts = [ "B", "JI1", "JI2", "JS1", "JS2", "P1", "P2", "M1", "M2", "BI1", "BI2", "BS1", "BS2", "TS", "T", "C", "CH", "SAC1", "SAC2", "MZ1", "MZ2" ];
			
			var tFlowFunctions = [
				function(){
					hair = _setupCostumeArray({ base:"M_1", type:ITEM.HAIR, pad:4, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_HAIR });
				},
				function(){
					head = _setupCostumeArray({ base:"M_2", type:ITEM.HEAD, pad:4, after:"_", map:tSkinParts, sex:true });
				},
				function(){
					shirts = _setupCostumeArray({ base:"M_3", type:ITEM.SHIRT, pad:4, after:"_", map:tSkinParts, sex:true });
				},
				function(){
					pants = _setupCostumeArray({ base:"M_4", type:ITEM.PANTS, pad:4, after:"_", map:tSkinParts, sex:true });
				},
				function(){
					shoes = _setupCostumeArray({ base:"M_5", type:ITEM.SHOES, pad:4, after:"_", map:tSkinParts, sex:true });
				},
				function(){
					faces = _setupCostumeArray({ base:"M_5", type:ITEM.FACE, pad:3, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_MISC });
					faces.push( new ItemData({ type:ITEM.FACE, classMap:{} }) );
				},
				function(){
					beards = _setupCostumeArray({ base:"M_7", type:ITEM.BEARD, pad:3, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_MISC });
				},
				function(){
					masks = _setupCostumeArray({ base:"M_17", type:ITEM.MASK, pad:3, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_SURVIVOR });
					masks = masks.concat(_setupCostumeArray({ base:"M_34", type:ITEM.MASK, pad:3, after:"_", map:tSkinParts, sex:true, idPrefix:"nk", numToCheck:_CHECK_SURVIVOR }));
				},
				function(){
					bags = _setupCostumeArray({ base:"M_35", type:ITEM.BAG, pad:3, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_SURVIVOR });
				},
				function(){
					gloves = _setupCostumeArray({ base:"M_37", type:ITEM.GLOVES, pad:3, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_SURVIVOR });
				},
				function(){
					belts = _setupCostumeArray({ base:"M_45", type:ITEM.BELT, pad:3, after:"_", map:tSkinParts, sex:true, numToCheck:_CHECK_SURVIVOR });
				},
				function(){
					objects = _setupCostumeArray({ base:"dmo_", type:ITEM.OBJECT, itemClassToClassMap:"_Arme", numToCheck:_CHECK_OBJECTS });
				},
				function(){
					skins = new Array();
					for(i = 0; i < _CHECK_SKINS; i++) {
						/*if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1_1" ) != null) {
							skins.push( new SkinData( i, SEX.FEMALE ) );
						}
						if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1_2" ) != null) {
							skins.push( new SkinData( i, SEX.MALE ) );
						}*/
						/*if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1_1" ) != null) {*/
						if(Fewf.assets.getLoadedClass( "M_"+i+"_BS1" ) != null) {
							skins.push( new SkinData( String(i), null ) );
						}
					}
					skins.push( new SkinData( "inv", null ) );
					skins[skins.length-1].classMap = {};
					skins[skins.length-1].hair = new ItemData({ type:ITEM.HAIR, classMap:{} });
					/*defaultSkinIndex = 0;//FewfUtils.getIndexFromArrayWithKeyVal(skins, "id", ConstantsApp.DEFAULT_SKIN_ID);*/
					//defaultSkinIndexMale = 1;//FewfUtils.getIndexFromArrayWithKeyVal(skins, "id", ConstantsApp.DEFAULT_SKIN_ID);
				},
				function(){
					poses = [];
					var tPoseClasses = [
						"Statique",
						"Course",
						"Stun",
						"Esquive",
						"Feinte",
						"Mort",
						"Mort_retraite",
						"Manip",
						"ManipComp",
						"Sort_1", "Sort_2",
						
						"Emote1",
						"Emote2",
						"Emote3",
						"Emote3transition",
						"Emote4",
						"Emote5",
						"Emote6",
						"Emote7",
						"Emote8",
						"Emote9",
						"Emote10",
						"Emote11",
						"Emote12",
						
						"AttaqueComp",
						"AttaqueNormal_1", "AttaqueNormal_2",
						"AttaqueMN_1", "AttaqueMN_2", "AttaqueMN_3",
						"AttaqueLente_1",
						"AttaquePique_1", "AttaquePique_2",
						"Parade1_1", "Parade1_2",
						"Parade2_1", "Parade2_2",
						"Parade3_1", "Parade3_2",
						"Parade4_1", "Parade4_2",
						"Statique/Combat",
						"Statique/Defensif",
						"Arc",
						"Pistolet",
						"Lancer",
						"$Molotov",
						
						"$EnJoue",
						"$EnJoue2",
						"$EnJouePistolet",
						"$EnJouePistolet2",
						
						/* "$Camp1",
						"$Camp2",
						"$Camp3",
						"$Camp4", */
						
						"Statique/Camp1",
						"Statique/Camp2",
						"Statique/Camp3",
						"Statique/Camp4",
						
						"$Cendre",
						
						//####### Zombies #######
						"ZombieStatique",
						"ZombieStatique/2",
						"ZombieStatique/3",
						"ZombieStatique/4",
						"ZombieStatique/5",
						
						"ZombieCourse",
						"ZombieCourse/2",
						"ZombieCourse/3",
						"ZombieCourse/4",
						"ZombieCourse/5",
						
						"ZombieMort",
						"ZombieMort/2",
						"ZombieStun",
						"ZombieStun/2",
						"ZombieSort_1",
						"ZombieEsquive",
						
						"ZombieTouche",
						"ZombieTouche/2",
						"ZombieTouche/3",
						
						"ZombieAttaque",
						"ZombieAttaque/2",
						"ZombieAttaque/3",
						"ZombieAttaque/4",
						"ZombieAttaque/5",
						
						//####### NPCs #######
						"AttaqueLente_1/Jay",
						"AttaqueNormal_1/ChloeCombat",
						"AttaqueNormal_1/Jay",
						"AttaqueNormal_1/JayBlesse",
						"AttaqueNormal_1/JayBlesseCombo",
						"AttaqueNormal_2/ChloeCombat",
						"AttaqueNormal_2/Jay",
						
						"Course/Blesse",
						"Course/BrasCroiseMarche",
						"Course/Chloe",
						"Course/ChloeBlessee",
						"Course/ChloeCombat",
						"Course/ChloePieton",
						"Course/FusilMarche",
						"Course/Jay",
						"Course/JayBlesse",
						"Course/JayMarche",
						"Course/Karen",
						"Course/Murphy",
						"Course/Pieton",
						
						"Esquive/JayBlesse",
						
						"Manip/Chloe",
						
						"Mort/Chloe",
						"Mort/Jay",
						
						"Statique/Bequilles",
						"Statique/Blesse",
						"Statique/BlesseAssis",
						"Statique/Carte1",
						"Statique/Carte2",
						"Statique/ChefScientifique",
						"Statique/Chloe",
						"Statique/ChloeBlessee",
						"Statique/ChloeBlesseeAssise",
						"Statique/ChloeCombat",
						"Statique/ChloeCroise",
						"Statique/ChloeCrossee",
						"Statique/ChloePousse",
						"Statique/EnJouePistolet",
						"Statique/Fusil",
						"Statique/Fusil2",
						"Statique/Fusil3",
						"Statique/Fusil4",
						"Statique/Fusil5",
						"Statique/Gary",
						"Statique/Hache",
						"Statique/Jared",
						"Statique/Jay",
						"Statique/JayBlesse",
						"Statique/JayCroise",
						"Statique/JayMort",
						"Statique/Karen",
						"Statique/Lynn",
						"Statique/Manip",
						"Statique/ManipGenou",
						"Statique/Mannequin",
						"Statique/Manuel",
						"Statique/ManuelHache",
						"Statique/Marchand",
						"Statique/Marchand2",
						"Statique/Murphy",
						"Statique/MurphyAccoudee",
						"Statique/MurphyDebout",
						"Statique/MurphyDebout2",
						"Statique/Peur",
						"Statique/Pistolet",
						"Statique/Planque",
						"Statique/PrepCombat",
						"Statique/PrepCombatHache",
						"Statique/Quete",
						"Statique/Statique2",
						"Statique/Statique3",
						"Statique/Statique4",
						"Statique/Statique5",
						"Statique/Statique6",
						"Statique/Statique7",
						"Statique/Statique8",
						"Statique/TodMoss",
						"Statique/Wallace",
						
						"Stun/Chloe",
						"Stun/ChloeCombat",
						"Stun/Jay",
						
						"$Chloe_BlesseeReleve",
						"$ChloeAttaqueBlessee",
						"$ChloeEgon1",
						"$ChloeEgon2",
						"$ChloeEgon3",
						"$ChloeProtection",
						"$Crosse",
						"$Crossee",
						"$CrosseeReleve",
						
						"$JayManipGenou",
						"$JayMort1",
						"$JayMort2",
						"$JayMort3",
						"$JayMort4",
						"$JayPropulseSol",
						"$JaySol",
						
						"$posture_blesse1",
						"$posture_blesse2",
						"$posture_blesse3",
						"$posture_blesse4",
						"$posture_blesse5",
						
						"MurphyAccoudeeTransition1",
						"MurphyAccoudeeTransition2",
						"MurphyAccoudeeTransition3",
					];
					var tClass:Class, tClassName:String, tClassNameSimple:String;
					for(i = 0; i < tPoseClasses.length; i++) {
						/*if((tClass = Fewf.assets.getLoadedClass( "$Anim"+(tClassName=strReplace(tPoseClasses[i], "{0}", "F")) )) != null) {
							poses.push(new PoseData({ id:tClassName, type:ITEM.POSE, itemClass:tClass, sex:SEX.FEMALE }));
						}
						if((tClass = Fewf.assets.getLoadedClass( "$Anim"+(tClassName=strReplace(tPoseClasses[i], "{0}", "H")) )) != null) {
							poses.push(new PoseData({ id:tClassName, type:ITEM.POSE, itemClass:tClass, sex:SEX.MALE }));
						}*/
						/*if((tClass = Fewf.assets.getLoadedClass( "$Anim"+strReplace(tPoseClasses[i], "{0}", "F") )) != null) {*/
						tClassName = tClassNameSimple = tPoseClasses[i];
						if(tClassName.indexOf("$") == 0) {
							tClassNameSimple = tClassNameSimple.slice(1);
						}
						else if(tClassName.indexOf("MurphyAccoudee") == 0) {
							// Nothing, perfect as is
						} else {
							tClassName = "$Anim"+tClassName;
						}
						if((tClass = Fewf.assets.getLoadedClass( tClassName )) != null) {
							poses.push(new PoseData({ id:tClassNameSimple, assetID:tClassNameSimple, type:ITEM.POSE, itemClass:tClass, sex:null }));
						}
					}
					/*defaultPoseIndex = 0;//FewfUtils.getIndexFromArrayWithKeyVal(poses, "id", ConstantsApp.DEFAULT_POSE_ID);*/
					//defaultPoseIndexMale = 1;//FewfUtils.getIndexFromArrayWithKeyVal(poses, "id", ConstantsApp.DEFAULT_POSE_ID);
				},
				function(){
					// Loop through config and mark required assets as "extra" so they can be toggled on/off.
					var tExtras = Fewf.assets.getData("config").extras, tDataArray, tData;
					for(var key:String in tExtras) {
						if((tDataArray = getArrayByType(key)) != null) {
							for each(var tID in tExtras[key]) {
								tData = FewfUtils.getFromArrayWithKeyVal(tDataArray, "id", tID);
								if(tData) { tData.tags.push("extra"); }
							}
						}
					}
					
					// All skins and faces are "extras" by default. Need to add extra type so toggling removes stuff.
					for each(var tFace in faces) { tFace.tags.push("extra"); }
					for each(var tSkin in skins) { tSkin.tags.push("extra"); }
				},
				pCallback,
			];
			var tContinueFlow = function(){
				setTimeout(function(){
					(tFlowFunctions.shift())();
					if(tFlowFunctions.length > 0) { tContinueFlow(); }
				}, 1);
			}
			tContinueFlow();
		}
		function strReplace(str:String, search:String, replace:String):String {
			return str.split(search).join(replace);
		}

		// pData = { base:String, type:String, after:String, pad:int, map:Array, sex:Boolean, itemClassToClassMap:String OR Array, numToCheck:int=null, ?idPrefix:String }
		private static function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			var tSexSpecificParts:int;
			var tLength:int = pData.numToCheck ? pData.numToCheck : _CHECK_DEFAULT;
			var tIdPrefix = pData.idPrefix ? pData.idPrefix : "";
			// Default
			if(!pData.after) { pData.after = ""; }
			// Loop
			for(var i = 0; i <= tLength; i++) {
				if(pData.map) {
					var tSexSpecificArray = new Array();
					for(var g:int = 0; g < (pData.sex ? 2 : 1); g++) {
						var tClassMap = {  }, tClassSuccess = null;
						tSexSpecificParts = 0;
						for(var j = 0; j < pData.map.length; j++) {
							tClass = Fewf.assets.getLoadedClass( tClassName = pData.base+zeroPad(i, pData.pad)+pData.after+pData.map[j] );
							if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; }
							else if(pData.sex){
								tClass = Fewf.assets.getLoadedClass( tClassName+"_"+(g==0?1:2) );
								if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; tSexSpecificParts++; }
							}
						}
						if(tClassSuccess) {
							var tIsSexSpecific = pData.sex && tSexSpecificParts > 0;
							tSexSpecificArray.push( new ItemData({ id:tIdPrefix+i+(tIsSexSpecific ? (g==1 ? "M" : "F") : ""), assetID:pData.base+(pData.pad ? zeroPad(i, pData.pad) : i), type:pData.type, classMap:tClassMap, itemClass:tClassSuccess, sex:(tIsSexSpecific ? (g==1?SEX.MALE:SEX.FEMALE) : null) }) );
						}
						if(tSexSpecificParts == 0 && tClassSuccess) {
							break;
						}
					}
					// TODO: This is a hacky way to removed the items after they've been created. Rework?
					// Check if more than 1 entry
					if(tSexSpecificArray.length > 1) {
						// If there are two entries then at least one must be sex-specific.
						// If one of these is gender neutral, it should be removed.
						for(var n:int = 0; n < tSexSpecificArray.length; n++) {
							if(tSexSpecificArray[n].sex == null) { tSexSpecificArray.splice(n, 1); break; }
						}
					}
					tArray = tArray.concat(tSexSpecificArray);
				} else {
					tClass = Fewf.assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
					if(tClass != null) {
						tArray.push( new ItemData({ id:tIdPrefix+i, type:pData.type, itemClass:tClass}) );
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

		public static function zeroPad(number:int, width:int):String {
			if(!width) { return String(number); }
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}

		public static function getArrayByType(pType:String) : Array {
			switch(pType) {
				case ITEM.FACE:		return faces;
				case ITEM.HAIR:		return hair;
				case ITEM.BEARD:	return beards;
				case ITEM.HEAD:		return head;
				case ITEM.MASK:		return masks;
				case ITEM.SHIRT:	return shirts;
				case ITEM.PANTS:	return pants;
				case ITEM.BELT:		return belts;
				case ITEM.GLOVES:	return gloves;
				case ITEM.SHOES:	return shoes;
				case ITEM.BAG:		return bags;
				case ITEM.OBJECT:	return objects;

				case ITEM.SKIN:		return skins;
				case ITEM.POSE:		return poses;
				default: trace("[GameAssets](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}

		public static function getItemFromTypeID(pType:String, pID:String) : ItemData {
			return FewfUtils.getFromArrayWithKeyVal(getArrayByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
		public static function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return null; }
			// copyToMC.gotoAndPlay(copyFromMC.currentFrame);
			var tChild1:*=null;
			var tChild2:*=null;
			var i:int = 0;
			while (i < copyFromMC.numChildren) {
				tChild1 = copyFromMC.getChildAt(i);
				tChild2 = copyToMC.getChildAt(i);
				if (tChild1.name == "$2" || (tChild1.name.indexOf("Couleur") == 0 && tChild1.name.length > 7)) {
					tChild2.transform.colorTransform = tChild1.transform.colorTransform;
				}
				i++;
			}
			return copyToMC;
		}

		public static function colorDefault(pMC:MovieClip) : MovieClip {
			if (pMC == null) { return null; }
			pMC.gotoAndPlay(0);

			// var tChild:*=null;
			// var tHex:int=0;
			// var loc1:*=0;
			// while (loc1 < pMC.numChildren)
			// {
			// 	tChild = pMC.getChildAt(loc1);
			// 	if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)
			// 	{
			// 		tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
			// 		applyColorToObject(tChild, tHex);
			// 	}
			// 	++loc1;
			// }
			return pMC;
		}

		// pData = { obj:DisplayObject, color:String OR int, ?swatch:int, ?name:String, ?colors:Array<int> }
		public static function colorItem(pData:Object) : DisplayObject {
			if (pData.obj == null) { return null; }

			var tHex:int = convertColorToNumber(pData.color);

			var tChild:DisplayObject;
			var i:int=0;
			while (i < pData.obj.numChildren) {
				tChild = pData.obj.getChildAt(i);
				if (tChild.name == pData.name || (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)) {
					if(pData.colors != null && pData.colors[tChild.name.charAt(7)] != null) {
						applyColorToObject(tChild, convertColorToNumber(pData.colors[tChild.name.charAt(7)]));
					}
					else if (!pData.swatch || pData.swatch == tChild.name.charAt(7)) {
						applyColorToObject(tChild, tHex);
					}
				}
				i++;
			}
			return pData.obj;
		}
		public static function convertColorToNumber(pColor) : int {
			return pColor is Number || pColor == null ? pColor : int("0x" + pColor);
		}
		
		// pColor is an int hex value. ex: 0x000000
		public static function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			if(pColor < 0) { return; }
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}

		// public static function getColors(pMC:MovieClip) : Array {
		// 	var tChild:*=null;
		// 	var tTransform:*=null;
		// 	var tArray:Array=new Array();

		// 	var i:int=0;
		// 	while (i < pMC.numChildren) {
		// 		tChild = pMC.getChildAt(i);
		// 		if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
		// 			tTransform = tChild.transform.colorTransform;
		// 			tArray[tChild.name.charAt(7)] = ColorMathUtil.RGBToHex(tTransform.redMultiplier * 128, tTransform.greenMultiplier * 128, tTransform.blueMultiplier * 128);
		// 		}
		// 		i++;
		// 	}
		// 	return tArray;
		// }

		public static function getNumOfCustomColors(pMC:MovieClip) : int {
			var tChild:*=null;
			var num:int = 0;
			var i:int = 0;
			while (i < pMC.numChildren) {
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					num++;
				}
				i++;
			}
			return num;
		}
		
		public static function getColoredItemImage(pData:ItemData) : MovieClip {
			return colorItem({ obj:getItemImage(pData), colors:[pData.color] }) as MovieClip;//pData.colors });
			// return getItemImage(pData); // Colored items not supported
		}

		/****************************
		* Asset Creation
		*****************************/
		public static function getItemImage(pData:ItemData) : MovieClip {
			var tItem:MovieClip;
			switch(pData.type) {
				case ITEM.SKIN:
					tItem = getDefaultPoseSetup({ skin:pData, skipItems:true, baseArgs:{ skinColor:GameAssets.skinColor, secondaryColor:GameAssets.secondaryColor } });
					break;
				case ITEM.POSE:
					tItem = getDefaultPoseSetup({ pose:pData, baseArgs:{ skinColor:GameAssets.skinColor } });
					break;
				// Items with multiple parts (or needs to be colored) that must be added onto a pose to show properly
				case ITEM.SHIRT:
				case ITEM.PANTS:
				case ITEM.SHOES:
				case ITEM.MASK:
				case ITEM.BAG:
				case ITEM.GLOVES:
					tItem = new Pose(poses[defaultPoseIndex]).apply({ items:[ pData ], removeBlanks:true, facingForward:true });
					break;
				case ITEM.HAIR:
				case ITEM.BEARD:
					tItem = new Pose(poses[defaultPoseIndex]).apply({ items:[ pData ], removeBlanks:true, facingForward:true, hairColor:GameAssets.hairColor });
					break;
				default:
					tItem = new pData.itemClass();
					colorDefault(tItem);
					tItem.gotoAndPlay(pData.stopFrame);
					tItem.stop();
					break;
			}
			return tItem;
		}

		// pData = { ?pose:ItemData, ?skin:SkinData, ?baseArgs:Object, ?skipItems:Boolean=false }
		public static function getDefaultPoseSetup(pData:Object) : Pose {
			var tPoseData = pData.pose ? pData.pose : poses[defaultPoseIndex];
			var tSkinData = pData.skin ? pData.skin : skins[defaultSkinIndex];
			
			var tApplyData = pData.baseArgs != null ? pData.baseArgs : {};
			tApplyData.facingForward = true;
			
			var tPose = new Pose(tPoseData);
			/*if(tSkinData.sex == SEX.MALE) {
				tPose.apply({ items:[
					tSkinData,
					shirts[1],
					pants[1],
					shoes[0]
				] });
			} else {*/
				if(pData.skipItems) {
					tApplyData.items = [
						tSkinData,
						faces[0]
					];
				} else {
					tApplyData.items = [
						tSkinData,
						shirts[0],
						pants[0],
						shoes[0],
						faces[0]
					];
				}
			/*}*/
			tPose.apply(tApplyData);
			tApplyData = null;
			tPose.stopAtLastFrame();
			
			return tPose;
		}
	}
}
