package panels {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.SysManager;
	
	
	public class ResultPanel extends MovieClip {
		
		public function resetPanel(score:int):void{
			this["scoreTf"].text=score+"";
			SysManager.saveScore(score);
			if(score>=80){
				//更新播放列表，题目完成了
				PlayerPanel.getIns().quesPass();
				this["wbTf"].text="恭喜你，挑战成功!";
				//保存本次成绩
				SysManager.sendPassed();
				
				//是否发送complete
				if(PlayerPanel.getIns().isAllLearnOver()){
					SysManager.sendComplete();
				}
			}else{
				this["wbTf"].text="很遗憾，你没有通过测试。";
			}
		}
		
		public function ResultPanel() {
			// constructor code
			this.addEventListener(MouseEvent.CLICK,onHandel);
			this.x=314;
			this.y=96;
		}
		
		private function onHandel(e:MouseEvent):void{
			switch(e.target){
				case this["rePricticeBtn"]:
					Main.ins.removeChild(this);
					Main.ins.addChild(AnswerPanel.getIns());
					AnswerPanel.getIns().resetAns();
					break;
				case this["reLearnBtn"]:
					Main.ins.removeChild(this);
					PlayerPanel.getIns().playVideo(0);
					break;
				case this["overBtn"]:
					SysManager.closeWindow();
					break;
			}
		}
		
		
		
		//获取加载单单例
		private static var ins:ResultPanel;
		public static function getIns():ResultPanel{
			if(!ResultPanel.ins){
				ResultPanel.ins=new ResultPanel();
			}
			return ResultPanel.ins;
		}

	}
	
}
