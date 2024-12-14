package app.ui
{
	import app.ui.buttons.SpriteButton;
	import app.ui.common.FancySlider;
	import app.ui.common.FrameBase;
	import app.ui.common.RoundedRectangle;
	import app.world.elements.Character;
	import com.fewfre.display.ButtonBase;
	import com.fewfre.utils.Fewf;
	import ext.ParentApp;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	
	public class Toolbox extends Sprite
	{
		// Constants
		public static const SAVE_CLICKED         = "save_clicked";
		
		public static const SHARE_CLICKED        = "share_clicked";
		public static const CLIPBOARD_CLICKED    = "clipboard_clicked";
		public static const IMGUR_CLICKED        = "imgur_clicked";
		
		public static const SCALE_SLIDER_CHANGE  = "scale_slider_change";
		
		public static const ANIMATION_TOGGLED    = "animation_toggled";
		public static const RANDOM_CLICKED       = "random_clicked";
		public static const TRASH_CLICKED        = "trash_clicked";
		
		// Storage
		public var scaleSlider       : FancySlider;
		private var _downloadButton  : ButtonBase;
		private var _animateButton   : SpriteButton;
		private var _imgurButton     : SpriteButton;
		private var _clipboardButton : SpriteButton;
		
		// Constructor
		// onShareCodeEntered: (code, (state:String)=>void)=>void
		public function Toolbox(pCharacter:Character, onShareCodeEntered:Function) {
			var bg:RoundRectangle = new RoundRectangle(365, 35).toOrigin(0.5).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			var tDownloadTray:FrameBase = new FrameBase({ x:-bg.width*0.5 + 33, y:9, width:66, height:66, origin:0.5 }).appendTo(this);
			
			_downloadButton = new SpriteButton({ size:46, obj:new $LargeDownload(), origin:0.5 })
				.on(ButtonBase.CLICK, dispatchEventHandler(SAVE_CLICKED))
				.appendTo(tDownloadTray);
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray:Sprite = bg.addChild(new Sprite()) as Sprite;
			var tTrayWidth = bg.width - tDownloadTray.Width;
			tTray.x = -(bg.width*0.5) + (tTrayWidth*0.5) + (bg.width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }).appendTo(tTray)
				.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(!Fewf.isExternallyLoaded) {
				_imgurButton = new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })
					.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
					.on(ButtonBase.CLICK, dispatchEventHandler(IMGUR_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			} else {
				_clipboardButton = new SpriteButton({ size:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })
					.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
					.on(ButtonBase.CLICK, dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			new SpriteButton({ size:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 }).appendTo(tTray)
				.setXY(tX-tButtonXInc*tButtonOnRight, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(TRASH_CLICKED));
			tButtonOnRight++;

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			new SpriteButton({ size:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 }).appendTo(tTray)
				.setXY(tX-tButtonXInc*tButtonOnRight, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(RANDOM_CLICKED));
			tButtonOnRight++;
			
			_animateButton = new SpriteButton({ size:tButtonSize, obj:new $PlayButton(), obj_scale:0.5, origin:0.5 })
				.setXY(tX-tButtonXInc*tButtonOnRight, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(ANIMATION_TOGGLED))
				.appendTo(tTray) as SpriteButton;
			toggleAnimateButtonAsset(pCharacter.animatePose);
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			tX = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			scaleSlider = new FancySlider(tSliderWidth).setXY(tX, yy)
				.setSliderParams(1, 4, pCharacter.outfit.scaleX)
				.appendTo(tTray);
			scaleSlider.addEventListener(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			/****************************
			* Selectable text field
			*****************************/
			new PasteShareCodeInput().appendTo(this).move(18, 33)
				.on(PasteShareCodeInput.CHANGE, function(e:FewfEvent):void{ onShareCodeEntered(e.data.code, e.data.update); });

		}
		public function setXY(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): Toolbox { target.addChild(this); return this; }
		public function on(type:String, listener:Function): Toolbox { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Toolbox { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function downloadButtonEnable(pOn:Boolean) : void {
			if(pOn) _downloadButton.enable(); else _downloadButton.disable();
		}
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			_animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
		
		public function imgurButtonEnable(pOn:Boolean) : void {
			if(pOn) _imgurButton.enable(); else _imgurButton.disable();
		}
		
		public function updateClipboardButton(normal:Boolean, elseYes:Boolean=true) : void {
			if(!_clipboardButton) return;
			_clipboardButton.ChangeImage(normal ? new $CopyIcon() : elseYes ? new $Yes() : new $No());
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
	}
}
