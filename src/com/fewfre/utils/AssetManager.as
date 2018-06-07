package com.fewfre.utils
{
	import com.fewfre.events.FewfEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.net.URLLoader;
	
	public class AssetManager extends Sprite
	{
		// Constants
		public static const LOADING_FINISHED:String = "asset_loading_finished";
		public static const PACK_LOADED:String = "asset_pack_loaded";
		
		// Storage
		internal var _cacheBreaker:String;
		
		internal var _urlsToLoad:Array;
		internal var _loadedStuffCallbacks:Array; // Store all loaded stuff in here to allow async loading, but still force loading in specified order.
		internal var _itemsLeftToLoad:Number;
		
		internal var _applicationDomains:Array;
		internal var _loadedData:Dictionary;
		
		// Properties
		public function get itemsLeftToLoad():int { return _itemsLeftToLoad; }//_urlsToLoad.length; }
		
		public function AssetManager() {
			super();
			_applicationDomains = [];
			_loadedData = new Dictionary();
			_cacheBreaker = null;
		}
		
		/****************************
		* Loading
		*****************************/
			public function load(pURLs:Array, pCacheBreaker:String=null) : void {
				_urlsToLoad = pURLs;
				_itemsLeftToLoad = _urlsToLoad.length;
				_loadedStuffCallbacks = [];
				_cacheBreaker = pCacheBreaker;
				var i = -1;
				while(_urlsToLoad.length > 0) { i++;
					_loadedStuffCallbacks.push(null);
					_loadNextItem(i);
				}
			}
			
			private function _loadNextItem(i:int) : void {
				var tItem:* = _urlsToLoad.shift();
				if(!(tItem is Array)) {
					_newLoader( i, tItem );
				} else {
					_newLoader( i, tItem[0], tItem[1] );
				}
			}
			
			private function _newLoader(pIndex:int, pUrl:String, pOptions:Object=null) : void {
				var tUrlParts:Array = pUrl.split("/").pop().split("."), tName:String = tUrlParts[0], tType:String = tUrlParts[1];
				if(_cacheBreaker && ExternalInterface.call("eval", "window.location.href")) {
					pUrl += "?cb="+_cacheBreaker;
				}
				switch(tType) {
					case "swf":
					case "swc":
						var tLoader:Loader = new Loader();
						tLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{ _onAssetsLoaded(pIndex, e, arguments.callee); });//, _onAssetsLoaded);
						tLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{ _onLoadError(e as IOErrorEvent, arguments.callee); });//, _onLoadError);
						tLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onProgress);
						var tRequest:URLRequest = new URLRequest(pUrl);
						tRequest.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
						if(pOptions && pOptions.useCurrentDomain) {
							var tLoaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
							tLoader.load(tRequest, tLoaderContext);
						} else {
							tLoader.load(tRequest);
						}
						break;
					case "json":
						var tUrlLoader:URLLoader = new URLLoader();
						tUrlLoader.addEventListener(Event.COMPLETE, function(e:Event):void{ _onJsonLoaded(pIndex, e, tName, arguments.callee); });
						tUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{ _onURLLoadError(e as IOErrorEvent, pUrl, arguments.callee); });
						tUrlLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
						var tRequest2:URLRequest = new URLRequest(pUrl);
						tRequest2.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
						tUrlLoader.load(tRequest2);
						break;
					default:
						trace("[AssetManager](_newLoader) Unknown file type: "+tType);
						break;
				}
			}
			
			private function _destroyAssetLoader(pLoader:Loader, pOnComplete) : void {
				pLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, pOnComplete);//_onAssetsLoaded);
				pLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
				pLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
			}
			
			private function _destroyURLLoader(pLoader:URLLoader, pOnComplete) : void {
				pLoader.removeEventListener(Event.COMPLETE, pOnComplete);
				pLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onURLLoadError);
				pLoader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
			}
			
			private function _onAssetsLoaded(pIndex:int, e:Event, pOnComplete) : void {
				_loadedStuffCallbacks[pIndex] = function(){
					_applicationDomains.push( MovieClip(e.target.content).loaderInfo.applicationDomain );
					_destroyAssetLoader(e.target.loader, pOnComplete);
				};
				_checkIfLoadingDone();
			}
			
			private function _onJsonLoaded(pIndex:int, e:Event, pKey:String, pOnComplete) : void {
				_loadedStuffCallbacks[pIndex] = function(){
					_loadedData[pKey] = JSON.parse(e.target.data);
					_destroyURLLoader(e.target as URLLoader, pOnComplete);
				};
				_checkIfLoadingDone();
			}
			
			private function _onLoadError(e:IOErrorEvent, pOnComplete) : void {
				trace("[AssetManager](_onLoadError) ERROR("+e.errorID+"): Was not able to load url: "+e.target.url);
				_destroyAssetLoader(e.target.loader, pOnComplete);
				_checkIfLoadingDone();
			}
			
			private function _onURLLoadError(e:IOErrorEvent, pUrl:String, pOnComplete) : void {
				trace("[AssetManager](_onLoadError) ERROR("+e.errorID+"): Was not able to load url: "+pUrl);
				_destroyURLLoader(e.target as URLLoader, pOnComplete);
				_checkIfLoadingDone();
			}
			
			private function _onProgress(e:ProgressEvent) : void {
				dispatchEvent(e);
				//trace("Loading: "+String(Math.floor(e.bytesLoaded/1024))+" KB of "+String(Math.floor(e.bytesTotal/1024))+" KB.");
			}
			
			private function _checkIfLoadingDone() : void {
				_itemsLeftToLoad--;
				dispatchEvent(new FewfEvent(PACK_LOADED, { itemsLeftToLoad:itemsLeftToLoad }));
				if(itemsLeftToLoad > 0) {
					// _loadNextItem();
				} else {
					trace("[AssetManager](_checkIfLoadingDone) All resources loaded.");
					for each(var pCallback in _loadedStuffCallbacks) {
						if(pCallback != null) { pCallback(); }
					}
					_loadedStuffCallbacks = null;
					trace("[AssetManager](_checkIfLoadingDone) All resources stored.");
					setTimeout(function():void{ dispatchEvent(new Event(AssetManager.LOADING_FINISHED)); }, 0);
				}
			}
		
		/****************************
		* Access Assets
		*****************************/
			public function getData(pKey:String) : * {
				return _loadedData[pKey];
			}
			
			public function getLoadedClass(pName:String, pTrace:Boolean=false) : Class {
				for(var i:int = 0; i < _applicationDomains.length; i++) {
					if(_applicationDomains[i].hasDefinition(pName)) {
						return _applicationDomains[i].getDefinition( pName ) as Class;
					}
				}
				if(pTrace) { trace("[AssetManager](getLoadedClass) ERROR: No Linkage by name: "+pName); }
				return null;
			}
	}
}
