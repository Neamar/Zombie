package achievements 
{
	import entity.Player;
	import levels.Level;
	/**
	 * Base class for all achievements.
	 * 
	 * @author Neamar
	 */
	public class Achievement 
	{
		protected var game:Game;
		protected var level:Level;
		protected var player:Player;
		
		public function setGame(game:Game):void
		{
			this.game = game;
			level = game.level;
			player = level.player;
		}
		
		/**
		 * Define the parameters for the achievement
		 * @param	params
		 */
		public function setParams(params:Array):void
		{
			throw new Error("Call to an abstract method.");
		}
		
		/**
		 * Apply the achievement to the game
		 */
		public function apply():void
		{
			throw new Error("Call to an abstract method.");
		}
		
	}

}