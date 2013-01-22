<!--#include file="conn.asp"-->
<!--#include file="head.asp"-->
<%
If Session(CookieName & "_flag")="" Then
	response.Redirect("login.asp")
end if
'//////////////////////////////
Select Case Request("action")
Case "manage"
	Call guide()
	Call manage()
	Call Footer()
Case "save_manage"
	Call guide()
	Call save_manage()	
	Call Footer()
Case "class_manage"
	Call guide()
	Call class_manage()
	Call Footer()
Case "save_class_manage"
	Call guide()
	Call save_class_manage()
	Call Footer()
Case "config"
	Call guide()
	Call config()
	Call Footer()
Case "save_config"
	Call guide()
	Call save_config()
	Call Footer()
Case "make_xml"
	Call guide()
	Call make_xml()
	Call Footer()
Case "show"
	Call guide()
	Call show()
	Call Footer()
Case "check_music_name"
	Call check_music_name()
Case "make_lrc"
	Call make_lrc()
	Call Footer()
Case Else
	Call guide()
	Call main()
	Call Footer()
End Select
If Errmsg<>"" Then cenfun_error()

sub guide()
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <th>CenFun Music Player ���ֹ�������</th>
  </tr>
  <tr>
    <td class="cmsRow"><a href="?">�����б�</a> | <a href="?action=manage">�������</a> | <a href="?action=class_manage">ר������</a> | <a href="?action=config">����������</a> | <a href="?action=make_xml" title="���еĲ�����ɣ�������������������xml�ļ����ܸ�����Ϣ��"><font color="#ff0000">����XML�ļ�</font></a> | <a href="?action=show">�鿴Ч��</a></td>
  </tr>
</table>
<br>
<%
end sub

sub main()
dim num
dim cfclass_list
	sql="select classid,classname from cmp_class order by sn"
	set rs=conn.execute(sql)
		if rs.bof or rs.eof then
			Errmsg=Errmsg&"<li>������Ҫһ��ר��,����<a href=""?action=class_manage""><strong>���</strong></a>"
			cenfun_error()
			exit sub
		else
			cfclass_list=rs.GetRows()
		end if
	rs.close
	set rs=nothing
dim classid,classname
if request("classid")<>"" and IsNumeric(request("classid")) then
	classid=request("classid")
end if

dim selectm,selectkey,classsql
dim lrc_select,pic_select
selectm=trim(request("selectm"))
selectkey=trim(request(trim("selectkey")))
	if selectkey="" then
		selectm=""
	end if
lrc_select=request("lrc_select")
pic_select=request("pic_select")
%>
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="1">
  <form name="form_search" method="post" action="?classid=<%=classid%>&page=<%=request("page")%>">
    <tr>
      <td align="center"><table border="0" align="center" cellpadding="2" cellspacing="0">
          <tr align="center">
            <td><select name='JumpClass' id="JumpClass" onChange="if(this.options[this.selectedIndex].value!='0'){location='?classId='+this.options[this.selectedIndex].value;}">
                <option value='' selected>����ר��</option>
                <%
for num=0 to UBound(cfclass_list,2)
	response.write "<option value='"&cfclass_list(0,num)&"' "
	if trim(cfclass_list(0,num))=classid then
		response.write "selected"
	end if
	response.write ">"&cfclass_list(1,num)&"</option>"	
next
%>
              </select>
            </td>
            <td><strong>�ؼ���</strong></td>
            <td><input name="selectkey" type="text" size="15" id="selectkey" onDblClick="this.value=''" value="<%=selectkey%>"></td>
            <td><select name="selectm" id="select">
                <option value="title">������</option>
                <option value="url" <%if selectm="url" then%>selected="selected"<%end if%>>����ַ</option>
                <option value="content" <%if selectm="content" then%>selected="selected"<%end if%>>������</option>
              </select>
            </td>
            <td><select name="lrc_select">
                <option value="">��ʲ���</option>
                <option value="0" <%if lrc_select="0" then%>selected="selected"<%end if%>>�޸��</option>
                <option value="1" <%if lrc_select="1" then%>selected="selected"<%end if%>>�и��</option>
              </select>
            </td>
            <td><select name="pic_select">
                <option value="">ͼƬ����</option>
                <option value="0" <%if pic_select="0" then%>selected="selected"<%end if%>>��ͼƬ</option>
                <option value="1" <%if pic_select="1" then%>selected="selected"<%end if%>>��ͼƬ</option>
              </select>
            </td>
            <td><input type="submit" name="Submit2" value="�� ��"></td>
          </tr>
        </table></td>
    </tr>
  </form>
</table>
<table border="0" cellspacing="1" cellpadding="2" align=center class="tableBorder">
  <form name="form_main" method="post" action="?classid=<%=classid%>&page=<%=request("page")%>">
    <tr>
      <th height="25" colspan="9" align="center"><strong>�����б�</strong></th>
    </tr>
    <tr align="center" class="cmsRow">
      <td nowrap><input name="chkAll" type="checkbox" id="chkAll" onClick="CheckAll(this.form)" value="checkbox" /></td>
      <td nowrap>���</td>
      <td nowrap>����</td>
      <td>ר��</td>
      <td nowrap>����</td>
      <td nowrap="nowrap">Url/Lrc/Pic</td>
      <td nowrap>����ʱ��</td>
    </tr>
    <%
