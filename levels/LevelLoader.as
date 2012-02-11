package levels
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filters.BevelFilter;
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
	public final class LevelLoader extends Sprite
	{
		[Embed(source = "../assets/blood.jpg")]
		public static const waitingImage:Class;
		
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
		 * Store total number of bytes for each asset currently downloaded
		 */
		private var totalSize:Dictionary = new Dictionary(true);
		
		/**
		 * Store currently downloaded number of bytes for each asset.
		 */
		private var downloadedSize:Dictionary = new Dictionary(true);
		
		
		/**
		 * Parameters to use for the level
		 */
		public var params:LevelParams = new LevelParams();
		
		/**
		 * Name of the level currently loaded
		 */
		public var levelName:String;
		
		/**
		 * Loads specified level
		 * @param	levelName
		 */
		public function LevelLoader(levelName:String)
		{
			this.levelName = levelName;
			initDisplay();
			
			//Load associated XML :
			var loader:URLLoader = new URLLoader(new URLRequest(buildUrl("level-def.xml")));
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
			updateDisplay(15);
			
			//Clean.
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, loadLevelData);
			
			xml = new XML(e.target.data);
			
			// Load external assets asap
			var bitmapUrl:String = buildUrl(xml.visible.bitmap);
			var hitmapUrl:String = buildUrl(xml.technical.hitmap);
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
			if(xml.technical.success[0]["@display-help"].toXMLString() != "")
				params.displayHelp = true;
			
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
				params.wavesMaxNumberOfZombies = successXML["@max-zombies"];
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
			
			//Monitor progress :
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			//One this one is loaded, shall we wait for anymore assets to load ?
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onResourceLoaded);
		}
		
		/**
		 * Monitor progress and updates the progressbar
		 * @param	e
		 */
		private function onProgress(e:ProgressEvent):void
		{
			totalSize[e.target] = e.bytesTotal;
			downloadedSize[e.target] = e.bytesLoaded;
			
			//Compute progress :
			var v:Number;
			var total:Number = 0;
			var current:Number = 0;
			for each(v in totalSize)
				total += v;
			for each(v in downloadedSize)
				current += v;
			
			updateDisplay(25 + 75 * (current / total));
		
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
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
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
				
				updateDisplay(100);
				
				//Dispatch event
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		
		/**
		 * Helper to build URL
		 * @param	name name of the assets to load
		 * @return absolute path to level
		 */
		private function buildUrl(name:String):String
		{
			return BASE_URL + '/' + levelName + '/' + name;
		}
		
		
		
		/*
		 * Graphics handling
		 */
		
		/**
		 * Initialize this instance to be displayed.
		 */
		protected function initDisplay():void
		{
			var bitmap:Bitmap = new waitingImage();
			addChild(bitmap);
			bitmap.x = Main.WIDTH2 - bitmap.width / 2;
			bitmap.y = Main.WIDTH2 - bitmap.height / 2;
			
			updateDisplay(0);
			
			var progressBar:Shape = new Shape();
			progressBar.x = Main.WIDTH / 4;
			progressBar.y = 3 * Main.WIDTH / 4;
			addChild(progressBar);
		}
		
		/**
		 * Update the display, depending on the percentage of assets loaded
		 * @param	v Progress, from 0 to 100
		 */
		protected function updateDisplay(v:int):void
		{
			alpha = .25 + .75 * v / 100;
			
			if (v != 0)
			{
				var percent:Number = v / 100;
				
				var progressBar:Shape = getChildAt(1) as Shape;
				progressBar.graphics.clear();
				progressBar.graphics.beginFill(0x0000FF);
				progressBar.graphics.drawRoundRectComplex(0, 0, percent * Main.WIDTH / 2, 20, 10, Math.max(0, v - 90), 10, Math.max(0, v - 90));
				progressBar.graphics.endFill();
			}
		}
	}

}