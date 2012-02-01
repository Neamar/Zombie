package levels
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.Dictionary;
	
	/**
	 * Load a level.
	 * Dispatch Event.COMPLETE when every assets has been loaded
	 * 
	 * @author Neamar
	 */
	public final class LevelLoader extends EventDispatcher
	{
		/**
		 * On which URL shall we load the resources ?
		 */
		public static const BASE_URL:String = '../src/assets/levels';
		
		/**
		 * XML raw datas
		 */
		public var xml:XML;
		
		/**
		 * When this var hits 0, every external assets had been loaded. Start the level.
		 */
		private var remainingResourcesToLoad:int = 0;
		
		/**
		 * Needed for removing the listeners. Without this, every loader keeps a reference to the COMPLETE event,
		 * forbidding the GC to dispose of the Loader & LevelLoader & LevelParams class.
		 */
		private var dict:Dictionary = new Dictionary(true);
		
		/**
		 * Parameters to use for the level
		 */
		public var params:LevelParams = new LevelParams();
		
		/**
		 * Loads specified level
		 * @param	levelName
		 */
		public function LevelLoader(levelName:String)
		{
			//Load associated XML :
			var loader:URLLoader = new URLLoader(new URLRequest(buildUrl(levelName) + '/level-def.xml'));
			loader.addEventListener(Event.COMPLETE, loadLevelData);
		}
		
		/**
		 * This function should be called after the Event.COMPLETE has been dispatched.
		 * Else, the behavior is undefined.
		 *
		 * @return the level
		 */
		public function getLevel():Level
		{
			var level:Level = new params.LevelClass(params);;
			return level;
		}
		
		/**
		 * Load a level from XML file
		 * @param	e
		 */
		private function loadLevelData(e:Event):void
		{
			//Clean.
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, loadLevelData);
			
			xml = new XML(e.target.data);
			
			// Load external assets asap
			var bitmapUrl:String = buildUrl(xml.technical.name) + '/' + xml.visible.bitmap;
			var hitmapUrl:String = buildUrl(xml.technical.name) + '/' + xml.technical.hitmap;
			loadAssets(bitmapUrl, function(e:Event):void
				{
					params.bitmap = e.target.content
				});
			loadAssets(hitmapUrl, function(e:Event):void
				{
					params.hitmap = e.target.content
				});
			
			/**
			 * Read other parameters and parse them into LevelParams
			 */
			//Meta-parameters
			params.nextLevelName = xml.technical["followed-by"][0];
			
			//Load player info
			var playerXML:XML = xml.technical.player[0];
			params.playerStartX = playerXML.@x;
			params.playerStartY = playerXML.@y;
			params.playerMagazines.handgun = playerXML["@handgun-magazines"];
			params.playerMagazines.shotgun = playerXML["@shotgun-magazines"];
			params.playerMagazines.uzi = playerXML["@uzi-magazines"];
			if (playerXML.@resolution.toXMLString() != "")
				params.playerStartResolution = playerXML.@resolution;
			
			//Number of zombies per area at startup
			var spawnZonesXML:XMLList = xml.technical.zombies[0].elements('spawn-zone');
			for each (var spawnZoneXML:XML in spawnZonesXML)
			{
				params.initialSpawns.push(new LevelSpawn(spawnZoneXML));
			}
			
			//Load success type
			var successXML:XML = xml.technical.success[0];
			if (successXML.@on == 'accessing_area')
			{
				var successAreaXML:XML = successXML.area[0];
				params.LevelClass = AccessingAreaLevel;
				params.successArea = new Rectangle(successAreaXML.@x, successAreaXML.@y, successAreaXML.@width, successAreaXML.@height);
			}
			else if (successXML.@on == 'killing_all')
			{
				params.LevelClass = KillAllLevel;
			}
			else if (successXML.@on == 'surviving_waves')
			{
				params.LevelClass = WavesLevel;
				for each (var wave:XML in successXML.wave)
				{
					params.wavesDelay.push(int(wave.@delay.toString()));
					
					var spawnZones:Vector.<LevelSpawn> = new Vector.<LevelSpawn>();
					for each(spawnZoneXML in wave.children())
					{
						spawnZones.push(new LevelSpawn(spawnZoneXML));
					}
					params.wavesDatas.push(spawnZones);
				}
			}
			else
			{
				throw new Error("Success type for the level is unknown.");
			}
		}
		
		private function loadAssets(url:String, callback:Function):void
		{
			remainingResourcesToLoad++;
			
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			
			//Execute defined callback function when complete
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, callback);
			
			//Remember the callback function to clean after ourselves :
			// (weakReference on the addEventListener would simply result in the suppression of our listener...)
			dict[loader.contentLoaderInfo] = callback;
			
			//Shall we wait for anymore assets to load ?
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onResourceLoaded);
		}
		
		/**
		 * Called when a resource finishes loading.
		 * Dispatch the COMPLETE event if it was the last.
		 *
		 * Needs some specific care regarding memory managements and listeners.
		 * @param	e
		 */
		private function onResourceLoaded(e:Event):void
		{
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, onResourceLoaded);
			loaderInfo.removeEventListener(Event.COMPLETE, dict[loaderInfo]);
			loaderInfo.loader.unload();
			dict[loaderInfo] = null;
			
			remainingResourcesToLoad--;
			
			//Are we finished yet ?
			if (remainingResourcesToLoad == 0)
			{
				//Cleanup
				System.disposeXML(xml);
				dict = null;
				
				//Dispatch event
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		
		/**
		 * Helper to build URL
		 * @param	level
		 * @return path to level
		 */
		private function buildUrl(level:String):String
		{
			return BASE_URL + '/' + level;
		}
	}

}