package app
{
	import app.data.*;
	import app.ui.screens.LoaderDisplay;
	import app.world.World;
	
	import com.fewfre.utils.*;

	import flash.display.*;
	import flash.events.*;
	import flash.system.Capabilities;

	public class Main extends MovieClip
	{
		// Storage
		private var _loaderDisplay	: LoaderDisplay;
		private var _world			: World;
		private var _config			: Object;
		private var _defaultLang	: String;

		// Constructor
		public function Main() {
			super();
			Fewf.init(stage);
			
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 10;
			
			BrowserMouseWheelPrevention.init(stage);

			_loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 }) ) as LoaderDisplay;
			
			_startPreload();
		}
		
		private function _startPreload() : void {
			_load([
				"resources/config.json",
			], String( new Date().getTime() ), _onPreloadComplete);
		}
		
		private function _onPreloadComplete() : void {
			_config = Fewf.assets.getData("config");
			_defaultLang = _getDefaultLang(_config.languages.default);
			
			_startInitialLoad();
		}
		
		private function _startInitialLoad() : void {
			_load([
				"resources/i18n/"+_defaultLang+".json",
			], Fewf.assets.getData("config").cachebreaker, _onInitialLoadComplete);
		}
		
		private function _onInitialLoadComplete() : void {
			Fewf.i18n.parseFile(_defaultLang, Fewf.assets.getData(_defaultLang));
			
			_startLoad();
		}
		
		// Start main load
		private function _startLoad() : void {
			var tPacks = [
				["resources/interface.swf", { useCurrentDomain:true }],
				"resources/flags.swf"
			];
			
			var tPack = _config.packs.parts.concat(_config.packs.outfit);
			for(var i:int = 0; i < tPack.length; i++) { tPacks.push("resources/"+tPack[i]); }
			
			_load(tPacks, Fewf.assets.getData("config").cachebreaker, _onLoadComplete);
		}

		private function _onLoadComplete() : void {
			GameAssets.init(_onGameAssetsInitComplete);
		}
		
		private function _onGameAssetsInitComplete() : void {
			_loaderDisplay.destroy();
			removeChild( _loaderDisplay );
			_loaderDisplay = null;
			
			_world = addChild(new World(stage)) as World;
		}
		
		/***************************
		* Helper Methods
		****************************/
		private function _load(pPacks:Array, pCacheBreaker:String, pCallback:Function) : void {
			Fewf.assets.load(pPacks, pCacheBreaker);
			var tFunc = function(event:Event){
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, tFunc);
				pCallback();
				tFunc = null; pCallback = null;
			};
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, tFunc);
		}
		
		private function _getDefaultLang(pConfigLang:String) : String {
			var tFlagDefaultLangExists:Boolean = false;
			// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
			if(Capabilities.language) {
				var tLanguages:Array = _config.languages.list;
				for(var i:Object in tLanguages) {
					if(Capabilities.language == tLanguages[i].code || Capabilities.language == tLanguages[i].code.split("-")[0]) {
						return tLanguages[i].code;
					}
					if(pConfigLang == tLanguages[i].code) {
						tFlagDefaultLangExists = true;
					}
				}
			}
			return tFlagDefaultLangExists ? pConfigLang : "en";
		}
	}
}