'############################ɾ��ѡ��#######################################
dim selectid
selectid=request("selectid")  
if request("del")="ɾ����ѡ" and selectid<>"" then
conn.execute("delete from cmp_list where id in ("&selectid&")")
response.redirect Request.ServerVariables("HTTP_REFERER")
end if
'##############################ר��#########################################
  if classid<>"" and IsNumeric(classid) then
	 classsql="and classid="&classid
  end if
'#########################�Զ���������######################################
dim sum,autosn
sum=1
autosn=Replace(trim(Request("autosn")),"'","")
if autosn<>"" then
set rs=conn.execute("select id from cmp_list order by "&autosn&" desc")
do while not rs.eof
conn.execute("update cmp_list set sn="&sum&" where id="&rs("id"))
sum=sum+1
rs.movenext
loop
rs.close
set rs=nothing
end if
 
'############################����ѡ��#######################################
if request("sn")="������ѡ" and selectid<>"" then
'response.Write ""
dim selectidlist
    selectidlist=split(selectid,", ")
'response.Write ""
 for i=0 to ubound(selectidlist)
if IsNumeric(request.form("sn"&selectidlist(i))) then 
conn.execute("update cmp_list set sn="&request.form("sn"&selectidlist(i))&" where id="&int(selectidlist(i))&"")
end if
 next

'response.redirect Request.ServerVariables("HTTP_REFERER")
'response.Redirect "?classid="&request("classid")
end if

'#############################��ҳ��ʾ######################################
    dim CurrentPage,totalnumber,page_count,MaxPerPage,Pagenumber
    MaxPerPage=12 'ÿҳ��ʾ��Ŀ
	CurrentPage=request("page")
	if CurrentPage="" or not IsNumeric(CurrentPage) then
		CurrentPage=1
	else
		CurrentPage=clng(CurrentPage)
		if err then
			CurrentPage=1
			err.clear
		end if
	end if

'##########  ��ѯ����  ############
dim sql1
	sql1=" order by sn,lasttime desc "
select case selectm
	case ""
        sql=" title like '%"&selectkey&"%' "&classsql&" "
	case "title"
        sql=" title like '%"&selectkey&"%' "&classsql&" "
	case "url"
        sql=" url like '%"&selectkey&"%' "&classsql&" "
	case "content"
        sql=" content like '%"&selectkey&"%' "&classsql&" "
	case else
        sql=" 1=1 "&classsql&" "
end select
if lrc_select="0" then
	sql=sql&" and lrc='' "
elseif lrc_select="1" then
	sql=sql&" and lrc<>'' "
end if
if pic_select="0" then
	sql=sql&" and pic='' "
elseif pic_select="1" then
	sql=sql&" and pic<>'' "
end if

Set Rs=conn.execute("Select count(id) From cmp_list Where "&sql&" ")
totalnumber=Rs(0)
Rs.close:Set Rs=Nothing

set rs=conn.execute("select id,classid,title,url,lrc,content,pic,lasttime,sn from cmp_list where "&sql&" "&sql1&" ")
'##########��ҳ############		  
    if err.number<>0 or (rs.eof And rs.bof) then
		Response.Write "<tr><td colspan=8 align=center class=cmsRow><font color=#ff0000>û���ҵ������Ϣ!</font></td></tr>"
   	else
  	if totalnumber mod MaxPerPage=0 then
     		Pagenumber= totalnumber \ MaxPerPage
  	else
     		Pagenumber= totalnumber \ MaxPerPage+1
  	end if
	RS.MoveFirst
	if CurrentPage > Pagenumber then CurrentPage = Pagenumber
   	if CurrentPage<1 then CurrentPage=1
	RS.Move (CurrentPage-1) * MaxPerPage
	page_count=0	
    do while not rs.eof and page_count < Clng(MaxPerPage)
%>
    <tr class="cmsRow" onMouseOver="this.style.backgroundColor='#E4E4E4'" onMouseOut="this.style.backgroundColor=''">
      <td align="center"><input name="selectid" type="checkbox" id="selectid" value="<%=rs("id")%>"></td>
      <td align="center"><input type="text" name="sn<%=rs("id")%>" id="sn<%=rs("id")%>" size="3" maxlength="6" value="<%=rs("sn")%>"></td>
      <td nowrap="nowrap"><a href="?action=manage&manage=edit&classid=<%=classid%>&id=<%=rs("id")%>" title="����޸�"><%=rs("title")%></a></td>
      <td align="center" nowrap><%
classname="δ֪����"
for num=0 to UBound(cfclass_list,2)
	if trim(cfclass_list(0,num))=trim(rs("classid")) then
		classname="<a href=?classid="&cfclass_list(0,num)&">"&cfclass_list(1,num)&"</a>"
	end if
