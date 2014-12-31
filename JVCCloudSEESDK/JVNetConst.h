//
//  JVNetConst.h
//  CloudSee
//  云视通网络库的常量定义
//  Created by jovision on 12-4-28.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

/*实时监控数据类型*/
#define JVN_DATA_I          0x01//视频I帧
#define JVN_DATA_B          0x02//视频B帧
#define JVN_DATA_P          0x03//视频P帧
#define JVN_DATA_A          0x04//音频
#define JVN_DATA_S          0x05//帧尺寸
#define JVN_DATA_OK         0x06//视频帧收到确认
#define JVN_DATA_DANDP      0x07//下载或回放收到确认
#define JVN_DATA_O          0x08//其他自定义数据
#define JVN_DATA_SKIP       0x09//视频S帧
/*请求类型*/
#define JVN_REQ_CHECK       0x10//请求录像检索
#define JVN_REQ_DOWNLOAD    0x20//请求录像下载
#define JVN_REQ_PLAY        0x30//请求远程回放
#define JVN_REQ_CHAT        0x40//请求语音聊天
#define JVN_REQ_TEXT        0x50//请求文本聊天
#define JVN_REQ_CHECKPASS   0x71//请求身份验证
/*请求返回结果类型*/
#define JVN_RSP_CHECKDATA   0x11//检索结果
#define JVN_RSP_CHECKOVER   0x12//检索完成
#define JVN_RSP_DOWNLOADDATA 0x21//下载数据
#define JVN_RSP_DOWNLOADOVER 0x22//下载数据完成
#define JVN_RSP_DOWNLOADE   0x23//下载数据失败
#define JVN_RSP_PLAYDATA    0x31//回放数据
#define JVN_RSP_PLAYOVER    0x32//回放完成
#define JVN_RSP_PLAYE       0x39//回放失败
#define JVN_RSP_CHATDATA    0x41//语音数据
#define JVN_RSP_CHATACCEPT  0x42//同意语音请求
#define JVN_RSP_TEXTDATA    0x51//文本数据
#define JVN_RSP_TEXTACCEPT  0x52//同意文本请求
#define JVN_RSP_CHECKPASST  0x72//身份验证成功
#define JVN_RSP_CHECKPASSF  0x73//身份验证失败
#define JVN_RSP_NOSERVER    0x74//无该通道服务
#define JVN_RSP_INVALIDTYPE 0x7A//连接类型无效
#define JVN_RSP_OVERLIMIT   0x7B//连接超过主控允许的最大数目
#define JVN_RSP_DLTIMEOUT   0x76//下载超时
#define JVN_RSP_PLTIMEOUT   0x77//回放超时
#define JVN_RSP_DISCONN     0x7C//断开连接确认

/*命令类型*/
#define JVN_CMD_DOWNLOADSTOP 0x24//停止下载数据
#define JVN_CMD_PLAYUP      0x33//快进
#define JVN_CMD_PLAYDOWN    0x34//慢放
#define JVN_CMD_PLAYDEF     0x35//原速播放
#define JVN_CMD_PLAYSTOP    0x36//停止播放
#define JVN_CMD_PLAYPAUSE   0x37//暂停播放
#define JVN_CMD_PLAYGOON    0x38//继续播放
#define JVN_CMD_CHATSTOP    0x43//停止语音聊天
#define JVN_CMD_TEXTSTOP    0x53//停止文本聊天
#define JVN_CMD_YTCTRL      0x60//云台控制
#define JVN_CMD_VIDEO       0x70//实时监控
#define JVN_CMD_VIDEOPAUSE  0x75//暂停实时监控
#define JVN_CMD_TRYTOUCH    0x78//打洞包
#define JVN_CMD_FRAMETIME   0x79//帧发送时间间隔(单位ms)
#define JVN_CMD_DISCONN     0x80//断开连接

/*局域网设备搜索*/
#define JVN_REQ_LANSERCH  0x01//局域网设备搜索命令
#define JVN_CMD_LANSALL   1//局域网搜索所有中维设备
#define JVN_CMD_LANSYST   2//局域网搜索指定云视通号码的设备
#define JVN_CMD_LANSTYPE  3//局域网搜索指定卡系的设备
#define JVN_RSP_LANSERCH  0x02//局域网设备搜索响应命令

