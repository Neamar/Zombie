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
		public static const HEIGHT:int = 400;
		public static const HEIGHT2:int = HEIGHT / 2;
		public static const LEVEL_WIDTH:int = 1934;
		public static const LEVEL_HEIGHT:int = 1094;
		public static const ZOMBIES_NUMBER:int = 200;
		
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
			
			//Load xml for current level
			var loader:LevelLoader = new LevelLoader(FIRST_LEVEL);
			loader.addEventListener(Event.COMPLETE, addLevel);
			
			//For debug :
			var movieMonitor:MovieMonitor = new MovieMonitor();
			addChild(movieMonitor);
			movieMonitor.addEventListener(MouseEvent.CLICK, function(e:Event):void { movieMonitor.alpha = .3; } );
		}
		
		public function addLevel(e:Event):void
		{
			var loader:LevelLoader = e.target as LevelLoader;
			
			level = loader.getLevel()
			addChild(level);
		}
		
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
			this.y = stage.stageHeight / 2 - Main.HEIGHT2;
		}
	}
	
}