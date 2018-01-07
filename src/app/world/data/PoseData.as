package app.world.data
{
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;

	public class PoseData extends ItemData
	{
		public function PoseData(pData:Object) {
			super(pData);
		}
		
		// pOptions = { ?facingForward:Boolean=true, ?sex:SEX }
		public function getClass(pOptions:Object=null) : Class {
			var facingForward = GameAssets.facingForward;
			var sex = GameAssets.sex;
			if(pOptions != null) {
				if(pOptions.facingForward) { facingForward = pOptions.facingForward; }
				if(pOptions.sex) { sex = pOptions.sex; }
			}
			/*var tSex = sex == SEX.MALE ? "H" : "F";
			var tFacing = facingForward ? "" : "D";*/
			
			/*var tClass = Fewf.assets.getLoadedClass( "$Anim"+strReplace(_assetID, "{0}", tSex)+tFacing );*/
			var tClass = Fewf.assets.getLoadedClass( "$Anim"+_assetID );
			return tClass;
		}
		
		function strReplace(str:String, search:String, replace:String):String {
			return str.split(search).join(replace);
		}
	}
}
