package  com{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class QuesItem extends MovieClip {		
		private var _selected:Boolean=false;
		
		public var pos:int;
		//设置文本
		public function set text(value:String):void{
			this["txtTf"].text=value;
		}
		
		//重置数据，不选择
		public function reset():void{
			this["txtTf"].text="";
			_selected=false;
			this["checkMc"].gotoAndStop(1);
		}

		
		public function QuesItem() {
			this["txtTf"].mouseEnabled=false;
			this.buttonMode=true;
		}
		
		//对选择读写
		public function get selected():Boolean{
			return _selected;
		}
		public function set selected(value:Boolean):void{
			_selected=value;
			if(value){
				this["checkMc"].gotoAndStop(2);
			}else{
				this["checkMc"].gotoAndStop(1);
			}
		}
	}
	
}
