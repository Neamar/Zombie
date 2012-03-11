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
		
		public function setGame(game:Game):void
		{
			this.game = game;
		}
		
		public function get level():Level
		{
			return game.level;
		}
		
		public function get player():Player
		{
			return game.level.player;
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