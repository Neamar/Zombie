package weapon
{
	import entity.Player;
	import levels.Level;
	
	/**
	 * Jungle style : each even reload is faster
	 * @author Neamar
	 */
	public class JungleStyleWeapon extends Weapon
	{
		/**
		 * Is jungle style enabled ?
		 */
		public var isJungleStyle:Boolean = false;
		
		/**
		 * Are we using the first part of our magazine ?
		 * If yes, future reload will be faster.
		 */
		public var isFirstMagazine:Boolean = true;
		
		/**
		 * Duration (in frames) for a fast reload
		 */
		public var fastReload:int = -1;
		
		/**
		 * Duration (in frames) for a default reload.
		 */
		public var defaultReload:int;
		
		public function JungleStyleWeapon(level:Level, player:Player)
		{
			super(level, player);
		}
		
		public final override function reload():void
		{
			if (!isJungleStyle)
			{
				super.reload();
				return;
			}
			
			//Check if the reloadTime has changed externally
			if (reloadTime != reloadTime && fastReload != reloadTime)
			{
				defaultReload = reloadTime;
				fastReload = 0;
			}
			
			//Switch reload time depending on the situation
			if (magazineNumber > 0 && ammoInCurrentMagazine != magazineCapacity)
			{
				if (isFirstMagazine)
				{
					reloadTime = fastReload;
					isFirstMagazine = false;
				}
				else
				{
					reloadTime = defaultReload;
					isFirstMagazine = true;
				}
				
				super.reload();
			}
		}
	}

}