/*与云视通服务器的交互消息*/
#define JVN_CMD_TOUCH       0x81//探测包
#define JVN_REQ_ACTIVEYSTNO 0x82//主控请求激活YST号码
#define JVN_RSP_YSTNO       0x82//服务器返回YST号码
#define JVN_REQ_ONLINE      0x83//主控请求上线
#define JVN_RSP_ONLINE      0x84//服务器返回上线令牌
#define JVN_CMD_ONLINE      0x84//主控地址更新
#define JVN_CMD_OFFLINE     0x85//主控下线
#define JVN_CMD_KEEP        0x86//主控保活
#define JVN_REQ_CONNA       0x87//分控请求主控地址
#define JVN_RSP_CONNA       0x87//服务器向分控返回主控地址
#define JVN_CMD_CONNB       0x87//服务器命令主控向分控穿透
#define JVN_RSP_CONNAF      0x88//服务器向分控返回 主控未上线
#define JVN_CMD_RELOGIN		0x89//通知主控重新登陆
#define JVN_CMD_CLEAR		0x8A//通知主控下线并清除网络信息包括云视通号码
#define JVN_CMD_REGCARD		0x8B//主控注册板卡信息到服务器

#define JVN_CMD_ONLINES2    0x8C//服务器命令主控向转发服务器上线/主控向转发服务器上线
#define JVN_CMD_CONNS2      0x8D//服务器命令分控向转发服务器发起连接
#define JVN_REQ_S2          0x8E//分控向服务器请求转发
#define JVN_TDATA_CONN      0x8F//分控向转发服务器发起连接
#define JVN_TDATA_NORMAL    0x90//分控/主控向转发服务器发送普通数据

#define JVN_CMD_CARDCHECK   0x91//板卡验证
#define JVN_CMD_ONLINEEX    0x92//主控地址更新扩展
#define JVN_CMD_TCPONLINES2 0x93//服务器命令主控TCP向转发服务器上线

#define JVN_ALLSERVER    0//所有服务
#define JVN_ONLYNET      1//只局域网服务

#define JVN_NOTURN       0//云视通方式时禁用转发
#define JVN_TRYTURN      1//云视通方式时启用转发
#define JVN_ONLYTURN     2//云视通方式时仅用转发

#define JVN_LANGUAGE_ENGLISH 1
#define JVN_LANGUAGE_CHINESE 2

#define TYPE_PC_UDP       1//连接类型 UDP 支持UDP收发完整数据
#define TYPE_PC_TCP       2//连接类型 TCP 支持TCP收发完整数据
#define TYPE_MO_TCP       3//连接类型 TCP 支持TCP收发简单数据,普通视频帧等不再发送，只能采用专用接口收发数据(适用于手机监控)
#define TYPE_MO_UDP       4//连接类型 TCP 支持TCP收发简单数据,普通视频帧等不再发送，只能采用专用接口收发数据(适用于手机监控)
#define TYPE_3GMO_UDP     5//连接类型 3GUDP
#define TYPE_3GMOHOME_UDP 6//连接类型 3GUDP

/*云台控制类型*/
#define JVN_YTCTRL_U     1//上
#define JVN_YTCTRL_D     2//下
#define JVN_YTCTRL_L     3//左
#define JVN_YTCTRL_R     4//右
#define JVN_YTCTRL_A     5//自动
#define JVN_YTCTRL_GQD   6//光圈大
#define JVN_YTCTRL_GQX   7//光圈小
#define JVN_YTCTRL_BJD   8//变焦大
#define JVN_YTCTRL_BJX   9//变焦小
#define JVN_YTCTRL_BBD   10//变倍大
#define JVN_YTCTRL_BBX   11//变倍小

#define JVN_YTCTRL_UT    21//上停止
#define JVN_YTCTRL_DT    22//下停止
#define JVN_YTCTRL_LT    23//左停止
#define JVN_YTCTRL_RT    24//右停止
#define JVN_YTCTRL_AT    25//自动停止
#define JVN_YTCTRL_GQDT  26//光圈大停止
#define JVN_YTCTRL_GQXT  27//光圈小停止
#define JVN_YTCTRL_BJDT  28//变焦大停止
#define JVN_YTCTRL_BJXT  29//变焦小停止
#define JVN_YTCTRL_BBDT  30//变倍大停止
#define JVN_YTCTRL_BBXT  31//变倍小停止

