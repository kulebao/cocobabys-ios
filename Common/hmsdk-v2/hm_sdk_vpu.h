#ifndef __HM_SDK_VPU__H
#define __HM_SDK_VPU__H
#include "hm_sdk.h"

typedef uint32		hm_vpu_result;
typedef pointer		vpu_user_id;
typedef pointer		vpu_user_data;
typedef pointer		vpu_device_info_handler;
typedef pointer		vpu_video_handler;
typedef pointer		vpu_audio_handler;
typedef pointer		vpu_talk_handler;

#define HMCAPI

//	DVS通道能力，单个设备（对应1个通道，通道号为0）
typedef struct _VPU_CHANNEL_CAPACITY
{
	char channel_name[260];			// 通道名称
	char video_name[260];			//	视频名称
	bool video_support;				//	视频支持
	bool audio_support;				//	音频支持
	bool talk_support;				//	对讲支持
	bool ptz_support;				//	云台支持
	uint32 audio_code_type;	//	音频编码
	int32 audio_sample;				//	采样率
	int32 audio_channel;			//	声道
} _VPU_CHANNEL_CAPACITY, *P_VPU_CHANNEL_CAPACITY;

// 设备信息
typedef struct _VPU_DEVICE_INFO
{
	char	dev_name[260];		//	设备名称
	char	dev_type[64];		//	设备类型
	char	dev_sn[14];				//	设备SN号
	int32	total_channel;		//	通道总数
	int32	alram_in_count;		//	报警输入通道数
	int32	alarm_out_count;	//	报警输出通道数
	int32	sensor_count;		//	传感器数量
	P_VPU_CHANNEL_CAPACITY  channel_capacity[20];	//	DVS通道能力，单个设备（对应1个通道，通道号为0）
} VPU_DEVICE_INFO, *P_VPU_DEVICE_INFO;

HMCAPI hm_vpu_result hm_vpu_init_device_info(P_VPU_DEVICE_INFO);

typedef void(*vpu_net_abnormal)(vpu_user_data, uint32);
typedef struct _VPU_CONNECT_NVS_AUTH_INFO
{
	char user_name[256];
	char user_pwd[256];
	char dev_sn[14];
	char nvs_ip[20];
	uint16 nvs_port;
	vpu_net_abnormal net_cb;
	vpu_user_data    data;
} VPU_CONNECT_NVS_AUTH_INFO, *P_VPU_CONNECT_NVS_AUTH_INFO;

HMCAPI hm_vpu_result hm_vpu_login_nvs(P_VPU_CONNECT_NVS_AUTH_INFO info, vpu_user_id* id);
HMCAPI hm_vpu_result hm_vpu_logout_nvs(vpu_user_id id);

typedef enum {REQUEST_OPEN_VIDEO_EVENT, REQUEST_CLOSE_VIDEO_EVENT};
typedef struct _VPU_FRAME_INFO
{
	uint16	channel;
	uint16	data_type;
	uint16	stream_type;
	uint16	frame_type;
	uint64	absolute_timestamp;
} VPU_FRAME_INFO, *P_VPU_FRAME_INFO;

typedef struct _VPU_FRAME_DATA
{
	VPU_FRAME_INFO frame_info;
	uint32     frame_len;
	cpointer   frame_stream;
} VPU_FRAME_DATA, *P_VPU_FRAME_DATA;

typedef struct _REQUEST_VIDEO
{
	uint32 channel;
	uint32 video_type;
	uint32 stream_type;
} REQUEST_VIDEO, *P_REQUEST_VIDEO;

typedef struct _RESPONSE_VIDEO
{
	uint32 channel;
	uint32 video_code;
	uint32 video_width;
	uint32 video_height;
	uint32 video_fps;
	uint32 gop_size;
} RESPONSE_VIDEO, *P_RESPONSE_VIDEO;

typedef void(*vpu_request_video)(vpu_user_data, vpu_video_handler, uint32 event, pointer info);
HMCAPI hm_vpu_result hm_vpu_register_video_cb(vpu_request_video, vpu_user_data);
HMCAPI hm_vpu_result hm_vpu_response_video_request(vpu_video_handler, P_RESPONSE_VIDEO);
HMCAPI hm_vpu_result hm_vpu_send_video_data(vpu_video_handler, P_VPU_FRAME_DATA);
HMCAPI hm_vpu_result hm_vpu_release_video(vpu_video_handler);

// 音频操作
typedef enum {REQUEST_OPEN_AUDIO_EVENT, REQUEST_CLOSE_AUDIO_EVENT};
typedef struct _REQUEST_AUDIO
{
	uint32 channel;
} REQUEST_AUDIO, *P_REQUEST_AUDIO;

typedef struct _RESPONSE_AUDIO
{
	uint32 channel;
	uint32 audio_type;
	uint32 audio_sample;
	uint32 audio_channel;
} RESPONSE_AUDIO, *P_RESPONSE_AUDIO;

typedef void(*vpu_request_audio)(vpu_user_data, vpu_audio_handler, uint32 event, pointer info);
HMCAPI hm_vpu_result hm_vpu_register_audio_event_cb(vpu_request_audio, vpu_user_data);
HMCAPI hm_vpu_result hm_vpu_response_audio_request(vpu_audio_handler, P_RESPONSE_AUDIO);
HMCAPI hm_vpu_result hm_vpu_send_audio_data(vpu_audio_handler, P_VPU_FRAME_DATA);
HMCAPI hm_vpu_result hm_vpu_release_audio(vpu_audio_handler);

// 对讲操作
typedef enum {REQUEST_OPEN_TALK_EVENT, REQUEST_CLOSE_TALK_EVENT, REQUEST_RECV_TALK_EVENT};
typedef struct _REQUEST_TALK
{
	uint32 channel;
	uint32 audio_type;
	uint32 audio_sample;
	uint32 audio_channel;
} REQUEST_TALK, *P_REQUEST_TALK;

typedef void(*vpu_request_talk)(vpu_user_data, vpu_talk_handler, uint32 event, pointer info);
HMCAPI hm_vpu_result hm_vpu_register_talk_event_cb(vpu_request_talk, vpu_user_data);
HMCAPI hm_vpu_result hm_vpu_response_talk_request(vpu_talk_handler, uint32);
HMCAPI hm_vpu_result hm_vpu_release_talk(vpu_talk_handler);

#endif