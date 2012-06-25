package starling.extensions.ui
{
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 
	 * List에 item을 추가할 때, ListItem의 instance를 사용한다.
	 * ListItem을 확장하여 사용하는 것을 권장.
	 * 
	 * @author volzh
	 * 
	 * @example
	 * <listing version='3.0'>
	 * 
	 * var list:List = new List();
	 * this.addChild(list);
	 * 
	 * for (var i:int = 0; i < 200; i++) 
	 * {
	 * 	var item:CustomListItem = new CustomListItem();
	 * 	list.add(item);
	 * }
	 * 
	 * class CustomListItem extends ListItem
	 * {
	 * 
	 * 	private var _check:CheckBox;
	 * 	public function CustomListItem()
	 * 	{
	 * 		super();
	 * 		
	 * 		this.init();
	 * 		this.onSelect = handleOnSelect;
	 * 	}
	 * 	
	 * 	private function init():void
	 * 	{
	 * 		_check = new CheckBox();
	 * 		_check.setLabel('checkbox');
	 * 		_check.setLabelOffset(0, 3);
	 * 		this.addChild(_check);
	 * 	}
	 * 	
	 * 	private function handleOnSelect():void
	 * 	{
	 * 		_check.checked = !_check.checked;
	 * 	}	
	 * 	
	 * }
	 * </listing>
	 */
	[Event(name="triggered", type="starling.events.Event")]
	public class ListItem extends Sprite
	{
		private var _enabled:Boolean = true;
		public function ListItem()
		{
			super();
		}
		
		/**
		 * 
		 * 강제로 직접 선택을 시도하는 경우의 처리
		 * 
		 */
		internal function doSelect():void
		{
			if (_enabled) this.dispatchEvent(new Event(Event.TRIGGERED));
		}
		
		public function get enabled():Boolean
		{
			return _enabled; 
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			if (_enabled){
				this.touchable = true;
				this.alpha = 1;
			} else {
				this.touchable = false;
				this.alpha = 0.5;
			}
		}
	}
}