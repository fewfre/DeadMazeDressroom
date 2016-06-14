package 
{
	import flash.display.*;
	import flash.geom.*;
	
	public class SkinData extends ShopItemData
	{
		// Storage
		public var hair			: ShopItemData; // E_#
		public var head			: Class; // M_#_T_1 / M_#_T_2 (female / male)
		
		public var torso		: Class; // M_#_TS_1 / M_#_TS_2 (female / male)
		public var pelvis		: Class; // M_#_B_1 / M_#_B_2 (female / male)
		
		public var upperArm1	: Class; // M_#_BS1_1 / M_#_BS1_2 (female / male)
		public var upperArm2	: Class; // M_#_BS2_1 / M_#_BS2_2 (female / male)
		public var lowerArm1	: Class; // M_#_BI1 / M_#_BI2 (female / male)
		public var lowerArm2	: Class; // M_#_BI1 / M_#_BI2 (female / male)
		
		public var hand1		: Class; // M_#_M1
		public var hand2		: Class; // M_#_M2
		
		public var upperLeg1	: Class; // M_#_JS1
		public var upperLeg2	: Class; // M_#_JS2
		public var lowerLeg1	: Class; // M_#_JI1
		public var lowerLeg2	: Class; // M_#_JI2
		public var foot1		: Class; // M_#_P1
		public var foot2		: Class; // M_#_P2
		
		// Constructor
		public function SkinData(pID:int, pGender:String) {
			super({ id:pID, type:ItemType.SKIN, gender:pGender });
			
			_initSkin();
		}
		
		private function _initSkin() : void {
			classMap = {};
			var tSex = gender == GENDER.FEMALE ? "1" : "2";
			
			classMap.T	= head		= Main.assets.getLoadedClass( "M_"+id+"_T_"+tSex );
			
			// Hair may be replaced, so we don't want it in the classMap.
			hair		= new ShopItemData({ type:ItemType.HAIR, classMap:{ T:Main.assets.getLoadedClass( "M_"+id+"_C_"+tSex ), CH:Main.assets.getLoadedClass( "M_"+id+"_CB_"+tSex ) } });
			//classMap.T	= Main.assets.getLoadedClass( "M_"+id+"_C_"+tSex );
			//classMap.CH	= Main.assets.getLoadedClass( "M_"+id+"_CB_"+tSex );
			
			classMap.TS	= torso		= Main.assets.getLoadedClass( "M_"+id+"_TS_"+tSex );
			classMap.B	= pelvis	= Main.assets.getLoadedClass( "M_"+id+"_B_"+tSex );
			
			
			classMap.BS1= upperArm1	= Main.assets.getLoadedClass( "M_"+id+"_BS1_"+tSex );
			classMap.BS2= upperArm2	= Main.assets.getLoadedClass( "M_"+id+"_BS2_"+tSex );
			classMap.BI1= lowerArm1	= Main.assets.getLoadedClass( "M_"+id+"_BI"+tSex );
			classMap.BI2= lowerArm2	= MovieClip;//Main.assets.getLoadedClass( "M_"+id+"_BI"+tSex );
			
			classMap.M1	= hand1		= Main.assets.getLoadedClass( "M_"+id+"_M1" );
			classMap.M2	= hand2		= Main.assets.getLoadedClass( "M_"+id+"_M2" );
			
			classMap.JS1= upperLeg1	= Main.assets.getLoadedClass( "M_"+id+"_JS1" );
			classMap.JS2= upperLeg2	= Main.assets.getLoadedClass( "M_"+id+"_JS2" );
			classMap.JI1= lowerLeg1	= Main.assets.getLoadedClass( "M_"+id+"_JI1" );
			classMap.JI2= lowerLeg2	= Main.assets.getLoadedClass( "M_"+id+"_JI2" );
			classMap.P1	= foot1		= Main.assets.getLoadedClass( "M_"+id+"_P1" );
			classMap.P2	= foot2		= Main.assets.getLoadedClass( "M_"+id+"_P2" );
		}
		
		public function getPartClassFromType(pType:String) : Class {
			switch(pType) {
				case "T":	return head;
				case "CH":	return MovieClip;
				case "TS":	return torso;
				case "B":	return pelvis;
				case "BS1":	return upperArm1;
				case "BS2":	return upperArm2;
				case "BI1":	return lowerArm1;
				case "BI2":	return lowerArm2;
				case "M1":	return hand1;
				case "M2":	return hand2;
				case "JS1":	return upperLeg1;
				case "JS2":	return upperLeg2;
				case "JI1":	return lowerLeg1;
				case "JI2":	return lowerLeg2;
				case "P1":	return foot1;
				case "P2":	return foot2;
				default: {
					trace("[SkinData](getPartFromType) Unknown skin part: "+pType);
					return MovieClip;
				}
			}
		}
		
		// pData = { pose:MovieClip, hair:ShopItemData[optional],  }
		public function applySkinToPose(pData:Object) {
			var tPose:MovieClip = pData.pose;
			var tHairData:ShopItemData = pData.hair ? pData.hair : this.hair;
			
			var part:MovieClip = null;
			var hairPart:DisplayObject = null;
			var tChild:* = null;
			var tChildType:String = null;
			
			var i:Number = 0;
			while (i < tPose.numChildren) {
				tChild = tPose.getChildAt(i);
				tChildType = tChild.name;
				
				switch (tChildType){
					case "_Arme": if(objectData) { this.object = part = tChild.addChild(new objectData.itemClass()); } break;
					case "CH": if(tHairData.itemClass2) { hairPart = tChild.addChild(new tHairData.itemClass2()); } break;
					case "T": {
						part = tChild.addChild(new (skinData.getPartClassFromType(tChildType))());
						hairPart = tChild.addChild(new tHairData.itemClass());
						break;
					} // else check for default skin hair
					default: part = tChild.addChild(new (skinData.getPartClassFromType(tChildType))()); break;
				}
				if(part && part is MovieClip) Main.costumes.colorItem({ mc:part, color:skinColor, name:"$0" });
				if(part && part is MovieClip) Main.costumes.colorItem({ mc:part, color:secondaryColor, name:"$2" });
				if(hairPart) Main.costumes.applyColorToObject(hairPart, hairColor);
				
				part = null;
				i++;
			}
			return tPose;
		}
	}
}