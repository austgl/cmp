﻿package {

	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.*;
	import com.adobe.serialization.json.*;
	import flash.geom.Point;

	public class Weather extends MovieClip {
		public var api:Object;
		public var tw:Number;
		public var th:Number;

		public var weather_handler:String = "weather.php";
		public var weather_xywh:String = "0C,10,48,48";
		
		public var weather_info:Object;
		public var weather_id:String;
		
		public var city_name:String = "";
		
		public var main_point:Point;
		public var main_alpha:Number = 0.3;
		
		public var citylist:Array = [];

		public function Weather() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			initList();
			
			info.visible = false;
			info.loading.visible = false;
			info.bt_close.addEventListener(MouseEvent.CLICK, closeClick);
			info.bt_change.addEventListener(MouseEvent.CLICK, changeClick);
			
			main.mouseChildren = false;
			main.buttonMode = true;
			main.alpha = main_alpha;
			main.addEventListener(MouseEvent.CLICK, mainClick);
			main.addEventListener(MouseEvent.ROLL_OVER, mainOver);
			main.addEventListener(MouseEvent.ROLL_OUT, mainOut);
			
			dragEnabled();
			
		}
		
		public function showIcon(n:String):void {
			var icon1:Sprite = getIcon("icon_" + n);
			clear(main);
			main.addChild(icon1);
			layout();
			var icon2:Sprite = getIcon("icon_" + n);
			clear(info.icon);
			info.icon.addChild(icon2);
			info.icon.x = info.width - icon2.width - 15;
			info.icon.y = 35;
		}
		
		public function getIcon(n:String):Sprite {
			var icon:Sprite = new Sprite();
			if (n) {
				var icons:Icons = new Icons();
				icon = icons.getChildByName(n) as Sprite;
			}
			return icon;
		}
		
		public function showMsg(str:String):void {
			api.tools.output(str)
		}
		public function mainOver(e:MouseEvent):void {
			TweenNano.to(main, 0.2, {alpha:1});
		}
		public function mainOut(e:MouseEvent):void {
			if (!info.visible) {
				TweenNano.to(main, 0.2, {alpha:main_alpha});
			}
		}
		
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			//api.tools.output("api remove");

		}
		public function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			if (api.config.weather_xywh) {
				weather_xywh = api.config.weather_xywh;
			}

			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();

			if (api.config.weather_handler) {
				weather_handler = api.config.weather_handler;
			}
			
			var id:String = api.cookie("weather_id");
			
			//api.tools.output(id);

			getPC();

		}
		
		//================================================================================================
		
		public function changeClick(e:MouseEvent):void {
			var city:String = info.city.text;
			if (city) {
				showCity(city);
			}
		}
		
		
		public function closeClick(e:MouseEvent):void {
			hideInfo();
		}
		
		public function mainClick(e:MouseEvent):void {
			
			if (!weather_info) {
				return;
			}
			
			var point:Point = new Point(mouseX, mouseY);
			if (!main_point.equals(point)) {
				return;
			}
			
			if (info.visible) {
				hideInfo();
			} else {
				showInfo();
			}
		}
		
		public function showInfo():void {
			if (!info.visible) {
				info.alpha = 0;
				info.visible = true;
			}
			TweenNano.to(info, 0.2, {alpha:1});
			hideMain();
		}
		
		public function hideInfo():void {
			if (info.visible) {
				TweenNano.to(info, 0.2, {alpha:0, onCompleteParams:[info], onComplete:hideMc});
				showMain();
			}
		}
		
		public function hideMc(mc:MovieClip):void {
			mc.visible = false;
		}
		
		
		public function showMain():void {
			if (!main.visible) {
				main.alpha = 0;
				main.visible = true;
			}
			TweenNano.to(main, 0.2, {alpha:main_alpha});
		}
		
		public function hideMain():void {
			if (main.visible) {
				TweenNano.to(main, 0.2, {alpha:0, onCompleteParams:[main], onComplete:hideMc});
			}
		}
		
		//================================================================================================
		
		public function load(url:String, onerr:Function, oning:Function, onled:Function):void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, onerr);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onerr);
			loader.addEventListener(ProgressEvent.PROGRESS, oning);
			loader.addEventListener(Event.COMPLETE, onled);
			var req:URLRequest = new URLRequest(url);
			try {
				loader.load(req);
			} catch (e:Error) {
				onerr.call(null, e);
			}
			
		}
		private function onError(e:Event = null):void {
			showMsg("服务数据连接错误");
			info.loading.visible = false;
		}
		private function onProgress(e:ProgressEvent):void {
		}
		
		public function getPC():void {
			var params:Object = {cmd:"getpc"};
			var url:String = addUrlParameters(weather_handler,params);
			load(url, onError, onProgress, onPCLoaded);
		}

		
		private function onPCLoaded(e:Event):void {
			info.loading.visible = false;
			var json:Object;
			try {
				json = JSON.decode(e.target.data);
			} catch (e) {
			}
			if (!json) {
				showMsg("返回数据格式错误");
				return;
			}
			
			var city:String = unescape(json.city);
			var province:String = unescape(json.province);
			showCity(city, province)
		}
		
		public function showCity(city:String, province:String = ""):void {
			var id:String = cityid(city, province);
			if (id) {
				weather_id = id;
				api.cookie("weather_id", id);
				getID();
			} else {
				showMsg("无法找到城市信息");
			}
		}
		
		public function cityid(city:String, province:String = ""):String {
			var cl:int = citylist.length;
			for (var i:int = 0; i < cl; i ++) {
				if (citylist[i][0] == city) {
					return citylist[i][1];
					break;
				}
			}
			if (province) {
				for (var j:int = 0; j < cl; j ++) {
					if (citylist[j][0] == province) {
						return citylist[i][1];
						break;
					}
				}
			}
			return "";
		}
		
		public function getID():void {
			info.loading.visible = true;
			var params:Object = {cmd:"getid", id:weather_id};
			params.rd = Math.random().toString().substr(2);
			var url:String = addUrlParameters(weather_handler,params);
			load(url, onError, onProgress, onIDLoaded);
		}
		
		private function onIDLoaded(e:Event):void {
			info.loading.visible = false;
			var json:Object;
			try {
				json = JSON.decode(e.target.data);
			} catch (e) {
			}
			if (!json) {
				showMsg("返回数据格式错误");
				return;
			}
						
			weather_info = json.weatherinfo;
			
			city_name = weather_info.city;
			
			info.city.text = city_name;
			
			var str:String = "";
			str = "<b>" + city_name + '</b> 今天  <font size="12px">' + weather_info.date_y + " " + weather_info.week + '</font>';
			info.citytitle1.htmlText = str;
			
			str = weather_info.weather1 + "  气温：<b>" + weather_info.temp1 + "</b>  " + weather_info.wind1 + "\n";
			str += '<font color="#cccccc" size="12px">紫外线：' + weather_info.index_uv + '  ' + weather_info.index_d + '</font>';
			info.citytext1.htmlText = str;
			
			
			str = '天气：' + weather_info.weather2 + "\n气温：<b>" + weather_info.temp2 + "</b>\n" + weather_info.wind2;
			info.citytext2.htmlText = str;
			
			str = '天气：' + weather_info.weather3 + "\n气温：<b>" + weather_info.temp3 + "</b>\n" + weather_info.wind3;
			info.citytext3.htmlText = str;
			
			
			var imgpath:String = "http://flash.weather.com.cn/wmaps/icon/";
			
			var durl1:String = imgpath + "d"+weather_info.img1+".swf";
			if (weather_info.img2 > 32) {
				weather_info.img2 = weather_info.img1;
			}
			var nurl1:String = imgpath + "n"+weather_info.img2+".swf";
			
			clear(info.cityicon1);
			iconLoad(durl1, dled1);
			iconLoad(nurl1, nled1);
			
			showIcon(weather_info.img1);
			
			var durl2:String = imgpath + "d"+weather_info.img3+".swf";
			if (weather_info.img4 > 32) {
				weather_info.img4 = weather_info.img3;
			}
			var nurl2:String = imgpath + "n"+weather_info.img4+".swf";
			clear(info.cityicon2);
			iconLoad(durl2, dled2);
			iconLoad(nurl2, nled2);
			var durl3:String = imgpath + "d"+weather_info.img5+".swf";
			if (weather_info.img6 > 32) {
				weather_info.img6 = weather_info.img5;
			}
			var nurl3:String = imgpath + "n"+weather_info.img6+".swf";
			clear(info.cityicon3);
			iconLoad(durl3, dled3);
			iconLoad(nurl3, nled3);
		}
		
		private function dled1(e:Event):void {
			var loader:Loader = e.target.loader;
			info.cityicon1.addChild(loader);
		}
		
		private function nled1(e:Event):void {
			var loader:Loader = e.target.loader;
			loader.x = loader.width + 5;
			info.cityicon1.addChild(loader);
		}
		
		private function dled2(e:Event):void {
			var loader:Loader = e.target.loader;
			info.cityicon2.addChild(loader);
		}
		
		private function nled2(e:Event):void {
			var loader:Loader = e.target.loader;
			loader.x = loader.width + 5;
			info.cityicon2.addChild(loader);
		}
		
		private function dled3(e:Event):void {
			var loader:Loader = e.target.loader;
			info.cityicon3.addChild(loader);
		}
		
		private function nled3(e:Event):void {
			var loader:Loader = e.target.loader;
			loader.x = loader.width + 5;
			info.cityicon3.addChild(loader);
		}
		
		public function iconLoad(url:String, onled:Function):void {
			if (! url) {
				return;
			}
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onled);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, iconError);
			var request:URLRequest = new URLRequest(url);
			try {
				loader.load(request);
			} catch (e:Error) {
			}
		}

		private function iconError(e:IOErrorEvent):void {
		}

		public function resizeHandler(e:Event = null):void {
			if (! api) {
				return;
			}

			tw = api.config.width;
			th = api.config.height;
			
			info.x = Math.round((tw - info.width) * 0.5);
			info.y = Math.round((th - info.height) * 0.5);
			
			layout();
		}
		
		public function layout():void {
			var arr:Array = api.tools.strings.xywh(weather_xywh,tw,th);
			main.x = arr[0];
			main.y = arr[1];
			main.width = arr[2];
			main.height = arr[3];
		}
		
		public function clear(clip:DisplayObjectContainer):void {
			if (!clip) {
				return;
			}
			while (clip.numChildren) {
				clip.removeChildAt(0);
			}
		}
		
		public function dragEnabled():void {
			info.back.addEventListener(MouseEvent.MOUSE_DOWN, backDown);
			main.addEventListener(MouseEvent.MOUSE_DOWN, mainDown);
		}
		public function backDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, backUp);
			info.startDrag();
		}
		public function backUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, backUp);
			info.stopDrag();
		}
		public function mainDown(e:MouseEvent):void {
			main_point = new Point(mouseX, mouseY);
			stage.addEventListener(MouseEvent.MOUSE_UP, mainUp);
			main.startDrag();
		}
		public function mainUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mainUp);
			main.stopDrag();
		}


		public function addUrlParameters(url:String, obj:Object):String {
			if (! url) {
				return "";
			}
			if (url.indexOf("?") == -1) {
				url +=  "?";
			} else {
				url +=  "&";
			}
			if (obj) {
				var arr:Array = [];
				for (var i:String in obj) {
					arr.push(i + "=" + encodeURIComponent(obj[i]));
				}
				url +=  arr.join("&");
			}
			return url;
		}
		

		public function initList():void {
			citylist = [['北京','101010100'],['上海','101020100'],['天津','101030100'],['塘沽','101031100'],['重庆','101040100'],['涪陵','101041400'],['江津','101040500'],['巫山','101042000'],['河北','101090101'],['石家庄','101090101'],['张家口','101090301'],['承德','101090402'],['秦皇岛','101091101'],['唐山','101090501'],['廊坊','101090601'],['保定','101090201'],['沧州','101090701'],['衡水','101090801'],['邢台','101090901'],['邯郸','101091001'],['张北','101090303'],['蔚县','101090307'],['丰宁','101090408'],['围场','101090410'],['怀来','101090311'],['遵化','101090510'],['青龙','101091102'],['坝县','101090608'],['乐亭','101090506'],['饶阳','101090805'],['黄骅','101090713'],['南宫','101090916'],['山西','101100101'],['太原','101100101'],['大同','101100201'],['朔州','101100901'],['阳泉','101100301'],['长治','101100501'],['晋城','101100601'],['忻州','101101001'],['晋中','101100410'],['临汾','101100701'],['运城','101100801'],['吕梁','101101100'],['右玉','101100904'],['河曲','101101004'],['五台山','101101010'],['五寨','101101014'],['兴县','101101103'],['原平','101101015'],['离石','101101100'],['榆社','101100403'],['隰县','101100704'],['介休','101100412'],['候马','101100714'],['阳城','101100603'],['内蒙古','101080101'],['呼和浩特','101080101'],['包头','101080201'],['乌海','101080708'],['赤峰','101080601'],['通辽','101080501'],['呼伦贝尔','101081000'],['鄂尔多斯','101080701'],['乌兰察布','101080401'],['巴彦淖尔','101080801'],['兴安盟','101081101'],['锡林郭勒盟','101080901'],['阿拉善盟','101081202'],['额尔古纳右旗','101081014'],['图里河','101081016'],['满州里','101081010'],['海拉尔','101081000'],['小二沟','101081002'],['新巴尔虎右旗','101081009'],['新巴尔虎左旗','101081008'],['博克图','101080916'],['扎兰屯','101081012'],['科前旗阿尔山','101081102'],['索轮','101081106'],['乌兰浩特','101081101'],['东乌珠穆沁旗','101080909'],['额济纳旗','101081203'],['拐子湖','101081204'],['巴音毛道','101081209'],['阿拉善右旗','101081202'],['二连浩特','101080903'],['那仁宝力格','101080809'],['满都拉','101080203'],['阿巴嘎旗','101080904'],['苏尼特左旗','101080906'],['海力素','101080808'],['朱日和','101080908'],['乌拉特中旗','101080806'],['百灵庙','101080206'],['四子王旗','101080411'],['化德','101080403'],['集宁','101080401'],['吉兰太','101081205'],['临河','101080801'],['鄂托克旗','101080708'],['东胜','101080701'],['伊金霍洛旗','101080711'],['阿拉善左旗','101081201'],['西乌珠穆沁旗','101080910'],['扎鲁特旗','101080509'],['巴林左旗','101080605'],['锡林浩特','101080901'],['林西','101080607'],['开鲁','101080506'],['多伦','101080915'],['翁牛特旗','101080609'],['宝国图','101080615'],['辽宁','101070101'],['沈阳','101070101'],['朝阳','101071201'],['阜新','101070901'],['铁岭','101071101'],['抚顺','101070401'],['本溪','101070501'],['辽阳','101071001'],['鞍山','101070301'],['丹东','101070601'],['大连','101070201'],['营口','101070801'],['盘锦','101071301'],['锦州','101070701'],['葫芦岛','101071401'],['彰武','101070902'],['开原','101071102'],['清原','101070403'],['叶柏寿','101071207'],['新民','101070106'],['黑山','101070705'],['章党','101070404'],['桓仁','101070504'],['绥中','101071403'],['兴城','101071404'],['岫岩','101070303'],['宽甸','101070603'],['瓦房店','101070202'],['庄河','101070207'],['吉林','101060101'],['长春','101060101'],['白城','101060601'],['松原','101060801'],['吉林','101060201'],['四平','101060401'],['辽源','101060701'],['通化','101060501'],['白山','101060901'],['延吉','101060301'],['乾安','101060802'],['前郭尔罗斯','101060803'],['通榆','101060605'],['长岭','101060804'],['三岔河','101060805'],['双辽','101060402'],['蛟河','101060204'],['敦化','101060302'],['汪清','101060304'],['梅河口','101060502'],['桦甸','101060206'],['靖宇','101060902'],['东岗','101060904'],['松江','101060310'],['临江','101060903'],['集安','101060505'],['长白','101060905'],['黑龙江','101050101'],['哈尔滨','101050101'],['齐齐哈尔','101050201'],['黑河','101050601'],['大庆','101050905'],['伊春','101050801'],['鹤岗','101051201'],['佳木斯','101050401'],['双鸭山','101051301'],['七台河','101051003'],['鸡西','101051101'],['牡丹江','101050301'],['绥化','101050501'],['大兴安岭','101050701'],['漠河','101050703'],['塔河','101050702'],['新林','101050706'],['呼玛','101050704'],['嫩江','101050602'],['孙吴','101050603'],['北安','101050606'],['克山','101050208'],['富裕','101050205'],['海伦','101050504'],['明水','101050505'],['富锦','101050407'],['泰来','101050210'],['安达','101050503'],['铁力','101050804'],['依兰','101050106'],['宝清','101051303'],['肇州','101050903'],['通河','101050108'],['尚志','101050111'],['虎林','101051102'],['绥芬河','101050305'],['江苏','101190101'],['南京','101190101'],['徐州','101190801'],['连云港','101191001'],['宿迁','101191301'],['淮安','101190908'],['盐城','101190701'],['扬州','101190601'],['泰州','101191201'],['南通','101190501'],['镇江','101190301'],['常州','101191101'],['无锡','101190201'],['苏州','101190401'],['赣榆','101191003'],['盱眙','101190903'],['淮阴','101190901'],['射阳','101190705'],['高邮','101190604'],['东台','101190707'],['吕泗','101190505'],['溧阳','101191102'],['吴县东山','101190405'],['浙江','101210101'],['杭州','101210101'],['湖州','101210201'],['嘉兴','101210301'],['舟山','101211101'],['宁波','101210410'],['绍兴','101210501'],['衢州','101211001'],['金华','101210901'],['台州','101210601'],['温州','101210701'],['丽水','101210801'],['平湖','101210305'],['慈溪','101210403'],['嵊泗','101211102'],['定海','101211101'],['嵊县','101210505'],['鄞县','101210401'],['龙泉','101210803'],['洪家','101210609'],['玉环','101210603'],['安徽','101220101'],['合肥','101220101'],['宿州','101221201'],['淮北','101221201'],['阜阳','101220801'],['亳州','101220901'],['蚌埠','101220201'],['淮南','101220401'],['滁州','101221101'],['马鞍山','101220501'],['芜湖','101220301'],['铜陵','101221301'],['安庆','101220601'],['黄山','101221001'],['六安','101221501'],['巢湖','101221601'],['池州','101221701'],['宣城','101221401'],['砀山','101220702'],['宿县','101220701'],['寿县','101221503'],['霍山','101221506'],['桐城','101220609'],['芜湖县','101220303'],['宁国','101221404'],['屯溪','101221003'],['福建','101230101'],['福州','101230101'],['南平','101230901'],['三明','101230801'],['莆田','101230401'],['泉州','101230509'],['厦门','101230201'],['漳州','101230601'],['龙岩','101230701'],['宁德','101230301'],['邵武','101230904'],['武夷山市','101230905'],['浦城','101230906'],['建瓯','101230910'],['福鼎','101230308'],['泰宁','101230804'],['长汀','101230702'],['上杭','101230705'],['永安','101230810'],['屏南','101230309'],['平潭','101230108'],['崇武','101230507'],['东山','101230608'],['江西','101240101'],['南昌','101240101'],['九江','101240201'],['景德镇','101240801'],['鹰潭','101241101'],['新余','101241001'],['萍乡','101240901'],['赣州','101240701'],['上饶','101240301'],['抚州','101240401'],['宜春','101240501'],['吉安','101240601'],['修水','101240212'],['宁冈','101240613'],['遂川','101240610'],['庐山','101240203'],['波阳','101240302'],['樟树','101240509'],['贵溪','101241103'],['玉山','101240312'],['南城','101240408'],['广昌','101240402'],['寻乌','101240716'],['山东','101120101'],['济南','101120101'],['聊城','101121701'],['德州','101120401'],['东营','101121201'],['淄博','101120301'],['潍坊','101120601'],['烟台','101120501'],['威海','101121301'],['青岛','101120201'],['日照','101121501'],['临沂','101120901'],['枣庄','101121401'],['济宁','101120701'],['泰安','101120801'],['莱芜','101121601'],['滨州','101121101'],['菏泽','101121001'],['惠民县','101121105'],['羊角沟','101121201'],['长岛','101120503'],['龙口','101120505'],['成山头','101121305'],['朝城','101121708'],['泰山','101120803'],['沂源','101120306'],['莱阳','101120510'],['海阳','101120511'],['石岛','101121306'],['兖州','101120705'],['莒县','101121503'],['河南','101180101'],['郑州','101180101'],['三门峡','101181701'],['洛阳','101180901'],['焦作','101181101'],['新乡','101180301'],['鹤壁','101181201'],['安阳','101180201'],['濮阳','101181301'],['开封','101180801'],['商丘','101181001'],['许昌','101180401'],['漯河','101181501'],['平顶山','101180501'],['南阳','101180701'],['信阳','101180601'],['周口','101181401'],['驻马店','101181601'],['济源','101181801'],['卢氏','101181704'],['孟津','101180903'],['栾川','101180909'],['西峡','101180705'],['宝丰','101180503'],['西华','101181405'],['固始','101180608'],['湖北','101200101'],['武汉','101200101'],['十堰','101201101'],['襄樊','101200201'],['荆门','101201401'],['孝感','101200401'],['黄冈','101200501'],['鄂州','101200301'],['黄石','101200601'],['咸宁','101200701'],['荆州','101200801'],['宜昌','101200901'],['随州','101201301'],['仙桃','101201601'],['天门','101201501'],['潜江','101201701'],['神农架','101201201'],['恩施','101201001'],['郧西','101201103'],['房县','101201106'],['老河口','101200206'],['枣阳','101200208'],['巴东','101201008'],['钟祥','101201402'],['广水','101201302'],['麻城','101200503'],['五峰','101200906'],['来风','101201007'],['嘉鱼','101200703'],['英山','101200505'],['湖南','101250101'],['长沙','101250101'],['张家界','101251101'],['常德','101250601'],['益阳','101250700'],['岳阳','101251001'],['株洲','101250301'],['湘潭','101250201'],['衡阳','101250401'],['郴州','101250501'],['永州','101251405'],['邵阳','101250901'],['怀化','101251201'],['娄底','101250801'],['吉首','101251501'],['桑植','101251102'],['石门','101250607'],['南县','101250702'],['沅陵','101251203'],['安化','101250704'],['沅江','101250705'],['平江','101251005'],['芷江','101251210'],['双峰','101250802'],['南岳','101250409'],['通道','101251207'],['武冈','101250908'],['零陵','101251401'],['常宁','101250406'],['道县','101251405'],['广东','101280101'],['广州','101280101'],['清远','101281301'],['韶关','101280201'],['河源','101281201'],['梅州','101280401'],['潮州','101281501'],['汕头','101280501'],['揭阳','101281901'],['汕尾','101282101'],['惠州','101280301'],['东莞','101281601'],['深圳','101280601'],['珠海','101280701'],['中山','101281701'],['江门','101281101'],['佛山','101280800'],['肇庆','101280901'],['云浮','101281401'],['阳江','101281801'],['茂名','101282001'],['湛江','101281001'],['南雄','101280207'],['连县','101281303'],['佛冈','101281306'],['连平','101281203'],['广宁','101280902'],['增城','101280104'],['五华','101280408'],['惠来','101281904'],['南澳','101280504'],['信宜','101282005'],['罗定','101281402'],['台山','101281106'],['电白','101282004'],['徐闻','101281004'],['广西','101300101'],['南宁','101300101'],['桂林','101300501'],['柳州','101300301'],['梧州','101300601'],['贵港','101300801'],['玉林','101300901'],['钦州','101301101'],['北海','101301301'],['防城港','101301401'],['崇左','101300201'],['百色','101301001'],['河池','101301201'],['来宾','101300401'],['贺州','101300701'],['融安','101300306'],['凤山','101301208'],['都安','101301210'],['蒙山','101300605'],['那坡','101301002'],['靖西','101301005'],['平果','101301007'],['桂平','101300802'],['龙州','101300203'],['灵山','101301103'],['东兴','101301403'],['涠洲岛','101301303'],['海南','101310101'],['海口','101310101'],['三亚','101310201'],['文昌','101310212'],['琼海','101310211'],['万宁','101310215'],['东方','101310202'],['澄迈','101310204'],['定安','101310209'],['儋县','101310205'],['琼中','101310208'],['陵水','101310216'],['西沙','101310217'],['昌江','101310206'],['乐东','101310221'],['白沙','101310207'],['临高','101310203'],['四川','101270101'],['成都','101270101'],['广元','101272101'],['绵阳','101270401'],['德阳','101272001'],['南充','101270501'],['广安','101270801'],['遂宁','101270701'],['内江','101271201'],['乐山','101271401'],['自贡','101270301'],['泸州','101271001'],['宜宾','101271101'],['攀枝花','101270201'],['巴中','101270901'],['达川','101270601'],['资阳','101271301'],['眉山','101271501'],['雅安','101271701'],['阿坝','101271901'],['甘孜','101271801'],['西昌','101271601'],['石渠','101271812'],['若尔盖','101271912'],['德格','101271810'],['色达','101271813'],['道孚','101271807'],['马尔康','101271910'],['红原','101271913'],['小金','101271908'],['松潘','101271905'],['都江堰','101270111'],['平武','101270407'],['巴塘','101271815'],['新龙','101271809'],['理塘','101271814'],['稻城','101271817'],['康定','101271802'],['峨眉山','101271409'],['木里','101271603'],['九龙','101271805'],['越西','101271615'],['昭觉','101271612'],['雷波','101271617'],['盐源','101271604'],['会理','101271606'],['万源','101270606'],['阆中','101270507'],['奉节','101041900'],['梁平','101042300'],['万县市','101041300'],['叙永','101271005'],['酉阳','101043400'],['贵州','101260101'],['贵阳','101260101'],['六盘水','101260801'],['遵义','101260201'],['安顺','101260301'],['毕节','101260701'],['铜仁','101260601'],['凯里','101260501'],['都匀','101260401'],['兴义','101260903'],['威宁','101260704'],['盘县','101260804'],['桐梓','101260207'],['习水','101260209'],['湄潭','101260205'],['思南','101260605'],['黔西','101260901'],['三穗','101260509'],['兴仁','101260903'],['望谟','101260905'],['罗甸','101260408'],['独山','101260410'],['榕江','101260516'],['云南','101290101'],['昆明','101290101'],['曲靖','101290401'],['玉溪','101290701'],['保山','101290501'],['昭通','101291001'],['丽江','101291401'],['思茅','101290901'],['临沧','101291101'],['德宏','101291501'],['怒江','101291201 '],['迪庆','101291302'],['大理','101290201'],['楚雄','101290801'],['红河','101290301'],['文山州','101290601'],['德钦','101291302'],['贡山','101291207'],['中甸','101291301'],['维西','101291303'],['华坪','101291403'],['会泽','101290408'],['腾冲','101290506'],['元谋','101290803'],['沾益','101290401'],['瑞丽','101291506'],['景东','101290903'],['泸西','101290311'],['耿马','101291103'],['澜沧','101290904'],['景洪','101291604'],['元江','101290709'],['勐腊','101291605'],['江城','101290907'],['蒙自','101290309'],['屏边','101290310'],['广南','101290607'],['勐海','101291603'],['西藏','101140101'],['拉萨','101140101'],['那曲','101140601'],['昌都','101140501'],['林芝','101140401'],['山南','101140307'],['日喀则','101140201'],['阿里','101140701'],['狮泉河','101140701'],['改则','101140702'],['班戈','101140604'],['安多','101140605'],['普兰','101140705'],['申扎','101140703'],['当雄','101140102'],['拉孜','101140202'],['尼木','101140103'],['泽当','101140301'],['聂拉木','101140204'],['定日','101140205'],['江孜','101140206'],['错那','101140306'],['隆子','101140307'],['帕里','101140207'],['索县','101140606'],['丁青','101140502'],['嘉黎','101140603'],['洛隆','101140504'],['波密','101140402'],['左贡','101140505'],['察隅','101140404'],['陕西','101110101'],['西安','101110101'],['延安','101110300'],['铜川','101111001'],['渭南','101110501'],['咸阳','101110200'],['宝鸡','101110901'],['汉中','101110801'],['榆林','101110401'],['安康','101110701'],['商洛','101110601'],['定边','101110405'],['吴旗','101110312'],['横山','101110407'],['绥德','101110410'],['长武','101110209'],['洛川','101110309'],['武功','101110206'],['华山','101110512'],['略阳','101110802'],['佛坪','101110808'],['镇安','101110605'],['石泉','101110703'],['甘肃','101160101'],['兰州','101160101'],['嘉峪关','101160801'],['金昌','101160601'],['白银','101161301'],['天水','101160901'],['武威','101160501'],['酒泉','101160801'],['张掖','101160701'],['庆阳','101160401'],['安西','101160805'],['陇南','101161001'],['临夏','101161101'],['甘南','101050204'],['马鬃山','101160804'],['敦煌','101160808'],['玉门镇','101160807'],['金塔','101160803'],['高台','101160705'],['山丹','101160706'],['永昌','101160601'],['民勤','101160502'],['景泰','101161305'],['靖远','101161302'],['榆中','101160104'],['临洮','101160205'],['环县','101160403'],['平凉','101160301'],['西峰镇','101160402'],['玛曲','101161206'],['夏河合作','101161201'],['岷县','101160207'],['定西','101160201'],['青海','101150101'],['西宁','101150101'],['海东','101150201'],['海北','101150801'],['海南','101150401'],['黄南','101150301'],['果洛','101150501'],['玉树','101150601'],['海西','101150701'],['茫崖','101150712'],['冷湖','101150207'],['祁连','101150803'],['大柴旦','101150713'],['德令哈','101150701'],['刚察','101150806'],['门源','101150802'],['格尔木','101150702'],['都兰','101150710'],['共和县','101150401'],['贵德','101150404'],['民和','101150203'],['兴海','101150406'],['同德','101150408'],['同仁','101150301'],['杂多','101150604'],['曲麻莱','101150606'],['玛多','101150506'],['清水河','101150507'],['达日','101150504'],['河南','101150304'],['久治','101150505'],['囊谦','101150605'],['班玛','101150502'],['宁夏','101170101'],['银川','101170101'],['石嘴山','101170201'],['吴忠','101170301'],['固原','101170401'],['中卫','101170501'],['惠农','101170202'],['陶乐','101170204'],['中宁','101170502'],['盐池','101170303'],['海源','101170504'],['同心','101170302'],['西吉','101170402'],['新疆','101130101'],['乌鲁木齐','101130101'],['克拉玛依','101130201'],['石河子','101130301'],['阿拉尔','101130701'],['喀什','101130901'],['阿克苏','101130801'],['和田','101131301'],['吐鲁番','101130501'],['哈密','101131201'],['克孜勒','101131501'],['博尔塔拉','101131601'],['昌吉','101130401'],['库尔勒','101130601'],['伊犁','101131001'],['塔城','101131101'],['阿勒泰','101131401'],['哈巴河','101131402'],['吉木乃','101131405'],['福海','101131407'],['富蕴','101131408'],['和布克赛尔','101131104'],['青河','101131409'],['阿拉山口','101131606'],['托里','101131105'],['北塔山','101130409'],['温泉','101131602'],['精河','101131603'],['乌苏','101131106'],['蔡家湖','101130102'],['奇台','101130406'],['昭苏','101131007'],['巴仑台','101130104'],['达板城','101130105'],['七角井','101130106'],['库米什','101130609'],['巴音布鲁克','101130610'],['焉耆','101130607'],['拜城','101130804'],['轮台','101130602'],['库车','101130807'],['吐尔尕特','101131505'],['乌恰','101131502'],['阿合奇','101131504'],['巴楚','101130908'],['柯坪','101130808'],['铁干里克','101130611'],['若羌','101130604'],['塔什库尔干','101130903'],['莎车','101130905'],['皮山','101131302'],['民丰','101131306'],['且末','101130605'],['于田','101131307'],['巴里坤','101131203'],['伊吾','101131204'],['伊宁','101131001'],['香港','101320101'],['澳门','101330101'],['台湾','101340101'],['台北','101340101'],['台中','101340401'],['高雄','101340201']];
		}


	}

}