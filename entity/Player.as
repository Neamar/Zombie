package entity
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import levels.Level;
	import levels.LevelParams;
	import weapon.Handgun;
	import weapon.Weapon;
	
	/**
	 * The current player.
	 * @author Neamar
	 */
	public final class Player extends Entity
	{
		/**
		 * Events.
		 */
		public static const PLAYER_DEAD:String = "playerDead";
		public static const WEAPON_CHANGED:String = "weaponChanged";
		public static const WEAPON_SHOT:String = "weaponShot";
		
		/**
		 * For debug : the player is never hurt.
		 */
		public static const INVINCIBLE:Boolean = false;
		
		/**
		 * Player radius (he's a fatty!)
		 */
		public const RADIUS:int = 10;
		
		/**
		 * Player speed when moving
		 */
		public const SPEED:int = 4;
		
		/**
		 * Max player life
		 */
		public const MAX_HEALTHPOINTS:int = 100;
		
		/**
		 * Half-angular visiblity. Full value should be 180° in realistic game, however 100 gives more fun.
		 */
		public const ANGULAR_VISIBILITY2:int = 50;
		
		/**
		 * Max width one may see if no obstacles in front.
		 */
		public const DEPTH_VISIBILITY:int = Main.WIDTH2;
		
		/**
		 * Mathematic constant = Math.PI / 180
		 * rad = deg * TO_RADIANS
		 */
		public static const TO_RADIANS:Number = 0.0174532925;
		
		/**
		 * Mathematic constant = 180 / Math.PI
		 * deg = rad * TO_DEGREE;
		 */
		public static const TO_DEGREE:Number = 57.2957795;
		
		/**
		 * Action related constants
		 */
		public static const UP:int = 1;
		public static const DOWN:int = 2;
		public static const RELOAD:int = 3;
		
		/**
		 * Special constants
		 */
		public static const DEBUG:int = 10;
		public static const FORCE_WIN:int = 11;
		
		/**
		 * Key-binding for moving.
		 */
		public var bindings:Object = {
			/*up	key */38: UP, 
			/*down	key */40: DOWN,
			/*z		key */90: UP,
			/*q		key */81: DOWN,
			/*s		key */83: DOWN,
			/*j		key */74: DOWN,
			/*k		key */75: UP,
			/*t		key */84: DEBUG,
			/*w		key */87: FORCE_WIN,
			/*r		key */82: RELOAD,
			/*space	key */32: RELOAD};
		
		/**
		 * Which keys are currently pressed ?
		 */
		public var downKeys:Vector.<int> = new Vector.<int>();
		
		public var isClicked:Boolean = false;
		
		/**
		 * Number of rays to throw for raycasting
		 */
		public var resolution:int;
		
		/**
		 * Mask for the level, depending on the direction player is facing.
		 * Although this Shape belongs to the player, it is displayed on the Level.
		 */
		public var lightMask:Shape = new Shape();
		
		/**
		 * Blood rush of the player, when he is hit.
		 * Although this Shape belongs to the player, it is displayed on the Level.
		 */
		public var bloodRush:Bitmap = new Bitmap();
		
		/**
		 * Shape for the weapon deflagration when shooting
		 */
		public var weaponDeflagration:Shape = new Shape();
		
		/**
		 * Matrix to use to draw lamp torch.
		 */
		public var transformationMatrix:Matrix = new Matrix();
		
		/**
		 * Weapon currently in use, picked from availableWeapon
		 */
		public var currentWeapon:Weapon;
		
		/**
		 * All weapons the player may use
		 */
		public var availableWeapons:Vector.<Weapon> = new Vector.<Weapon>();
		
		/**
		 * Count the number of frames since the player begins playing.
		 * Useful for weapon cooldown.
		 */
		public var frameNumber:int = 0;
		
		/**
		 * Number of magazines available for each type of weapon
		 */
		public var defaultMagazines:Object;
		
		/**
		 * Enlight stage when a weapon is shot, to show deflagration.
		 * When 0, no deflagration.
		 * 20 : max deflagration.
		 *
		 * Initial value is 10, for fun ;)
		 */
		public var hasShot:int = 10;
		
		/**
		 * Half-angular visiblity. Full value should be 90° in realistic game, however lower values gives more fun.
		 */
		public var halfAngularVisibility:int = 50;
		
		/**
		 * Opacity of invisible parts
		 */
		public var subconsciousVision:Number = .05;
		
		/**
		 * Max player life
		 */
		public var maxHealthPoints:int = 50;
		
		/**
		 * Current health of the player.
		 * You can't move when you're hurt.
		 * If damagesTaken > maxHealthPoints, you die.
		 */
		public var damagesTaken:int = 0;
		
		/**
		 * Get back one healthpoint every recuperationSpeed frame
		 */
		public var recuperationSpeed:int = 3;
		
		/**
		 * Shall we improve the bloodrush by disminishing its intensity ?
		 */
		public var tamedBloodrush:Boolean = false;
		
		/**
		 * Will zombie flee from the light to outflank the player ?
		 */
		public var isLamplightRepulsive:Boolean = false;
		
		/**
		 * Current level we're on
		 */
		public var level:Level;
		
		/**
		 * Create the player
		 * @param	parent
		 * @param	params needed to get start information
		 */
		public function Player(parent:Level, params:LevelParams)
		{
			super(parent);
			
			x = params.playerStartX;
			y = params.playerStartY;
			resolution = params.playerStartResolution;
			defaultMagazines = params.playerMagazines;
			level = parent;
			
			//Player graphics
			this.graphics.lineStyle(2);
			this.graphics.beginFill(0xAAAAAA, 1);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineTo(0, 0);
			this.alpha = .7;
			this.cacheAsBitmap = true;
			
			//Great effect, but may causes flickering
			lightMask.filters = [new BlurFilter()];
			transformationMatrix.createGradientBox(2 * DEPTH_VISIBILITY, 2 * DEPTH_VISIBILITY, 0);
			addChild(weaponDeflagration);
			
			//Blood rush
			var bd:BitmapData = new BitmapData(Main.WIDTH, Main.WIDTH);
			bloodRush = new Bitmap(bd)
			bloodRush.visible = false;
			bloodRush.x = bloodRush.y = -Main.WIDTH2;
			drawBloodrush();
			
			//Various initialisations
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//Populate weapons
			this.availableWeapons.push(new Handgun(parent, this));
			this.currentWeapon = this.availableWeapons[0];
		}
		
		public function destroy():void
		{
			removeChild(weaponDeflagration);
			
			lightMask.filters = [];
			
			bloodRush.bitmapData.dispose();
			removeListeners();
			
			this.availableWeapons.length = 0;
			this.currentWeapon = null;
		}
		
		/**
		 * Hit the player
		 * @param	foe the foe who hit him
		 * @param	power the power of the blow.
		 */
		public function hit(foe:Entity, power:int = 30):void
		{
			if (!INVINCIBLE)
			{
				damagesTaken += power;
			}
			if (damagesTaken > maxHealthPoints)
			{
				//Die, miserable wretch. This instance will most probably be destroyed soon, along with the level
				parent.dispatchEvent(new Event(PLAYER_DEAD));
			}
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode in bindings)
			{
				var action:int = bindings[e.keyCode];
				if (downKeys.indexOf(action) == -1)
				{
					if (action == RELOAD)
					{
						currentWeapon.reload();
						dispatchEvent(new Event(WEAPON_SHOT));
					}
					else if (action == DEBUG)
					{
						(parent as Level).toggleDebugMode();
					}
					else if (action == FORCE_WIN)
					{
						(parent as Level).dispatchWin();
					}
					else
					{
						downKeys.push(action);
					}
				}
			}
			else
			{
				trace('Unknown key : ', e.keyCode);
			}
		}
		
		protected function onKeyUp(e:KeyboardEvent):void
		{
			var indexOf:int = downKeys.indexOf(bindings[e.keyCode]);
			if (indexOf != -1)
			{
				downKeys.splice(indexOf, 1);
			}
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			isClicked = true;
			//Shoot now if possible
			if (currentWeapon.isAbleToFire())
			{
				//Enlight stage, intensity depends on the weapon's deflagration power.
				hasShot = currentWeapon.fire();
				dispatchEvent(new Event(WEAPON_SHOT));
			}
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			isClicked = false;
		}
		
		protected function onMouseWheel(e:MouseEvent):void
		{
			//Select next / prev weapon
			var offset:int = (availableWeapons.indexOf(currentWeapon) + e.delta / Math.abs(e.delta)) % availableWeapons.length;
			if (offset < 0)
			{
				offset = availableWeapons.length + offset;
			}
			
			currentWeapon = availableWeapons[offset];
			dispatchEvent(new Event(WEAPON_CHANGED));
		}
		
		/**
		 * Move & turn the player
		 * Compute the lightmask
		 * Shoot if need be
		 * @param	e
		 */
		protected function onFrame(e:Event):void
		{
			frameNumber++;
			
			//Shoot if possible
			if (isClicked && currentWeapon.isAbleToFire())
			{
				hasShot = currentWeapon.fire();
				dispatchEvent(new Event(WEAPON_SHOT));
			}
			
			//When this var is true, we need to recompute masks.
			var hasMoved:Boolean = false;
			
			//Shall we turn the player ?
			var angle:Number = Math.atan2(y - parent.mouseY, x - parent.mouseX);
			var newRotation:Number = (Math.PI + angle) * TO_DEGREE;
			if (rotation != newRotation)
			{
				rotation = newRotation;
				hasMoved = true;
			}
			
			//Shall we move the player ?
			if (downKeys.length > 0)
			{
				//Precomputing
				var cos:Number = Math.cos(rotation * TO_RADIANS);
				var sin:Number = Math.sin(rotation * TO_RADIANS);
				var realSpeed:int = SPEED; // damagesTaken > 5 ? Zombie.SPEED:SPEED;
				
				//Application
				for each (var action:int in downKeys)
				{
					var destX:int;
					var destY:int;
					var move:Boolean = false;
					
					//Does hitmap allows move ?
					if (action == UP && hitmapTest(x + RADIUS * cos, y + RADIUS * sin) != 0xFF000000)
					{
						destX = x + realSpeed * cos;
						destY = y + realSpeed * sin;
						move = true;
					}
					else if (action == DOWN && hitmapTest(x - RADIUS * cos, y - RADIUS * sin) != 0xFF000000)
					{
						destX = x - realSpeed * cos;
						destY = y - realSpeed * sin;
						move = true;
					}
				}
				
				//Is a zombie blocking move ?
				if (move)
				{
					var potentialZombies:Vector.<Zombie> = level.frameWaker[(level.frameNumber + 1) % level.FRAME_WAKER_LENGTH].concat(level.frameWaker[(level.frameNumber + 9) % level.FRAME_WAKER_LENGTH]);
					for each (var zombie:Zombie in potentialZombies)
					{
						if (zombie.x - zombie.radius < destX && zombie.x + zombie.radius > destX && zombie.y - zombie.radius < destY && zombie.y + zombie.radius > destY)
						{
							move = false;
							break;
						}
					}
					
					// No zombie + no wall : ok.
					if (move)
					{
						x = destX;
						y = destY;
						hasMoved = true;
					}
				}
			}
			
			//Recompute mask only if needed.
			if (hasMoved || hasShot > 0)
			{
				parent.x = Main.WIDTH2 - x;
				parent.y = Main.WIDTH2 - y;
				
				//Torch & masking
				var startAngle:Number = ((rotation - halfAngularVisibility) % 360) * TO_RADIANS;
				var endAngle:Number = ((rotation + halfAngularVisibility) % 360) * TO_RADIANS;
				
				var maskGraphics:Graphics = lightMask.graphics;
				var theta:Number;
				var radius:int;
				var step:Number;
				
				maskGraphics.clear();
				
				//Everything is gray-dark, except when a weapon was just fired or when you're hurt
				maskGraphics.beginFill(0, subconsciousVision + 0.05 * (hasShot));
				maskGraphics.drawRect(x - Main.WIDTH2, y - Main.WIDTH2, Main.WIDTH, Main.WIDTH);
				
				//And his line of sight
				maskGraphics.moveTo(x + (RADIUS + 2) * Math.cos(startAngle), y + (RADIUS + 2) * Math.sin(startAngle));
				transformationMatrix.tx = x;
				transformationMatrix.ty = y;
				
				//Color doesn't matter, beacause the mask is used with a blendMode.ALPHA, meaning all color information will be discarded.
				maskGraphics.beginGradientFill(GradientType.RADIAL, [0, 0], [1, 0], [0, 255], transformationMatrix);
				step = Math.abs(startAngle - endAngle) / resolution;
				for (theta = startAngle; theta <= endAngle + .01; theta += step)
				{
					radius = 0;
					while (hitmapTest(x + radius * Math.cos(theta), y + radius * Math.sin(theta)) != 0xFF000000)
					{
						radius += 2;
						if (radius > DEPTH_VISIBILITY)
						{
							break;
						}
					}
					maskGraphics.lineTo(x + radius * Math.cos(theta), y + radius * Math.sin(theta));
				}
				maskGraphics.lineTo(x + (RADIUS + 2) * Math.cos(endAngle), y + (RADIUS + 2) * Math.sin(endAngle));
				maskGraphics.endFill();
				
				if (hasShot > 0)
				{
					weaponDeflagration.graphics.clear();
					//Bit operation <=> /2
					hasShot = hasShot >> 1;
					
					if (hasShot > 0)
					{
						weaponDeflagration.graphics.beginFill(0xFFFF00, .5);
						weaponDeflagration.graphics.drawCircle(RADIUS + hasShot, 0, hasShot << 1);
						weaponDeflagration.graphics.endFill();
						weaponDeflagration.graphics.beginFill(0xFFFF00, .3);
						weaponDeflagration.graphics.drawEllipse(RADIUS + hasShot, -hasShot >> 1, hasShot * 4, hasShot);
					}
				}
			}
			
			if (damagesTaken > 0)
			{
				//Display bloodrush
				bloodRush.visible = true;
				bloodRush.alpha = damagesTaken / maxHealthPoints;
				bloodRush.x = x - Main.WIDTH2;
				bloodRush.y = y - Main.WIDTH2;
				
				//Heal damages every recuperationSpeed frame
				if (frameNumber % recuperationSpeed == 0)
					damagesTaken--;
				
				if (damagesTaken == 0)
				{
					bloodRush.visible = false;
				}
			}
		}
		
		public function drawBloodrush():void
		{
			var bd:BitmapData = bloodRush.bitmapData;
			bd.perlinNoise(Main.WIDTH, Main.WIDTH, 3, 1268000 + 1000 * Math.random(), false, false, BitmapDataChannel.RED);
			
			if (tamedBloodrush)
			{
				//Disminish intensity of the red around the player.
				var mask:Shape = new Shape();
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(bd.width, bd.height, 0, -bd.width / 2, -bd.height / 2);
				
				mask.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0], [0.2, 1], [0, 255], matrix);
				mask.graphics.drawCircle(0, 0, 200);
				mask.graphics.endFill();
				bd.draw(mask, new Matrix(1, 0, 0, 1, bd.width / 2, bd.height / 2), null, BlendMode.ALPHA);
			}
		}
		
		/**
		 * Called as soon as we get a reference to the stage
		 * 
		 * @param	e
		 */
		protected function onAddedToStage(e:Event):void
		{
			//Add all the listeners (key, mouse...)
			addListeners();
			
			//Clean the event
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function addListeners():void
		{
			stage.addEventListener(Event.ENTER_FRAME, onFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		protected function removeListeners():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, onFrame);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
	}
}