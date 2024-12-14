package app.world.elements
{
	import com.piterwilson.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import app.world.data.PoseData;

	public class Character extends Sprite
	{
		// Storage
		public var outfit:Pose;
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
			_itemDataMap[ItemType.SKIN] = pData.skin;
			_itemDataMap[ItemType.FACE] = pData.face;
			_itemDataMap[ItemType.HAIR] = pData.hair;
			_itemDataMap[ItemType.BEARD] = pData.beard;
			_itemDataMap[ItemType.HEAD] = pData.head;
			_itemDataMap[ItemType.MASK] = pData.mask;
			_itemDataMap[ItemType.SHIRT] = pData.shirt;
			_itemDataMap[ItemType.PANTS] = pData.pants;
			_itemDataMap[ItemType.BELT] = pData.belt;
			_itemDataMap[ItemType.GLOVES] = pData.gloves;
			_itemDataMap[ItemType.SHOES] = pData.shoes;
			_itemDataMap[ItemType.BAG] = pData.bag;
			_itemDataMap[ItemType.OBJECT] = pData.object;
			_itemDataMap[ItemType.POSE] = pData.pose;

			if(pData.params) parseParams(pData.params);

			updatePose(pData.scale);
		}

		public function updatePose(pScale:Number=-1) {
			var tScale = pScale;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = new Pose(getItemData(ItemType.POSE) as PoseData).appendTo(this);
			outfit.scaleX = outfit.scaleY = tScale;
			// Don't let the pose eat mouse input
			outfit.mouseChildren = false;
			outfit.mouseEnabled = false;

			outfit.apply(new <ItemData>[
					getItemData(ItemType.SKIN),
					getItemData(ItemType.FACE),
					getItemData(ItemType.HAIR),
					getItemData(ItemType.BEARD),
					getItemData(ItemType.HEAD),
					getItemData(ItemType.MASK),
					getItemData(ItemType.SHIRT),
					getItemData(ItemType.PANTS),
					getItemData(ItemType.BELT),
					getItemData(ItemType.GLOVES),
					getItemData(ItemType.SHOES),
					getItemData(ItemType.BAG),
					getItemData(ItemType.OBJECT)
				], {
				skinColor:GameAssets.skinColor,
				hairColor:GameAssets.hairColor,
				secondaryColor:GameAssets.secondaryColor,
				tornStates:GameAssets.tornStates
			});
			if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}

		public function parseParams(pParams:URLVariables) : void {
			trace(pParams.toString());
			GameAssets.showAll = pParams.xtr == "1";
			
			if(pParams.hc) { GameAssets.hairColor = uint("0x"+pParams.hc); }
			if(pParams.sk) { GameAssets.skinColor = uint("0x"+pParams.sk); }
			if(pParams.oc) { GameAssets.secondaryColor = uint("0x"+pParams.oc); }
			
			GameAssets.tornStates[ItemType.SHIRT] = pParams.t_t == "1";
			GameAssets.tornStates[ItemType.PANTS] = pParams.b_t == "1";

			_setParamToType(pParams, ItemType.SKIN, "s", false);
			_setParamToType(pParams, ItemType.HAIR, "d");
			_setParamToType(pParams, ItemType.BEARD, "fh");
			_setParamToType(pParams, ItemType.FACE, "fc");
			_setParamToType(pParams, ItemType.HEAD, "h");
			_setParamToType(pParams, ItemType.MASK, "m");
			_setParamToType(pParams, ItemType.SHIRT, "t");
			_setParamToType(pParams, ItemType.PANTS, "b");
			_setParamToType(pParams, ItemType.BELT, "bt");
			_setParamToType(pParams, ItemType.GLOVES, "g");
			_setParamToType(pParams, ItemType.SHOES, "f");
			_setParamToType(pParams, ItemType.BAG, "bg");
			_setParamToType(pParams, ItemType.OBJECT, "o");
			_setParamToType(pParams, ItemType.POSE, "p", false);
			
			if(pParams.sex) { GameAssets.sex = pParams.sex == Sex.MALE.toString() ? Sex.MALE : Sex.FEMALE; }
			/*if(pParams.ff) { GameAssets.facingForward = pParams.ff != "0"; }*/
		}
		private function _setParamToType(pParams:URLVariables, pType:ItemType, pParam:String, pAllowNull:Boolean=true) {
			var tData:ItemData = null, tID = pParams[pParam];
			if(tID != null && tID != "") {
				var tColors = _splitOnUrlColorSeperator(tID); // Get a list of all the colors (ID is first); ex: 5;ffffff;abcdef;169742
				tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
				tData = GameAssets.getItemFromTypeID(pType, tID);
				if(tColors.length > 0) { tData.color = _hexToInt(tColors[0]); }
			}
			_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
		}
		private function _hexToInt(pVal:String) : int {
			return parseInt(pVal, 16);
		}
		private function _splitOnUrlColorSeperator(pVal:String) : Array {
			// Used to be , but changed to ; (for atelier801 forum support)
			return pVal.indexOf(";") > -1 ? pVal.split(";") : pVal.split(",");
		}

		public function getParams() : String {
			var tParms = new URLVariables();

			tParms.xtr = GameAssets.showAll ? "1" : "0";
			
			tParms.hc = GameAssets.hairColor.toString(16);
			tParms.sk = GameAssets.skinColor.toString(16);
			tParms.oc = GameAssets.secondaryColor.toString(16);
			
			tParms.t_t = GameAssets.tornStates[ItemType.SHIRT] ? "1" : "0";
			tParms.b_t = GameAssets.tornStates[ItemType.PANTS] ? "1" : "0";
			
			var tData:ItemData;
			_addParamToVariables(tParms, "s", ItemType.SKIN);
			_addParamToVariables(tParms, "d", ItemType.HAIR);
			_addParamToVariables(tParms, "fh", ItemType.BEARD);
			_addParamToVariables(tParms, "h", ItemType.HEAD);
			_addParamToVariables(tParms, "m", ItemType.MASK);
			_addParamToVariables(tParms, "t", ItemType.SHIRT);
			_addParamToVariables(tParms, "b", ItemType.PANTS);
			_addParamToVariables(tParms, "bt", ItemType.BELT);
			_addParamToVariables(tParms, "g", ItemType.GLOVES);
			_addParamToVariables(tParms, "f", ItemType.SHOES);
			_addParamToVariables(tParms, "bg", ItemType.BAG);
			_addParamToVariables(tParms, "o", ItemType.OBJECT);
			_addParamToVariables(tParms, "p", ItemType.POSE);
			_addParamToVariables(tParms, "fc", ItemType.FACE);
			/* tParms.s = (tData = getItemData(ItemType.SKIN)) ? tData.id : ''; */
			/* tParms.d = (tData = getItemData(ItemType.HAIR)) ? tData.id : ''; */
			/* tParms.fh = (tData = getItemData(ItemType.BEARD)) ? tData.id : ''; */
			/* tParms.h = (tData = getItemData(ItemType.HEAD)) ? tData.id : ''; */
			/* tParms.m = (tData = getItemData(ItemType.MASK)) ? tData.id : ''; */
			/* tParms.t = (tData = getItemData(ItemType.SHIRT)) ? tData.id : ''; */
			/* tParms.b = (tData = getItemData(ItemType.PANTS)) ? tData.id : ''; */
			/* tParms.bt = (tData = getItemData(ItemType.BELT)) ? tData.id : ''; */
			/* tParms.g = (tData = getItemData(ItemType.GLOVES)) ? tData.id : ''; */
			/* tParms.f = (tData = getItemData(ItemType.SHOES)) ? tData.id : ''; */
			/* tParms.bg = (tData = getItemData(ItemType.BAG)) ? tData.id : ''; */
			/* tParms.o = (tData = getItemData(ItemType.OBJECT)) ? tData.id : ''; */
			/* tParms.p = (tData = getItemData(ItemType.POSE)) ? tData.id : ''; */
			/* tParms.fc = (tData = getItemData(ItemType.FACE)) ? tData.id : ''; */
			
			tParms.sex = GameAssets.sex.toString();
			/*tParms.ff = GameAssets.facingForward ? "1" : "0";*/

			return tParms.toString().replace(/%5f/gi, "_").replace(/%3B/g, ";");
		}
		private function _addParamToVariables(pParams:URLVariables, pParam:String, pType:ItemType) {
			var tData:ItemData = getItemData(pType);
			if(tData) {
				pParams[pParam] = tData.id;
				if(tData.color > -1) {
					pParams[pParam] += ";"+_intToHex(tData.color);
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
		public function getItemData(pType:ItemType) : ItemData {
			return _itemDataMap[pType];
		}

		public function setItemData(pItem:ItemData) : void {
			_itemDataMap[pItem.type] = pItem;
			updatePose();
		}

		public function removeItem(pType:ItemType) : void {
			_itemDataMap[pType] = null;
			updatePose();
		}
	}
}
