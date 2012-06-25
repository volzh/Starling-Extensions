package starling.extensions.ui
{
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	
	import sng.util.StarlingUtil;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class Button extends Sprite
	{
		private static var _group:Dictionary = new Dictionary();
		
		public var onDown:Function;
		public var onUp:Function;
		public var onOver:Function;
		public var onOut:Function;
		public var onDrag:Function;
		public var useDefaultSound:Boolean = true;
		
		private var _upState:Image;
		private var _overState:Image;
		private var _downState:Image;
		private var _disableState:Image;
		private var _text:TextField;
		private var _enabled:Boolean = true;
		private var _isOver:Boolean = false;
		private var _groupName:String;
		
		/**
		 * true일 경우, upState와 downState로 토글 됨.
		 */
		public var isToggle:Boolean = false;
		private var _currentState:String;
		private var _alignCenter:Boolean = true;
		
		public function Button()
		{
			super();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			this.useHandCursor = true;
		}
		
		private function onRemoved(e:Event):void
		{
			Mouse.cursor = MouseCursor.AUTO;
			if (this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private function onAdded(e:Event):void
		{
			if (this._currentState == null) this.currentState = TouchPhase.ENDED;
		}
		
		private function onTouch(e:TouchEvent):void
		{
			if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.MOVED)){
				this.checkIsOut(e);
				this.onDragHandle(e);
			} else if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.BEGAN)){
				this.onDownHandle();
			} else if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.ENDED)){
				this.onUpHandle();
			} else if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.HOVER) && !this._isOver){
				this.onOverHandle();
			} else if (!e.getTouch(e.currentTarget as DisplayObject, TouchPhase.HOVER) && this._isOver){
				this.onOutHandle();
			}
		}
		
		private function onDragHandle(e:TouchEvent):void
		{
			if (onDrag == null) return;
			
			var touch:Touch = e.getTouch(e.currentTarget as DisplayObject, TouchPhase.MOVED);
			var cur:Point = touch.getLocation(this.stage);
			var prev:Point = touch.getPreviousLocation(this.stage);
			onDrag.call(null, cur, prev);
		}
		
		private function checkIsOut(e:TouchEvent):void
		{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			var touch:Touch;
			
			touch = e.getTouch(target, TouchPhase.MOVED);
			if (touch == null){
				this.onOutHandle();
			} else if (target.getBounds(this.stage).contains(touch.globalX, touch.globalY)){
				this.onOverHandle();
			} else {
				this.onOutHandle();
			}
		}
		
		private function updateButtonGroup():void
		{
			var g:Vector.<Button> = _group[this._groupName];
			for (var i:int = 0; i < g.length; i++) 
			{
				if (g[i] != this){
					g[i].currentState = TouchPhase.ENDED;
				}
			}
		}
		
		private function onDownHandle():void
		{
			if (this.onDown != null) this.onDown.call(this);
			if (!this._downState) return;
			
			if (this.isToggle){
				if (this._groupName && this.currentState == TouchPhase.BEGAN) return;
				if (this._groupName && this.currentState == TouchPhase.ENDED){
					this.currentState = TouchPhase.BEGAN;
				} else {
					if (this.currentState == TouchPhase.BEGAN){
						this.currentState = TouchPhase.ENDED;
					} else {
						this.currentState = TouchPhase.BEGAN;
					}
				}
				return;
			}
			this.currentState = TouchPhase.BEGAN;
		}
		
		private function onUpHandle():void
		{
			if (this.onUp != null){
				var stage:flash.display.Stage = Starling.current.nativeStage;
				if (this.getBounds(this.stage).contains(stage.mouseX, stage.mouseY) == true){
					this.onUp.call(null);
				}
			}
			
			if (this.isToggle) return;
			if (!this._downState) return;
			this.currentState = TouchPhase.ENDED;
		}
		
		private function onOverHandle():void
		{
			if (this.onOver != null) this.onOver.call(null);
			
			this._isOver = true;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if (this.isToggle) return;
			this.currentState = TouchPhase.HOVER;
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (!this._isOver && this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			var stage:flash.display.Stage = Starling.current.nativeStage;
			if (this.getBounds(this.stage).contains(stage.mouseX, stage.mouseY) == false){
				this.onOutHandle();
			} else {
//				this.onOverHandle();
			}
		}
		
		private function onOutHandle():void
		{
			if (this.onOut != null) this.onOut.call(null);
			
			this._isOver = false;
			if (this.isToggle) return;
			this.currentState = TouchPhase.ENDED;
		}
		
		private function updateImage(target:Image, texture:Texture):void
		{
			target.texture = texture;
			target.width = texture.width;
			target.height = texture.height;
			if (this._alignCenter) StarlingUtil.SpriteAlignCenter(target);
			else StarlingUtil.SpriteAlignCenter(target, false);
			this.addChild(target);
		}
		
		public function set upState(texture:Texture):void
		{
			if (this._upState == null) this._upState = new Image(texture);
			this.updateImage(this._upState, texture);
		}
		public function set overState(texture:Texture):void
		{
			if (this._overState == null) this._overState = new Image(texture);
			this.updateImage(this._overState, texture);
		}
		public function set downState(texture:Texture):void
		{
			if (this._downState == null) this._downState = new Image(texture);
			this.updateImage(this._downState, texture);
		}
		public function set disableState(texture:Texture):void
		{
			if (this._disableState) this._disableState.texture = texture;
			else this._disableState = new Image(texture);
			StarlingUtil.SpriteAlignCenter(this._disableState);
			this.addChild(this._disableState);
		}
		public function set enabled(value:Boolean):void
		{
			this._enabled = value;
			this.touchable = this._enabled;
			this.currentState = this.currentState;
		}
		public function set currentState(value:String):void
		{
			if (this._disableState) this._disableState.visible = false;
			if (this._upState) this._upState.visible = false;
			if (this._overState) this._overState.visible = false;
			if (this._downState) this._downState.visible = false;
			
			if (this._enabled){
				if (this._disableState == null){
					if (_upState) this._upState.alpha = 1;
					this.touchable = true;
				}
			} else {
				if (this._disableState == null){
					if (_upState) this._upState.alpha = 0.5;
					this.touchable = false;
				} else {
					this._disableState.visible = true;
					return;
				}
			}
			if (value == TouchPhase.BEGAN && this._downState){
				if (_groupName) this.updateButtonGroup();
				this._currentState = TouchPhase.BEGAN;
				if (_downState) this._downState.visible = true;
			} else if (value == TouchPhase.HOVER && this._isOver && this._overState){
				this._currentState = TouchPhase.HOVER;
				if (_overState) this._overState.visible = true;
			} else {
				this._currentState = TouchPhase.ENDED;
				if (_upState) this._upState.visible = true;
			}
		}
		public function get currentState():String
		{
			return this._currentState;
		}
		
		/**
		 * 
		 * 그룹 설정. 그룹이 설정될 경우, 버튼은 toggle모드로 셋팅되며,
		 * 하나의 버튼이 selected 상태가 될 때 다른 버튼은 off 상태로 변경.
		 * 
		 * @param value
		 * 
		 */
		public function set group(value:String):void
		{
			this._groupName = value;
			this.isToggle = true;
			if (_group.hasOwnProperty(value) == false){
				_group[value] = new Vector.<Button>();
				this.currentState = TouchPhase.BEGAN;
			}
			_group[value].push(this);
		}
		
		public function set alignCenter(value:Boolean):void
		{
			this._alignCenter = value;
			if (this._upState) StarlingUtil.SpriteAlignCenter(this._upState, false);
			if (this._overState) StarlingUtil.SpriteAlignCenter(this._overState, false);
			if (this._downState) StarlingUtil.SpriteAlignCenter(this._downState, false);
		}
		
		public function set text(value:String):void
		{
			if (this._text == null){
				this._text = new TextField(this._upState.width, this._upState.height, 'button', 'Gulim', 12, 0xffffff, true);
				this._text.hAlign = HAlign.CENTER;
				this._text.vAlign = VAlign.CENTER;
				this._text.x = -this._text.width >> 1;
				this._text.y = -this._text.height >> 1;
				this.addChild(this._text);
			}
			this._text.text = value;
		}
		
		public function get text():String
		{
			if (this._text) return this._text.text;
			return null;
		}
	}
}