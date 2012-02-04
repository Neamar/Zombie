package  
{
	import entity.Player;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Head Up Display for the player
	 * 
	 * @author Neamar
	 */
	public final class Hud extends Sprite 
	{
		[Embed(source = "assets/hud/weapons/handgun.png")]
		private static const HandgunHud:Class;
		private static const HandgunBitmap:Bitmap = new HandgunHud();
		
		[Embed(source = "assets/hud/weapons/shotgun.png")]
		private static const ShotgunHud:Class;
		private static const ShotgunBitmap:Bitmap = new ShotgunHud();
		
		[Embed(source = "assets/hud/weapons/railgun.png")]
		private static const RailgunHud:Class;
		private static const RailgunBitmap:Bitmap = new RailgunHud();
		
		[Embed(source = "assets/hud/weapons/uzi.png")]
		private static const UziHud:Class;
		private static const UziBitmap:Bitmap = new UziHud();
		
		private var weaponsOrder:Vector.<Bitmap> = Vector.<Bitmap>([HandgunBitmap, ShotgunBitmap, RailgunBitmap, UziBitmap]);
		private var weaponDisplayed:Bitmap = null;
		
		/**
		 * Text format for the style to use when displaying message
		 */
		protected var textFormat:TextFormat = new TextFormat(null, null, null, true);
		
		/**
		 * Y-coordinate where a message should disappear
		 */
		protected var finalMessagePosition:int = Main.WIDTH - 120;
		
		/**
		 * Last displayed textfield
		 * Stored to avoid overlapping messages
		 */
		protected var lastMessage:TextField = null;
		
		public function Hud() 
		{
		}
		
		public function updateWeapon(e:Event = null):void
		{
			var player:Player = (e.target as Player);
			var weaponToDisplay:Bitmap = weaponsOrder[player.availableWeapons.indexOf(player.currentWeapon)];
			
			if (weaponDisplayed != null && weaponDisplayed != weaponToDisplay)
				removeChild(weaponDisplayed);
				
			addChild(weaponToDisplay);
			weaponToDisplay.x = 5;
			weaponToDisplay.y = Main.WIDTH - weaponToDisplay.height;
			weaponDisplayed = weaponToDisplay;
		}
		
		public function updateBullets(e:Event = null):void
		{
			trace("Bullets: ", (e.target as Player).currentWeapon.ammoInCurrentMagazine);
		}
		
		/**
		 * Display a message
		 * @param	msg
		 */
		public function displayMessage(msg:String, color:int = 0xFFFFFF):void
		{
			var message:TextField = new TextField();
			message.defaultTextFormat = textFormat;
			message.selectable = false;
			message.mouseEnabled = false;
			message.textColor = color;
			message.width = Main.WIDTH;
			message.y = Math.max(Main.WIDTH + 15, (lastMessage == null)?0:lastMessage.y + 25);
			message.autoSize = TextFieldAutoSize.CENTER;
			message.multiline = false;
			message.filters = [new BlurFilter(0, 0)];

			addChild(message);
			message.text = msg;
			
			message.addEventListener(Event.ENTER_FRAME, moveMessage);
			
			lastMessage = message;
		}
		
		protected function moveMessage(e:Event):void
		{
			var message:TextField = (e.target as TextField);
			message.y -=2;
			
			/**
			 * Rentrer dans la zone "à effets" pour faire disparaître le message
			 */
			if (message.y <= finalMessagePosition + 90)
			{
				if (message.y <= finalMessagePosition + 50)
				{
					//Slow down the message
					message.y++;
				}
					
				if (message.y <= finalMessagePosition + 30)
				{
					message.alpha = (message.y - finalMessagePosition) / 60;
					var filter:BlurFilter = (message.filters[0] as BlurFilter);
					filter.blurY = 48 - 48 * (message.y - finalMessagePosition) / 30;
					message.filters = [filter];
				}
				else
				{
					message.alpha = (message.y - finalMessagePosition) / 45 + .5
				}
			}
			
			/**
			 * Fin du voyage !
			 */
			if (message.y == finalMessagePosition)
			{
				message.filters = [];
				message.removeEventListener(Event.ENTER_FRAME, moveMessage);
				removeChild(message);
				
				if (message == lastMessage)
					lastMessage = null;
			}
		}
	}

}