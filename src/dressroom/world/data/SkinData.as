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
		public function SkinData(pID:String, pSex:String) {
			super({ id:pID, type:ITEM.SKIN, sex:pSex });

			/*classMap = {};
			var tSex = sex == SEX.FEMALE ? "_1" : "_2";
			var tPrefix = "M_"+id+"_";*/

			// Hair may be replaced, so we don't want it in the classMap.
			/*hair = new ItemData({ type:ITEM.HAIR, classMap:{
				T: Main.assets.getLoadedClass( tPrefix+"C"+tSex ),
				CH: Main.assets.getLoadedClass( tPrefix+"CB"+tSex )
			} });*/

			/*var tSkinParts = [ "T", "TS", "B", "BS1", "BS2", "BI1", "BI2", "M1", "M2", "CO", "JS1", "JS2", "JI1", "JI2", "P1", "P2" ];
			for each(var part in tSkinParts) {
				classMap[part]		= Main.assets.getLoadedClass( tPrefix+part+tSex );
			}*/
			
			/*// Head
			classMap.T		= Main.assets.getLoadedClass( tSk+"T"+tSex );
			// Torso / Pelvis
			classMap.TS		= Main.assets.getLoadedClass( tSk+"TS"+tSex );
			classMap.B		= Main.assets.getLoadedClass( tSk+"B"+tSex );

			// Upper Arms
			classMap.BS1	= Main.assets.getLoadedClass( tSk+"BS1"+tSex );
			classMap.BS2	= Main.assets.getLoadedClass( tSk+"BS2"+tSex );
			// Lower Arms
			classMap.BI1	= Main.assets.getLoadedClass( tSk+"BI1"+tSex );
			classMap.BI2	= Main.assets.getLoadedClass( tSk+"BI2"+tSex );
			// Hands
			classMap.M1		= Main.assets.getLoadedClass( tSk+"M1"+tSex );
			classMap.M2		= Main.assets.getLoadedClass( tSk+"M2"+tSex );

			classMap.CO		= Main.assets.getLoadedClass( tSk+"CO"+tSex );

			// Upper Legs
			classMap.JS1	= Main.assets.getLoadedClass( tSk+"JS1"+tSex );
			classMap.JS2	= Main.assets.getLoadedClass( tSk+"JS2"+tSex );
			// Lower Legs
			classMap.JI1	= Main.assets.getLoadedClass( tSk+"JI1"+tSex );
			classMap.JI2	= Main.assets.getLoadedClass( tSk+"JI2"+tSex );
			// Feet
			classMap.P1		= Main.assets.getLoadedClass( tSk+"P1"+tSex );
			classMap.P2		= Main.assets.getLoadedClass( tSk+"P2"+tSex );*/

			/*if(sex) this.id += (sex == SEX.FEMALE ? "F" : "M");*/
		}
		
		// pOptions = { ?facingForward:Boolean=true, ?sex:SEX }
		public override function getPart(pID:String, pOptions:Object=null) : Class {
			var facingForward = Main.costumes.facingForward;
			var sex = Main.costumes.sex;
			if(pOptions != null) {
				if(pOptions.facingForward) { facingForward = pOptions.facingForward; }
				if(pOptions.sex) { sex = pOptions.sex; }
			}
			var tSex = sex == SEX.MALE ? "_2" : "_1";
			var tFacing = facingForward ? "" : "_dos";
			
			var tClass = Main.assets.getLoadedClass( "M_"+_assetID+"_"+pID+tFacing+tSex );
			return tClass;
		}
	}
}
