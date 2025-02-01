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
	import com.fewfre.utils.FewfUtils;
	import com.fewfre.utils.Fewf;
	import flash.utils.Dictionary;

	public class Character extends Sprite
	{
		// Storage
		public var outfit:Pose;
		public var animatePose:Boolean;
		
		private var _dragging:Boolean = false;
		private var _dragBounds:Rectangle;

		private var _itemDataMap:Dictionary; // { [ItemType]: ItemData }
		private var _itemLockMap:Dictionary; // { [ItemType]: Boolean }

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		public function Character(pWornItems:Vector.<ItemData>=null, pParams:String=null, pScale:Number=1)
		{
			super();
			animatePose = true;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) {
				_dragging = true;
				var bounds:Rectangle = _dragBounds.clone();
				bounds.x -= e.localX * scaleX;
				bounds.y -= e.localY * scaleY;
				startDrag(false, bounds);
			});
			Fewf.stage.addEventListener(MouseEvent.MOUSE_UP, function () { if(_dragging) { _dragging = false; stopDrag(); } });

			// Store Data
			_itemDataMap = new Dictionary();
			for each(var item:ItemData in pWornItems) {
				_itemDataMap[item.type] = item;
			}
			
			_itemLockMap = new Dictionary();

			if(pParams) parseParams(pParams);

			updatePose(pScale);
		}
		public function move(pX:Number, pY:Number) : Character { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): Character { pParent.addChild(this); return this; }
		
		public function copy() : Character { return new Character(null, getParams()); }

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
		
		public function setDragBounds(pX:Number, pY:Number, pWidth:Number, pHeight:Number): Character {
			_dragBounds = new Rectangle(pX, pY, pWidth, pHeight); return this;
		}
		public function clampCoordsToDragBounds() : void {
			this.x = Math.max(_dragBounds.x, Math.min(_dragBounds.right, this.x));
			this.y = Math.max(_dragBounds.y, Math.min(_dragBounds.bottom, this.y));
		}
		
		/////////////////////////////
		// Item Data
		/////////////////////////////
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

		/////////////////////////////
		// ItemType Locked
		/////////////////////////////
		public function isItemTypeLocked(pType:ItemType) : Boolean {
			return !!_itemLockMap[pType];
		}
		
		public function setItemTypeLock(pType:ItemType, pLocked:Boolean) : void {
			_itemLockMap[pType] = pLocked;
			// no need to update pose as this has no direct effect on character, only controlling what changes can be made to it
		}

		/////////////////////////////
		// Share Code
		/////////////////////////////
		public function parseParams(pCode:String) : Boolean {
			try {
				var pParams = new flash.net.URLVariables();
				pParams.decode(pCode);
					
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
			catch (error:Error) { return false; };
			return true;
		}
		private function _setParamToType(pParams:URLVariables, pType:ItemType, pParam:String, pAllowNull:Boolean=true) {
			if(isItemTypeLocked(pType)) return;
			var tData:ItemData = null, tID = pParams[pParam];
			if(tID != null && tID != "") {
				var tColors = _splitOnUrlColorSeperator(tID); // Get a list of all the colors (ID is first); ex: 5;ffffff;abcdef;169742
				tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
				tData = GameAssets.getItemFromTypeID(pType, tID);
				if(tColors.length > 0) { tData.color = FewfUtils.colorHexStringToInt(tColors[0]); }
			}
			_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
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
					pParams[pParam] += ";"+FewfUtils.colorIntToHexString(tData.color);
				}
			}
			/*else { pParams[pParam] = ''; }*/
		}
	}
}
