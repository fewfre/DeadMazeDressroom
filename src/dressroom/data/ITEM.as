package dressroom.data
{
	public class ITEM
	{
		public static const POSE				: String = "pose";
		public static const SKIN				: String = "skin";
		
		public static const HAIR				: String = "hair";
		public static const HEAD				: String = "head";
		public static const SHIRT				: String = "shirt";
		public static const PANTS				: String = "pants";
		public static const SHOES				: String = "shoes";
		public static const OBJECT				: String = "object";
		
		// Order of item layering when occupying the same spot.
		public static const LAYERING			: Array = [ SKIN, HAIR, HEAD, SHIRT, PANTS, SHOES, OBJECT ];
	}
}