#define JVN_YTCTRL_RECSTART 41//远程录像开始
#define JVN_YTCTRL_RECSTOP	42//远程录像开始

#define JVN_CMD_PLAYSEEK    0x44 //远程回放的针快进确定 1～最大针

#define JVN_ABFRAMERET   35    //帧序列中每个多少帧一个回复}

#define RC_GETMINORCFG 0x10		//获得dvr次码流配置
#define RC_SETMINORCFG 0x11


#pragma 设置主控配置的宏定义数据
#define PACKET_O_SIZE			1024
#define PACKET_O_STARTCODE	    0xFFFFFFFF
#define RC_GET_MOPIC	        0x01
#define RC_SET_MOPIC            0x02


//板卡04解码
#define JVN_DSC_CARD        0x0453564A
#define JVN_DSC_9800CARD    0x0953564A //9800板卡

//新版标准05版板卡
#define JVN_DSC_960CARD     0x0A53564A

//DVR
#define JVN_DSC_DVR         0x0553563A //DVR的解码器类
#define DVR8004_STARTCOODE  0x0553564A

//951硬卡
#define JVSC951_STARTCOODE  0x0753564A

//950硬卡
#define JVSC950_STARTCOODE  0x0653564A

#define JVN_DSC_952CARD     0x0153564A

#define JVN_DVR_8004CARD    0x0253564A //宝宝在线

//IPC
#define IPC3507_STARTCODE    0x1053564A
#define IPC_DEC_STARTCODE    0x1153564A //1080

//NVR
#define JVN_NVR_STARTCODE    0x2053564A


#define CONNECTINTERVAL      200.0*1000.0f


#define MAX_PATH_01 256
#define LOGIONPADDING 15.0
#define LOGINBTNPADDING 45.0
#define REQUESTHOSTURL @"http://api.jovecloud.com"
#define TRYCOUNTMAX 50
#define SOURCELISTWIDTH 140.0
#define SOURCELISTIPHONEFIVEWIDTH 160.0
#define TRYMAXCOUNT 20
#define MAXIMAGENUMS 25
#define WAITIMAXCOUNT 6

/* ****************************************************************************************************************** */
/** DEBUG LOG **/
#ifdef DEBUG

#define DLog( s, ... ) NSLog( @"< %@:(%d) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define DLog( s, ... )

#endif


typedef struct STBASEYSTNO
{
    char chGroup[4];
    int nYSTNO;
    int nChannel;
    char chPName[MAX_PATH_01];
    char chPWord[MAX_PATH_01];
    int nConnectStatus;
}STBASEYSTNO;//云视通号码基本信息，用于初始化小助手的虚连接

typedef struct _JVS_FRAME_HEADER
{
    int    nStartCode;
    int nFrameType:4;    //低地址
    int    nFrameLens:20;
    int    nTickCount:8;    //高地址
    //HI_U64    u64PTS;        //时间戳
}JVS_FRAME_HEADER, *PJVS_FRAME_HEADER;

typedef struct _JVS_FILE_HEADER{
    
    int startCode;
    int width ;
    int height;
    int dwToatlFrames;
    int dwVideoFormat;//视频原格式 0：表示PAL ,1:表示NTSC
    int bThrowFrame;//是否抽针 0:表示不抽针 1:表示抽针
    int dwReserved1;//保留字段
    int dwReserved2;//保留字段
    
}JVS_FILE_HEADER,*PJVS_FILE_HEADER;

#define  NET_MOD_UNKNOW 0 // 未名
#define  NET_MOD_WIFI   1 //wifi 模式
#define  NET_MOD_WIRED  2 // 有线模式

