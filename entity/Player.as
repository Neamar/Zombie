package entity
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
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
	import weapon.Railgun;
	import weapon.Shotgun;
	import weapon.Uzi;
	import weapon.Weapon;

	/**
	 * The current player.
	 * @author Neamar
	 */
	public final class Player extends Entity
	{
		/**
		 * For debug : the player is never hurt.
		 */
		public static const INVINCIBLE:Boolean = true;
		
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
		public const MAX_HEALTHPOINTS:int = 50;

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
			/*up	key */38:UP,
			/*down	key */40:DOWN,
			/*z		key */90:UP,
			/*q		key */81:DOWN,
			/*s		key */83:DOWN,
			/*j		key */74:DOWN,
			/*k		key */75:UP,
			/*t		key */84:DEBUG,
			/*w		key */87:FORCE_WIN,
			/*r		key */82:RELOAD,
			/*space	key */32:RELOAD
		};

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
		public var availableWeapon:Vector.<Weapon> = new Vector.<Weapon>();
		
		/**
		 * Count the number of frames since the player begins playing.
		 * Useful for weapon cooldown.
		 */
		public var frameNumber:int = 0;

		/**
		 * Enlight stage when a weapon is shot, to show deflagration.
		 * When 0, no deflagration.
		 * 20 : max deflagration.
		 * 
		 * Initial value is 10, for fun ;)
		 */
		public var hasShot:int = 10;
		
		/**
		 * Current health of the player.
		 * You can't move when you're hurt.
		 * If damagesTaken > MAX_HEALTHPOINTS, you die.
		 */
		public var damagesTaken:int = 0;

		public function Player(parent:Level, params:LevelParams)
		{
			super(parent);

			x = params.playerStartX;
			y = params.playerStartY;
			resolution = params.playerStartResolution;

			//Player graphics
			this.graphics.lineStyle(2);
			this.graphics.beginFill(0xAAAAAA, 1);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineTo(0, 0);
			this.cacheAsBitmap = true;
			
			//Great effect, but may causes flickering
			lightMask.filters = [new BlurFilter()];
			transformationMatrix.createGradientBox(2 * DEPTH_VISIBILITY, 2 * DEPTH_VISIBILITY, 0);
			addChild(weaponDeflagration);
			
			//Blood rush
			var bd:BitmapData = new BitmapData(Main.WIDTH, Main.WIDTH);
			bloodRush = new Bitmap(bd)
			bloodRush.visible = false;
			bd.perlinNoise(Main.WIDTH, Main.WIDTH, 3, 1268000 + 1000 * Math.random(), false, false, BitmapDataChannel.RED);
			
			//Various initialisations
			addEventListener(Event.ENTER_FRAME, onFrame);
			Main.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			//Populate weapons
			this.availableWeapon.push(new Handgun(parent, this));
			this.availableWeapon.push(new Uzi(parent, this));
			this.availableWeapon.push(new Railgun(parent, this));
			this.availableWeapon.push(new Shotgun(parent, this));
			this.currentWeapon = this.availableWeapon[this.availableWeapon.length - 1];
		}
		
		public function destroy():void
		{
			removeChild(weaponDeflagration);
			
			lightMask.filters = [];
			
			bloodRush.bitmapData.dispose();
			removeEventListener(Event.ENTER_FRAME, onFrame);
			Main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Main.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			Main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			this.availableWeapon.length = 0;
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
			if (damagesTaken > MAX_HEALTHPOINTS)
			{
				trace('You die : ', damagesTaken - MAX_HEALTHPOINTS);
				damagesTaken = MAX_HEALTHPOINTS;
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
			}
		}
		protected function onMouseUp(e:MouseEvent):void { isClicked = false; }
		
		protected function onMouseWheel(e:MouseEvent):void
		{
			//Select next / prev weapon
			var offset:int = (availableWeapon.indexOf(currentWeapon) + e.delta / Math.abs(e.delta)) % availableWeapon.length;
			if (offset < 0)
			{
				offset = availableWeapon.length + offset;
			}
			
			currentWeapon = availableWeapon[offset];
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
				var realSpeed:int = SPEED;// damagesTaken > 5 ? Zombie.SPEED:SPEED;

				//Application
				for each(var action:int in downKeys)
				{
					var destX:int;
					var destY:int;
					var move:Boolean = false;

					//Does hitmap allows move ?
					if (action == UP && hitmapTest(x + RADIUS * cos, y + RADIUS * sin) == 0)
					{
						destX = x + realSpeed * cos;
						destY = y + realSpeed * sin;
						move = true;
					}
					else if (action == DOWN && hitmapTest(x - RADIUS * cos, y - RADIUS * sin) == 0)
					{
						destX = x - realSpeed * cos;
						destY = y - realSpeed * sin;
						move = true;
					}
				}

				//Is a zombie blocking move ?
				if (move)
				{/*
					var potentialZombies:Vector.<Zombie> = Zombie.frameWaker[(Zombie.frameNumber + 1) % Zombie.MAX_DURATION].concat(Zombie.frameWaker[(Zombie.frameNumber + 9) % Zombie.MAX_DURATION]);
					for each(var zombie:Zombie in potentialZombies)
					{
						if (zombie.x - Zombie.RADIUS < destX && zombie.x + Zombie.RADIUS > destX && zombie.y - Zombie.RADIUS < destY && zombie.y + Zombie.RADIUS > destY)
						{
							move = false;
							break;
						}
					}*/
					
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
				var startAngle:Number = ((rotation - ANGULAR_VISIBILITY2) % 360) * TO_RADIANS;
				var endAngle:Number = ((rotation + ANGULAR_VISIBILITY2) % 360) * TO_RADIANS;

				var maskGraphics:Graphics = lightMask.graphics;
				var theta:Number;
				var radius:int;
				var step:Number;

				maskGraphics.clear();

				//Everything is gray-dark, except when a weapon was just fired or when you're hurt
				maskGraphics.beginFill(0, .05 * (hasShot + 1));
				maskGraphics.drawRect(x - Main.WIDTH2, y - Main.WIDTH2, Main.WIDTH, Main.WIDTH);
				//Except for the player, which is visible no matter what
				maskGraphics.beginFill(0, 1);
				maskGraphics.drawCircle(x, y, RADIUS);
				maskGraphics.endFill();

				//And his line of sight
				maskGraphics.moveTo(x, y);
				transformationMatrix.tx = x;
				transformationMatrix.ty = y;
				
				//Color doesn't matter, beacause the mask is used with a blendMode.ALPHA, meaning all color information will be discarded.
				maskGraphics.beginGradientFill(GradientType.RADIAL, [0, 0], [1, 0], [0, 255], transformationMatrix);
				step = Math.abs(startAngle - endAngle) / resolution;
				for (theta = startAngle; theta <= endAngle + .01; theta += step)
				{
					radius = 0;
					while (hitmapTest(x + radius * Math.cos(theta), y + radius * Math.sin(theta)) == 0)
					{
						radius += 2;
						if (radius > DEPTH_VISIBILITY)
						{
							break;
						}
					}
					maskGraphics.lineTo(x + radius * Math.cos(theta), y + radius * Math.sin(theta));
				}

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
						weaponDeflagration.graphics.drawEllipse(RADIUS + hasShot, - hasShot >> 1, hasShot*4, hasShot);
					}
				}
			}
			
			if (damagesTaken > 0)
			{
				//Display bloodrush
				bloodRush.visible = true;
				bloodRush.alpha = damagesTaken / MAX_HEALTHPOINTS;
				bloodRush.x = x - Main.WIDTH2;
				bloodRush.y = y - Main.WIDTH2;
				
				//Heal one-by-frame
				damagesTaken--;
				
				if (damagesTaken == 0)
				{
					bloodRush.visible = false;
				}
			}
		}
	}
}