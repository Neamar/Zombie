package sounds 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * ...
	 * @author Paul
	 */
	public final class SoundManager 
	{
		
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_noammo.mp3")]
		public static var handgun_noAmmo:Class;
		
		public static const HANDGUN_NOAMMO:int = 0;
		
		protected static const soundsList:Vector.<Vector.<Class>> = Vector.<Vector.<Class>>(
		[
			Vector.<Class>([handgun_noAmmo])
		]);
		
		/**
		 * Trigger a sound.
		 * @param	soundName id of the sound -- most probably a static constant from this class.
		 * @return a new sound channel to stop the sound
		 */
		public static function trigger(soundId:int):SoundChannel
		{
			if (soundId == -1)
				return null;
				
			var alternativesSound:Vector.<Class> = soundsList[soundId];
			
			var sound:Sound = new alternativesSound[Math.floor(Math.random() * alternativesSound.length)]() as Sound;
			return sound.play();
		}
	}

}