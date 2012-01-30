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
		
		/**
		 * Name of the next level to load
		 */
		public var nextLevelName:String;
		
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
			
			//Register parameters
			this.hitmap = params.hitmap;
			this.bitmap = params.bitmap;
			this.nextLevelName = params.nextLevelName
			//Small optimisation, possible since we never update the hitmap
			hitmap.bitmapData.lock();
			
			player = new Player(this, params);
			
			heatmap = new Heatmap(this);
			
			//Layouting everything on the display list
			addChild(bitmap);
			
			//Generate Zombies
			generateZombies(params.zombiesLocation, params.zombiesDensity, params.behemothProbability, params.satanusProbability);
			
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
			
			//Clean up proprieties :
			zombies.length = 0;
			
			hitmap.loaderInfo.loader.unloadAndStop();
			bitmap.loaderInfo.loader.unloadAndStop();
			
			//Remove listener
			this.removeEventListener(Event.ENTER_FRAME, onFrame);
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
		 * This function dispatch the WIN event.
		 */
		public function dispatchWin():void
		{
			dispatchEvent(new Event(Level.WIN));
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
			for each (var zombie:Zombie in zombies)
			{
				setChildIndex(zombie, numChildren - 2);
			}
		}
		
		/**
		 * Add some zombies according to the specified parameters.
		 *
		 * @param	zombiesLocation
		 * @param	zombiesDensity
		 * @param	behemothProbabilityVector
		 * @param	satanusProbabilityVector
		 * @param	avoidPlayer whether to add zombies right in front of the player
		 */
		protected function generateZombies(zombiesLocation:Vector.<Rectangle>, zombiesDensity:Vector.<int>, behemothProbabilityVector:Vector.<int>, satanusProbabilityVector:Vector.<int>, avoidPlayer:Boolean = false):void
		{
			//Generate Zombies
			while (zombiesLocation.length > 0)
			{
				var spawnArea:Rectangle = zombiesLocation.pop();
				var spawnQuantity:int = zombiesDensity.pop();
				var behemothProbability:Number = 1 / behemothProbabilityVector.pop();
				var satanusProbability:Number = 1 / satanusProbabilityVector.pop();
				
				for (var i:int = 0; i < spawnQuantity; i++)
				{
					var x:int = spawnArea.x + spawnArea.width * Math.random();
					var y:int = spawnArea.y + spawnArea.height * Math.random();
					
					if (hitmap.bitmapData.getPixel32(x, y) != 0 || (avoidPlayer && (Math.abs(x - player.x) < 200 && Math.abs(y - player.y) < 200)))
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