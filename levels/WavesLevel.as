package levels 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * Wave of zombie keeps spawning.
	 * Fight them.
	 * 
	 * @author Neamar
	 */
	public final class WavesLevel extends KillAllLevel 
	{
		public var spawner:Timer;
		public function WavesLevel(params:LevelParams) 
		{
			super(params);
			
			spawner = new Timer(delay);
            spawner.addEventListener(TimerEvent.TIMER, onSpawner);
            spawner.start();
		}
		
		/**
		 * Spawn new zombie wave
		 * @param	e
		 */
		protected function onSpawner(e:TimerEvent):void
		{
			trace("new wave !");
		}
	}

}