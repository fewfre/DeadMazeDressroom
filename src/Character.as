package 
{
	import com.piterwilson.utils.*;
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.geom.*;
	
	public class Character extends flash.display.Sprite
	{
		// Storage
		public var outfit:MovieClip;
		
		internal var skinData:SkinData;
		internal var hairData:ShopItemData;
		internal var headData:ShopItemData;
		internal var shirtData:ShopItemData;
		internal var pantsData:ShopItemData;
		internal var shoesData:ShopItemData;
		internal var objectData:ShopItemData;
		
		internal var skin:MovieClip;
		internal var hair:MovieClip;
		internal var head:MovieClip;
		internal var shirt:MovieClip;
		internal var pants:MovieClip;
		internal var shoes:MovieClip;
		internal var object:MovieClip;
		
		internal var pose:Class;
		
		internal var scale:Number;
		
		// Constructor
		public function Character(pData:Object)
		{
			super();
			
			this.skinData = pData.skin;
			
			this.hairData = pData.hair;
			this.headData = pData.head;
			this.shirtData = pData.shirt;
			this.pantsData = pData.pants;
			this.shoesData = pData.shoes;
			this.objectData = pData.object;
			
			this.pose = pData.pose.itemClass;
			
			updatePose(this.pose);
		}
		
		public function updatePose(pPose:Class=null) {
			if(pPose) { this.pose = pPose; }
			var tScale = 3;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new pose());
			outfit.scaleX = outfit.scaleY = tScale;
			
			var tHairData = hairData ? hairData : skinData.hair;
			
			var part:DisplayObject = null;
			//var hairPart:DisplayObject = null;
			var tChild:* = null;
			var tChildType:String = null;
			
			var tShopData = [
				tHairData,
				headData,
				shirtData,
				pantsData,
				shoesData
			];
			
			var i:Number = 0;
			while (i < outfit.numChildren) {
				tChild = outfit.getChildAt(i);
				tChildType = tChild.name;
				
				switch (tChildType){
					case "_Arme": if(objectData) { this.object = part = tChild.addChild(new objectData.itemClass()); } break;
					//case "CH": if(tHairData.itemClass2) { hairPart = tChild.addChild(new tHairData.itemClass2()); } break;
					case "T": {
						part = tChild.addChild(new (skinData.getPartClassFromType(tChildType))());
						//hairPart = tChild.addChild(new tHairData.itemClass());
						break;
					} // else check for default skin hair
					default: part = tChild.addChild(new (skinData.getPartClassFromType(tChildType))()); break;
				}
				if(part && part is MovieClip) Main.costumes.colorItem({ mc:part, color: Main.costumes.skinColor, name:"$0" });
				if(part && part is MovieClip) Main.costumes.colorItem({ mc:part, color: Main.costumes.secondaryColor, name:"$2" });
				
				for(var j:int = 0; j < tShopData.length; j++) {
					part = _addToSkinIfCan(tChild, tShopData[j], tChildType);
					if(part && tShopData[j].type == ItemType.HAIR) Main.costumes.applyColorToObject(part,  Main.costumes.hairColor);
				}
				
				part = null;
				i++;
			}
		}
		private function _addToSkinIfCan(pSkinPart:MovieClip, pData:ShopItemData, pID:String) : MovieClip {
			if(pData) {
				var tClass = pData.getPart(pID);
				if(!(tClass is MovieClip)) {
					return pSkinPart.addChild( new tClass() );
				}
			}
			return null;
		}

		/*
			public function colorDefault(pType:String) : void {
				Main.costumes.colorDefault( this.getItem(pType) );
			}

			public function getColors(pType:String) : Array {
				var tItem:MovieClip = this.getItem(pType);
				if (tItem == null) { return new Array(); }
				
				var tChild:DisplayObject;
				var tTransform:*=null;
				var tArray:*=new Array();
				
				var i:int=0;
				while (i < tItem.numChildren) {
					tChild = tItem.getChildAt(i);
					if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
						tTransform = tChild.transform.colorTransform;
						tArray[tChild.name.charAt(7)] = com.piterwilson.utils.ColorMathUtil.RGBToHex(tTransform.redMultiplier * 128, tTransform.greenMultiplier * 128, tTransform.blueMultiplier * 128);
					}
					i++;
				}
				return tArray;
			}

			public function colorItem(pType:String, arg2:int, pColor:String) : void {
				var tItem:MovieClip = this.getItem(pType);
				Main.costumes.colorItem({ mc:tItem, color:pColor, swatch:arg2 });
			}
		*/

		public function setHair(pData:ShopItemData, pRemove:Boolean=true) : void {
			this.hairData = pData;
			//updatePose();
		}

		public function setObject(pData:ShopItemData, pRemove:Boolean=true) : void {
			this.objectData = pData;
			//updatePose();
		}

		public function setSkin(pData:ShopItemData, pRemove:Boolean=true) : void {
			this.skinData = pData;
			//updatePose();
		}

		public function getItem(pType:String):MovieClip
		{
			switch(pType) {
				case ItemType.HAIR				: return this.hair; break;
				case ItemType.HEAD				: return this.head; break;
				case ItemType.SHIRT				: return this.shirt; break;
				case ItemType.PANTS				: return this.pants; break;
				case ItemType.SHOES				: return this.shoes; break;
				case ItemType.OBJECT			: return this.object; break;
				case ItemType.SKIN				: return this.skin; break;
				default: trace("[Character](getItem) Unknown Type: "+pType); break;
			}
		}
		
		public function addItem(pType:String, pItem:ShopItemData) : void {
			switch(pType) {
				case ItemType.HAIR				: setHair(pItem); break;
				case ItemType.HEAD				: this.headData = pItem; break;
				case ItemType.SHIRT				: this.shirtData = pItem; break;
				case ItemType.PANTS				: this.pantsData = pItem; break;
				case ItemType.SHOES				: this.shoesData = pItem; break;
				case ItemType.OBJECT			: setObject(pItem); break;
				case ItemType.SKIN				: setSkin(pItem); break;
				default: trace("[Character](addItem) Unknown Type: "+pType); break;
			}
			updatePose();
		}
		
		public function removeItem(pType:String) : void {
			switch(pType) {
				case ItemType.HAIR				: this.hairData = null; break;
				case ItemType.HEAD				: this.headData = null; break;
				case ItemType.SHIRT				: this.shirtData = null; break;
				case ItemType.PANTS				: this.pantsData = null; break;
				case ItemType.SHOES				: this.shoesData = null; break;
				case ItemType.OBJECT			: this.objectData = null; break;
				case ItemType.SKIN				: this.skinData = null; break;
				default: trace("[Character](removeItem) Unknown Type: "+pType); break;
			}
			updatePose();
		}
	}
}
