package levels 
{
	import flash.geom.Rectangle;
	/**
	 * A spawn, representing an area where zombies may pop.
	 * 
	 * @author Neamar
	 */
	public class LevelSpawn 
	{
		/**
		 * Spawn area for the zombies
		 */
		public var location:Rectangle;
		
		/**
		 * Number of zombies for each area.
		 */
		public var number:int;
		
		/**
		 * One zombie in behemothProbability will be a behemoth.
		 * This is a probability, and therefore you may have a few surprises
		 */
		public var behemothProbability:int = 50;
		
		/**
		 * One zombie in satanusProbability will be a satanus
		 * This is a probability, and therefore you may have a few surprises
		 */
		public var satanusProbability:int = 50;
		
		/**
		 * Whether or not to avoid spawning zombies right in front of the zombies.
		 * Be careful : if you use this option, an infinite loop may occur if the rectangle is inside the player vision
		 */
		public var avoidPlayer:Boolean = false;
		
		/**
		 * Generates the spawn from XML <span-zone> values
		 * Example : <spawn-zone x="1240" y="0" width="160" height="200" number="150" behemoth-probability="100" satanus-probability="5" />

		 * @param	xml
		 */
		public function LevelSpawn(xml:XML)
		{
			number = xml.@number;
			location = new Rectangle(xml.@x, xml.@y, xml.@width, xml.@height);

			if (xml["@behemoth-probability"].toXMLString() != "")
				behemothProbability = xml["@behemoth-probability"];
			
			if (xml["@satanus-probability"].toXMLString() != "")
				satanusProbability = xml["@satanus-probability"];
				
			if (xml["@avoid-player"].toXMLString() != "")
				avoidPlayer = true;
		}
	}

}