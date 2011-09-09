package 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
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
			// entry point
			Main.stage = this.stage;
			
			addChild(new Level());
			
			addChild(new movieMonitor());
		}
		
	}
	
}