package levels 
{
	import flash.events.TimerEvent;
	
	/**
	 * Kill all zombie to acces next level.
	 * 
	 * @author Neamar
	 */
	public class KillAllLevel extends TimedLevel 
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