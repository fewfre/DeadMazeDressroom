package app.data
{
	public class ITEM
	{
		public static const POSE				: String = "pose";
		public static const SKIN				: String = "skin";
		
		public static const HAIR				: String = "hair";
		public static const BEARD				: String = "beard";
		public static const FACE				: String = "face";
		public static const HEAD				: String = "head";
		public static const MASK				: String = "mask";
		public static const SHIRT				: String = "shirt";
		public static const PANTS				: String = "pants";
		public static const GLOVES				: String = "gloves";
		public static const SHOES				: String = "shoes";
		public static const BAG					: String = "bag";
		public static const OBJECT				: String = "object";
		
		// Order of item layering when occupying the same spot.
		public static const LAYERING			: Array = [ SKIN, FACE, BEARD, HAIR, MASK, HEAD, SHIRT, PANTS, GLOVES, BAG, SHOES, OBJECT ];
	}
}
