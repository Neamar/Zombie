package levels
{
	import entity.Behemoth;
	import entity.Player;
	import entity.Satanus;
	import entity.Survivor;
	import entity.Zombie;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
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
		
		/**
		 * The player on the map
		 */
		public var player:Player;
		
		/**
		 * B&W map listing (un-)available places.
		 */
		public var hitmap:Bitmap;
		
		/**
		 * Texture for the game
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Zombies.
		 * We need to keep a complete list, to count ombies and to shoot them
		 *
		 * @see Weapon
		 */
		public var zombies:Vector.<Zombie> = new Vector.<Zombie>();
		
		/**
		 * Length should be greater than Zombie.SLEEP_DURATION.
		 */
		public const FRAME_WAKER_LENGTH:int = 100;
		
		/**
		 * Which zombie should awake in which frame ?
		 *
		 */
		public var frameWaker:Vector.<Vector.<Zombie>> = new Vector.<Vector.<Zombie>>(FRAME_WAKER_LENGTH, true);
		
		/**
		 * Current frame number % MAX_DURATION
		 */
		public var frameNumber:int = 0;
		
		/*
		 * Survivors (if any)
		 */
		public var survivors:Vector.<Survivor> = new Vector.<Survivor>();
		
		/**
		 * Influence map, to compute easily multiples pathfindings without burying CPU
		 *
		 * @see http://aigamedev.com/open/tutorials/potential-fields/
		 */
		public var heatmap:Heatmap;
		
		public function Level(params:LevelParams)
		{
			//Optimise display
			mouseChildren = false;
			mouseEnabled = false;
			
			//Prepare to receive and animate zombies
			addEventListener(Event.ENTER_FRAME, onFrame);
			for (frameNumber = 0; frameNumber < FRAME_WAKER_LENGTH; frameNumber++)
			{
				frameWaker[frameNumber] = new Vector.<Zombie>();
			}
			frameNumber = 0;
			
			//Register parameters. Clone the bitmpa to avoid drawing on the original dead zombies.
			this.hitmap = params.hitmap;
			this.bitmap = new Bitmap(params.bitmap.bitmapData.clone());

			//Small optimisation, possible since we never update the hitmap
			hitmap.bitmapData.lock();
			
			player = new Player(this, params);
			addEventListener(Player.PLAYER_DEAD, onPlayerDead);
			
			heatmap = new Heatmap(this);
			
			//Layouting everything on the display list
			addChild(bitmap);
			
			//Generate Zombies
			generateZombies(params.initialSpawns);
			
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
			
			addChild(player);
			addChild(hitmap);
			addChild(player.bloodRush);
		}
		
		public function destroy():void
		{
			player.destroy();
			
			//Remove all children for faster GC
			while (numChildren > 0)
				removeChildAt(0);
			
			//Empty frames
			for (frameNumber = 0; frameNumber < FRAME_WAKER_LENGTH; frameNumber++)
			{
				frameWaker[frameNumber].length = 0;
			}
			
			//Clean up properties
			zombies.length = 0;
			
			//Remove listener
			removeEventListener(Event.ENTER_FRAME, onFrame);
			removeEventListener(Player.PLAYER_DEAD, onPlayerDead);
		}
		
		/**
		 * This function awake any zombies that registered for a watch on this frame.
		 * @param	e
		 */
		public function onFrame(e:Event = null):void
		{
			frameNumber = (frameNumber + 1) % FRAME_WAKER_LENGTH;
			
			var currentFrame:Vector.<Zombie> = frameWaker[frameNumber];
			while (currentFrame.length > 0)
			{
				//Move the zombies.
				var zombie:Zombie = currentFrame.pop();
				//The function returns the number of frames before moving the same zombie again
				var duration:int = zombie.move();
				
				if (duration != 0)
					frameWaker[(frameNumber + duration) % FRAME_WAKER_LENGTH].push(zombie);
			}
		}
		
		/**
		 * This function force the dispatch of the WIN event.
		 */
		public function dispatchWin():void
		{
			dispatchEvent(new Event(Level.WIN));
		}
		
		/**
		 * When the player dies, the level is lost.
		 */
		protected function onPlayerDead(e:Event):void
		{
			dispatchEvent(new Event(Level.LOST));
		}
		
		/**
		 * Toggle debug mode and view the influence map.
		 * @param	e
		 */
		public function toggleDebugMode():void
		{
			if (player.lightMask.parent == this)
			{
				removeChild(bitmap);
				removeChild(player.lightMask);
				addChild(heatmap);
			}
			else if (heatmap.parent == this)
			{
				removeChild(heatmap);
				addChild(bitmap);
			}
			else
			{
				addChild(player.lightMask);
			}
			
			//Player and zombies ought to be visible at any time
			setChildIndex(player, numChildren - 1);
			setChildIndex(hitmap, numChildren - 1);
			for each (var zombie:Zombie in zombies)
			{
				setChildIndex(zombie, numChildren - 3);
			}
		}
		
		/**
		 * Add some zombies according to the specified parameters.
		 * TODO : factorize in common class
		 * 
		 * @param	zombiesLocation
		 * @param	zombiesDensity
		 * @param	behemothProbabilityVector
		 * @param	satanusProbabilityVector
		 * @param	avoidPlayer whether to add zombies right in front of the player
		 */
		protected function generateZombies(spawns:Vector.<LevelSpawn>):void
		{
			//Generate Zombies based on the s
			for each(var spawn:LevelSpawn in spawns)
			{
				var spawnArea:Rectangle = spawn.location;
				var spawnQuantity:int = spawn.number;
				var behemothProbability:Number = 1 / spawn.behemothProbability;
				var satanusProbability:Number = 1 / spawn.satanusProbability;
				
				for (var i:int = 0; i < spawnQuantity; i++)
				{
					var x:int = spawnArea.x + spawnArea.width * Math.random();
					var y:int = spawnArea.y + spawnArea.height * Math.random();
					
					if (hitmap.bitmapData.getPixel32(x, y) != 0 || (spawn.avoidPlayer && (Math.abs(x - player.x) < 200 && Math.abs(y - player.y) < 200)))
					{
						i--;
					}
					else
					{
						var foe:Zombie;
						if (Math.random() > behemothProbability)
						{
							if (Math.random() > satanusProbability)
								foe = new Zombie(this, x, y);
							else
								foe = new Satanus(this, x, y);
						}
						else
							foe = new Behemoth(this, x, y);
						
						zombies.push(foe);
						//Set time for first awakening :
						var firstWake:int = 30 + 30 * Math.random()
						frameWaker[(frameNumber + firstWake) % FRAME_WAKER_LENGTH].push(foe);
						addChild(foe);
						setChildIndex(foe, 1);
					}
				}
			}
		}
	}

}