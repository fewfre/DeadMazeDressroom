package dressroom.world.elements
{
	import com.fewfre.utils.*;
	import dressroom.data.*;
	import dressroom.world.data.*;
	import flash.display.*;
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
		
		// pData = { ?items:Array, ?removeBlanks:Boolean=false, ?skinColor:int, ?hairColor:int, ?secondaryColor:int }
		public function apply(pData:Object) : MovieClip {
			if(!pData.items) pData.items = [];
			
			// If no hair data in array, add the skin's default hair style (if there is one).
			var tHairData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.HAIR);
			if(!tHairData) {
				var tSkinData = FewfUtils.getFromArrayWithKeyVal(pData.items, "type", ITEM.SKIN);
				if(tSkinData) {
					pData.items.unshift(tSkinData.hair);
				}
			}
			
			var tSkinColor:int = pData.skinColor != null ? pData.skinColor : Main.costumes.skinColors[0];
			var tHairColor:int = pData.hairColor != null ? pData.hairColor : Main.costumes.hairColors[0];
			var tSecondaryColor:int = pData.secondaryColor != null ? pData.secondaryColor : Main.costumes.secondaryColors[0];
			
			var tShopData = _orderType(pData.items);
			var part:DisplayObject = null;
			var tChild:* = null;
			var tItemsOnChild:int = 0;
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			for(var i:int = 0; i < _pose.numChildren; i++) {
				tChild = _pose.getChildAt(i);
				tItemsOnChild = 0;
				
				for(var j:int = 0; j < tShopData.length; j++) {
					part = _addToPoseIfCan(tChild, tShopData[j], tChild.name);
					if(part) {
						tItemsOnChild++;
						if(tShopData[j].type == ITEM.HAIR) Main.costumes.applyColorToObject(part,  tHairColor);
						if(part is MovieClip) {
							Main.costumes.colorItem({ obj:part, color: tSkinColor, name:"$0" });
							Main.costumes.colorItem({ obj:part, color: tSecondaryColor, name:"$2" });
						}
					}
				}
				if(tItemsOnChild == 0) {
					tChild.enabled = false; // Hacky way to mark the child as "unused" for use in _removeUnusedParts().
				}
				
				part = null;
			}
			if(pData.removeBlanks) {
				_removeUnusedParts();
			}
			
			return this;
		}
		
		private function _removeUnusedParts() {
			i = _pose.numChildren;
			while(i > 0) { i--;
				tChild = _pose.getChildAt(i);
				if(!tChild.enabled) { _pose.removeChildAt(i); }// else { var ttt = new $ColorWheel(); ttt.scaleX = ttt.scaleY = 0.1; tChild.addChild(ttt); }
			}
		}
		
		private function _addToPoseIfCan(pSkinPart:MovieClip, pData:ItemData, pID:String) : MovieClip {
			if(pData) {
				var tClass = pData.getPart(pID);
				if(tClass) {
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
				return ITEM.LAYERING.indexOf(a.type) > ITEM.LAYERING.indexOf(b.type) ? 1 : -1;
			});
			
			return pItems;
		}
	}
}