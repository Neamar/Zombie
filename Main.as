package 
{
	import achievements.AchievementsHandler;
	import entity.Zombie;
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
	 * "When in doubt, call an airstrike."
	 * 
	 * TODO : organize imports
	 * TODO : clean code
	 * TODO : run FD Analyzer
	 * TODO : watch for useless static properties
	 * 
	 * @author Neamar
	 */
	[SWF(width="600", height="400", backgroundColor="#000000",frameRate="30")]
	public final class Main extends Sprite 
	{
		public static const WIDTH:int = 400;
		public static const WIDTH2:int = WIDTH / 2;
		
		/**
		 * Current game.
		 */
		protected var game:Game;
		
		/**
		 * Monitor game data for debug.
		 */
		protected var monitor:Monitor;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Forbid stage resizing
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			stage.dispatchEvent(new Event(Event.RESIZE));
			
			game = new Game();
			addChild(game);
			
			//For debug :
			monitor = new Monitor(game);
			stage.addChild(monitor);
			
			//Clip (avoid displaying all the level on fullscreen)
			scrollRect = new Rectangle(0, 0, Main.WIDTH, Main.WIDTH);
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