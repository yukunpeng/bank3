package  com{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class AutoText extends Sprite{
		
		private var format:TextFormat;
		
		private var _selected:Boolean=false;
		
		private var tf:TextField;
		
		public function getSelected():Boolean{
			return _selected;
		}
		
		public function selected(bl:Boolean):void{
			_selected=bl;
			if(bl){
				format.color = 0xEEEE00;
			}else{
				format.color = 0xEEEEEE;
			}
			tf.setTextFormat(format);
		}

		public function AutoText(txt:String,size:Number,w:Number,bold:Boolean) {
			tf=new TextField();
			tf.selectable=false;
			tf.width = w;//重点
			tf.wordWrap = true;//重点
			tf.autoSize = "left";//重点
            
			
			format=new TextFormat();
			format.size=size;
			format.color = 0xEEEEEE;
			format.bold = bold;
			tf.text=txt;
			tf.setTextFormat(format);
			
			addChild(tf);
			this.mouseChildren=false;
			this.buttonMode=true;
		}

	}
	
}
