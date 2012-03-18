package sounds 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author Paul
	 */
	public final class SoundManager 
	{
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_noammo.mp3")]
		public static const handgun_noammo_0:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_reload.mp3")]
		public static const handgun_reload_0:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_0.mp3")]
		public static const handgun_shot_0:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_1.mp3")]
		public static const handgun_shot_1:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_2.mp3")]
		public static const handgun_shot_2:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_3.mp3")]
		public static const handgun_shot_3:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_4.mp3")]
		public static const handgun_shot_4:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_5.mp3")]
		public static const handgun_shot_5:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_6.mp3")]
		public static const handgun_shot_6:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_7.mp3")]
		public static const handgun_shot_7:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_8.mp3")]
		public static const handgun_shot_8:Class;
		[Embed(source = "../assets/sounds/weapons/handgun/handgun_shot_9.mp3")]
		public static const handgun_shot_9:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_noammo.mp3")]
		public static const shotgun_noammo_0:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_reload.mp3")]
		public static const shotgun_reload_0:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_0.mp3")]
		public static const shotgun_shot_0:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_1.mp3")]
		public static const shotgun_shot_1:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_10.mp3")]
		public static const shotgun_shot_10:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_11.mp3")]
		public static const shotgun_shot_11:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_12.mp3")]
		public static const shotgun_shot_12:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_2.mp3")]
		public static const shotgun_shot_2:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_3.mp3")]
		public static const shotgun_shot_3:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_4.mp3")]
		public static const shotgun_shot_4:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_5.mp3")]
		public static const shotgun_shot_5:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_6.mp3")]
		public static const shotgun_shot_6:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_7.mp3")]
		public static const shotgun_shot_7:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_8.mp3")]
		public static const shotgun_shot_8:Class;
		[Embed(source = "../assets/sounds/weapons/shotgun/shotgun_shot_9.mp3")]
		public static const shotgun_shot_9:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_noammo.mp3")]
		public static const uzi_noammo_0:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_reload.mp3")]
		public static const uzi_reload_0:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_1.mp3")]
		public static const uzi_shot_1:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_10.mp3")]
		public static const uzi_shot_10:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_11.mp3")]
		public static const uzi_shot_11:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_12.mp3")]
		public static const uzi_shot_12:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_13.mp3")]
		public static const uzi_shot_13:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_14.mp3")]
		public static const uzi_shot_14:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_15.mp3")]
		public static const uzi_shot_15:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_16.mp3")]
		public static const uzi_shot_16:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_2.mp3")]
		public static const uzi_shot_2:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_3.mp3")]
		public static const uzi_shot_3:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_4.mp3")]
		public static const uzi_shot_4:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_5.mp3")]
		public static const uzi_shot_5:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_6.mp3")]
		public static const uzi_shot_6:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_7.mp3")]
		public static const uzi_shot_7:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_8.mp3")]
		public static const uzi_shot_8:Class;
		[Embed(source = "../assets/sounds/weapons/uzi/uzi_shot_9.mp3")]
		public static const uzi_shot_9:Class;
		[Embed(source = "../assets/sounds/weapons/railgun/railgun_noammo.mp3")]
		public static const railgun_noammo_0:Class;
		[Embed(source="../assets/sounds/weapons/railgun/railgun_shot.mp3")]
		public static const railgun_shot_0:Class;
		
		public static const HANDGUN_NOAMMO:int = 0;
		public static const HANDGUN_RELOAD:int = 1;
		public static const HANDGUN_SHOT:int = 2;
		public static const SHOTGUN_NOAMMO:int = 3;
		public static const SHOTGUN_RELOAD:int = 4;
		public static const SHOTGUN_SHOT:int = 5;
		public static const UZI_NOAMMO:int = 6;
		public static const UZI_RELOAD:int = 7;
		public static const UZI_SHOT:int = 8;
		public static const RAILGUN_NOAMMO:int = 9;
		public static const RAILGUN_SHOT:int = 10;
		
		protected static const soundsList:Vector.<Vector.<Class>> = new Vector.<Vector.<Class>>(RAILGUN_SHOT + 1);
		protected static const soundsPlaying:Vector.<SoundChannel> = new Vector.<SoundChannel>(RAILGUN_SHOT + 1);
		
		public static function init():void
		{
			for (var i:int = 0; i < soundsList.length; i++)
			{
				soundsList[i] = new Vector.<Class>();
			}
			
			//Build the sound array using introspection
			var lastEncountered:String = "";
			for each (var s:String in describeType(SoundManager).constant.@name)
			{
				if (SoundManager[s] is Class)
				{
					//Is this sound another instance of the previously encoutered sound ?
					var name:String = s.substr(0, s.lastIndexOf("_")).toUpperCase();

					soundsList[SoundManager[name]].push(SoundManager[s]);
				}
			}
		}
		
		/**
		 * Trigger a sound.
		 * @param	soundName id of the sound -- most probably a static constant from this class.
		 * 
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
		
		/**
		 * Trigger a sound, forbidding repetition of this particulat sound until the current one is finished
		 * @param	soundName id of the sound -- most probably a static constant from this class.
		 * 
		 * @return a new sound channel to stop the sound
		 */
		public static function triggerNoRepeat(soundId:int):SoundChannel
		{
			if (soundsPlaying[soundId] == null)
			{
				var soundChannel:SoundChannel = trigger(soundId);
				soundsPlaying[soundId] = soundChannel;
				soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundCompleted);
				return soundChannel;
			}
			else
				return null;
		}
		
		private static function onSoundCompleted(e:Event):void
		{
			(e.target as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, onSoundCompleted);
			for (var i:int = 0; i < soundsPlaying.length; i++ )
			{
				if (soundsPlaying[i] == e.target)
				{
					soundsPlaying[i] = null;
				}
			}
		}
	}

}