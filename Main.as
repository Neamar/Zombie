package 
{
	import entity.Zombie;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import levels.Level;
	import levels.LevelLoader;
	
	/**
	 * ...
	 * @author Neamar
	 */
	[SWF(width="400", height="400", backgroundColor="#000000",frameRate="30")]
	public class Main extends Sprite 
	{
		public static var stage:Stage;
		public static const WIDTH:int = 400;
		public static const WIDTH2:int = WIDTH / 2;
		
		public static const FIRST_LEVEL:String = "1";
		
		public var level:Level;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// static initialisation
			Main.stage = this.stage;
			Zombie.init();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, toggleQuality);
			
			//Forbid stage resizing
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			stage.dispatchEvent(new Event(Event.RESIZE));
			
			//Load first level
			prepareLevel(FIRST_LEVEL);
			
			//For debug :
			var movieMonitor:Monitor = new Monitor();
			addChild(movieMonitor);
			movieMonitor.addEventListener(MouseEvent.CLICK, function(e:Event):void { movieMonitor.alpha = .3; } );
		}
		
		/**
		 * Call when the WIN event is dispatched
		 */
		public function gotoNextLevel(e:Event):void
		{
			removeChild(level);
			level.removeEventListener(Level.WIN, gotoNextLevel);
			
			prepareLevel(level.nextLevelName);
		}
		
		/**
		 * Call when a new level should be loaded
		 * @param	levelName
		 */
		public function prepareLevel(levelName:String):void
		{
			//Load xml for current level
			var loader:LevelLoader = new LevelLoader(levelName);
			loader.addEventListener(Event.COMPLETE, addLevel);
		}
		
		/**
		 * Call when a new level is ready for play
		 * @param	e
		 */
		public function addLevel(e:Event):void
		{
			var loader:LevelLoader = e.target as LevelLoader;
			loader.removeEventListener(Event.COMPLETE, addLevel);
			
			level = loader.getLevel()
			level.addEventListener(Level.WIN, gotoNextLevel );
			addChild(level);
		}
		
		/**
		 * TODO : remove.
		 * @param	e
		 */
		private function toggleQuality(e:KeyboardEvent):void
		{
			if (e.keyCode == 81)
			{
				if (stage.quality == StageQuality.HIGH)
				{
					stage.quality = StageQuality.LOW;
				}
				else
				{
					stage.quality = StageQuality.HIGH;
				}
			}
			else if (e.keyCode == 84)
			{
				level.toggleDebugMode();
			}
		}
		
		private function onResize(e:Event):void
		{
			this.x = stage.stageWidth / 2 - Main.WIDTH2;
			this.y = stage.stageHeight / 2 - Main.WIDTH2;
		}
	}
	
}