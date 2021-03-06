﻿package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * "When in doubt, call an airstrike."
	 *
	 * TODO : run FD Analyzer
	 * TODO : watch for useless static properties
	 *
	 * @author Neamar
	 */
	[SWF(width="800", height="500", backgroundColor="#000000", frameRate="30")]
	
	public final class Main extends Sprite
	{
		/**
		 * Width used by the game.
		 * TODO : pause game if window is smaller
		 */
		public static const WIDTH:int = 500;
		
		/**
		 * Area covered by the player's light; technically this is the gaming area since
		 * anything beyond is here only to provide graphical background
		 */
		public static const GAMING_AREA:int = 400;
		
		/**
		 * Half width, pre-computed
		 */
		public static const WIDTH2:int = WIDTH / 2;
		
		/**
		 * Half-width of the gaming area, pre-computed
		 */
		public static const GAMING_AREA2:int = GAMING_AREA / 2;
		
		/**
		 * Current game being played
		 */
		protected var game:Game;
		
		/**
		 * Monitor game data for debug.
		 */
		protected var monitor:Monitor;
		
		public function Main()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
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