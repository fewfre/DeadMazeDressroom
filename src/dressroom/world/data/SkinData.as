package dressroom.world.data
{
	import dressroom.data.*;
	import flash.display.*;
	import flash.geom.*;
	
	public class SkinData extends ItemData
	{
		// Storage
		public var hair			: ItemData;
		
		// Constructor
		public function SkinData(pID:String, pGender:String) {
			super({ id:pID, type:ITEM.SKIN, gender:pGender });
			
			classMap = {};
			var tSex = gender == GENDER.FEMALE ? "1" : "2";
			
			// Hair may be replaced, so we don't want it in the classMap.
			hair		= new ItemData({ type:ITEM.HAIR, classMap:{ T:Main.assets.getLoadedClass( "M_"+id+"_C_"+tSex ), CH:Main.assets.getLoadedClass( "M_"+id+"_CB_"+tSex ) } });
			//classMap.T	= Main.assets.getLoadedClass( "M_"+id+"_C_"+tSex );
			//classMap.CH	= Main.assets.getLoadedClass( "M_"+id+"_CB_"+tSex );
			
			// Head
			classMap.T		= Main.assets.getLoadedClass( "M_"+id+"_T_"+tSex );
			// Torso / Pelvis
			classMap.TS		= Main.assets.getLoadedClass( "M_"+id+"_TS_"+tSex );
			classMap.B		= Main.assets.getLoadedClass( "M_"+id+"_B_"+tSex );
			
			// Upper Arms
			classMap.BS1	= Main.assets.getLoadedClass( "M_"+id+"_BS1_"+tSex );
			classMap.BS2	= Main.assets.getLoadedClass( "M_"+id+"_BS2_"+tSex );
			// Lower Arms
			classMap.BI1	= Main.assets.getLoadedClass( "M_"+id+"_BI1" );
			classMap.BI2	= Main.assets.getLoadedClass( "M_"+id+"_BI2" );
			// Hands
			classMap.M1		= Main.assets.getLoadedClass( "M_"+id+"_M1" );
			classMap.M2		= Main.assets.getLoadedClass( "M_"+id+"_M2" );
			
			// Upper Legs
			classMap.JS1	= Main.assets.getLoadedClass( "M_"+id+"_JS1" );
			classMap.JS2	= Main.assets.getLoadedClass( "M_"+id+"_JS2" );
			// Lower Legs
			classMap.JI1	= Main.assets.getLoadedClass( "M_"+id+"_JI1" );
			classMap.JI2	= Main.assets.getLoadedClass( "M_"+id+"_JI2" );
			// Feet
			classMap.P1		= Main.assets.getLoadedClass( "M_"+id+"_P1" );
			classMap.P2		= Main.assets.getLoadedClass( "M_"+id+"_P2" );
			
			if(gender) this.id += (gender == GENDER.FEMALE ? "F" : "M");
		}
	}
}