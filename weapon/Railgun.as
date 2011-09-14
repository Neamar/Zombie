package weapon 
{
	import entity.Player;
	import entity.Zombie;
	/**
	 * ...
	 * @author Neamar
	 */
	public class Railgun extends Weapon
	{
		public function Railgun(level:Level, player:Player) 
		{
			cooldown = Main.stage.frameRate;
			super(level, player);
		}
		
		public override function fire():int		{
			super.fire();
			raycast(0);
			
			return 15;
		}
		
		public override function shoot(zombie:Zombie):Boolean
		{
			super.shoot(zombie);
			
			//Return true so as not to stop raycasting. See raycast() function.
			return true;
		}
	}

}