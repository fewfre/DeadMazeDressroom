package app.ui
{
	import app.ui.buttons.SpriteButton;
	import app.ui.common.FancySlider;
	import app.ui.common.FrameBase;
	import app.ui.common.RoundedRectangle;
	import app.world.elements.Character;
	import com.fewfre.utils.Fewf;
	import ext.ParentApp;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.DisplayWrapper;
	import flash.events.MouseEvent;
	import flash.display.Graphics;
	import app.data.ConstantsApp;
	
	public class Toolbox extends Sprite
	{
		// Constants
		public static const SAVE_CLICKED         = "save_clicked";
		public static const GIF_CLICKED          = "gif_clicked";
		public static const WEBP_CLICKED         = "webp_clicked";
		
		public static const SHARE_CLICKED        = "share_clicked";
		public static const CLIPBOARD_CLICKED    = "clipboard_clicked";
		
		public static const SCALE_SLIDER_CHANGE  = "scale_slider_change";
		
		public static const ANIMATION_TOGGLED    = "animation_toggled";
		public static const RANDOM_CLICKED       = "random_clicked";
		public static const TRASH_CLICKED        = "trash_clicked";
		
		// Storage
		private var _downloadButton    : SpriteButton;
		private var _downloadHoverTray : Sprite;
		private var _gifButton         : SpriteButton;
		private var _webpButton        : SpriteButton;
		
		private var _animateButton     : SpriteButton;
		private var _clipboardButton   : SpriteButton;
		
		private var _scaleSlider         : FancySlider;
		
		// Properties
		public function get scaleSlider() : FancySlider { return _scaleSlider; }
		
		// Constructor
		// onShareCodeEntered: (code, (state:String)=>void)=>void
		public function Toolbox(pCharacter:Character, onShareCodeEntered:Function) {
			var bg:RoundRectangle = new RoundRectangle(365, 35).toOrigin(0.5).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			var tDownloadTray:FrameBase = new FrameBase(66, 66).move(-bg.width*0.5 + 33, 9).appendTo(this);
			_downloadHoverTray = DisplayWrapper.wrap(new Sprite(), tDownloadTray.root).asSprite;
			_downloadHoverTray.visible = false;
			
			_downloadButton = new SpriteButton({ size:46, obj:new $LargeDownload(), origin:0.5 })
				.onButtonClick(dispatchEventHandler(SAVE_CLICKED))
				.appendTo(tDownloadTray.root) as SpriteButton;
			
			// Dropdown buttons
			
			_gifButton = SpriteButton.rect(46, 16).setTextUntranslated('.gif').toOrigin(0.5).move(0, 42)
				.onButtonClick(dispatchEventHandler(GIF_CLICKED))
				.appendTo(_downloadHoverTray) as SpriteButton;
			
			_webpButton = SpriteButton.rect(46, 16).setTextUntranslated('.webp').toOrigin(0.5).move(0, 42+_gifButton.Height+2)
				.onButtonClick(dispatchEventHandler(WEBP_CLICKED))
				.appendTo(_downloadHoverTray) as SpriteButton;
			
			// Draw rectangle to act as hitbox for mouse over
			_downloadHoverTray.graphics.beginFill(0, 0);
			_downloadHoverTray.graphics.drawRect(-_gifButton.Width/2, 0, _gifButton.Width, _webpButton.y+_webpButton.Height/2);
			_downloadHoverTray.graphics.endFill();
			
			if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED) {
				_downloadButton.on(MouseEvent.MOUSE_OVER, _showDownloadHoverTray);
				_downloadHoverTray.addEventListener(MouseEvent.MOUSE_OVER, _showDownloadHoverTray);
				
				_downloadButton.on(MouseEvent.MOUSE_OUT, _hideDownloadHoverTray);
				_downloadHoverTray.addEventListener(MouseEvent.MOUSE_OUT, _hideDownloadHoverTray);
			}
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray:Sprite = bg.addChild(new Sprite()) as Sprite;
			var tTrayWidth = bg.width - tDownloadTray.width;
			tTray.x = -(bg.width*0.5) + (tTrayWidth*0.5) + (bg.width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var xx = 0, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			xx = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }).appendTo(tTray)
				.move(xx+tButtonXInc*tButtonsOnLeft, yy)
				.onButtonClick(dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(Fewf.isExternallyLoaded) {
				_clipboardButton = new SpriteButton({ size:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })
					.move(xx+tButtonXInc*tButtonsOnLeft, yy)
					.onButtonClick(dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			xx = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			new SpriteButton({ size:tButtonSize, obj_scale:0.42, obj:new $Trash(), origin:0.5 }).appendTo(tTray)
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.onButtonClick(dispatchEventHandler(TRASH_CLICKED));
			tButtonOnRight++;

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			new SpriteButton({ size:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 }).appendTo(tTray)
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.onButtonClick(dispatchEventHandler(RANDOM_CLICKED));
			tButtonOnRight++;
			
			_animateButton = new SpriteButton({ size:tButtonSize, obj:new $PlayButton(), obj_scale:0.5, origin:0.5 })
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.onButtonClick(dispatchEventHandler(ANIMATION_TOGGLED))
				.appendTo(tTray) as SpriteButton;
			toggleAnimateButtonAsset(pCharacter.animatePose);
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			xx = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			_scaleSlider = new FancySlider(tSliderWidth).move(xx, yy)
				.setSliderParams(1, 4, pCharacter.outfit.scaleX)
				.appendTo(tTray)
				.on(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			/****************************
			* Selectable text field
			*****************************/
			new PasteShareCodeInput().appendTo(this).move(18, 34)
				.on(PasteShareCodeInput.CHANGE, function(e:FewfEvent):void{ onShareCodeEntered(e.data.code, e.data.update); });

		}
		public function move(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): Toolbox { target.addChild(this); return this; }
		public function on(type:String, listener:Function): Toolbox { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Toolbox { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function downloadButtonEnable(pOn:Boolean) : void {
			if(pOn) _downloadButton.enable(); else _downloadButton.disable();
			if(pOn) _gifButton.enable(); else _gifButton.disable();
			if(pOn) _webpButton.enable(); else _webpButton.disable();
		}
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			_animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
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
		
		private function _showDownloadHoverTray(e:Event) : void { _downloadHoverTray.visible = true; }
		private function _hideDownloadHoverTray(e:Event) : void { _downloadHoverTray.visible = false; }
	}
}
