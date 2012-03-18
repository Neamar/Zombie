package sounds 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * Handle all music within the application
	 * @author Neamar
	 */
	public final class MusicManager 
	{
		[Embed(source = "../assets/sounds/ambient/0.mp3")]
		private static const ambient0:Class;
	
		private static var musics:Vector.<Class> = Vector.<Class>([ambient0]);
		
		/**
		 * Channel holding current music
		 */
		private static var ambientChannel:SoundChannel = null;
		
		/**
		 * Play music by id
		 * @param	id
		 */
		public static function play(id:int):void
		{
			if (ambientChannel != null)
				stop();
			
			ambientChannel = (new musics[id]() as Sound).play();
		}
		
		public static function stop():void
		{
			ambientChannel.stop();
			ambientChannel = null;
		}
		
	}

}