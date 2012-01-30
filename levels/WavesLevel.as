package levels
{
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
		
		private var wavesDelay:Vector.<int>;
		private var wavesZombiesLocation:Vector.<Vector.<Rectangle>>;
		private var wavesZombiesDensity:Vector.<Vector.<int>>;
		private var wavesBehemothProbability:Vector.<Vector.<int>>;
		private var wavesSatanusProbability:Vector.<Vector.<int>>;
		
		public function WavesLevel(params:LevelParams)
		{
			super(params);
			
			wavesDelay = params.wavesDelay;
			wavesZombiesLocation = params.wavesZombiesLocation;
			wavesZombiesDensity = params.wavesZombiesDensity;
			wavesBehemothProbability = params.wavesBehemothProbability;
			wavesSatanusProbability = params.wavesSatanusProbability;
			
			spawner = new Timer(params.wavesDelay.shift());
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
			trace("new wave !");
			//Add the zombies
			generateZombies(wavesZombiesLocation.shift(), wavesZombiesDensity.shift(), wavesBehemothProbability.shift(), wavesSatanusProbability.shift(), true);
			
			if (wavesDelay.length == 0)
			{
				trace("end of waves");
				spawner.removeEventListener(TimerEvent.TIMER, onSpawner);
				spawner.stop();
			}
			else
			{
				spawner.delay = wavesDelay.shift();
			}
			
			if (zombies.length > 100)
			{
				player.hit(null, 5000);
				trace("YOU DIE. MISERABLY.");
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