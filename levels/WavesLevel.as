package levels
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * Wave of zombie keeps spawning.
	 * Fight them.
	 *
	 * @author Neamar
	 */
	public final class WavesLevel extends TimedLevel
	{
		private var spawner:Timer;
		
		private var currentWave:int = 0;
		private var wavesDelay:Vector.<int>;
		private var wavesData:Vector.<Vector.<LevelSpawn>>;
		
		public function WavesLevel(params:LevelParams)
		{
			super(params);
			
			wavesDelay = params.wavesDelay;
			wavesData = params.wavesDatas;
			
			spawner = new Timer(wavesDelay[currentWave]);
			spawner.addEventListener(TimerEvent.TIMER, onSpawner);
			spawner.start();
		}
		
		public override function destroy():void
		{
			spawner.removeEventListener(TimerEvent.TIMER, onSpawner);
			spawner.stop();
			
			super.destroy();
		}
		
		/**
		 * Spawn new zombie wave
		 * @param	e
		 */
		protected function onSpawner(e:TimerEvent):void
		{
			//Add the zombies
			generateZombies(wavesData[currentWave]);
			
			currentWave++;
			if (wavesDelay.length == currentWave)
			{
				trace("end of waves");
				spawner.removeEventListener(TimerEvent.TIMER, onSpawner);
				spawner.stop();
			}
			else
			{
				spawner.delay = wavesDelay[currentWave];
			}
			
			// Zombie limit exceeded
			// TODO : implement in the XML ?
			if (zombies.length > 100)
			{
				dispatchEvent(new Event(Level.LOST));
			}

		}
		
		protected override function onTimer(e:TimerEvent):void
		{
			if (zombies.length == 0 && wavesDelay.length == 0)
			{
				dispatchWin();
			}
		}
	}

}