package  com{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import panels.PlayerPanel;
	
	public class SubNav extends MovieClip {
		private var subData:Object;
		private var videoPos:int;
		
		//设置状态
		public function setState(value:int):void{
			this["stateMc"].gotoAndStop(value);
		}
		//读取状态
		public function getState():int{
			return this["stateMc"].currentFrame;
		}

		public function selcted(bl:Boolean):void{
			//取消一级菜单的选择
			var autoText:AutoText = this["mainCon"].getChildAt(0) as AutoText;
			autoText.selected(false);
		}
		
		public function SubNav(subData:Object) {
			this.videoPos=FoldMenu.getIns().tempPos;
			this.subData=subData;
			var autoText:AutoText=new AutoText(this.subData["title"],16,240,false);
			this["mainCon"].addChild(autoText);
			
			this["mainCon"].addEventListener(MouseEvent.CLICK,onHandle);
			
			var url:String=this.subData["url"];
			var urlArr:Array=url.split("|");
			FoldMenu.getIns().tempPos += urlArr.length;
			
			for(var i:int=0;i<urlArr.length;i++){
				PlayerPanel.autoTfArr.push(autoText);
			}
		}
		
		//点击二级菜单
		private function onHandle(e:MouseEvent):void{
			var autoText:AutoText=this["mainCon"].getChildAt(0) as AutoText;
			if(!autoText.getSelected()){
				//播放选中的视频
				PlayerPanel.getIns().playVideo(videoPos);
			}
		}
	}
	
}
