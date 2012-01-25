package achievements.weapon 
{
	import weapon.Weapon;
	/**
	 * Unlock a new weapon by adding it to the player arsenal
	 * 
	 * @author Neamar
	 */
	public final class UnlockAchievement
	{
		protected var weapon:Weapon;
		
		public override function setParams(params:Array):void
		{
			//weapon = new params[0]();
		}
		
		public override function apply():void
		{
			
		}
	}

}