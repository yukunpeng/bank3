package panels {
	
	import com.QuesItem;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.LoadManager;
	import utils.QuesManager;
	import utils.SysManager;
	
	
	public class AnswerPanel extends MovieClip {
		private var score:int;
		
		private var rightArr:Array;
		private var rightNum:int;
		private var format:TextFormat;
		
		private var titleTf:TextField;
		
		//重置题目
		public function resetAns():void{
			rightNum=0;
			QuesManager.getIns().resetPos();
			fillQues();
		}

		
		public function AnswerPanel() {
			for(var i:int=0;i<6;i++){
				this["quesItem"+i].pos=i;
				this["quesItem"+i].addEventListener(MouseEvent.CLICK,quesItemClick);
			}
			
			this["tjBtn"].addEventListener(MouseEvent.CLICK,tjBtnClick);
			this.x=314;
			this.y=96;
			titleTf=getTf();
			titleTf.x=75;
			titleTf.y=94;
			addChild(titleTf);
			format=new TextFormat();
			format.size=18;
			format.color = 0x666666;
			format.bold = true;
		}
		
		
		//填入一道题目
		private function fillQues():void{
			this["tipsMc"].visible=false;
			
			if(QuesManager.getIns().isQuesOver()){
				//答题完毕
				Main.ins.removeChild(AnswerPanel.getIns());
				Main.ins.addChild(ResultPanel.getIns());
				
				var score:int=rightNum/QuesManager.getIns().getQuesSum()*100;
				ResultPanel.getIns().resetPanel(score);
			}else{
				//题目没有进行完毕,获取当前题目
				var obj:Object=QuesManager.getIns().getQues();
				//获取当前题目编号
				this["numTf"].text=QuesManager.getIns().getQuesPos()+".";
				//获取当前题目类型
				this["subjectTf"].text=QuesManager.getIns().getQuesType();
				//进入下一题
				QuesManager.getIns().gotoNext();
				//刷新题目
				titleTf.text=obj.ques;
				titleTf.setTextFormat(format);
				resetAnsPos(titleTf.y+titleTf.height+20);
				//隐藏所有答案，防止答案不止4项
				resetAllAns();
				//显示所有选项
				for(var i:int=0;i<obj.ansArr.length;i++){
					var ansMc:QuesItem=this["quesItem"+i] as QuesItem;
					//显示答案项
					ansMc.visible=true;
					//显示答案文本
					ansMc.text=obj.ansArr[i];
				}
				//保存正确答案
				rightArr=obj.ans;
			}
		}
		
		private function resetAnsPos(dis:Number):void{
			for(var i:int=0;i<6;i++){
				this["quesItem"+i].y=dis+45*i;
			}
		}
		
		//隐藏所有答案
		private function resetAllAns():void{
			for(var i:int=0;i<6;i++){
				this["quesItem"+i].visible=false;
				this["quesItem"+i].reset();
			}
		}
		
		//点击答案选项
		private function quesItemClick(e:MouseEvent):void{
			this["tipsMc"].visible=false;
			//选择点中的答案
			var quesItem:QuesItem=e.currentTarget as QuesItem;
			if(quesItem.selected){
				quesItem.selected=false;
			}else{
				quesItem.selected=true;
			}
			if(this.rightArr.length==1){
				//取消选择所有答案
				for(var i:int=0;i<6;i++){
					if(i!=quesItem.pos){
						this["quesItem"+i].selected=false;
					}
				}
			}
		}
		//点击提交按钮
		private function tjBtnClick(e:MouseEvent):void{
			var selectArr:Array=getSectedAns();
			if(selectArr.length==0){
				this["tipsMc"].visible=true;
			}else{
				if(SysManager.compareArr(selectArr,rightArr)){
					rightNum++;
				}else{
					
				}
				fillQues();
			}
		}
		//获取选择的答案
		private function getSectedAns():Array{
			var arr:Array=[];
			//取消选择所有答案
			for(var i:int=0;i<6;i++){
				if(this["quesItem"+i].selected){
					arr.push(i);
				}
			}
			return arr;
		}
		
		private function getTf():TextField{
			var tf:TextField=new TextField();
			tf.selectable=false;
			tf.width = 585;//重点
			tf.wordWrap = true;//重点
			tf.autoSize = "left";//重点
			return tf;
		}
		
		//获取加载单单例
		private static var ins:AnswerPanel;
		public static function getIns():AnswerPanel{
			if(!AnswerPanel.ins){
				AnswerPanel.ins=new AnswerPanel();
			}
			return AnswerPanel.ins;
		}

	}
	
}
