package starling.extensions.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
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
	
	/**
	 * 
	 * CheckBox component to select multiple items.
	 * 
	 * @author volzh
	 * 
	 */
	public class CheckBox extends Sprite
	{
		[Embed(source="embed/CheckBox.png")]
		private static var IMG_CHECKBOX:Class;
		private static var _defaultUncheck:Texture;
		private static var _defaultCheck:Texture;
		
		/**
		 * 체크 변경 시 호출될 콜백 함수
		 */
		public var onChange:Function;
		
		/**
		 * hold value for CheckBox
		 */
		public var value:String = '';
		
		private var _enable:Boolean = true;
		private var _checked:Boolean = false;
		private var _label:String = 'Label';
		
		private var _imageCheckBox:Image;
		private var _textLabel:starling.text.TextField;
		private var _textMeasure:flash.text.TextField;
		
		private var _textureUnchecked:Texture;
		private var _textureChecked:Texture;
		
		/**
		 * 
		 * Create CheckBox.
		 * if no parameters, it will show default checkbox image.
		 * 
		 * @param uncheckImage set texture to be shown if unchecked
		 * @param checkImage set texture to be shown if checked
		 * 
		 */
		public function CheckBox(uncheckTexture:Texture = null, checkTexture:Texture = null)
		{
			super();
			
			_textureUnchecked = uncheckTexture;
			_textureChecked = checkTexture;
			
			this.init();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var obj:DisplayObject = e.currentTarget as DisplayObject;
			var touch:Vector.<Touch> = e.getTouches(e.currentTarget as DisplayObject, TouchPhase.ENDED);
			if ((touch.length > 0 && touch.indexOf(this) < 0) || e.getTouch(obj, TouchPhase.ENDED)){
				this.onUpHandle();
			}
		}
		
		private function onUpHandle():void
		{
			_checked = !checked;
			updateCheckImage();
			if (onChange != null) onChange.call();
		}
		
		private function init():void
		{
			if (_textureUnchecked == null || _textureChecked == null){
				this.loadTexture();
			}
			_imageCheckBox = new Image(_textureUnchecked);
			this.addChild(_imageCheckBox);
		}
		
		private function loadTexture():void
		{
			if (_defaultUncheck == null || _defaultCheck == null){
				_defaultUncheck = getTexture(21,21,0,21);
				_defaultCheck = getTexture(21,21,0,0);
			}
			_textureUnchecked = _defaultUncheck;
			_textureChecked = _defaultCheck;
		}
		
		private function getTexture(w:Number, h:Number, top:Number, left:Number):Texture
		{
			var bmp:Bitmap = new IMG_CHECKBOX() as Bitmap;
			var bmpData:BitmapData = new BitmapData(w,h,true,0);
			bmpData.draw(bmp, new Matrix(1,0,0,1,-left,-top));
			return Texture.fromBitmapData(bmpData);
		}
		
		/**
		 * 
		 * enable/disable component
		 * 
		 * @return 
		 * 
		 */
		public function get enable():Boolean
		{
			return _enable;
		}

		/**
		 * 
		 * Return true if enabled
		 * 
		 * @param value
		 * 
		 */
		public function set enable(value:Boolean):void
		{
			_enable = value;
		}

		/**
		 * 
		 * Return true if checked
		 * 
		 * @return 
		 * 
		 */
		public function get checked():Boolean
		{
			return _checked;
		}

		/**
		 * 
		 * set 'true' to be checked
		 * 
		 * @param value
		 * 
		 */
		public function set checked(value:Boolean):void
		{
			_checked = value;
			updateCheckImage();
		}

		/**
		 * 
		 * Return Label string
		 * 
		 * @return 
		 * 
		 */
		public function getLabel():String
		{
			return _label;
		}

		/**
		 *
		 * Set label.
		 * flash.display.stage.scaleMode should be set to NO_SCALE.
		 * if not, label is not displyed properly.
		 *  
		 * @param value
		 * 
		 */
		public function setLabel(text:String, fontName:String = 'Arial', fontSize:int = 12, fontColor:int = 0x00000000, bold:Boolean = false):void
		{
			_label = text;
			if (_textMeasure == null){
				_textMeasure = new flash.text.TextField();
				_textMeasure.autoSize = TextFieldAutoSize.LEFT;
			}
			
			var tf:TextFormat = new TextFormat(fontName, fontSize, fontColor, bold);
			_textMeasure.defaultTextFormat = tf;
			_textMeasure.text = text;
			
			if (_textLabel != null){
				_textLabel.dispose();
				_textLabel = null;
			}
			_textLabel = new starling.text.TextField(_textMeasure.width+10, _textMeasure.height, _label, fontName, fontSize, fontColor, bold);
			_textLabel.x = _imageCheckBox.width;
			this.addChild(_textLabel);
		}
		public function setLabelOffset(left:Number, top:Number):void
		{
			_textLabel.x = _imageCheckBox.width + left;
			_textLabel.y = top;
		}
		private function updateCheckImage():void
		{
			if (_checked == false){
				_imageCheckBox.texture = _textureUnchecked;
			} else {
				_imageCheckBox.texture = _textureChecked;
			}
			_imageCheckBox.readjustSize();
			_imageCheckBox.pivotY = _imageCheckBox.height - _textureUnchecked.height;
		}
	}
}