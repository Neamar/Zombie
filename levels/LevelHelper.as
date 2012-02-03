package levels 
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * Display some contextual help to the player.
	 * 
	 * @author Neamar
	 */
	public class LevelHelper
	{
		public var level:Level;
		
		public function LevelHelper(level:Level)
		{
			level.addEventListener(Event.ADDED_TO_STAGE, addListeners);
		}
		
		protected function addListeners(e:Event)
		{
			level.removeEventListener(Event.ADDED_TO_STAGE, addListeners);
			
			//Display first message :
			displayMessage("Press `z` to move forward");
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function displayMessage(msg:String)
		{
			(level.parent as Game).hud.displayMessage(msg, 0xFFFF00);
		}
		
		protected function onKeyDown(e:KeyboardEvent)
		{
			//, `s`to move backward
		}
	}

}