typedef struct _JVS_FILE_HEADER_EX
{
	//老文件头，为兼容以前版本分控，保证其能正常预览
	uint8_t			ucOldHeader[32];//JVS_FILE_HEADER	oldHeader; //此处定义不可直接定义为JVS_FILE_HEADER类型，否则会有结构体成员对齐问题
    
	//结构体信息
	uint8_t			ucHeader[3];		//结构体识别码，设置为‘J','F','H'
	uint8_t			ucVersion;			//结构体版本号，当前版本为1
    
	//设备相关
	uint16_t		wDeviceType;		//设备类型
    
	//视频部分
	uint16_t		wVideoCodecID;		//视频编码类型
	uint16_t		wVideoDataType;    	//数据类型
	uint16_t		wVideoFormat;		//视频模式
	uint16_t		wVideoWidth;		//视频宽
	uint16_t		wVideoHeight;		//视频高
	uint16_t		wFrameRateNum;		//帧率分子
	uint16_t		wFrameRateDen;		//帧率分母
    
	//音频部分
	uint16_t		wAudioCodecID;		//音频编码格式
	uint16_t		wAudioSampleRate;	//音频采样率
	uint16_t		wAudioChannels;	    //音频声道数
	uint16_t		wAudioBits;		    //音频采样位数
    
	//录像相关
	uint32_t		dwRecFileTotalFrames;	//录像总帧数
	uint16_t		wRecFileType;		//录像类型
    
	//保留位
	uint8_t			ucReserved[30];		//请全部置0
    
} JVS_FILE_HEADER_EX, *PJVS_FILE_HEADER_EX;


#define RC_DATA_SIZE	192*800
typedef struct tagPAC
{
	unsigned int	nPacketType:5;		//包的类型
	unsigned int	nPacketCount:8;		//包总数
	unsigned int	nPacketID:8;		//包序号
	unsigned int	nPacketLen:11;		//包的长度
	char acData[RC_DATA_SIZE];
} PAC, *PPAC;

typedef struct
{
	int nStartCode;						//固定为PACKET_O_STARTCODE
	int nDataType;						//类型
	int reserved;							//保留字段
	int nLength;							//data字符串长度
	char data[PACKET_O_SIZE];
}PACKET_O_1;

typedef struct Frame//音频数据结构
{
    int	iIndex;//音频数据序号
    char cb[12];//音频数据？
} Frame;


typedef struct tagEXTEND
{
	int	nType;
	int	nParam1;   //存放的包的个数
	int	nParam2;
	int	nParam3;
	char acData[RC_DATA_SIZE-16];
} EXTEND, *PEXTEND;


typedef struct
{
    char    name[32];       //
    char    passwd[16];     //历史纪录的密码
    int     quality;     //信号强度，满值一百
    int     keystat;     //是否需要加密 －1不需要
    char    iestat[8];      //加密的方式 支持wpa/..
}wifiap_t;

typedef struct
{
    char wifiSsid[32];
    char wifiPwd[64];
    int wifiAuth;
    int wifiEncryp;
    u_int8_t wifiIndex;
    u_int8_t wifiChannel;
    u_int8_t wifiRate;
    
}WIFI_INFO;

#define JVN_CMD_ONLYI        0x61//该通道只发关键帧
#define JVN_CMD_FULL         0x62//该通道恢复满帧

#define EX_STORAGE_SWITCH   0x07



//远程控制指令
#define RC_DISCOVER            0x01
#define RC_GETPARAM            0x02
#define RC_SETPARAM            0x03
#define RC_VERITY              0x04
#define RC_LOADDLG             0x05
#define RC_EXTEND              0x06
#define RC_USERLIST            0x07
#define RC_PRODUCTREG          0X08
#define RC_GETSYSTIME          0x09
#define RC_SETSYSTIME          0x0a
#define RC_DEVRESTORE          0x0b
#define RC_SETPARAMOK          0x0c
#define RC_DVRBUSY             0X0d
#define RC_GETDEVLOG           0x0e
#define RC_DISCOVER_CSST       0x0f
#define RC_WEB_PROXY           0x0f/    /请求WEB页面
//#define RC_JSPARAM            0x10    //json格式的设置模式
/**
 *  手环门磁报警的
 */
#define RC_GPIN_ADD            0x10
#define RC_GPIN_SET            0x11
#define RC_GPIN_SELECT         0x12
#define RC_GPIN_DEL            0x13


