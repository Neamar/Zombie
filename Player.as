package 
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Player extends Sprite
	{
		public const RADIUS:int = 10;
		public const SPEED:int = 4;
		public const VISIBILITY2:int = 60;
		public const RESOLUTION:int = 25;
		public const TO_RADIANS:Number = 0.0174532925;
		public const TO_DEGREE:Number = 57.2957795;
		public var bindings:Object = { UP:38, DOWN:40, LEFT:37, RIGHT:39 };
		public var downKeys:Vector.<int> = new Vector.<int>();
		public var hitmapTest:Function;
		public var lightMask:Shape = new Shape();
		
		public function Player()
		{
			x = 200;
			y = 200;
			
			this.graphics.lineStyle(2);
			this.graphics.beginFill(0xAAAAAA, 1);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineTo(0, 0);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			var that:Player = this;
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void { that.hitmapTest = (that.parent as Level).hitmap.bitmapData.getPixel32; } );
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
		
		protected function onFrame(e:Event):void
		{
			var hasMoved:Boolean = false;
			
			var angle:Number = Math.atan2(y - parent.mouseY, x - parent.mouseX);
			var newRotation:Number = (Math.PI + angle) * TO_DEGREE;
			if (rotation != newRotation)
			{
				rotation = newRotation;
				hasMoved = true;
			}
			
			if (downKeys.length > 0)
			{
				//Précomputing
				var cos:Number = Math.cos(rotation * TO_RADIANS);
				var sin:Number = Math.sin(rotation * TO_RADIANS);
				
				//Application
				for each(var downKey:int in downKeys)
				{
					if (downKey == bindings.UP && hitmapTest(x + RADIUS * cos, y + RADIUS * sin) == 0)
					{
						x += SPEED * cos;
						y += SPEED * sin;
						hasMoved = true;
					}
					else if (downKey == bindings.DOWN && hitmapTest(x - RADIUS * cos, y - RADIUS * sin) == 0)
					{
						x -= SPEED * cos;
						y -= SPEED * sin;
						hasMoved = true;
					}
				}
				
				//Landscape move
				parent.x = Main.WIDTH2 - x;
				parent.y = Main.HEIGHT2 - y;
			}
			
			if (hasMoved)
			{
				//Torch & masking
				var startAngle:Number = ((rotation - VISIBILITY2) % 360) * TO_RADIANS;
				var endAngle:Number = ((rotation + VISIBILITY2) % 360) * TO_RADIANS;
				
				var maskGraphics:Graphics = lightMask.graphics;
				var theta:Number;
				var radius:int;
				var step:Number;
				
				maskGraphics.clear();
				maskGraphics.moveTo(x, y);
				var transformationMatrix:Matrix = new Matrix();
				transformationMatrix.createGradientBox(Main.WIDTH, Main.HEIGHT, 0, -Main.WIDTH2 + x, -Main.HEIGHT2 + y);
				maskGraphics.beginGradientFill(GradientType.RADIAL, [0, 0], [1, 0], [0, 255], transformationMatrix);
				step = Math.abs(startAngle - endAngle) / RESOLUTION;
				for (theta = startAngle; theta <= endAngle + .01; theta += step)
				{
					radius = 0;
					while (hitmapTest(x + radius * Math.cos(theta), y + radius * Math.sin(theta)) == 0)
					{
						radius += 2;
						if (radius > Main.WIDTH2)
						{
							break;
						}
					}
					maskGraphics.lineTo(x + radius * Math.cos(theta), y + radius * Math.sin(theta));
				}
				
				maskGraphics.lineTo(x, y);
				maskGraphics.endFill();
			}
		}
	}
}