package sounds 
{
	import flash.media.Sound;
	/**
	 * ...
	 * @author Paul
	 */
	public final class SoundManager 
	{
		
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_noammo.mp3")] public var handgun_noAmmo:Class;
		public static const HANDGUN_NOAMMO:int = 0;
		
		protected static const soundsList:Vector.<Class> = Vector.<Class>(
		[
			handgun_noAmmo
		]);
		
		public static function trigger(soundName:int):void
		{
			var sound:Sound = new soundsList[soundName]() as Sound;
			sound.play();
		}
	}

}