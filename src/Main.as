package  {
	
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	import panels.AnswerPanel;
	import panels.PlayerPanel;
	import panels.Shuiyin;
	
	import utils.LoadManager;
	
	public class Main extends MovieClip {		
		public static var ins:Main;
		
		public function Main() {
			//显示全部
			stage.scaleMode=StageScaleMode.SHOW_ALL;
			Main.ins=this;
			//LoadManager.getIns().loadJson("asset/videolist.json",videoListCom);
			//answerPanel=new AnswerPanel();
			//addChild(answerPanel);
			addChild(PlayerPanel.getIns());
			addChild(Shuiyin.getIns());
			
		}
		
	}
	
}
