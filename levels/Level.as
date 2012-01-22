package levels
{
	import entity.Player;
	import entity.Zombie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * [abstract]
	 * Basis for a level.
	 * 
	 * @author Neamar
	 */
	public class Level extends Sprite
	{
		public static const WIN:String = 'win';
		public static const LOST:String = 'lost';
		
		public static var current:Level = null;
		
		public var player:Player;
		
		/**
		 * B&W map listing (un-)available places.
		 */
		public var hitmap:Bitmap;
		
		/**
		 * Texture for the game
		 * @todo Rename to bitmap ? I used to had problems with that, can't remember why.
		 */
		public var bitmapLevel:Bitmap;
		
		/**
		 * Zombies
		 */
		public var zombies:Vector.<Zombie> = new Vector.<Zombie>();
		
		/**
		 * Influence map, to compute easily multiples pathfindings without burying CPU
		 * 
		 * @see http://aigamedev.com/open/tutorials/potential-fields/
		 */
		public var heatmap:Heatmap;
		
		public function Level(params:LevelParams)
		{
			mouseChildren = false;
			mouseEnabled = false;
			
			this.hitmap = params.hitmap;
			this.bitmapLevel = params.bitmap;
			
			//For debug, store current instance
			Level.current = this;
			
			player = new Player(this, params);
			heatmap = new Heatmap(this);
			//Small optimisation, possible since we never update the hitmap
			hitmap.bitmapData.lock();
			
			
			//Layouting everything on the display list
			addChild(bitmapLevel);
			addChild(player);
			
			//Generate Zombies
			while (params.zombiesLocation.length > 0)
			{
				var spawnArea:Rectangle = params.zombiesLocation.pop();
				var spawnQuantity:int = params.zombiesDensity.pop();
				
				for (var i:int = 0; i < spawnQuantity; i++)
				{
					var x:int = spawnArea.x + spawnArea.width * Math.random();
					var y:int = spawnArea.y + spawnArea.height * Math.random();
					
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
			}

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
			
			addChild(player.bloodRush);
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