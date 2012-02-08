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
		
		/**
		 * Current wave number
		 */
		private var currentWave:int = 0;
		
		/**
		 * Delay between two consecutives waves.
		 * The first value is the delay between level start and first wave, second value between first and second wave, ad lib.
		 */
		private var wavesDelay:Vector.<int>;
		
		/**
		 * Datas. Respects the same structure as initialSpawns
		 * @see initialSpawns
		 */
		private var wavesData:Vector.<Vector.<LevelSpawn>>;
		
		/**
		 * Maximum number of zimbies before the level is lost.
		 */
		private var maxNumberOfZombies:int;
		
		public function WavesLevel(params:LevelParams)
		{
			super(params);
			
			wavesDelay = params.wavesDelay;
			wavesData = params.wavesDatas;
			maxNumberOfZombies = params.wavesMaxNumberOfZombies;
			
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
			if (zombies.length > maxNumberOfZombies)
			{
				dispatchEvent(new Event(Level.LOST));
			}

		}
		
		protected override function onTimer(e:TimerEvent):void
		{
			if (zombies.length == 0 && currentWave == wavesDelay.length)
			{
				dispatchWin();
			}
		}
	}

}