next
response.write classname
%></td>
      <td><%=rs("content")%></td>
      <td align="center"><a href="<%=rs("url")%>" target="_blank" title="���ֱ�Ӵ����ֵ�ַ"><img src="images/mp3.gif" width="16" height="16" border="0" /></a>
        <%if rs("lrc")<>"" then%>
        <img src="images/lrc.gif" width="16" height="16" border="0" />
        <%else response.write("<img src=""images/null.gif"" width=""16"" height=""16"" border=""0"" /> ") end if%>
        <%if rs("pic")<>"" then%>
        <img src="images/jpg.gif" width="16" height="16" border="0" />
        <%else response.write("<img src=""images/null.gif"" width=""16"" height=""16"" border=""0"" /> ") end if%></td>
      <td align="center" nowrap><%=FormatDateTime(rs("lasttime"),2)%></td>
    </tr>
    <%
		page_count=page_count+1
		rs.movenext
	loop
	end if
	rs.close
	set rs=nothing
'########################################end############################################
%>
    <tr>
      <td height="30" colspan="9" align="center" class="cmsRow"> ��ѡ����в���:
        <input type="submit" name="sn" value="������ѡ">
        <select name="autosn" id="select" onChange="{if(confirm('ȷ��������������������������?')){submit();}return false;}">
          <option value="">�Զ�����</option>
          <option value="addtime">�����ʱ��</option>
          <option value="lasttime">������ʱ��</option>
          <option value="id">������ID</option>
          <option value="title">������</option>
        </select>
        <input type="submit" name="del" value="ɾ����ѡ" onClick="return test();">
        <font color="#ff0000">ע��:δѡ���������Ч</font> </td>
    </tr>
    <tr align="center">
      <td class="cmsRow" colspan="9"><table width="95%"  border="0" cellpadding="0" cellspacing="0">
          <tr align="right">
            <td><%showpage "zh",1,"?selectm="&selectm&"&selectkey="&selectkey&"&lrc_select="&lrc_select&"&pic_select="&pic_select&"&classid="&request("classid")&"",totalnumber,MaxPerPage,true,true,"��",CurrentPage%></td>
          </tr>
        </table></td>
    </tr>
  </form>
</table>
<%
end sub

sub manage()
dim manage,pagetitle
dim id,classid,title,url,lrc,content,pic,t,fg,a,c,u,scene,addtime,lasttime,sn
if request("manage")="edit" then
'----------------------------------------------
manage="edit"
pagetitle="�޸�����"
set rs=conn.execute("select id,classid,title,url,lrc,content,pic,t,fg,a,c,u,scene,addtime,lasttime,sn from cmp_list where id="&trim(request.QueryString("id"))&" ")
id=rs("id")
classid=rs("classid")
title=rs("title")
url=rs("url")
lrc=rs("lrc")
content=rs("content")
pic=rs("pic")
t=rs("t")
fg=rs("fg")
a=rs("a")
c=rs("c")
u=rs("u")
scene=rs("scene")
addtime=rs("addtime")
lasttime=SystemTime
sn=rs("sn")
rs.close
set rs=nothing
'----------------------------------------------
else
'----------------------------------------------
manage="add"
pagetitle="�������"
classid=0
title=""
url=""
lrc=""
content=""
pic=""
t=""
fg=""
a=""
c=""
u=""
scene=""
addtime=SystemTime
lasttime=SystemTime
sn=""
'----------------------------------------------
end if
%>
<table border="0" align=center cellpadding="5" cellspacing="1" class="tableBorder">
  <form name="form_cmp_list_manage" action="?action=save_manage&save_manage=<%=manage%>" method="post">
    <tr>
      <th colspan="4" align="center"><%=pagetitle%></th>
    </tr>
    <tr>
      <td width="7%" align="right" nowrap class="cmsRow01"><strong>����ר��:</strong></td>
      <td width="93%" class="cmsRow01"><select name="classid" id="JumpClass">
          <%
sql="select classid,classname from cmp_class order by sn"
set rs=conn.execute(sql)
	if rs.bof or rs.eof then
		Errmsg=Errmsg&"<li>������Ҫһ��ר��,����<a href=""?action=class_manage""><strong>���</strong></a>"
		cenfun_error()
		exit sub
	else
		do while not rs.eof
			response.write "<option value="&rs("classid")&""
				if rs("classid")=classid then
					response.write " selected"
				end if
			response.write ">"&rs("classname")&"</option>"			
			rs.movenext
		loop
	end if
