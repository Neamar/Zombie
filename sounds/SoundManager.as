package sounds 
{
	import flash.media.Sound;
	/**
	 * ...
	 * @author Paul
	 */
	public final class SoundManager 
	{
		
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_noammo.mp3")]
		public static var handgun_noAmmo:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_noammo.mp3")]
		public static var handgun_noammo:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_reload.mp3")]
		public static var handgun_reload:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_0.mp3")]
		public static var handgun_shot_0:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_1.mp3")]
		public static var handgun_shot_1:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_2.mp3")]
		public static var handgun_shot_2:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_3.mp3")]
		public static var handgun_shot_3:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_4.mp3")]
		public static var handgun_shot_4:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_5.mp3")]
		public static var handgun_shot_5:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_6.mp3")]
		public static var handgun_shot_6:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_7.mp3")]
		public static var handgun_shot_7:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_8.mp3")]
		public static var handgun_shot_8:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_9.mp3")]
		public static var handgun_shot_9:Class;

		public static const HANDGUN_NOAMMO:int = 0;
		public static const HANDGUN_RELOAD:int = 1;
		public static const HANDGUN_SHOT:int = 2;

		
		protected static const soundsList:Vector.<Vector.<Class>> = Vector.<Vector.<Class>>(
		[
			Vector.<Class>({handgun_noAmmo])
		]);
		
		public static function trigger(soundName:int):void
		{
			var sound:Sound = new soundsList[soundName]() as Sound;
			sound.play();
		}
	}

}