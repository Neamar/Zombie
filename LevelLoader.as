package  
{
	import components.lights.Bulb;
	import components.lights.Light;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLNode;
	/**
	 * Load a level.
	 * Dispatch Event.COMPLETE when every assets has been loaded
	 * @author Neamar
	 */
	public final class LevelLoader extends EventDispatcher
	{
		public static const BASE_URL:String = '../src/assets/levels';
		
		/**
		 * XML datas of the level
		 */
		private var xml:XML;
		
		/**
		 * Number of resources still loading
		 * 
		 * When this var hits 0, every external assets had been loaded. Start the level.
		 */
		private var remainingResourcesToLoad:int = 0;
	
		private var bitmap:Bitmap;
		private var hitmap:Bitmap;
		private var lights:Vector.<Light>;
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
			
			// Start loading external assets
			var bitmapUrl:String = buildUrl(xml.technical.name) + '/' + xml.visible.bitmap;
			var hitmapUrl:String = buildUrl(xml.technical.name) + '/' + xml.technical.hitmap;
			loadAssets(bitmapUrl, function(e:Event):void { bitmap = e.target.content } );
			loadAssets(hitmapUrl, function(e:Event):void { hitmap = e.target.content } );
			
			//Setting up the light
			lights = new Vector.<Light>();
			var light:Bulb = new Bulb();
			light.x = 1729;
			light.y = 100;
			light.intensity = 150;
			light.flicker = .5;
			lights.push(light);
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
			level = new Level(bitmap, hitmap, lights);
			
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