package app.data
{
	public class Sex
	{
		public static const MALE		: Sex = new Sex("male");
		public static const FEMALE		: Sex = new Sex("female");
		
		// Enum Storage + Constructor
		private var _value: String;
		function Sex(pValue:String) { _value = pValue }
		
		// This is required for proper auto string convertion on `trace`/`Dictionary` and such - enums should always have
		public function toString() : String { return _value.toString(); }
	}
}
