package levels 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * [abstract]
	 * Basis for a level with a timer to check some conditions
	 * 
	 * @author Neamar
	 */
	public class TimedLevel extends Level 
	{
		protected var delay:int = 2000;
		protected var checker:Timer;

		public function TimedLevel(params:LevelParams) 
		{
			super(params);
			
			checker = new Timer(delay);
            checker.addEventListener(TimerEvent.TIMER, onTimer);
            checker.start();
		}
		
		protected function onTimer(e:TimerEvent):void
		{
			throw new Error("Call to abstract method onTimer()");
		}
		
		/**
		 * This function dispatch the WIN event and stop the timer.
		 */
		protected function dispatchWin():void
		{
			checker.stop();
			dispatchEvent(new Event(Level.WIN));
		}
	}

}