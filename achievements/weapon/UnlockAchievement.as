package achievements.weapon 
{
	/**
	 * ...
	 * @author Neamar
	 */
	public class UnlockAchievement extends WeaponAchievement
	{
		public override function setParams(params:Array):void
		{
			trace(params);
		}
		
		public override function apply():void
		{
			trace('applied');
		}
	}

}