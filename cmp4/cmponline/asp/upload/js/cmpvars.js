var CMP_CONFIG = {
	api : "定义播放器初始化完成时调用的js函数名称",
	auto_open : "当下一个要播放的项是一个目录时，是否自动打开后进行播放",
	auto_play : "是否开启自动播放",
	background : "附加背景处的插件，自动添加到backgrounds参数前面",
	backgrounds : "定义背景处的插件列表，多个请用英文逗号(,)隔开",
	bg_lrc : "全局歌词背景设置",
	bg_video : "全局视频背景设置",
	bgcolor : "播放器所在flash背景颜色，默认#181818",
	buffer_time : "音乐需要缓冲的时间，默认5，单位秒",
	click_next : "双击播放模式下，点击了播放项以外的另一项后，是否将此项作为下一个要播放的项，无视播放模式选择",
	click_play : "是否单击列表开始播放，否则双击才播放",
	context_menu : "右键菜单选项，0为不显示，1为全部，其他为仅名称",
	counter : "计数器地址，仅图片或flash类统计",
	default_skin : "设置中是否显示默认皮肤项",
	default_type : "默认媒体的类型，默认为video，即无法识别媒体类型时，将使用视频模块去处理，如改为sound则默认为声音类型",
	description : "描述，无歌词时显示，默认没有",
	forward_time : "每次快进快退时长，默认3秒，需快进快退按钮支持",
	fullscreen_max : "用来设置全屏后是否最大化视频或歌词，默认最大化视频，即fullscreen_max=video",
	fullscreen_scale : "用来设置全屏时进行硬件缩放的比例，值小于等于1，不能过小，将根据客户端显示器分辨率进行比例缩放",
	image_handler : "缩略图全局代理",
	javascript : "如果能启动页面脚本通讯，则允许此处设置的脚本串",
	label : "单曲名称标记",
	link : "右键中点击名称打开的链接",
	link_target : "链接是在当前窗口(默认)还是新窗口(_blank)",
	list : "列表xml的字符串内容",
	list_delete : "是否显示列表删除按钮",
	lists : "列表调用地址，多个请用英文逗号(,)隔开；如果是外载列表地址，请先确认来源域的跨域策略文件crossdomain.xml是否已经配置妥当，否则无法跨域加载列表",
	logo : "加载logo图标的地址，默认为空",
	logo_alpha : "logo图标的透明度，默认0.2",
	lrc : "单曲歌词；如果是外载歌词，请先确认来源域的跨域策略文件crossdomain.xml是否已经配置妥当，否则无法跨域加载歌词文件",
	lrc_handler : "自动歌词处理地址",
	lrc_image : "歌词区图片路径，预览图，一直显示，不同于歌词背景bg_lrc每次都更换",
	lrc_max : "是否最大化歌词",
	lrc_scale : "最大化时当前歌词的缩放倍数",
	lrc_scalemode : "歌词区缩放模式，默认为1，详情见下面的视频缩放模式说明",
	mixer_color : "设置声音频谱器颜色",
	mixer_displace : "是否开启图形置换效果",
	mixer_filter : "是否开启图形滤镜效果",
	mixer_id : "系统声音频谱器当前效果的id",
	mixer_src : "用来加载外部声音频谱器插件，默认不加载，即使用系统自带10种声音频谱效果",
	mute : "是否静音",
	name : "自定义播放器的名称，默认为当前cmp版本名",
	panning : "声音平移参数，表示声道从左到右的平移，范围从 -1（左侧最大平移）至 1（右侧最大平移），默认值0表示没有平移（居中）",
	play_id : "当前播放id序号",
	play_mode : "播放模式：0顺序，1重复，2随机，3向上，4单曲",
	plugin : "附加插件地址，将自动添加到plugins参数前面",
	plugins : "前置插件地址列表，多个请用英文逗号(,)隔开",
	plugins_disabled : "是否禁用所有插件",
	share_cmp : "设置中是否显示复制分享地址按钮",
	share_html : "CMP分享代码，默认按share_url参数自动生成",
	share_url : "CMP分享地址，默认按当前CMP主程序所在位置自动生成",
	shortcuts : "是否启用默认快捷键，默认启用",
	show_meta : "如果有读取权限，是否显示媒体的meta信息，默认显示",
	skin : "皮肤地址设置；如果是外载皮肤地址，请先确认来源域的跨域策略文件crossdomain.xml是否已经配置妥当，否则无法跨域加载皮肤文件",
	skin_id : "皮肤id",
	skin_info : "设置中是否打开皮肤详细信息",
	skins : "预加载皮肤的地址列表，可设置多个",
	sound_eq : "声音样本均衡参数(必须启用sound_sample声音样本处理才有效)，默认为空，即不进行均衡过滤处理",
	sound_sample : "是否启用声音样本处理，默认不开启，开启后将耗费更多系统资源，开启取样处理，能实现在跨域播放mp3时显示频谱效果，同时支持均衡器参数设置",
	src : "单曲地址",
	src_handler : "自动地址处理地址",
	text_handler : "描述全局代理",
	timeout : "音乐连接超时的时间，默认13，单位秒",
	type : "单曲或全局类型",
	video_blackwhite : "是否黑白",
	video_highlight : "是否高亮",
	video_image : "视频区图片路径，预览图，一直显示，不同于视频背景bg_video每次都更换",
	video_max : "是否最大化视频",
	video_scalemode : "视频缩放模式1/2/3/0",
	video_smoothing : "是否开启平滑",
	volume : "当前音量"
};

var CMP_LIST = {
	duration : "时长",
	image : "缩略图",
	label : "名称",
	lrc : "歌词；如果是外载歌词，请先确认来源域的跨域策略文件crossdomain.xml是否已经配置妥当，否则无法跨域加载歌词文件",
	opened : "如果是树目录，默认是否打开",
	src : "媒体源地址",
	bak : "备份地址",
	stream : "是否支持steam",
	rotation : "视频旋转参数",
	bg_video : "视频背景",
	bg_lrc : "歌词背景",
	xywh : "图片位置宽高",
	scalemode : "视频缩放模式",
	rtmp : "rtmp服务器地址",
	list_src : "子列表地址",
	text : "描述文本",
	type : "媒体类型"
};