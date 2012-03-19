package  
{
	import entity.Player;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
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
		public function Hud()
		{
			muteSprite.graphics.beginFill(0xFF0000);
			muteSprite.graphics.drawRoundRect( -10, -10, 20, 20, 3, 3);
			muteSprite.x = Main.WIDTH - 40;
			muteSprite.y = 40;
			addChild(muteSprite);
			muteSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMuteClick, false, 32);
			
			addChild(AmmosBitmap);
			AmmosBitmap.scaleX = AmmosBitmap.scaleY = 1 / 2;
		}
	
/**
 * SOUNDS SECTION
 */
		private var muteSprite:Sprite = new Sprite();
		private var isMute:Boolean = false;
		
		/**
		 * Mute sound.
		 * Prevent event propagation, to avoid useless shot.
		 * 
		 * @param	e
		 */
		private function onMuteClick(e:Event):void
		{
			var globalSoundTransform:SoundTransform = SoundMixer.soundTransform;
			if (isMute)
				globalSoundTransform.volume = 0;
			else
				globalSoundTransform.volume = 1;
			
			SoundMixer.soundTransform = globalSoundTransform;
			
			isMute = !isMute;
			
			e.stopImmediatePropagation();
		}
		
/*
 * WEAPONS SECTION
 * 
 * This section contains informaitons regarding the player's current weapon state.
 */
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
		
		[Embed(source = "assets/hud/weapons/ammos.png")]
		private static const AmmosHud:Class;
		private static const AmmosBitmap:Bitmap = new AmmosHud();
		private var ammosScrollRect:Rectangle = new Rectangle(0, 0, Main.WIDTH, 16);
		/**
		 * Updates the weapon on the HUD
		 * Called on the Player.WEAPON_CHANGED event
		 * 
		 * @param	e if this function is called by an event
		 * @param	player if this function is called directly
		 */
		public function updateWeapon(e:Event = null, player:Player = null):void
		{
			player = player == null?(e.target as Player):player;
			
			var weaponToDisplay:Bitmap = weaponsOrder[player.availableWeapons.indexOf(player.currentWeapon)];
			
			if (weaponDisplayed != null && weaponDisplayed != weaponToDisplay)
				removeChild(weaponDisplayed);
				
			addChild(weaponToDisplay);
			weaponToDisplay.scaleX = weaponToDisplay.scaleY = 1 / 2;
			weaponToDisplay.x = 5;
			weaponToDisplay.y = Main.WIDTH - weaponToDisplay.height;
			AmmosBitmap.y = weaponToDisplay.y + weaponToDisplay.height / 2 - AmmosBitmap.height / 2;
			AmmosBitmap.x = weaponToDisplay.width + 30;
			weaponDisplayed = weaponToDisplay;
			
			//Update bullets to, since the weapon changed
			updateBullets(null, player);
		}
		
		/**
		 * Update the numbers of bullets displayed
		 * Called on the Player.WEAPON_SHOT event
		 * 
		 * @param	e if this function is called by an event
		 * @param	player if this function is called directly
		 */
		public function updateBullets(e:Event = null, player:Player = null):void
		{
			player = player == null?(e.target as Player):player;
			
			ammosScrollRect.width = 16 * player.currentWeapon.ammoInCurrentMagazine;
			AmmosBitmap.scrollRect = ammosScrollRect;
		}

		
/*
 * MESSAGES SECTION
 * 
 * This section contains the properties and methods to display floating messages to the player.
 */
		/**
		 * Text format for the style to use when displaying message
		 */
		protected var textFormat:TextFormat = new TextFormat(null, null, null, true);
		
		/**
		 * Y-coordinate where a message should disappear
		 */
		protected var finalMessagePosition:int = 2 * Main.WIDTH / 3;
		
		/**
		 * Last displayed textfield
		 * Stored to avoid overlapping messages
		 */
		protected var lastMessage:TextField = null;
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