package levels
{
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Success on accessing some area (stored in successArea)
	 * @author Neamar
	 */
	public final class AccessingAreaLevel extends TimedLevel
	{
		public var successArea:Rectangle;
		
		public function AccessingAreaLevel(params:LevelParams)
		{
			super(params);
			this.successArea = params.successArea;
		}
		
		protected override function onTimer(e:TimerEvent):void
		{
			if (successArea.contains(player.x, player.y))
			{
				dispatchWin();
			}
		}
	}

}