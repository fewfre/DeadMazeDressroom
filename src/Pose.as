package 
{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.geom.*;
	
	public class Pose extends MovieClip
	{
		// Storage
		private var _pose : MovieClip;
		
		public function get pose():MovieClip { return _pose; }
		
		// Constructor
		public function Pose(pClass:Class) {
			super();
			
			_pose = addChild( new pClass() );
			stop();
		}
		
		override public function play() : void {
			super.play();
			_pose.play();
		}
		
		override public function stop() : void {
			super.stop();
			_pose.stop();
		}
		
		public function stopAtLastFrame() : void {
			_pose.gotoAndPlay(10000);
			stop();
		}
		
		// pData = { skin:SkinData, hair:ShopItemData[optional], items:Array[optional] }
		public function apply(pData:Object) : void {
			var tSkinData = pData.skin;
			var tHairData = pData.hair ? pData.hair : tSkinData.hair;
			
			if(!pData.items) pData.items = [];
			pData.items.unshift(tSkinData);
			pData.items.unshift(tHairData);
			var tShopData = _orderType(pData.items);
			
			var part:DisplayObject = null;
			var tChild:* = null;
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			for(var i:int = 0; i < _pose.numChildren; i++) {
				tChild = _pose.getChildAt(i);
				
				for(var j:int = 0; j < tShopData.length; j++) {
					part = _addToPoseIfCan(tChild, tShopData[j], tChild.name);
					if(part) {
						if(tShopData[j].type == ItemType.HAIR) Main.costumes.applyColorToObject(part,  Main.costumes.hairColor);
						if(part is MovieClip) {
							Main.costumes.colorItem({ mc:part, color: Main.costumes.skinColor, name:"$0" });
							Main.costumes.colorItem({ mc:part, color: Main.costumes.secondaryColor, name:"$2" });
						}
					}
				}
				
				part = null;
			}
		}
		
		private function _addToPoseIfCan(pSkinPart:MovieClip, pData:ShopItemData, pID:String) : MovieClip {
			if(pData) {
				var tClass = pData.getPart(pID);
				if(!(tClass is MovieClip)) {
					return pSkinPart.addChild( new tClass() );
				}
			}
			return null;
		}
		
		private function _orderType(pItems:Array) : Array {
			var i = pItems.length;
			while(i > 0) { i--;
				if(pItems[i] == null) {
					pItems.splice(i, 1);
				}
			}
			
			pItems.sort(function(a, b){
				return ItemType.LAYERING.indexOf(a.type) > ItemType.LAYERING.indexOf(b.type) ? 1 : -1;
			});
			
			return pItems;
		}
	}
}