<?php

//��������ģʽ����ʾ���󱨸棬������ʾ֪ͨ
//error_reporting(E_ERROR | E_WARNING | E_PARSE);
//����ģʽ������ʾ�κδ��󱨸�
error_reporting(0);

//Ҫ�����жϵ���վ�����б�
//��������ȫСд��ע��ǰ�治Ҫ��http://
//��ȫƥ�䣬��֧��ͨ�������Ҫͨ����Ŀ�����ȥд����֧��
$domain_list = array("cenfun.com", "bbs.cenfun.com", "www.cenfun.com");

//�����б��е������Ƿ�Ϊ������������Ϊ������(Ĭ��)
//����������ֻ������Щ��Դ��
//���������ǲ�������Щ��Դ��
$is_black_list = FALSE;

//�Ƿ��������Դ(Ĭ������)�����������ԴҳΪ��ʱ������ͨ�����������Ҫ����ȷ����Դ��ַ
//����ֱ�Ӵ�û��referer������Firefox�У�wmp�У����ܲ�һ��ÿ�ζ���referer��Դ��ַ
$allow_empty_referer = TRUE;


//�ص�����==================================================================

//�ɹ�ͨ����֤��Ҫ���õĳ�������Ҫ������д��������
function succeed() {
	
	echo "welcome";
	
}

//����û��ͨ����֤Ҫ���õĳ��򣬱��緵��һ������ҳ�棬�򷵻�һ��������Ϣ����һ���������б�
function error() {
	
	echo "error";
	
}


//��Դҳ�ж�===============================================================
//ȡ�÷�����Դ�ĵ�ַ
$referer = $_SERVER["HTTP_REFERER"];	
if($referer) {
	//������Դ��ַ
	$refererhost = parse_url($referer);
	//��Դ��ַ��������
	$host = strtolower($refererhost['host']);
	if($is_black_list) {
		//����Ǻ�����
		if (in_array($host, $domain_list)) {
			error();
		} else {
			succeed();
		}
	} else {
		//����ǰ�����
		if($host == $_SERVER['HTTP_HOST'] || in_array($host, $domain_list)) {
			succeed();
		} else {
			error();
		}
	}
} else {
	if ($allow_empty_referer) {
		succeed();
	} else {
		error();
	}
}

?>
