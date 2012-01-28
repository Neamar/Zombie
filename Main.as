package 
{
	import entity.Zombie;
	import entity.ZombieAnim;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	 * ...
	 * @author Neamar
	 */
	[SWF(width="600", height="400", backgroundColor="#000000",frameRate="30")]
	public final class Main extends Sprite 
	{
		public static var stage:Stage;
		public static const WIDTH:int = 400;
		public static const WIDTH2:int = WIDTH / 2;
		
		public static const FIRST_LEVEL:String = "1";
		
		public var level:Level;
		public var monitor:Monitor;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			stage.frameRate = 3;
			var za:ZombieAnim;
				
			for (var i:int = 0; i <= 6; i++)
			{
				za = new ZombieAnim();
				za.x = 50 + 75 * i;
				za.y = 150;
				za.setState(i);
				addChild(za);
				addEventListener(Event.ENTER_FRAME, za.onMove);
			}
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
			
			if (monitor)
			{
				monitor.x = 0;
				monitor.y = y;
			}
		}
	}
	
}