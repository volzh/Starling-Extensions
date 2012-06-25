package starling.extensions.ui
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Cubic;
	import org.libspark.betweenas3.tweens.ITween;
	
	import starling.animation.Transitions;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.display.SpriteExtended;
	import starling.extensions.tweener.StarlingTween;
	import starling.extensions.tweener.TweenManager;
	import starling.textures.Texture;
	
	/**
	 * 
	 * 세로 방향 스크롤만 지원하는 리스트.
	 * This List class supports only vertical scrolling.
	 * 
	 * @author volzh
	 * 
	 */
	public class List extends Sprite
	{
		private var _items:Vector.<ListItem> = new Vector.<ListItem>();
		
		private var _itemHeight:Number = 0;
		private var _width:Number = 300;
		private var _height:Number = 300;
		private var _column:int = 1;
		
		/**
		 * 현재 스크롤 값
		 */
		private var _scrollY:int = 0;
		/**
		 * 모든 아이템들이 배치되었을 때의 높이값.
		 */
		private var _contentHeight:Number = 0;
		
		private var _content:SpriteExtended = new SpriteExtended();

		private var _tweenScroll:ITween;
		private var _isScrolling:Boolean;
		private var _isScrolled:Boolean = false;
		private var _invisibleBG:Image;
		private var _scrollSpeed:Number = 0;

		private var _scrollBar:Scroller;
		private var _overScroll:int = 0;
		private var _holdTimer:Timer;
		
		private var _isDynamicBar:Boolean = true;
		private var _checkScrollID:int = -1;
		
		public function List()
		{
			super();
			
			this.addChild(_content);
			this.setMask();
			
			_invisibleBG.addEventListener(TouchEvent.TOUCH, onTouch);
			
			_scrollBar = new Scroller();
			_scrollBar.x = _width;
			_scrollBar.onScrollDrag = this.onScrollDrag;
			this.addChild(_scrollBar);
			
			_holdTimer = new Timer(100,1);
			_holdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHoldHandle);
		}
		
		private function onScrollDrag():void
		{
			this.scrollY = - _scrollBar.scrollY / (_scrollBar.scrollHeight - _scrollBar.scrollBarHeight) * (_height - _contentHeight);
		}
		
		protected function onHoldHandle(event:TimerEvent):void
		{
			_scrollSpeed = 0;
		}
		
		private function setBG():void
		{
			if (_invisibleBG == null){
				_invisibleBG = new Image(Texture.empty(64,64,0x00ff0000,true));
				this.addChild(_invisibleBG);
			}
			_invisibleBG.width = _width;
			_invisibleBG.height = _height;
		}
		
		private function onTouch(e:TouchEvent):void
		{
			if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.BEGAN)){
				this.onDownHandle();
			} else if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.ENDED)){
				this.onUpHandle(e);
			} else if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.MOVED)){
				this.onMoveHandle(e);
			}
		}
		
		private function onMoveHandle(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(e.currentTarget as DisplayObject, TouchPhase.MOVED);
			var cur:Point = touch.getLocation(this.stage);
			var prev:Point = touch.getPreviousLocation(this.stage);
			_scrollSpeed = prev.y - cur.y;
			this.scrollY += _scrollSpeed;
			_isScrolled = true;
			
			_holdTimer.reset();
			_holdTimer.start();
		}
		
		private function onDownHandle():void
		{
			_overScroll = 0;
			_scrollSpeed = 0;
			if (_isScrolling){
				_isScrolling = false;
				_tweenScroll.stop();
			}
		}
		
		private function onUpHandle(e:TouchEvent):void
		{
			_holdTimer.reset();
			this.checkOverScrolled();
			if (_isScrolled == false){
				var range:Array = calculateRange();
				var touch:Touch = e.getTouch(e.currentTarget as DisplayObject);
				var point:Point = touch.getLocation(this);
				var obj:ListItem;
				for (var i:int = range[0]; i <= range[1]; i++) 
				{
					obj = _items[i];
					if (obj.getBounds(this).containsPoint(point)){
						obj.doSelect();
						break;
					}
				}
			}
			_isScrolled = false;
		}
		
		private function checkOverScrolled():void
		{
			if (Math.abs(_overScroll) > 0 && _contentHeight <= _height ){
				this.scrollYto(0);
			} else if (_overScroll > 0){
				this.scrollYto(scrollMaxY);
			} else if (Math.abs(_scrollSpeed) > 0){
				this.scrollingBySpeed();
			}
		}
		
		private function scrollingBySpeed():void
		{
			this.scrollY += _scrollSpeed;
			_scrollSpeed *= 0.9;
			if (_overScroll != 0) {
				this.scrollToEnd();
			} else if (Math.abs(_scrollSpeed) > 1){
				setTimeout(scrollingBySpeed, 25);
			}
		}
		
		private function scrollToEnd():void
		{
			if (_scrollY < 0) this.scrollYto(0);
			else this.scrollYto(scrollMaxY);
		}
		
		private function setMask():void
		{
			_content.maskArea = new Rectangle(0,0,_width,_height);
			this.setBG();
		}
		
		public function set showScrollButton(value:Boolean):void
		{
			_scrollBar.showScrollButton = value;
		}
		
		/**
		 * 
		 * 리스트 아이템의 높이값
		 * height of list items.
		 * 
		 * @return 
		 * 
		 */
		public function get itemHeight():Number
		{
			return _itemHeight;
		}

		/**
		 * 
		 * 리스트 아이템의 높이값 설정. 설정하지 않을 경우, 첫번째로 추가된 아이템의 높이값으로 설정.
		 * set height of list items. if not set, will use height of first added item.
		 * 
		 * @param value
		 * 
		 */
		public function set itemHeight(value:Number):void
		{
			_itemHeight = value;
			this.updateList();
		}

		public function get column():int
		{
			return _column;
		}

		/**
		 * 
		 * 한 행에 배치될 아이템의 갯수
		 * set number of list items in a row
		 * 
		 * @param value
		 * 
		 */
		public function set column(value:int):void
		{
			_column = value;
		}

		/**
		 * 
		 * 마지막에 아이템 추가
		 * add item to last
		 * 
		 * @param obj
		 * 
		 */
		public function add(obj:ListItem):void
		{
			addAt(obj, _items.length);
		}
		
		/**
		 * 
		 * index 위치에 아이템 추가
		 * insert item at index
		 * 
		 * @param obj
		 * @param index
		 * 
		 */
		public function addAt(obj:ListItem, index:int):void
		{
			_items.splice(index, 0, obj);
			if (_itemHeight == 0) _itemHeight = obj.height;
			_contentHeight = _itemHeight * Math.ceil(_items.length / _column);
			this.updateList();
			this.updateScrollBar();
			this.checkOverScrolled();
			trace(_overScroll);
		}
		
		/**
		 * 
		 * obj에 해당하는 아이템 삭제
		 * remove item
		 * 
		 * @param obj
		 * 
		 */
		public function remove(obj:ListItem):void
		{
			var index:int = _items.indexOf(obj);
			removeAt(index);
		}
		
		/**
		 * 
		 * index 위치의 아이템 삭제
		 * remove item at index
		 * 
		 * @param index
		 * 
		 */
		public function removeAt(index:int):void
		{
			_items.splice(index, 1);
			_contentHeight = _itemHeight * Math.ceil(_items.length / _column);
			this.updateList();
			this.updateScrollBar();
//			if (_items.length > 0){
//				if (_items[_items.length-1].parent != null && _items[_items.length-1].y + _itemHeight < _contentHeight){
//					this.scrollToEnd();
//				}
//			}
			this.checkOverScrolled();
		}
		
		public function removeAll():void
		{
			if (_tweenScroll) _tweenScroll.stop();
			_scrollY = 0;
			_overScroll = 0;
			_scrollSpeed = 0;
			this.updateScrollBar();
			_content.removeChildren();
			_items = new Vector.<ListItem>();
		}
		
		public override function get width():Number
		{
			return _width;
		}
		
		/**
		 * 
		 * 리스트의 너비값을 설정.
		 * update mask width, scroller position & size
		 * 
		 * @param value
		 * 
		 */
		public override function set width(value:Number):void
		{
			_width = value;
			_scrollBar.x = _width;
			this.setMask();
		}
		
		public override function get height():Number
		{
			return _height;
		}
		
		/**
		 * 
		 * 리스트의 높이값을 설정.
		 * update mask height, scroller position & size
		 * 
		 * @param value
		 * 
		 */
		public override function set height(value:Number):void
		{
			_height = value;
			this.setMask();
			_scrollBar.scrollHeight = _height;
		}
		
		public function get scrollMaxY():int
		{
			return _contentHeight - _height;
		}
		
		public function get scrollY():int
		{
			return _scrollY;
		}
		
		/**
		 * 
		 * y값으롤 스크롤 이동
		 * 
		 * @param value
		 * 
		 */
		public function set scrollY(value:int):void
		{
			_scrollY = value;
			if (_contentHeight <= _height) _scrollY = 0;
			updateList();
			updateScrollBar();
		}
		
		/**
		 * 
		 * y값으로 스크롤을 tween
		 * 
		 * @param value
		 * 
		 */
		public function scrollYto(value:int):void
		{
			if (_tweenScroll) _tweenScroll.stop();
			_tweenScroll = BetweenAS3.delay(
				BetweenAS3.tween(this, {scrollY:value}, null, 0.7, Cubic.easeOut)
				, 0.1
				);
			_tweenScroll.onComplete = scrollingComplete;
			_tweenScroll.play();
			_isScrolling = true;
		}
		
		private function scrollingComplete():void
		{
			_isScrolling = false;
		}
		
		/**
		 * 
		 * update all item position based on _items array
		 * 
		 */
		private function updateList():void
		{
			_content.removeChildren();
			
			var range:Array = calculateRange();
			if (range[0] < 0) return;
			for (var i:int = range[0]; i <= range[1]; i++) 
			{
				_items[i].x = int((i % _column) * (_width / _column));
				_items[i].y = -_scrollY + int(i / _column) * _itemHeight;
				_content.addChild(_items[i]);
			}
			
			if (_height <= _contentHeight){
				if (_scrollY <= 0){
					_overScroll = _scrollY;
				} else if (_scrollY >= _contentHeight - _height){
					_overScroll = -(_contentHeight - _height - _scrollY);
				}
			} else {
				_overScroll = _scrollY;
			}
		}
		
		private function calculateRange():Array
		{
			var start:int = Math.max(int(_scrollY / _itemHeight) * _column, 0);
			var end:int = Math.min(start + Math.ceil(_height / _itemHeight) * _column + _column, _items.length - 1);
			if (end - start < _column * Math.ceil(_height / _itemHeight)){
				end = _items.length - 1;
				start = Math.max(end - _column * Math.ceil(_height / _itemHeight), 0);
			}
			return [start, end];
		}
		
		private function updateScrollBar():void
		{
			_scrollBar.overScroll = Math.abs(_overScroll/2);
			_scrollBar.contentHeight = _contentHeight;
			if (_contentHeight <= _height){
				_scrollBar.contentY = 0;
			} else {
				_scrollBar.contentY = _scrollY;
			}
		}
		
		public function get scroller():Scroller
		{
			return _scrollBar;
		}

		/**
		 * ture일 경우, 컨텐츠 내용과 위치에 따라 스크롤바 사이즈가 변함. false는 고정 사이즈.
		 */
		public function get isDynamicBar():Boolean
		{
			return _isDynamicBar;
		}

		/**
		 * @private
		 */
		public function set isDynamicBar(value:Boolean):void
		{
			_isDynamicBar = value;
			_scrollBar.isDynamicBar = _isDynamicBar;
		}
		
		/**
		 * 
		 * index 번째 ListItem 반환
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function getItemAt(index:int):ListItem
		{
			if (index >= _items.length) return null;
			return _items[index];
		}
		
		/**
		 * 
		 * 리스트에 나열된 ListItem의 개수
		 * 
		 * @return 
		 * 
		 */
		public function get length():int
		{
			return _items.length;
		}
	}
}