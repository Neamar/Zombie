package 
{
	import entity.Zombie;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Main extends Sprite 
	{
		public static var stage:Stage;
		public static const WIDTH:int = 400;
		public static const WIDTH2:int = WIDTH / 2;
		public static const HEIGHT:int = 400;
		public static const HEIGHT2:int = HEIGHT / 2;
		public static const LEVEL_WIDTH:int = 1934;
		public static const LEVEL_HEIGHT:int = 1094;
		
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
			
			// entry point
			addChild(new Level());
			
			//For debug :
			var movieMonitor:MovieMonitor = new MovieMonitor();
			addChild(movieMonitor);
			movieMonitor.addEventListener(MouseEvent.CLICK, function(e:Event):void { movieMonitor.alpha = .3; } );
		}
		
		private function toggleQuality(e:KeyboardEvent):void
		{
			if (e.keyCode == 81)
			{
				stage.quality = StageQuality.LOW;
			}
		}
		
	}
	
}