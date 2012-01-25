package achievements 
{
	import levels.Level;
	/**
	 * Base class for all achievements.
	 * 
	 * @author Neamar
	 */
	public class Achievement 
	{
		
		public function Achievement() 
		{
			
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