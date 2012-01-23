package 
{
	import entity.Zombie;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import levels.Level;
	import levels.LevelLoader;
	
	/**
	 * "When in doubt, call an airstrike."
	 * @author Neamar
	 */
	[SWF(width="400", height="400", backgroundColor="#000000",frameRate="30")]
	public final class Main extends Sprite 
	{
		public static var stage:Stage;
		public static const WIDTH:int = 400;
		public static const WIDTH2:int = WIDTH / 2;
		
		public static const FIRST_LEVEL:String = "1";
		
		public var level:Level;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// Remember the stage and give static access ; some objects needs it to register events.
			//TODO : do they ?
			Main.stage = this.stage;
			
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
			
			scrollRect = new Rectangle(0, 0, Main.WIDTH, Main.WIDTH);
		}
		
		/**
		 * Call when the WIN event is dispatched
		 */
		public function gotoNextLevel(e:Event):void
		{
			removeChild(level);
			level.destroy();
			level.removeEventListener(Level.WIN, gotoNextLevel);
			
			prepareLevel(level.nextLevelName);
		}
		
		/**
		 * Call when a new level should be loaded
		 * @param	levelName
		 */
		public function prepareLevel(levelName:String):void
		{
			//Load current level
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
		
		private function onResize(e:Event):void
		{
			this.x = stage.stageWidth / 2 - Main.WIDTH2;
			this.y = stage.stageHeight / 2 - Main.WIDTH2;
		}
	}
	
}