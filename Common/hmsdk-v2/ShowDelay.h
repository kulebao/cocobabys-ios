#ifndef _SHOW_DELAY_H_
#define _SHOW_DELAY_H_
/************************************************************************/
//#include <windows.h>
//#include <Mmsystem.h>
#include <math.h>
#include <pthread.h>
#include "hm_sdk.h"

typedef unsigned int uint32_t;
int64 GetNowUnixTime();

/************************************************************************/
class CShowDelay
{
private:
	uint32_t m_dwGroupFrameCnt;     //两个主I帧之间帧数（定义为一个group 帧率和标准差的计算以group为一个单位）
	uint32_t m_dwGroupStartTime;
	uint32_t m_dwPreFrameRcvTime;
    
	bool m_bIsPreIFrame;
	bool m_bIsFirstValue;           //第一个值视为无效 因为不能保证帧从group开始
    
	double m_dBiggetSVariance;      //近期最大标准差
    pthread_mutex_t     m_cs;       // 队列锁
    
    
	//以下参数与播放密切相关
	double	m_dRealFps;	            //实际接收帧率
	int		m_nSubSpeedLine;        //无I时减速系数
	int		m_nAddSpeedLine;        //无I时加速系数
	int64	m_s64PreShowTime;       //上一帧显示的时刻 单位毫秒
	int		m_nFrameSize;           //当前队列中的帧数 除去小I帧
	uint32_t	m_dwIFrameNum;      //当前队列中主I帧个数（只考虑连续主I帧中最大长度的主I）
public:
	CShowDelay(void);
	~CShowDelay(void);
private:
	void Init();
	void Uninit();
	void InsertRcvSpace(const int& nFrameType, const uint32_t& cur_time);
	void InsertFrameCnt(const uint32_t& cur_time,const int& nFrameType, const int& nFrameLen);
	void UpdateParam(const int& nFrameType, const int& nFrameLen);
	double GetSVariance();
	void InserSVariance();
	double GetBiggestSVariance();
	int GetSubLineByVariance(double dVariance);
	int GetAddLineByVariance(double dVariance);
	void RefreshSpeedLine();
	void InsertFps(const uint32_t& cur_time);
	void RefreshFps();
	
    
public://对外接口
	
	// 参数说明
	// fps:请求实时视频回复中pu给出的帧率（传入参数）
	// 注：每请求实时视频结束后 应调用一次本接口
	void Reset(int fps = 11);
	
	// 参数说明
	// nFrameType:待插入缓冲队列的视频帧类型（传入参数）
	// nFrameLen：待插入缓冲队列的视频帧数据长度（传入参数）
	// 注：向缓冲队列插入视频帧之前调用
	void InsertFrameInfo(const int& nFrameType, const int& nFrameLen);
	
	// 参数说明
	// nFrameSize:缓冲队列的视频帧总数（传入参数）
	// nFrameType:当前取出的视频帧类型（传入参数）
	// nFrameLen：当前取出的视频帧数据长度（传入参数）
	// u64ShowTime：当前取出的视频帧应该显示的时刻，单位毫秒（传出参数）
	// 注：从缓冲队列取视频帧之后调用
	void RemoveFrameInfo(const int& nFrameType, const int& nFrameLen ,int64& u64ShowTime);
    
	int GetShowInterval();                                         //获取两帧显示的时间差距 单位毫秒
	double GetRealFps()	{	return m_dRealFps;	}	               //获取当前实际接收帧率
	int GetSubLine()	{	return m_nSubSpeedLine;	}	           //获取当前无大I帧时的减速系数
	int GetMaxSize()	{		return m_nAddSpeedLine;	}	       //获取缓冲无大I帧时，加速前允许的最大帧数
	double GetCurSVariance()	{		return m_dBiggetSVariance;	}	//获取近期最大标准差
	int GetBigINum() { return m_dwIFrameNum;}
	int GetSizeNum(){ return m_nFrameSize;}
};

/************************************************************************/
#endif //_SHOW_DELAY_H_