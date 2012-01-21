package levels 
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class AccessingAreaLevel extends Level 
	{
		protected var checker:Timer;
		
		public var successArea:Rectangle;
		public function AccessingAreaLevel(params:LevelParams) 
		{
			super(params);
			this.successArea = params.successArea;
			
			checker = new Timer(2000);
            checker.addEventListener(TimerEvent.TIMER, checkArea);
            checker.start();
		}
		
		protected function checkArea(e:Event):void
		{
			if (successArea.contains(player.x, player.y))
			{
				checker.stop();
				dispatchEvent(new Event(Level.WIN));
			}
		}
	}

}