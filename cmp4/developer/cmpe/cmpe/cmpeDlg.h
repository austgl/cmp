
// cmpeDlg.h : ͷ�ļ�
//

#pragma once
#include "explorer.h"


// CcmpeDlg �Ի���
class CcmpeDlg : public CDialogEx
{
// ����
public:
	CcmpeDlg(CWnd* pParent = NULL);	// ��׼���캯��

// �Ի�������
	enum { IDD = IDD_CMPE_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV ֧��


// ʵ��
protected:
	HICON m_hIcon;

	// ���ɵ���Ϣӳ�亯��
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	DECLARE_EVENTSINK_MAP()
	void DocumentCompleteExplorer1(LPDISPATCH pDisp, VARIANT* URL);
	// �����
	CExplorer1 m_IE;
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void setBrowserSize();
};
