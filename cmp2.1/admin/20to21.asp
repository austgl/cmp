<!--#include file="conn.asp"-->
<table width="90%" border="0" align="center" cellpadding="5" cellspacing="3">
  <tr>
    <td><strong>CMP v2.0����תCMP v2.1���ݳ���</strong></td>
  </tr>
  <form id="form1" name="form1" method="post" action="?action=up">
    <tr>
      <td> ����2.0�����ݿ��ļ���
        <input name="cmp20data" type="text" value="data/cmp20.mdb" size="30" />
        (��2.0�����ݿ����Ϊcmp20.mdb�ŵ�dataĿ¼��) </td>
    </tr>
    <tr>
      <td><input type="submit" name="Submit" value="�ύ" />
        (��ת��ǰ�������ݱ���,����ɾ���°����ݿ��г�ʼ�ķ���)</td>
    </tr>
  </form>
  <tr>
    <td><% 
if request("action")="up" then
	Dim ConnStr2,conn2,sql2
		ConnStr2 = "Provider = Microsoft.Jet.OLEDB.4.0;Data Source = " & Server.MapPath("data/cmp20.mdb")
	On Error Resume Next
	Set conn2 = Server.CreateObject("ADODB.Connection")
	conn2.open ConnStr2
	If Err Then
		err.Clear
		Set Conn2 = Nothing
		Response.Write "CMP v2.0�����ݿ����ӳ������������ִ���"
		Response.End
	End If
	'----------------------------------------------------------------------
	dim list_num,rs2
	dim classid,title,url,lrc,content,pic,a,c,u,scene,addtime,lasttime,sn
	set rs2=conn2.execute("select * from cfplay_list")
	do while not rs2.eof
		'-------------------------------------------
		list_num=list_num+1
		classid=rs2("classid")
		title=rs2("title")
		url=rs2("url")
		lrc=rs2("lrc")
		content=rs2("content")
		pic=rs2("pic")
		a=rs2("a")
		c=rs2("c")
		u=rs2("u")
		scene=rs2("scene")
		addtime=rs2("addtime")
		lasttime=rs2("lasttime")
		sn=rs2("sn")
		sql2="insert into cmp_list (classid,title,url,lrc,content,pic,a,c,u,scene,addtime,lasttime,sn) values("&classid&",'"&title&"','"&url&"','"&lrc&"','"&content&"','"&pic&"','"&a&"','"&c&"','"&u&"','"&scene&"','"&addtime&"','"&lasttime&"',"&sn&")"
		Conn.execute(sql2)
		'-------------------------------------------
		rs2.movenext
	loop
	response.Write("�ɹ�ת��"&list_num&"����������<br>")
	rs2.close
	set rs2=nothing
	'----------------------------------------------------------
	set rs2=conn2.execute("select * from cfplay_class")
	do while not rs2.eof
		'-------------------------------------------
		sql2="insert into cmp_class (classid,classname,sn) values("&rs2("classid")&",'"&rs2("classname")&"',"&rs2("sn")&")"
		Conn.execute(sql2)
		'-------------------------------------------
		rs2.movenext
	loop
	response.Write("�ɹ�ת����������")
	rs2.close
	set rs2=nothing
end if
%></td>
  </tr>
</table>
</body></html>