rs.close
set rs=nothing
%>
        </select>
       </td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>��������:</strong></td>
      <td class="cmsRow01"><input name="title" id="title" type="text" size="50" value="<%=title%>">
        <font color="red">*</font>
        <input type="button" value="����ظ�" onClick="checktitle();">
        <%if request("manage")="edit" then%>
        <input name="id" type="hidden" value="<%=id%>">
        <%end if%></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>���ֽ���:</strong></td>
      <td class="cmsRow01"><input name="content" type="text" size="50" value="<%=content%>"></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>���ֵ�ַ:</strong></td>
      <td class="cmsRow01"><input name="url" type="text" value="<%=url%>" size="70">
        <font color="red">*</font></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>��ʱ��:</strong></td>
      <td class="cmsRow01"><input name="t" type="text" id="t" size="5" maxlength="5" value="<%=t%>" />
        (flv��Ƶ��Ч,��д����,��λ:��) </td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>��ʵ�ַ:</strong></td>
      <td class="cmsRow01"><input name="lrc" id="lrc" type="text" size="70" value="<%=lrc%>">
        <input type="button" value="�鿴" onClick="showurl(document.getElementById('lrc'));">
        <input type="button" name="lrc_file" value="<%if request("manage")="edit" then%>�༭<%else%>���<%end if%>����ļ�" onClick="showlrc();"/>
      </td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>ͼƬ��ַ:</strong></td>
      <td class="cmsRow01"><input name="pic" id="pic" type="text" size="70" value="<%=pic%>">
        <input type="button" value="�鿴" onClick="showurl(document.getElementById('pic'));"></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>ͼƬ����:</strong></td>
      <td class="cmsRow01">a(͸����):
        <input name="a" type="text" size="3" value="<%=a%>" />
        c(����):
        <input name="c" type="text" size="15" value="<%=c%>" /></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>ͼƬ����:</strong></td>
      <td class="cmsRow01"><input name="u" id="u" type="text" size="70" value="<%=u%>" />
        <input type="button" value="��" onClick="showurl(document.getElementById('u'));" /></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>������ַ:</strong></td>
      <td class="cmsRow01"><input name="scene" id="scene" type="text" size="70" value="<%=scene%>" />
        <input type="button" value="�鿴" onClick="showurl(document.getElementById('scene'));" /></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>�Ƿ�ǰ��:</strong></td>
      <td class="cmsRow01"><select name="fg">
          <option value="">��</option>
          <option value="1" <%if fg="1" then%>selected="selected"<%end if%>>��</option>
        </select>
      </td>
    </tr>
    <tr <%if not request("manage")="edit" then%>style="display: none;"<%end if%>>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>���ʱ��:</strong></td>
      <td class="cmsRow01"><input name="addtime" id="addtime" type="text" size="20" value="<%=addtime%>">
        <input name="SqlNowString" type="button" onClick="document.getElementById('addtime').value='<%=lasttime%>'" value="����"/></td>
    </tr>
    <tr <%if not request("manage")="edit" then%>style="display: none;"<%end if%>>
      <td align="right" nowrap="nowrap" class="cmsRow01"><strong>����ʱ��:</strong></td>
      <td class="cmsRow01"><input name="lasttime" type="text" size="20" value="<%=lasttime%>"></td>
    </tr>
    <tr>
      <td colspan="4" align="center" class="cmsRow01"><input type="button" class=button name="submit_cmp_list_manage" value="<%=pagetitle%>" onClick="return check();">
      </td>
    </tr>
  </form>
</table>
<script LANGUAGE="javascript">
<!--
function showurl(obj){
	if(obj.value!=''){
		var this_url=obj.value;
		var t=this_url.indexOf("http://");
		//alert(t);
		if(t!=-1){
			window.open(this_url,'','status=no,scrollbars=1')
		}else{
			window.open("../"+this_url,'','status=no,scrollbars=1')
		}
	}
}
function checktitle(){
	var this_title=document.getElementById('title').value;
	if(this_title!=''){
		var win='width=400,height=150,left='+(window.screen.width/2-200)+',top='+(window.screen.height/2-100)+',status=no,scrollbars=1';
		window.open('?nomenu=1&action=check_music_name&music_name='+this_title,'',win);
	}
}
function showlrc(){
	var this_title=document.getElementById('title').value;
	if(this_title!=''){
		var win='width=760,height=500,left='+(window.screen.width/2-380)+',top='+(window.screen.height/2-275)+',status=no,scrollbars=1';
		window.open('?nomenu=1&action=make_lrc&lrc_name='+this_title,'lrc_edit',win);
	}
}
function checkspace(s) {
  var str = '';
  for(i = 0; i < s.length; i++) {
    str = str + ' ';
  }
  return (str == s);
}
function check()
{
  if(checkspace(document.form_cmp_list_manage.title.value)) {
	document.form_cmp_list_manage.title.focus();
    alert("����������Ϊ��!");
	return false;
  }
  if (document.form_cmp_list_manage.url.value=="")
  {
    alert("����д���ֵ�ַ��");
	document.form_cmp_list_manage.url.focus();
	return false;
  }
	document.form_cmp_list_manage.submit();
  }
//-->
</script>
<%
end sub

Sub save_manage()
dim saveaction,sql
dim id,classid,title,url,lrc,content,pic,t,fg,a,c,u,scene,addtime,lasttime,sn
dim addtime_sql,lasttime_sql
	saveaction=request.QueryString("save_manage")
	classid=Request("classid")
		if classid="" then Errmsg=Errmsg&"<li>ר������Ϊ��!�뷵��������д��Ϣ!"
	title=Replace(trim(Request("title")),"'","")
		if title="" then Errmsg=Errmsg&"<li>���Ʋ���Ϊ��!�뷵��������д��Ϣ!"
	url=Replace(trim(Request("url")),"'","")
		if url="" then Errmsg=Errmsg&"<li>��ַ����Ϊ��!�뷵��������д��Ϣ!"
	lrc=Replace(trim(Request("lrc")),"'","")
	content=Replace(trim(Request("content")),"'","")
	pic=Replace(trim(Request("pic")),"'","")
	t=Replace(trim(Request("t")),"'","")
	fg=Replace(trim(Request("fg")),"'","")
	a=Replace(trim(Request("a")),"'","")
	c=Replace(trim(Request("c")),"'","")
	u=Replace(trim(Request("u")),"'","")
	scene=Replace(trim(Request("scene")),"'","")
	addtime=Request("addtime")
		if IsDate(addtime) then
			addtime_sql="addtime='"&addtime&"',"
		end if
	lasttime=Request("lasttime")
		if IsDate(lasttime) then
			lasttime_sql="lasttime='"&lasttime&"',"
		end if
	sn=Replace(trim(Request("sn")),"'","")
		if sn="" then sn=0
