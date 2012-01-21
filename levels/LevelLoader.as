package levels
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * Load a level.
	 * Dispatch Event.COMPLETE when every assets has been loaded
	 * @author Neamar
	 */
	public final class LevelLoader extends EventDispatcher
	{
		public static const BASE_URL:String = '../src/assets/levels';
		
		/**
		 * XML datas
		 */
		public var xml:XML;
		
		// When this var hits 0, every external assets had been loaded. Start the level.
		private var remainingResourcesToLoad:int = 0;

		/**
		 * Parameters to use for the level
		 */
		private var params:LevelParams = new LevelParams();
		
		/**
		 * The level, once built.
		 * If called before the COMPLETE event, will be null.
		 */
		private var level:Level = null;
		
		public function LevelLoader(levelName:String)
		{
			//Load associated XML :
			var loader:URLLoader = new URLLoader(new URLRequest(buildUrl(levelName) + '/level-def.xml'));
			loader.addEventListener(Event.COMPLETE, loadLevelData );
		}
		
		/**
		 * This function should be called after the Event.COMPLET has been dispatched.
		 * Else, it returns null.
		 * 
		 * @return the level
		 */
		public function getLevel():Level 
		{
			return level;
		}
		/**
		 * Load a level from XML file
		 * @param	e
		 */
		private function loadLevelData(e:Event):void
		{
			xml = new XML(e.target.data);
			
			// Load external assets asap
			var bitmapUrl:String = buildUrl(xml.technical.name) + '/' + xml.visible.bitmap;
			var hitmapUrl:String = buildUrl(xml.technical.name) + '/' + xml.technical.hitmap;
			loadAssets(bitmapUrl, function(e:Event):void { params.bitmap = e.target.content } );
			loadAssets(hitmapUrl, function(e:Event):void { params.hitmap = e.target.content } );
			
			// Read other parameters and parse them into LevelParams
			//Load success type
			var successXML:XML = xml.technical.success[0];
			if (successXML.@on == 'accessing_area')
			{
				var successAreaXML:XML = successXML.area[0];
				params.LevelClass = AccessingAreaLevel;
				params.successArea = new Rectangle(successAreaXML.@x, successAreaXML.@y, successAreaXML.@width, successAreaXML.@height);
			}
			
			//Load player info
			var playerXML:XML = xml.technical.player[0];
			params.playerStartX = playerXML.@x;
			params.playerStartY = playerXML.@y;
			if(playerXML.@resolution.toXMLString() != "")
				params.playerStartResolution = playerXML.@resolution;
			//Number of zombies per area
			for each(var spawnAreaXML:XML in xml.technical.zombies[0].elements('spawn-zone'))
			{
				params.zombiesDensity.push(spawnAreaXML.@number);
				params.zombiesLocation.push(new Rectangle(spawnAreaXML.@x, spawnAreaXML.@y, spawnAreaXML.@width, spawnAreaXML.@height));
			}
		}
		
		private function loadAssets(url:String, callback:Function):void
		{
			remainingResourcesToLoad++;

			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			
			//Execute defined callback function when complete
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, callback );
			
			//Shall we wait for anymore assets to load ?
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				remainingResourcesToLoad--;
			
				if (remainingResourcesToLoad == 0)
				{
					buildLevel();
				}
			});
		}
		
		private function buildLevel():void
		{
			level = new params.LevelClass(params);
			
			dispatchEvent(new Event(Event.COMPLETE));
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