//扩展类型，用于指定哪个模块去处理,lck20120206
#define RC_EX_FIRMUP         0x01
#define RC_EX_NETWORK        0x02
#define RC_EX_STORAGE        0x03
#define RC_EX_ACCOUNT        0x04
#define RC_EX_PRIVACY        0x05
#define RC_EX_MD             0x06
#define RC_EX_ALARM          0x07
#define RC_EX_SENSOR         0x08
#define RC_EX_PTZ            0x09
#define RC_EX_AUDIO          0x0a
#define RC_EX_ALARMIN        0x0b
#define RC_EX_REGISTER       0x0c
#define RC_EX_EXPOSURE       0x0d
#define RC_EX_QRCODE         0x0e
#define RC_EX_IVP            0x0f
#define RC_EX_DOORALARM      0x10

//网络设置模块 （拓展）
#define EX_ADSL_ON         0x01    //连接ADSL消息
#define EX_ADSL_OFF        0x02    //断开ADSL消息
#define EX_WIFI_AP         0x03    //获取AP消息
#define EX_WIFI_ON         0x04    //连接wifi
#define EX_WIFI_OFF        0x05    //断开wifi
#define EX_NETWORK_OK      0x06    //设置成功
#define EX_UPDATE_ETH      0x07    //修改eth网络信息
#define EX_NW_REFRESH      0x08    //刷新当前网络信息
#define EX_NW_SUBMIT       0x09    //刷新当前网络信息
#define EX_WIFI_CON        0x0a
#define EX_WIFI_AP_CONFIG  0x0b
#define EX_START_AP        0x0c    //开启AP

//账户设置模块
#define EX_ACCOUNT_OK         0x01
#define EX_ACCOUNT_ERR        0x02
#define EX_ACCOUNT_REFRESH    0x03
#define EX_ACCOUNT_ADD        0x04
#define EX_ACCOUNT_DEL        0x05
#define EX_ACCOUNT_MODIFY     0x06

#define RC_EX_FlashJpeg	  0x0a


//设备系统升级指令,lck20120207
#define EX_UPLOAD_START		0x01
#define EX_UPLOAD_CANCEL	0x02
#define EX_UPLOAD_OK		0x03
#define EX_UPLOAD_DATA		0x04
#define EX_FIRMUP_START		0x05
#define EX_FIRMUP_STEP		0x06
#define EX_FIRMUP_OK		0x07
#define EX_FIRMUP_RET		0x08
#define EX_FIRMUP_REBOOT	0xA0
#define EX_FIRMUP_RESTORE	0xA1

//升级方法
#define FIRMUP_HTTP			0x00
#define FIRMUP_FILE			0x01
#define FIRMUP_FTP			0x02 //已废弃

/**
 *@brief 用户组定义
 *
 */
#define POWER_GUEST        0x0001
#define POWER_USER         0x0002
#define POWER_ADMIN        0x0004
#define POWER_FIXED        0x0010


/**
 *  图像翻转的
 */
#define EX_MD_SUBMIT	 0x02
#define EX_ALARM_SUBMIT	 0x02

/**
 *  修改设备的用户名密码
 */
#define SECRET_KEY			0x1053564A
#define	MAX_ACCOUNT			13
#define	SIZE_ID				20
#define	SIZE_PW				20
#define SIZE_DESCRIPT		32



//操作状态
#define	ERR_EXISTED		0x1
#define	ERR_LIMITED		0x2
#define	ERR_NOTEXIST	0x3
#define	ERR_PASSWD		0x4	//密码错误
#define	ERR_PERMISION_DENIED	0x5//无权限


typedef struct tagACCOUNT
{
    char	acID[SIZE_ID];	          //ID注册后不可更改，但可以删除
    char	acPW[SIZE_PW];	          //密码可以更改
    char	acDescript[SIZE_DESCRIPT];//帐户描述
}ACCOUNT, *PACCOUNT;

enum {

    IPCAM_MAIN		=0,
    IPCAM_SYSTEM	=1,
    IPCAM_STREAM	=2,
    IPCAM_STORAGE	=3,
    IPCAM_ACCOUNT	=4,
    IPCAM_NETWORK	=5,
    IPCAM_LOGINERR	=6,
    IPCAM_PTZ		=7,
    IPCAM_IVP		=8,
    IPCAM_MAX

};

#define POWER_GUEST		0x0001
#define POWER_USER		0x0002
#define POWER_ADMIN		0x0004
#define POWER_FIXED		0x0010
