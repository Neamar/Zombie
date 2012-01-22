package levels 
{
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public final class KillAllLevel extends TimedLevel 
	{
		
		public function KillAllLevel(params:LevelParams) 
		{
			super(params);
		}
		
		protected override function onTimer(e:TimerEvent):void
		{
			if (zombies.length == 0)
			{
				dispatchWin();
			}
		}
	}

}