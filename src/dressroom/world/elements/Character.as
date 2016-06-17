package dressroom.world.elements
{
	import com.piterwilson.utils.*;
	import dressroom.data.*;
	import dressroom.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class Character extends flash.display.Sprite
	{
		// Storage
		public var outfit:MovieClip;
		public var animatePose:Boolean;
		
		private var _itemDataMap:Object;
		
		// Properties
		public function set scale(pVal:Number) { outfit.scaleX = outfit.scaleY = pVal; }
		
		// Constructor
		// pData = { x:NUmber, y:Number, [various "__Data"s] }
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
			_itemDataMap[ITEM.HAIR] = pData.hair;
			_itemDataMap[ITEM.HEAD] = pData.head;
			_itemDataMap[ITEM.SHIRT] = pData.shirt;
			_itemDataMap[ITEM.PANTS] = pData.pants;
			_itemDataMap[ITEM.SHOES] = pData.shoes;
			_itemDataMap[ITEM.OBJECT] = pData.object;
			_itemDataMap[ITEM.POSE] = pData.pose;
			
			updatePose();
		}
		
		public function updatePose() {
			var tScale = 3;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new Pose(getItemData(ITEM.POSE).itemClass));
			outfit.scaleX = outfit.scaleY = tScale;
			
			outfit.apply({ skin:getItemData(ITEM.SKIN), hair:getItemData(ITEM.HAIR),
				skinColor:Main.costumes.skinColor,
				hairColor:Main.costumes.hairColor,
				secondaryColor:Main.costumes.secondaryColor,
				items:[
					getItemData(ITEM.HEAD),
					getItemData(ITEM.SHIRT),
					getItemData(ITEM.PANTS),
					getItemData(ITEM.SHOES),
					getItemData(ITEM.OBJECT)
				]
			});
			if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
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
