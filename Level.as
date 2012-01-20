package 
{
	import entity.Player;
	import entity.Survivor;
	import entity.Zombie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Neamar
	 */
	public class Level extends Sprite
	{
		public static var current:Level;
		
		[Embed(source = "assets/testlevelHitmap.png")] private static var Hitmap:Class;
		[Embed(source = "assets/testlevelBitmap.png")] private static var BitmapLevel:Class;
		
		public var player:Player;
		
		/**
		 * B&W map listing (un-)available places.
		 */
		public var hitmap:Bitmap;
		
		/**
		 * Texture for the game
		 */
		public var bitmapLevel:Bitmap;
		
		/**
		 * Zombies
		 */
		public var zombies:Vector.<Zombie> = new Vector.<Zombie>();
		
		/**
		 * Survivors (if any)
		 */
		public var survivors:Vector.<Survivor> = new Vector.<Survivor>();
		
		/**
		 * Influence map, to compute easily multiples pathfindings without burying CPU
		 * 
		 * @see http://aigamedev.com/open/tutorials/potential-fields/
		 */
		public var heatmap:Heatmap;
		
		/**
		 * Blood rush when player is shot.
		 */
		public var bloodRush:Bitmap;
		
		public function Level()
		{
			//For debug, store current instance
			Level.current = this;
			
			hitmap = new Hitmap();
			player = new Player(this);
			heatmap = new Heatmap(this);
			bitmapLevel = new BitmapLevel();
			//Small optimisation, possible since we never update the hitmap
			hitmap.bitmapData.lock();
			
			
			//Layouting everything on the display list
			addChild(bitmapLevel);
			addChild(player);
			
			//Generate Zombies
			for (var i:int = 0; i < Main.ZOMBIES_NUMBER; i++)
			{
				var x:int = Main.LEVEL_WIDTH * Math.random();
				var y:int = Main.LEVEL_HEIGHT * Math.random();
				
				if (hitmap.bitmapData.getPixel32(x, y) != 0)
				{
					i--;
				}
				else
				{
					var foe:Zombie = new Zombie(this, x, y);
					zombies.push(foe);
					addChild(foe);
				}
			}
			
			//Add a survivor
			var survivor:Survivor = new Survivor(this, 1800, 200);
			addChild(survivor);
			zombies.push(survivor);
			survivors.push(survivor);

			/**
			 * Blending and masking
			 * @see http://active.tutsplus.com/tutorials/games/introducing-blend-modes-in-flash/
			 */
			addChild(player.lightMask);
			//Use blendMode to achieve required effects.
			//Layer simply means an object "in front of" can affect the pixels.
			blendMode = BlendMode.LAYER;
			//Alpha applies an alpha mask to the object behind, in this case the level.
			//Since the lightMask is added after everything, it applies everywhere.
			//Is is incredibly faster than using a real as3-mask, since we don't have to cacheAsBitmap the level.
			player.lightMask.blendMode = BlendMode.ALPHA;
			
			var bd:BitmapData = new BitmapData(Main.WIDTH, Main.HEIGHT);
			bloodRush = new Bitmap(bd)
			bloodRush.visible = false;
			addChild(bloodRush);
			bd.perlinNoise(Main.WIDTH, Main.HEIGHT, 3, 1268496, false, false, BitmapDataChannel.RED);
		}
		
		/**
		 * Toggle debug mode and view the influence map.
		 * @param	e
		 */
		public function toggleDebugMode():void
		{
			if (player.lightMask.parent == this)
			{
				removeChild(bitmapLevel);
				removeChild(player.lightMask);
				addChild(heatmap);
			}
			else if(heatmap.parent == this)
			{
				removeChild(heatmap);
				addChild(bitmapLevel);
			}
			else
			{
				addChild(player.lightMask);
			}
			
			//Player and zombies ought to be visible at any time
			setChildIndex(player, numChildren - 1);
			for each(var zombie:Zombie in zombies)
			{
				setChildIndex(zombie, numChildren - 2);
			}
		}
	}
	
}