package  com{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import panels.PlayerPanel;

	
	public class MainNav extends MovieClip {
		private var mainData:Object;
		private var videoPos:int;
		public var state:int;
		
		//设置状态
		public function setState(value:int):void{
			state=value;
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
			//取消二级菜单的选择
			for(var i:int=0;i<this["subCon"].numChildren;i++){
				var subNav:SubNav=this["subCon"].getChildAt(i) as SubNav
				subNav.selcted(false);
			}
		}
		
		public function MainNav(mainData:Object) {
			this.mainData=mainData;
			//写入主菜单
			var autoText:AutoText=new AutoText(mainData["title"],16,250,true);
			this["mainCon"].addChild(autoText);
			//定位子菜单位置
			this["subCon"].y=this["mainCon"].height;
			if(this.mainData["subArr"]){
				this["foldMc"].gotoAndStop(2);
				//子菜单存在，生成子菜单
				for(var i:int=0;i<this.mainData["subArr"].length;i++){
					var subNav:SubNav=new SubNav(mainData["subArr"][i]);
					if(i>0){
						subNav.y=this["subCon"].height+10;
					}
					this["subCon"].addChild(subNav);
				}
				this["mainCon"].addEventListener(MouseEvent.CLICK,onHandle);
			}else if(this.mainData["over"]){
				this["foldMc"].visible=false;
				if(this.mainData["over"]=="prictice"){
					PlayerPanel.practiceTf=autoText;
				}else{
					PlayerPanel.overTf=autoText;
				}
				//课程结束
				this["mainCon"].addEventListener(MouseEvent.CLICK,practiceClick);
			}else{
				this["foldMc"].visible=false;
				//子菜单不存在
				videoPos=FoldMenu.getIns().tempPos;
				var url:String=this.mainData["url"];
				var urlArr:Array=url.split("|");
				FoldMenu.getIns().tempPos += urlArr.length;
				
				for(var j:int=0;j<urlArr.length;j++){
					PlayerPanel.autoTfArr.push(autoText);
				}
				this["mainCon"].addEventListener(MouseEvent.CLICK,onHandle);
			}
		}
		
		private function practiceClick(e:MouseEvent):void{
			if(mainData["over"]=="prictice"){
				PlayerPanel.getIns().beginAnswer();
			}else{
				
			}
		}
		
		//点击一级菜单
		private function onHandle(e:MouseEvent):void{
			//折叠或展开子菜单
			this["subCon"].visible=!this["subCon"].visible;
			if(this["subCon"].numChildren==0){
				this["foldMc"].visible=false;
			}else{
				if(this["subCon"].visible){
					this["foldMc"].gotoAndStop(2);
				}else{
					this["foldMc"].gotoAndStop(1);
				}
			}
			FoldMenu.getIns().resetH();
			if(!mainData["subArr"]){
				var autoText:AutoText=this["mainCon"].getChildAt(0) as AutoText;
				if(!autoText.getSelected()){
					//播放选中的视频
					PlayerPanel.getIns().playVideo(videoPos);
				}
				
			}
		}
	}
	
}
