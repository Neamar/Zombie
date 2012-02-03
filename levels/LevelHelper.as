package levels 
{
	import entity.Player;
	import entity.Zombie;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/**
	 * Display some contextual help to the player.
	 * Warning : this class adds overhead !
	 * Do not use with lots of zombies.
	 * 
	 * @author Neamar
	 */
	public class LevelHelper
	{
		public var level:Level;
		public var player:Player;
		
		protected var hasDisplayed:Object =
		{
			forward:false,
			backward:false,
			reload:false,
			zombieActive:false,
			zombieHitting:false,
			zombieDead:false,
			dead:false,
			_:false
		};
		
		public function LevelHelper(level:Level)
		{
			level.addEventListener(Event.ADDED_TO_STAGE, addListeners);
			this.level = level;
			this.player = level.player;
		}
		
		public function destroy():void
		{
			level.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			level.stage.removeEventListener(MouseEvent.CLICK, onClick);
			level.stage.removeEventListener(Event.ENTER_FRAME, onFrame);
			level.removeEventListener(Level.LOST, onLost);
			level = null;
			player = null;
		}
		
		protected function addListeners(e:Event):void
		{
			level.removeEventListener(Event.ADDED_TO_STAGE, addListeners);
			
			//Display first message :
			displayMessage("Press `z` to move forward", "forward");
			
			level.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			level.stage.addEventListener(MouseEvent.CLICK, onClick);
			level.stage.addEventListener(Event.ENTER_FRAME, onFrame, false, 1);
			level.addEventListener(Level.LOST, onLost);
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode in player.bindings)
			{
				var action:int = player.bindings[e.keyCode];
				if (action == Player.UP)
					displayMessage("Use `s`to move backward", "backward");
			}
		}
		
		protected function onClick(e:MouseEvent):void
		{
			if (player.currentWeapon.ammoInCurrentMagazine == 0)
				displayMessage("You're out of ammo! Use `r` to reload.");
		}
		
		protected function onLost(e:Event):void
		{
			displayMessage("Seems you're dead... try again?", "dead");
		}
		
		protected function onFrame(e:Event):void
		{
			for each(var z:Zombie in level.frameWaker[(level.frameNumber + 1) % level.FRAME_WAKER_LENGTH])
			{
				if (z.currentState == z.STATE_WALKING)
					displayMessage("A zombie saw you ! Aim with the mouse, then `click` to shoot.", "zombieActive");
				if (z.currentState == z.STATE_HITTING || z.currentState == z.STATE_HITTING2)
					displayMessage("He's hitting you! Kill him fast!", "zombieHitting");
				if (z.currentState == z.STATE_DIE || z.currentState == z.STATE_DIE2)
					displayMessage("Nice job, you killed him. Keep going.", "zombieDead");
			}
		}
		
		
		/**
		 * Display specifed message if the associated key in hasDisplayed is false.
		 * Meaning a message will only be displayed once.
		 * @param	key the message identifier, to prevent it from being shown twice
		 * @param 	msg
		 */
		protected function displayMessage(msg:String, key:String = "_"):void
		{
			if (!hasDisplayed[key])
			{
				(level.parent as Game).hud.displayMessage(msg, 0xFFFF00);
				hasDisplayed[key] = true;
			}
			
			//Special key : always displayed.
			hasDisplayed["_"] = false;
		}
	}

}