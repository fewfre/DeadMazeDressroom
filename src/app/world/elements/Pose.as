package app.world.elements
{
	import com.fewfre.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.geom.*;

	public class Pose extends MovieClip
	{
		// Storage
		private var _poseData : ItemData;
		private var _pose : MovieClip;

		public function get pose():MovieClip { return _pose; }

		// Constructor
		public function Pose(pPoseData:PoseData) {
			super();
			_poseData = pPoseData;
			
			//_createPoseFromData();
		}
		
		private function _createPoseFromData(pData:Object=null) : void {
			var tClass:Class = _poseData.getClass(pData);
			_pose = addChild( tClass ? new tClass() : new _poseData.itemClass() );
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
		
		// pData = { ?items:Array, ?removeBlanks:Boolean=false, ?skinColor:int, ?hairColor:int, ?secondaryColor:int, ?facingForward:Boolean=true, ?sex:SEX, ?tornStates:Object<ITEM, Boolean> }
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
			
			pData.skinColor = pData.skinColor != null ? pData.skinColor : GameAssets.skinColors[0];
			pData.hairColor = pData.hairColor != null ? pData.hairColor : GameAssets.hairColors[0];
			pData.secondaryColor = pData.secondaryColor != null ? pData.secondaryColor : GameAssets.secondaryColors[0];
			pData.sex = pData.sex != null ? pData.sex : GameAssets.sex;
			
			_createPoseFromData(pData);
			
			var tShopData = _orderType(pData.items);
			var part:DisplayObject = null;
			var tChild:* = null;
			var tItemsOnChild:int = 0;
			
			// This works because poses, skins, and items have a group of letters/numbers that let each other know they should be grouped together.
			// For example; the "head" of a pose is T, as is the skin's head, hats, and hair. Thus they all go onto same area of the skin.
			// Loop in reverse so unused parts can be removed if required
			for(var i:int = _pose.numChildren-1; i >= 0; i--) {
				tChild = _pose.getChildAt(i);
				tItemsOnChild = 0;
				
				for(var j:int = 0; j < tShopData.length; j++) {
					part = _addToPoseIfCan(tChild, tShopData[j], tChild.name, pData);
					if(pData.tornStates && pData.tornStates[tShopData[j].type]) _applyTornMask(tChild.name, part);
					_colorPart(part, tShopData[j], tChild.name, pData);
					if(part) { tItemsOnChild++; }
				}
				if(pData.removeBlanks && tItemsOnChild == 0) {
					_pose.removeChildAt(i);
				}
				part = null;
			}
			
			return this;
		}
		
		private function _addToPoseIfCan(pSkinPart:DisplayObject, pData:ItemData, pID:String, pOptions:Object=null) : MovieClip {
			if(pData) {
				var tClass = pData.getPart(pID, pOptions);
				if(tClass) {
					var tItem = new tClass();
					if(pData.color >= 0) {
						tItem.gotoAndPlay(tItem.totalFrames);
					} else {
						tItem.gotoAndPlay(pData.stopFrame);
					}
					tItem.stop();
					return pSkinPart.addChild( tItem );
				}
			}
			return null;
		}
		
		private function _applyTornMask(pID:String, pItem:MovieClip) : void {
			if(!pItem) { return; }
			var tClass = Fewf.assets.getLoadedClass( "$Dechirure_"+pID );
			if(tClass != null) {
				pItem.mask = pItem.addChild(new tClass());
			}
		}
		
		private function _colorPart(part:DisplayObject, pData:ItemData, pSlotName:String, pOptions:Object=null) : void {
			if(!part) { return; }
			if(part is MovieClip) {
				/*if(pData.colors != null && !pData.isSkin()) {
					GameAssets.colorItem({ obj:part, colors:pData.colors });
				}
				else { GameAssets.colorDefault(part); }*/
				
				if((pData.type == ITEM.HAIR || pData.type == ITEM.BEARD) && pOptions.hairColor != null) {
					GameAssets.applyColorToObject(part,  pOptions.hairColor);
				}
				GameAssets.colorItem({ obj:part, color: pOptions.skinColor, name:"$0" });
				GameAssets.colorItem({ obj:part, color: pData.color < 0 ? pOptions.secondaryColor : pData.color, name:"$2" });
			}
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
