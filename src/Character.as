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
		public var animatePose:Boolean;
		
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
		
		internal var poseClass:Class;
		
		internal var _scale:Number;
		
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
			this.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function () { startDrag(); });
			this.addEventListener(flash.events.MouseEvent.MOUSE_UP, function () { stopDrag(); });
			
			/****************************
			* Store Data
			*****************************/
			this.skinData = pData.skin;
			
			this.hairData = pData.hair;
			this.headData = pData.head;
			this.shirtData = pData.shirt;
			this.pantsData = pData.pants;
			this.shoesData = pData.shoes;
			this.objectData = pData.object;
			
			this.poseClass = pData.pose.itemClass;
			
			updatePose(this.poseClass);
		}
		
		public function updatePose(pPose:Class=null) {
			if(pPose) { this.poseClass = pPose; }
			var tScale = 3;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new Pose(poseClass));
			outfit.scaleX = outfit.scaleY = tScale;
			
			outfit.apply({ skin:skinData, hair:hairData, items:[
				headData,
				shirtData,
				pantsData,
				shoesData,
				objectData
			] });
			if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}
		
		/****************************
		* Color
		*****************************/
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

		/****************************
		* Update Data
		*****************************/
		public function setSkin(pData:ShopItemData) : void {
			setItemData(ItemType.SKIN, pData);
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
		
		public function setItemData(pType:String, pItem:ShopItemData) : void {
			switch(pType) {
				case ItemType.HAIR				: this.hairData = pItem; break;
				case ItemType.HEAD				: this.headData = pItem; break;
				case ItemType.SHIRT				: this.shirtData = pItem; break;
				case ItemType.PANTS				: this.pantsData = pItem; break;
				case ItemType.SHOES				: this.shoesData = pItem; break;
				case ItemType.OBJECT			: this.objectData = pItem; break;
				case ItemType.SKIN				: this.skinData = pItem; break;
				case ItemType.POSE				: this.poseClass = pItem.itemClass; break;
				default: trace("[Character](addItem) Unknown Type: "+pType); break;
			}
			updatePose();
		}
		
		public function addItem(pType:String, pItem:ShopItemData) : void {
			setItemData(pType, pItem);
		}
		
		public function removeItem(pType:String) : void {
			setItemData(pType, null);
		}
	}
}