if saveaction="edit" then
	saveaction=""
	id=Request("id")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cmp_list Set classid="&classid&",title='"&title&"',url='"&url&"',lrc='"&lrc&"',content='"&content&"',pic='"&pic&"',t='"&t&"',fg='"&fg&"',a='"&a&"',c='"&c&"',u='"&u&"',scene='"&scene&"',"&addtime_sql&""&lasttime_sql&"sn="&sn&" Where id="&id&"")
		SucMsg=SucMsg&"<li>�޸����ϳɹ�!"
		Cenfun_suc("?")
	end if
end if

if saveaction="add" then
	saveaction=""
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		sql="insert into cmp_list (classid,title,url,lrc,content,pic,t,fg,a,c,u,scene,addtime,lasttime,sn) values("&classid&",'"&title&"','"&url&"','"&lrc&"','"&content&"','"&pic&"','"&t&"','"&fg&"','"&a&"','"&c&"','"&u&"','"&scene&"',"&SqlNowString&","&SqlNowString&","&sn&")"
		conn.execute(sql)
		SucMsg=SucMsg&"<li>��ӳɹ�!"
		Cenfun_suc("?")
	end if
end if
end sub

sub class_manage()
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <th colspan="6"><strong>ר������</strong></th>
  </tr>
  <tr class="cmsRow">
    <td>���</td>
    <td>����</td>
    <td>��Ӧ�����ô���(���Զ��滻�������ļ��еĴ���)</td>
    <td>����</td>
  </tr>
  <%
dim nextsn
	nextsn=0
	sql="select classid,classname,sn from cmp_class order by sn"
	set rs=conn.execute(sql)
	if rs.EOF and rs.BOF then
		response.Write "<tr align=center><td colspan=4 class=cmsRow><font color=red>û���ҵ��κ���Ϣ!</font></td></tr>"
	else
		do while not rs.EOF
%>
  <tr class="cmsRow">
    <td><input name="sn" type="text" id="sn<%=rs("classid")%>" size="4" value="<%=rs("sn")%>"></td>
    <td><input name="classname" type="text" id="classname<%=rs("classid")%>" size="15" value="<%=trim(rs("classname"))%>"></td>
    <td>&lt;l name=&quot;<%=trim(rs("classname"))%>&quot;&gt;xml/list<%=nextsn%>.xml&lt;/l&gt;</td>
    <td><input name="edit" type="button"  value="�� ��" onClick="document.location='?action=save_class_manage&class_manage=edit&classid=<%=rs("classid")%>&sn='+document.getElementById('sn<%=rs("classid")%>').value+'&classname='+document.getElementById('classname<%=rs("classid")%>').value">
      <input type="button" name="del" value="ɾ ��" onClick="if(confirm('ɾ��ר��ʱ�����µ�������Ϣ����ɾ��!ȷ��ɾ����')){location='?action=save_class_manage&class_manage=del&classid=<%=rs("classid")%>'}"></td>
  </tr>
  <%
		nextsn=nextsn+1
		rs.MoveNext
		loop
	end if
	rs.close
	set rs=nothing
%>
  <form name="form_class_manage_add" method="post" action="?action=save_class_manage&class_manage=add">
    <tr class="cmsRow">
      <td><input name="sn" type="text" id="sn" size="4" value="<%=nextsn%>"></td>
      <td><input name="classname" type="text" id="classname" size="15" value=""></td>
      <td> </td>
      <td><input type="button" name="Submit" value="�� ��" onClick="check();"></td>
    </tr>
  </form>
</table>
<script LANGUAGE="javascript">
<!--
function check(){
	if(isNaN(document.form_class_manage_add.sn.value)) {
		document.form_class_manage_add.sn.focus();
		document.form_class_manage_add.reset();
		alert("��ű���λ����");
	}else if(document.form_class_manage_add.sn.value=="") {
		document.form_class_manage_add.sn.focus();
		alert("��Ų���Ϊ��");
	}else if(document.form_class_manage_add.classname.value=="") {
		document.form_class_manage_add.classname.focus();
		alert("���Ʋ���Ϊ��");
	}else{
		document.form_class_manage_add.submit();
	}
}
//-->
</script>
<%
end sub

sub save_class_manage()
dim class_manage
class_manage=request.querystring("class_manage")
if class_manage="del" then
	conn.execute ("delete from cmp_class where classid="&request.QueryString("classid"))
	SucMsg=SucMsg&"<li>ɾ���ɹ�!"
	set_config()
	response.Redirect("?action=class_manage")
