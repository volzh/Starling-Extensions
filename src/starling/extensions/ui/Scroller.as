package starling.extensions.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Text;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.tweener.StarlingTween;
	import starling.extensions.tweener.TweenManager;
	import starling.textures.Texture;
	
	public class Scroller extends Sprite
	{
		private var _scrollBtnUp:Button;
		private var _scrollBtnDown:Button;
		private var _scrollBar:Sprite;
		private var _scrollBarImage:Image;
		private var _scrollBG:Image;
		
		private var _contentHeight:Number = 0;
		private var _scrollHeight:Number = 1;
		private var _contentY:Number = 0;
		private var _overScroll:Number = 0;

		private var _barHeight:int;
		private var _disappearTimer:Timer;
		private var _disappearTween:StarlingTween;
		
		private var _showScrollButton:Boolean = false;
		
		/**
		 * 스크롤 버튼 클릭 시, 지속적인 스크롤 이동을 위한 타이머
		 */
		private var _scrollTimer:Timer;
		private var _scrollAmount:Number = 5;
		public var onScrollDrag:Function;
		/**
		 * ture일 경우, 컨텐츠 내용과 위치에 따라 스크롤바 사이즈가 변함. false는 고정 사이즈.
		 */
		public var isDynamicBar:Boolean = true;
		
		public function Scroller()
		{
			super();
			
			this.init();
		}
		
		private function init():void
		{
			_scrollBG = new Image(Texture.empty(10, _scrollHeight, 0xff888888));
			this.addChild(_scrollBG);
			
			_scrollBar = new Sprite();
			_scrollBarImage = new Image(Texture.empty(10, 10, 0xffff0000));
			_scrollBar.addChild(_scrollBarImage);
			this.addChild(_scrollBar);
			
			_scrollBar.addEventListener(TouchEvent.TOUCH, onScrollBarDrag);
			
			_disappearTimer = new Timer(1000,1);
			_disappearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, disappearScroller);
			
			_scrollTimer = new Timer(25);
			_scrollTimer.addEventListener(TimerEvent.TIMER, onScrollTimer);
		}
		
		protected function onScrollTimer(event:TimerEvent):void
		{
			this.dragScroll(_scrollAmount);
		}
		
		public function get showScrollButton():Boolean
		{
			return _showScrollButton;
		}

		public function set showScrollButton(value:Boolean):void
		{
			_showScrollButton = value;
			if (_showScrollButton == true){
				this.makeScrollButton();
				_scrollBG.y = _scrollBtnUp.height;
			} else {
				this.removeScrollButton();
				_scrollBG.y = 0;
			}
			_scrollBG.height = _scrollHeight - buttonHeight * 2;
		}
		
		private function makeScrollButton():void
		{
			if (_scrollBtnUp == null){
				_scrollBtnUp = new Button();
				_scrollBtnUp.alignCenter = false;
				_scrollBtnUp.upState = Texture.empty(10,10,0xff0000ff);
				_scrollBtnUp.onDown = onScrollUpBegin;
				_scrollBtnUp.onUp = onScrollUpEnd;
				this.addChild(_scrollBtnUp);
				
				_scrollBtnDown = new Button();
				_scrollBtnDown.alignCenter = false;
				_scrollBtnDown.upState = Texture.empty(10,10,0xff0000ff);
				_scrollBtnDown.onDown = onScrollDownBegin;
				_scrollBtnDown.onUp = onScrollDownEnd;
				this.addChild(_scrollBtnDown);
				
				this.relocate();
			}
		}
		
		/**
		 * 
		 * 스크롤바/버튼 등 위치 다시 설정
		 * 
		 */
		private function relocate():void
		{
			_scrollBtnDown.y = _scrollHeight - _scrollBtnDown.height;
			_scrollBG.x = int((_scrollBtnUp.width - _scrollBG.width ) / 2);
			_scrollBar.x = int((_scrollBtnUp.width - _scrollBar.width ) / 2);
			_scrollBar.y = buttonHeight;
		}
		
		private function removeScrollButton():void
		{
			_scrollBtnUp.removeFromParent();
			_scrollBtnDown.removeFromParent();
		}
		
		private function onScrollUpBegin():void
		{
			_scrollAmount = -Math.abs(_scrollAmount);
			_scrollTimer.start();
		}
		
		private function onScrollUpEnd():void
		{
			_scrollTimer.reset();
		}
		
		private function onScrollDownBegin():void
		{
			_scrollAmount = Math.abs(_scrollAmount);
			_scrollTimer.start();
		}
		
		private function onScrollDownEnd():void
		{
			_scrollTimer.reset();
		}
		
		public function get overScroll():Number
		{
			return _overScroll;
		}

		public function set overScroll(value:Number):void
		{
			_overScroll = value;
			this.updateScrollBarSize();
		}

		private function onScrollBarDrag(e:TouchEvent):void
		{
			var obj:DisplayObject = e.currentTarget as DisplayObject;
			var touch:Touch = e.getTouch(obj, TouchPhase.MOVED);
			if (touch){
				this.dragScroll(touch.getMovement(obj).y);
			}
		}
		
		private function dragScroll(amount:Number):void
		{
			_scrollBar.y += amount;
			if (_scrollBar.y < buttonHeight) _scrollBar.y = buttonHeight;
			if (_scrollBar.y > _scrollHeight - _scrollBar.height - buttonHeight) _scrollBar.y = _scrollHeight - _scrollBar.height - buttonHeight;
			if (onScrollDrag != null){
				onScrollDrag.call();
			}
		}
		
		public function get scrollY():Number
		{
			return _scrollBar.y - buttonHeight;
		}
		
		public function get scrollBarHeight():Number
		{
			return _scrollBar.height;
		}
		
		protected function disappearScroller(event:TimerEvent):void
		{
			_disappearTween = TweenManager.tween(this, {alpha:0}, {alpha:1}, 0.7);
			_disappearTween.play();
		}
		
		/**
		 * 스크롤된 컨텐트의 Y 값.
		 */
		public function get contentY():Number
		{
			return _contentY;
		}

		/**
		 * @private
		 */
		public function set contentY(value:Number):void
		{
			_contentY = value;
			this.updateScrollBar();
		}

		/**
		 * 스크롤 가능한 높이.
		 */
		public function get scrollHeight():Number
		{
			return _scrollHeight - buttonHeight * 2;
		}

		/**
		 * @private
		 */
		public function set scrollHeight(value:Number):void
		{
			_scrollHeight = value;
			this.updateScrollBarSize();
		}

		/**
		 * 스크롤이 되는 컨텐트의 높이.
		 */
		public function get contentHeight():Number
		{
			return _contentHeight;
		}

		/**
		 * @private
		 */
		public function set contentHeight(value:Number):void
		{
			_contentHeight = value;
			this.updateScrollBarSize();
		}
		
		private function updateScrollBarSize():void
		{
			if (_scrollHeight <= 0) return;
			if (_scrollHeight >= _contentHeight){
//				_scrollBar.removeFromParent();
				_scrollBar.alpha = 0.5;
				this.touchable = false;
				return;
//			} else if (this.contains(_scrollBar) == false){
			} else {
//				this.addChild(_scrollBar);
				_scrollBar.alpha = 1;
				this.touchable = true;
			}
			if (isDynamicBar){
				_barHeight = (_scrollHeight/_contentHeight) * _scrollHeight - _overScroll - buttonHeight;
				if (_barHeight < 10) _barHeight = 10;
				var tmpTexture:Texture = _scrollBarImage.texture;
				_scrollBarImage.texture = Texture.empty(10, _barHeight, 0xffff0000);
				_scrollBarImage.height = _barHeight;
				tmpTexture.dispose();
			} else {
				_barHeight = _scrollBar.height;
			}
		}

		private function updateScrollBar():void
		{
//			this.alpha = 1;
			if (_contentHeight <= 0 || _scrollHeight <= 0) return;
			/*if (_scrollHeight == _contentHeight) _scrollBar.y = 0;
			else */_scrollBar.y = (-_contentY/(_scrollHeight - _contentHeight)) * (scrollHeight - _barHeight) + buttonHeight;
			if (_scrollBar.y < buttonHeight) _scrollBar.y = buttonHeight;
			if (_scrollBar.y > _scrollHeight - _barHeight - buttonHeight) _scrollBar.y = _scrollHeight - _barHeight - buttonHeight;
			
			// pc와 모바일을 고려해서... 좀 더 생각해보고....
//			_disappearTimer.reset();
//			_disappearTimer.start();
		}
		
		private function get buttonHeight():Number
		{
			if (_showScrollButton == false) return 0;
			return _scrollBtnUp.height;
		}
		
		public function setScrollUpTexture(up:Texture, over:Texture = null, down:Texture = null):void
		{
			if (up) _scrollBtnUp.upState = up;
			if (over) _scrollBtnUp.overState = over;
			if (down) _scrollBtnUp.downState = down;
			this.relocate();
		}
		
		public function setScrollDownTexture(up:Texture, over:Texture = null, down:Texture = null):void
		{
			if (up) _scrollBtnDown.upState = up;
			if (over) _scrollBtnDown.overState = over;
			if (down) _scrollBtnDown.downState = down;
			this.relocate();
		}
		
		public function setScrollBarTexture(up:Texture):void
		{
			if (up){
				_scrollBarImage.texture = up;
				_scrollBarImage.readjustSize();
				this.relocate();
			}
		}
		
		public function setScrollBG(up:Texture):void
		{
			if (up){
				_scrollBG.texture = up;
				_scrollBG.readjustSize();
				_scrollBG.height = _scrollHeight - buttonHeight * 2;
			}
		}
	}
}