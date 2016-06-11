package GUI 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	
	public class SpriteButton extends RoundedRectangle
	{
		// Storage
		public var id:int;
		public var Image:flash.display.DisplayObject;
		public var doMouseover:Boolean=false;
		
		// Constants
		public static const MOUSE_DOWN:String="sb_mouse_down";
		public static const MOUSE_UP:String="sb_mouse_up";
		
		// Constructor
		public function SpriteButton(pX:Number, pY:Number, pWidth:Number, pHeight:Number, pMC:DisplayObject, pID:int)
		{
			super(pX, pY, pWidth, pHeight);
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			this.id = pID;
			addEventListener(MouseEvent.MOUSE_DOWN, this.Mouse_Down);
			addEventListener(MouseEvent.MOUSE_UP, this.Mouse_Up);
			addEventListener(MouseEvent.ROLL_OVER, this.Mouse_Over);
			addEventListener(MouseEvent.ROLL_OUT, this.Mouse_Out);
			
			ChangeImage(pMC);
			this.Unpressed();
		}

		public function ChangeImage(pMC:DisplayObject) : void
		{
			if(this.Image != null) { removeChild(this.Image); }
			this.Image = pMC;
			this.Image.scaleX = 0.75;
			this.Image.scaleY = 0.75;
			this.Image.x = this.Width / 2;
			this.Image.y = this.Height / 2;
			addChild(this.Image);
		}

		public function Unpressed() : void {
			this.draw(ConstantsApp.COLOR_BUTTON_BLUE, 7, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}

		public function Pressed() : void {
			this.draw(ConstantsApp.COLOR_BUTTON_DOWN, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_DOWN);
		}

		internal function Mouse_Down(pEvent:MouseEvent) : void
		{
			this.Pressed();
			dispatchEvent(new flash.events.Event(MOUSE_DOWN));
		}

		internal function Mouse_Up(pEvent:MouseEvent) : void
		{
			this.Unpressed();
			dispatchEvent(new flash.events.Event(MOUSE_UP));
		}

		internal function Mouse_Over(pEvent:MouseEvent) : void
		{
			if(doMouseover) { this.Pressed(); }
		}

		internal function Mouse_Out(pEvent:MouseEvent) : void
		{
			if(doMouseover) { this.Unpressed(); }
		}
	}
}
