package
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
	import weapon.Uzi;
	import weapon.Weapon;

	/**
	 * ...
	 * @author Neamar
	 */
	public class Player extends Entity
	{
		/**
		 * Player radius
		 */
		public const RADIUS:int = 10;

		/**
		 * Player speed when moving
		 */
		public const SPEED:int = 4;

		/**
		 * Half-angular visiblity. Should be 180° in realistic game, however 100 gives more fun.
		 */
		public const ANGULAR_VISIBILITY2:int = 50;

		/**
		 * Max width one may see if no obstacles in front.
		 */
		public const DEPTH_VISIBILITY:int = Main.WIDTH2;

		/**
		 * Number of rays to throw.
		 */
		public const RESOLUTION:int = 25;

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

		public var currentWeapon:Weapon;
		public var availableWeapon:Vector.<Weapon> = new Vector.<Weapon>();
		public var frameNumber:int = 0;

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
			lightMask.filters = [new BlurFilter()];

			//Various initialisations
			addEventListener(Event.ENTER_FRAME, onFrame);
			Main.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			this.availableWeapon.push(new Handgun(parent));
			this.availableWeapon.push(new Uzi(parent));
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
			//Shoot if possible
			if (currentWeapon.isAbleToFire())
			{
				hasShot = currentWeapon.fire();
			}
		}
		protected function onMouseUp(e:MouseEvent):void { isClicked = false; }
		
		protected function onMouseWheel(e:MouseEvent):void
		{
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
			
			//When true, recompute.
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

					//Is hitmap blocking move ?
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
						(parent as Level).heatmap.bitmapData.setPixel32(x / Heatmap.RESOLUTION, y / Heatmap.RESOLUTION, Heatmap.BASE_ALPHA + Heatmap.MAX_INFLUENCE);
						hasMoved = true;
					}
				}
			}

			if (hasMoved || hasShot > 0)
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

				//Everything is gray-dark
				maskGraphics.beginFill(0, .05 * (hasShot + 1));
				maskGraphics.drawRect(x - Main.WIDTH2, y - Main.HEIGHT2, Main.WIDTH, Main.HEIGHT);
				//Except for the player
				maskGraphics.beginFill(0, 1);
				maskGraphics.drawCircle(x, y, RADIUS);
				maskGraphics.endFill();

				//And his line of sight
				maskGraphics.moveTo(x, y);
				var transformationMatrix:Matrix = new Matrix();
				transformationMatrix.createGradientBox(2 * DEPTH_VISIBILITY, 2 * DEPTH_VISIBILITY, 0, -DEPTH_VISIBILITY + x, -DEPTH_VISIBILITY + y);
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
					hasShot = hasShot >> 1;
				}
			}
		}
	}
}