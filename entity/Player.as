package entity
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import weapon.Handgun;
	import weapon.Railgun;
	import weapon.Shotgun;
	import weapon.Uzi;
	import weapon.Weapon;

	/**
	 * ...
	 * @author Neamar
	 */
	public class Player extends Entity
	{
		/**
		 * Player radius (he's a fatty!)
		 */
		public const RADIUS:int = 10;

		/**
		 * Player speed when moving
		 */
		public const SPEED:int = 4;

		/**
		 * Half-angular visiblity. Full value should be 180° in realistic game, however 100 gives more fun.
		 */
		public const ANGULAR_VISIBILITY2:int = 50;

		/**
		 * Max width one may see if no obstacles in front.
		 */
		public const DEPTH_VISIBILITY:int = Main.WIDTH2;

		/**
		 * Number of rays to throw.
		 */
		public const RESOLUTION:int = 12;

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
		 * Key-binding for moving.
		 */
		public var bindings:Object = { UP:38, DOWN:40 };

		/**
		 * Which keys are currently pressed ?
		 */
		public var downKeys:Vector.<int> = new Vector.<int>();
		
		public var isClicked:Boolean = false;

		/**
		 * Shape to use to draw influence.
		 */
		public var influence:Shape = new Shape();

		/**
		 * Mask for the level, depending on the direction player is facing.
		 */
		public var lightMask:Shape = new Shape();
		
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

		public function Player(parent:Level)
		{
			super(parent);

			x = Main.WIDTH2;
			y = Main.HEIGHT2;

			//Player graphics
			this.graphics.lineStyle(2);
			this.graphics.beginFill(0xAAAAAA, 1);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineTo(0, 0);
			//Great effect, but may causes flickering
			lightMask.filters = [new BlurFilter()];
			transformationMatrix.createGradientBox(2 * DEPTH_VISIBILITY, 2 * DEPTH_VISIBILITY, 0);

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

		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (downKeys.indexOf(e.keyCode) == -1)
			{
				downKeys.push(e.keyCode);
			}
		}

		protected function onKeyUp(e:KeyboardEvent):void
		{
			downKeys.splice(downKeys.indexOf(e.keyCode), 1);
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

				//Application
				for each(var downKey:int in downKeys)
				{
					var destX:int;
					var destY:int;
					var move:Boolean = false;

					//Does hitmap allows move ?
					if (downKey == bindings.UP && hitmapTest(x + RADIUS * cos, y + RADIUS * sin) == 0)
					{
						destX = x + SPEED * cos;
						destY = y + SPEED * sin;
						move = true;
					}
					else if (downKey == bindings.DOWN && hitmapTest(x - RADIUS * cos, y - RADIUS * sin) == 0)
					{
						destX = x - SPEED * cos;
						destY = y - SPEED * sin;
						move = true;
					}
				}

				//Is a zombie blocking move ?
				if (move)
				{
					var potentialZombies:Vector.<Zombie> = Zombie.frameWaker[(Zombie.frameNumber + 1) % Zombie.MAX_DURATION];
					var cancelMove:Boolean = false;
					for each(var zombie:Zombie in potentialZombies)
					{
						if (zombie.x - Zombie.RADIUS < destX && zombie.x + Zombie.RADIUS > destX && zombie.y - Zombie.RADIUS < destY && zombie.y + Zombie.RADIUS > destY)
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

			//TODO : Mask should be recomputed *every* frame. Else, when the player is not moving, the stage flickers sometimes.
			//Seems to be a flash related issue.
			//hasMoved || hasShot > 0
			if (1)
			{
				parent.x = Main.WIDTH2 - x;
				parent.y = Main.HEIGHT2 - y;

				//Torch & masking
				var startAngle:Number = ((rotation - ANGULAR_VISIBILITY2) % 360) * TO_RADIANS;
				var endAngle:Number = ((rotation + ANGULAR_VISIBILITY2) % 360) * TO_RADIANS;

				var maskGraphics:Graphics = lightMask.graphics;
				var theta:Number;
				var radius:int;
				var step:Number;

				maskGraphics.clear();

				//Everything is gray-dark, except when a weapon was just fired
				maskGraphics.beginFill(0, .05 * (hasShot + 1));
				maskGraphics.drawRect(x - Main.WIDTH2, y - Main.HEIGHT2, Main.WIDTH, Main.HEIGHT);
				//Except for the player, which is visible no matter what
				maskGraphics.beginFill(0, 1);
				maskGraphics.drawCircle(x, y, RADIUS);
				maskGraphics.endFill();

				//And his line of sight
				maskGraphics.moveTo(x, y);
				transformationMatrix.tx = x;
				transformationMatrix.ty = y;
				
				maskGraphics.beginGradientFill(GradientType.RADIAL, [0, 0], [1, 0], [0, 255], transformationMatrix);
				step = Math.abs(startAngle - endAngle) / RESOLUTION;
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

				maskGraphics.lineTo(x, y);
				maskGraphics.endFill();

				if (hasShot > 0)
				{
					//Bit operation <=> /2
					hasShot = hasShot >> 1;
				}
			}
		}
	}
}