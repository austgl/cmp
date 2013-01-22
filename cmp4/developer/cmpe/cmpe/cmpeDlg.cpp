
// cmpeDlg.cpp : ʵ���ļ�
//
#include "stdafx.h"
#include "cmpe.h"
#include "cmpeDlg.h"
#include "afxdialogex.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// ����Ӧ�ó��򡰹��ڡ��˵���� CAboutDlg �Ի���

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

	// �Ի�������
	enum { IDD = IDD_ABOUTBOX };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

	// ʵ��
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CcmpeDlg �Ի���




CcmpeDlg::CcmpeDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CcmpeDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	//  ie = 0;
}

void CcmpeDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_EXPLORER1, m_IE);
}

BEGIN_MESSAGE_MAP(CcmpeDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_SIZE()
END_MESSAGE_MAP()


// CcmpeDlg ��Ϣ�������

BOOL CcmpeDlg::OnInitDialog()
{

	CDialogEx::OnInitDialog();

	// ��������...���˵�����ӵ�ϵͳ�˵��С�

	// IDM_ABOUTBOX ������ϵͳ���Χ�ڡ�
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// ���ô˶Ի����ͼ�ꡣ��Ӧ�ó��������ڲ��ǶԻ���ʱ����ܽ��Զ�
	//  ִ�д˲���
	SetIcon(m_hIcon, TRUE);			// ���ô�ͼ��
	SetIcon(m_hIcon, FALSE);		// ����Сͼ��


	//����
	CString strTitle;
	strTitle.LoadString(IDS_STRING_TITLE);
	CcmpeDlg::SetWindowTextW(strTitle);

	//Ĭ�ϴ�С
	UINT w = 1024;
	UINT h = 768;

	CString strW;
	strW.LoadString(IDS_STRING_WINDOW_WIDTH);
	CString strH;
	strH.LoadString(IDS_STRING_WINDOW_HEIGHT);

	w = _wtoi(strW);
	h = _wtoi(strH);

	CcmpeDlg::SetWindowPos(NULL, 0, 0, w, h, NULL);


	//m_IE.SetScrollInfo();




	// TODO: �ڴ���Ӷ���ĳ�ʼ������
	setBrowserSize();
	//��Ĭ����ַ

	CString strCmpUrl;
	strCmpUrl.LoadString(IDS_STRING_CMPURL);

	m_IE.Navigate(strCmpUrl, NULL, NULL, NULL, NULL);


	return TRUE;  // ���ǽ��������õ��ؼ������򷵻� TRUE
}

void CcmpeDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// �����Ի��������С����ť������Ҫ����Ĵ���
//  �����Ƹ�ͼ�ꡣ����ʹ���ĵ�/��ͼģ�͵� MFC Ӧ�ó���
//  �⽫�ɿ���Զ���ɡ�

void CcmpeDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // ���ڻ��Ƶ��豸������

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// ʹͼ���ڹ����������о���
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// ����ͼ��
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

//���û��϶���С������ʱϵͳ���ô˺���ȡ�ù��
//��ʾ��
HCURSOR CcmpeDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

BEGIN_EVENTSINK_MAP(CcmpeDlg, CDialogEx)
	ON_EVENT(CcmpeDlg, IDC_EXPLORER1, 259, CcmpeDlg::DocumentCompleteExplorer1, VTS_DISPATCH VTS_PVARIANT)
END_EVENTSINK_MAP()

void CcmpeDlg::DocumentCompleteExplorer1(LPDISPATCH pDisp, VARIANT* URL)
{

	//AfxMessageBox(strAboutMenu);

}

void CcmpeDlg::OnSize(UINT nType, int cx, int cy)
{
	CDialogEx::OnSize(nType, cx, cy);

	// TODO: �ڴ˴������Ϣ����������

	setBrowserSize();

}

void CcmpeDlg::setBrowserSize() {

	CRect rect;
	GetClientRect(&rect);

	//rect.top = 100;

	if (m_IE) {
		m_IE.MoveWindow(rect);
	}

}