package app.world.elements
{
	import com.piterwilson.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	public class Character extends Sprite
	{
		// Storage
		public var outfit:MovieClip;
		public var animatePose:Boolean;

		private var _itemDataMap:Object;

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		// pData = { x:Number, y:Number, scale:Number, [various "__Data"s], ?params:URLVariables }
		public function Character(pData:Object)
		{
			super();
			animatePose = true;

			this.x = pData.x;
			this.y = pData.y;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function () { startDrag(); });
			this.addEventListener(MouseEvent.MOUSE_UP, function () { stopDrag(); });

			/****************************
			* Store Data
			*****************************/
			_itemDataMap = {};
			_itemDataMap[ITEM.SKIN] = pData.skin;
			_itemDataMap[ITEM.FACE] = pData.face;
			_itemDataMap[ITEM.HAIR] = pData.hair;
			_itemDataMap[ITEM.BEARD] = pData.beard;
			_itemDataMap[ITEM.HEAD] = pData.head;
			_itemDataMap[ITEM.MASK] = pData.mask;
			_itemDataMap[ITEM.SHIRT] = pData.shirt;
			_itemDataMap[ITEM.PANTS] = pData.pants;
			_itemDataMap[ITEM.BELT] = pData.belt;
			_itemDataMap[ITEM.GLOVES] = pData.gloves;
			_itemDataMap[ITEM.SHOES] = pData.shoes;
			_itemDataMap[ITEM.BAG] = pData.bag;
			_itemDataMap[ITEM.OBJECT] = pData.object;
			_itemDataMap[ITEM.POSE] = pData.pose;

			if(pData.params) _parseParams(pData.params);

			updatePose(pData.scale);
		}

		public function updatePose(pScale:Number=-1) {
			var tScale = pScale;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new Pose(getItemData(ITEM.POSE)));
			outfit.scaleX = outfit.scaleY = tScale;

			outfit.apply({
				skinColor:GameAssets.skinColor,
				hairColor:GameAssets.hairColor,
				secondaryColor:GameAssets.secondaryColor,
				tornStates:GameAssets.tornStates,
				items:[
					getItemData(ITEM.SKIN),
					getItemData(ITEM.FACE),
					getItemData(ITEM.HAIR),
					getItemData(ITEM.BEARD),
					getItemData(ITEM.HEAD),
					getItemData(ITEM.MASK),
					getItemData(ITEM.SHIRT),
					getItemData(ITEM.PANTS),
					getItemData(ITEM.BELT),
					getItemData(ITEM.GLOVES),
					getItemData(ITEM.SHOES),
					getItemData(ITEM.BAG),
					getItemData(ITEM.OBJECT)
				]
			});
			if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}

		private function _parseParams(pParams:URLVariables) : void {
			trace(pParams.toString());
			GameAssets.showAll = pParams.xtr == "1";
			
			if(pParams.hc) { GameAssets.hairColor = uint("0x"+pParams.hc); }
			if(pParams.sk) { GameAssets.skinColor = uint("0x"+pParams.sk); }
			if(pParams.oc) { GameAssets.secondaryColor = uint("0x"+pParams.oc); }
			
			GameAssets.tornStates[ITEM.SHIRT] = pParams.t_t == "1";
			GameAssets.tornStates[ITEM.PANTS] = pParams.b_t == "1";

			_setParamToType(pParams, ITEM.SKIN, "s", false);
			_setParamToType(pParams, ITEM.HAIR, "d");
			_setParamToType(pParams, ITEM.BEARD, "fh");
			_setParamToType(pParams, ITEM.FACE, "fc");
			_setParamToType(pParams, ITEM.HEAD, "h");
			_setParamToType(pParams, ITEM.MASK, "m");
			_setParamToType(pParams, ITEM.SHIRT, "t");
			_setParamToType(pParams, ITEM.PANTS, "b");
			_setParamToType(pParams, ITEM.BELT, "bt");
			_setParamToType(pParams, ITEM.GLOVES, "g");
			_setParamToType(pParams, ITEM.SHOES, "f");
			_setParamToType(pParams, ITEM.BAG, "bg");
			_setParamToType(pParams, ITEM.OBJECT, "o");
			_setParamToType(pParams, ITEM.POSE, "p", false);
			
			if(pParams.sex) { GameAssets.sex = pParams.sex == SEX.MALE ? SEX.MALE : SEX.FEMALE; }
			/*if(pParams.ff) { GameAssets.facingForward = pParams.ff != "0"; }*/
		}
		private function _setParamToType(pParams:URLVariables, pType:String, pParam:String, pAllowNull:Boolean=true) {
			var tData:ItemData = null, tID = pParams[pParam];
			if(tID != null && tID != "") {
				var tColors = tID.split(","); // Get a list of all the colors (ID is first); ex: 5,ffffff,abcdef,169742
				tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
				tData = GameAssets.getItemFromTypeID(pType, tID);
				if(tColors.length > 0) { tData.color = _hexToInt(tColors[0]); }
			}
			_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
		}
		private function _hexToInt(pVal:String) : int {
			return parseInt(pVal, 16);
		}

		public function getParams() : URLVariables {
			var tParms = new URLVariables();

			tParms.xtr = GameAssets.showAll ? "1" : "0";
			
			tParms.hc = GameAssets.hairColor.toString(16);
			tParms.sk = GameAssets.skinColor.toString(16);
			tParms.oc = GameAssets.secondaryColor.toString(16);
			
			tParms.t_t = GameAssets.tornStates[ITEM.SHIRT] ? "1" : "0";
			tParms.b_t = GameAssets.tornStates[ITEM.PANTS] ? "1" : "0";
			
			var tData:ItemData;
			_addParamToVariables(tParms, "s", ITEM.SKIN);
			_addParamToVariables(tParms, "d", ITEM.HAIR);
			_addParamToVariables(tParms, "fh", ITEM.BEARD);
			_addParamToVariables(tParms, "h", ITEM.HEAD);
			_addParamToVariables(tParms, "m", ITEM.MASK);
			_addParamToVariables(tParms, "t", ITEM.SHIRT);
			_addParamToVariables(tParms, "b", ITEM.PANTS);
			_addParamToVariables(tParms, "bt", ITEM.BELT);
			_addParamToVariables(tParms, "g", ITEM.GLOVES);
			_addParamToVariables(tParms, "f", ITEM.SHOES);
			_addParamToVariables(tParms, "bg", ITEM.BAG);
			_addParamToVariables(tParms, "o", ITEM.OBJECT);
			_addParamToVariables(tParms, "p", ITEM.POSE);
			_addParamToVariables(tParms, "fc", ITEM.FACE);
			/* tParms.s = (tData = getItemData(ITEM.SKIN)) ? tData.id : ''; */
			/* tParms.d = (tData = getItemData(ITEM.HAIR)) ? tData.id : ''; */
			/* tParms.fh = (tData = getItemData(ITEM.BEARD)) ? tData.id : ''; */
			/* tParms.h = (tData = getItemData(ITEM.HEAD)) ? tData.id : ''; */
			/* tParms.m = (tData = getItemData(ITEM.MASK)) ? tData.id : ''; */
			/* tParms.t = (tData = getItemData(ITEM.SHIRT)) ? tData.id : ''; */
			/* tParms.b = (tData = getItemData(ITEM.PANTS)) ? tData.id : ''; */
			/* tParms.bt = (tData = getItemData(ITEM.BELT)) ? tData.id : ''; */
			/* tParms.g = (tData = getItemData(ITEM.GLOVES)) ? tData.id : ''; */
			/* tParms.f = (tData = getItemData(ITEM.SHOES)) ? tData.id : ''; */
			/* tParms.bg = (tData = getItemData(ITEM.BAG)) ? tData.id : ''; */
			/* tParms.o = (tData = getItemData(ITEM.OBJECT)) ? tData.id : ''; */
			/* tParms.p = (tData = getItemData(ITEM.POSE)) ? tData.id : ''; */
			/* tParms.fc = (tData = getItemData(ITEM.FACE)) ? tData.id : ''; */
			
			tParms.sex = GameAssets.sex;
			/*tParms.ff = GameAssets.facingForward ? "1" : "0";*/

			return tParms;
		}
		private function _addParamToVariables(pParams:URLVariables, pParam:String, pType:String) {
			var tData:ItemData = getItemData(pType);
			if(tData) {
				pParams[pParam] = tData.id;
				if(tData.color > -1) {
					pParams[pParam] += ","+_intToHex(tData.color);
				}
			}
			/*else { pParams[pParam] = ''; }*/
		}
		private function _intToHex(pVal:int) : String {
			return pVal.toString(16).toUpperCase();
		}

		/****************************
		* Update Data
		*****************************/
		public function getItemData(pType:String) : ItemData {
			return _itemDataMap[pType];
		}

		public function setItemData(pItem:ItemData) : void {
			_itemDataMap[pItem.type] = pItem;
			updatePose();
		}

		public function removeItem(pType:String) : void {
			_itemDataMap[pType] = null;
			updatePose();
		}
	}
}