else
	dim classname,sn
	classname=request("classname")
		if classname="" then Errmsg=Errmsg&"<li>���Ʋ���Ϊ�գ��뷵��������д��Ϣ��"
	sn=request("sn")
	If ErrMsg<>"" Then 
		cenfun_error()
	elseif class_manage="add" then
		sql="insert into cmp_class"
		sql=sql&"(classname,sn) values"
		sql=sql&"('"&classname&"',"&sn&")"
		conn.execute(sql)
		SucMsg=SucMsg&"<li>��ӳɹ�!"
		set_config()
		Cenfun_suc("?action=class_manage")
	elseif class_manage="edit" then
		sql="update cmp_class set "
		sql=sql&" classname='"&classname&"',sn="&sn&" where classid="&request.QueryString("classid")
		conn.execute(sql)
		SucMsg=SucMsg&"<li>�޸ĳɹ�!"
		set_config()
		response.Redirect("?action=class_manage")
	end if
end if
end sub
'�������÷���
function set_config()
	dim nextsn,list_str
	nextsn=0
	list_str=""
	sql="select classname from cmp_class order by sn"
	set rs=conn.execute(sql)
	do while not rs.EOF
		list_str=list_str&chr(9)&"<l name="""&rs("classname")&""">xml/list"&nextsn&".xml</l>"&Chr(13)&Chr(10)	
		nextsn=nextsn+1
		rs.MoveNext
	loop
	rs.close
	set rs=nothing
	'response.Write(list_str)
	'-------------------------------------------
	dim config_str
	sql="select config from cmp_config"
	set rs=conn.execute(sql)
	if not rs.eof then
		config_str=rs("config")
	end if
	rs.close
	set rs=nothing
	'-------------------------------------------
	dim re	
	Set re=new RegExp
	re.IgnoreCase =True
	re.Global=True
	re.Pattern="<class>.[^\]]*<\/class>"
	config_str= re.Replace(config_str,"<class>"&Chr(13)&Chr(10)&list_str&"</class>")	
	Set re=Nothing
	conn.execute("Update cmp_config Set config='"&config_str&"'")
	'response.Write(config_str)
end function

sub config()
set_config()
sql="select config from cmp_config"
set rs=conn.execute(sql)
if not rs.eof then
%>
<script language="JavaScript" type="text/javascript">
function check_config(){
	if(!confirm('ȷ���޸���')) return false;
}
</script>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <form name="form_config" method="post" id="form_config" action="?action=save_config" onSubmit="return check_config();">
    <tr>
      <th align="center">���������� (<a href="images/cmp21config.gif" target="_blank">�鿴����˵��</a>)</th>
    </tr>
    <tr>
      <td class="cmsRow" align="center"><textarea name="config" id="config" style="width:100%;height:420px;"><%=rs("config")%></textarea></td>
    </tr>
    <tr>
      <td class="cmsRow" align="center"><input type="submit" class=button name="submit_config" value=" �� �� "> 
        (�޸�ǰ�����ñ���,дhtml������ʹ�ã� <span style="color: #0000FF">&lt;![CDATA[<span style="color: #000000">����</span>]]&gt;</span> )</td>
    </tr>
  </form>
</table>
<%
end if
rs.close
set rs=nothing
end sub

sub save_config()
dim config
	config=request("config")
		if config="" then Errmsg=Errmsg&"<li>���ò���Ϊ��!�뷵��������д��Ϣ!"
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cmp_config Set config='"&config&"'")
		SucMsg=SucMsg&"<li>�޸��������ϳɹ�!"
		Cenfun_suc("?action=config")
	end if
end sub

Function Checkxml(Str)
	If Isnull(Str) Then
		Checkxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"<","&lt;")
	Str = Replace(Str,">","&gt;")
	Str = Replace(Str,"&","&amp;")
	Str = Replace(Str,"'","&apos;")
	Str = Replace(Str,Chr(34),"&quot;")
	Checkxml = Str
End Function
Function iCheckxml(Str)
	If Isnull(Str) Then
		iCheckxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"&lt;","<")
	Str = Replace(Str,"&gt;",">")
	Str = Replace(Str,"&amp;","&")
	Str = Replace(Str,"&apos;","'")
	'Str = Replace(Str,"&quot;",Chr(34))
	iCheckxml = Str
End Function

sub make_xml()
dim isnewlist,newlistname,listname
isnewlist=Checkxml(Request.Form("isnewlist"))
newlistname=Checkxml(Request.Form("newlistname"))
if isnewlist="1" and newlistname<>"" then
	listname=newlistname
else 
	listname="�������"
end if
%>
<table border="0" cellspacing="1" cellpadding="5" align="center" class="tableBorder">
  <tr>
    <th colspan="4" align="center">����XML�ļ�</th>
  </tr>
  <tr>
    <td align="right" class="cmsRow">ע��:</td>
    <td class="cmsRow">���еĲ�����ɣ�������������������xml�ļ����ܸ�����Ϣ!</td>
  </tr>
  <form name="makelistform" action="?action=make_xml&make_xml=make_list" method="post">
    <tr>
      <td align="right" nowrap="nowrap" class="cmsRow">��������XML�ļ�:</td>
      <td class="cmsRow"><input type="submit" class="button" name="submit_config2" value="�������"  style="width:120px;height:40px;cursor:hand;" /></td>
    </tr>
  </form>
  <%if request("make_xml")="make_list" then%>
  <tr>
    <td align="right" nowrap="nowrap" class="cmsRow">&nbsp;</td>
    <td class="cmsRow"><%
dim rsclass,num
num=0
dim cflist_str,file_server,file_path,file_name
file_server="xml/"
file_path="../xml/"
file_name="list"
dim xml_head,xml_foot
xml_head="<?xml version=""1.0"" encoding=""gb2312""?>"&"<list>"
xml_foot="</list>"
'---------------------------------------------------------------------------------
set rsclass=conn.execute("select classid,classname from cmp_class order by sn")
do while not rsclass.eof
	cflist_str=xml_head
	set rs=conn.execute("select title,url,lrc,content,pic,t,fg,a,c,u,scene from cmp_list where classid="&rsclass("classid")&" order by sn")
	do while not rs.eof	
		cflist_str=cflist_str&make_cflist_music(rs("title"),rs("url"),rs("lrc"),rs("content"),rs("pic"),rs("t"),rs("fg"),rs("a"),rs("c"),rs("u"),rs("scene"))
	rs.movenext
	loop
	rs.close
	set rs=nothing
	cflist_str=cflist_str&xml_foot
	make_file cflist_str,file_path&file_name&num&".xml"
	response.write "���� <a href='"&file_path&file_name&num&".xml' target='_blank' style='color:#ff0000;'>"&Checkxml(rsclass("classname"))&":"&file_path&file_name&num&".xml</a> �ɹ���<br>"
num=num+1
rsclass.movenext
loop
rsclass.close
set rsclass=nothing
'---------------------------------------------------------------------------------
'make config
dim config_str,file_path_name
file_path_name="../xml/config.xml"
sql="select config from cmp_config"
set rs=conn.execute(sql)
if not rs.eof then
	config_str=rs("config")	
	make_file config_str,file_path_name
	response.write "���� <a href='"&file_path_name&"' target='_blank' style='color:#ff0000;'>�����ļ�:"&file_path_name&"</a> �ɹ�!"		
else
	response.write "û���κ���Ϣ!�����ļ�ʧ��!"
end if
rs.close
set rs=nothing
%>
    </td>
  </tr>
  <%end if%>
</table>
<%
end sub

function make_file(str,path)
    dim fs,fsowrite
	on error resume next
	Set fs=CreateObject("Scripting.fileSystemObject")
    	Set fsowrite = fs.CreateTextFile(server.MapPath(path),true)
        fsowrite.Write str
        fsowrite.close
		set fsowrite=nothing
	set fs=nothing
	if err.number<>0 then
		response.write "<center>"&Err.Description&"�����Ŀռ䲻֧��FSO����ͬ���Ŀռ�����ϵ�����߲鿴���Ȩ�����á�</center>"
	end if
end function

function make_cflist_music(title,url,lrc,content,pic,t,fg,a,c,u,scene)
	dim str
		str=str&"<m>"
			str=str&"<n>"&Checkxml(title)&"</n>"
			str=str&"<u"
			if t<>"" then str=str&" t="""&t&""""
			str=str&">"&Checkxml(url)&"</u>"
			str=str&"<c>"&Checkxml(content)&"</c>"
			str=str&"<p"
			if a<>"" then str=str&" a="""&a&""""
			if c<>"" then str=str&" c="""&c&""""
			if u<>"" then str=str&" u="""&u&""""
			str=str&">"&Checkxml(pic)&"</p>"
			str=str&"<l>"&Checkxml(lrc)&"</l>"
			str=str&"<s"
			if fg<>"" then str=str&" fg="""&fg&""""
			str=str&">"&Checkxml(scene)&"</s>"		
		str=str&"</m>"
	make_cflist_music=str	
end function

sub check_music_name()
%>
<table border="0" cellspacing="2" cellpadding="5" align="center" width="95%">
  <tr>
    <td align="center"><%
	set rs=conn.execute("select title from cmp_list Where title='"&request("music_name")&"'")
	if rs.eof then
		response.Write("�������!")
	else
		response.Write("�Ѿ�����<a href=""javascript:search_music_name('"&request("music_name")&"')""><font color=#ff0000>"&rs("title")&"</font></a>")
	end if
	rs.close
	set rs=nothing
%>
    </td>
  </tr>
  <tr>
    <td align="center"><input type="button" value="�� ��" onClick="window.close();" /></td>
  </tr>
</table>
<script language="JavaScript" type="text/javascript">
function search_music_name(music_name){
	opener.location="?selectkey="+music_name;
	window.close();
}
</script>
<%
end sub

sub make_lrc()
dim objFSO,objCountFile
dim lrc_name,lrc_content,lrc_path,root_lrc_path
'on error resume next
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
dim this_path,parent_path
this_path="http://"&Request.ServerVariables("HTTP_HOST")&left(Request.ServerVariables("PATH_INFO"),InStrRev(Request.ServerVariables("PATH_INFO"),"/")-1)
parent_path=left(this_path,InStrRev(this_path,"/"))
if request("make_lrc")="save" then
	lrc_content=request("lrc_content")
	lrc_path=request("lrc_path")
	if lrc_path<>"" and lrc_content<>"" then
		make_file lrc_content,lrc_path
		root_lrc_path=request("root_lrc_path")
%>
<script language="JavaScript" type="text/javascript">
//
function savepath(){
	opener.document.getElementById('lrc').value=document.getElementById('lrc_url').value;
	window.close();
}
function userpath1(){
	document.getElementById('lrc_url').value="<%=root_lrc_path%>";
}
function userpath2(){
	document.getElementById('lrc_url').value="<%=parent_path&root_lrc_path%>";
}
//
function copyToClipboard(obj){
	obj.select();
	rgn = obj.createTextRange();
	rgn.execCommand("Copy");
}

</script>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <th align="center">����ļ�����</th>
  </tr>
  <tr>
    <td align="center" class="cmsRow">����ļ�����ɹ�!</td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><input name="radiobutton" type="radio" value="radiobutton" checked="checked" onClick="userpath1();" />
      ʹ����Ե�ַ
      <input type="radio" name="radiobutton" value="radiobutton" onClick="userpath2();" />
      ʹ�þ��Ե�ַ</td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><input name="lrc_url" type="text" id="lrc_url" value="<%=root_lrc_path%>" size="70">
      <input type="button" name="Submit" value="���Ƶ�������" onClick="copyToClipboard(document.getElementById('lrc_url'));"></td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><input type="button" name="Submit3" value="ȷ ��" onClick="savepath()"></td>
  </tr>
</table>
<%
	end if
else
	lrc_name=request("lrc_name")&".txt"
	lrc_path="../lrc/"&lrc_name
	root_lrc_path="lrc/"&lrc_name
	if objFSO.FileExists(Server.MapPath(lrc_path)) then
		Set objCountFile = objFSO.OpenTextFile(Server.MapPath(lrc_path),1,False)
		If Not objCountFile.AtEndOfStream Then
			lrc_content = objCountFile.ReadAll
		else
			lrc_content = ""
		end if
		objCountFile.Close
		Set objCountFile=Nothing
	else
		lrc_content = ""
	end if
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <form name="lrc_file_form" action="?nomenu=1&action=make_lrc&make_lrc=save" method="post">
    <tr>
      <th colspan="4" align="center">����ļ�����</th>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>�ļ���:</strong></td>
      <td class="cmsRow"><input type="text" size="50" name="lrc_name" value="<%=lrc_name%>" /></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>�������:</strong><br />
        <br />
        [ti:����]<br />
        [ar:����]<br />
        [al:ר��]<br />
        [by:CenFun]<br />
        [offset:500]</td>
      <td class="cmsRow"><textarea name="lrc_content" rows="20" style="width:100%;"><%=lrc_content%></textarea></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>�ļ�����·��:</strong></td>
      <td class="cmsRow"><input type="text" size="70" name="lrc_path" value="<%=lrc_path%>" /></td>
    </tr>
    <tr>
      <td align="right" class="cmsRow"><strong>���ʹ�õ�ַ:</strong></td>
      <td class="cmsRow"><input type="text" size="70" name="root_lrc_path" value="<%=root_lrc_path%>" /></td>
    </tr>
    <tr>
      <td colspan="2" align="center" class="cmsRow"><input type="button" onClick="check_lrc();" class="button" name="submit_lrc_file" value=" �� �� " />
        <input type="reset" class="button" name="reset_lrc_file" value=" ȡ �� " onClick="window.close();"/></td>
    </tr>
  </form>
</table>
<script language="JavaScript" type="text/javascript">
function check_lrc(){
	if(document.lrc_file_form.lrc_content.value==""){
		alert("������ݲ���Ϊ��!");
		document.lrc_file_form.lrc_content.focus();
		return false;
	}
	if(document.lrc_file_form.lrc_path.value==""){
		alert("����ļ�����·������Ϊ��!");
		document.lrc_file_form.lrc_path.focus();
		return false;
	}
	document.lrc_file_form.submit();
}
</script>
<%	
end if
Set objFSO = Nothing
if err.number<>0 then
	response.write "<center>"&Err.Description&"�����Ŀռ䲻֧��FSO����ͬ���Ŀռ�����ϵ�����߲鿴���Ȩ�����á�</center>"
end if
end sub

sub show()
%>
<table border="0" cellspacing="1" cellpadding="5" align=center class="tableBorder">
  <tr>
    <td align="center" class="cmsRow"><embed src="../cmp.swf?config=.." quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="100%" height="420" id="cmp"></embed>
    </td>
  </tr>
  <tr>
    <td align="center" class="cmsRow"><p>���û��ˢ��,��ȷ�������<a href="?action=make_xml">����xml�ļ�</a>���ܣ���Ȼû��ˢ�������������������漴��!(<a href="../index.htm" target="_blank">��WMP�ӿ�ҳ��</a>)</p></td>
  </tr>
</table>
<meta http-equiv=Pragma content=no-cache>
<meta http-equiv=expires content=0>
<meta http-equiv="cache-control" content="no-store">
<%
end sub
%>
