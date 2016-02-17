//
//  JVCCloudSEENetworkInterface.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import <Foundation/Foundation.h>
/*分控回调函数*/
typedef struct
{
    char chGroup[4];
    int  nYSTNO;
    int  nCardType;
    int  nChannelCount;
    char chClientIP[16];
    int  nClientPort;
    int  nVariety;
    char chDeviceName[100];
    BOOL bTimoOut;
    
    int  nNetMod;//例如 是否具有Wifi功能：nNetMod&NET_MOD_WIFI
    int  nCurMod;//例如 当前使用的（WIFI或有线）
    int  nPrivateSize;
    char chPrivateInfo[500];//◊‘∂®“Â ˝æ›ƒ⁄»›
}STLANSRESULT_01;

typedef void (*FUNC_CCONNECT_CALLBACK)(int nLocalChannel, unsigned char uchType, char *pMsg, int nPWData);
typedef void (*FUNC_CNORMALDATA_CALLBACK)(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize, int nWidth, int nHeight);
typedef void (*FUNC_CCHECKRESULT_CALLBACK)(int nLocalChannel,Byte *pBuffer, int nSize);
typedef void (*FUNC_CCHATDATA_CALLBACK)(int nLocalChannel, unsigned char uchType, Byte *pBuffer, int nSize);
typedef void (*FUNC_CTEXTDATA_CALLBACK)(int nLocalChannel, unsigned char uchType, char *pBuffer, int nSize);
typedef void (*FUNC_CDOWNLOAD_CALLBACK)(int nLocalChannel, unsigned char uchType, Byte *pBuffer, int nSize, int nFileLen);
typedef void (*FUNC_CPLAYDATA_CALLBACK)(int nLocalChannel, unsigned char uchType, Byte *pBuffer, int nSize, int nWidth, int nHeight, int nTotalFrame);

//手机端从内存卡中获取数据回调
typedef void (*FUNC_GETDATA_CALLBACK)(unsigned char *chGroup,unsigned char *pBuffer, int *nSize);
typedef void (*FUNC_WRITE_CALLBACK)(unsigned char *chGroup,unsigned char *pBuffer, int nSize);

typedef void (*FUNC_CBCSELFDATA_CALLBACK)(unsigned char *pBuffer, int nSize, char chIP[16], int nPort,int nType);

typedef int (*FUNC_DEVICE_CALLBACK)(STLANSRESULT_01*);

typedef void (*FUNC_CLANSDATA_CALLBACK)(STLANSRESULT_01 stLSResult);

@interface JVCCloudSEENetworkInterface : NSObject

/****************************************************************************
 *名称  : JVC_InitSDK
 *功能  : 初始化SDK资源，必须被第一个调用
 *参数  : [IN] nLocalStartPort 本地连接使用的起始端口 <0时默认9200
 *返回值: TRUE     成功
 FALSE    失败
 *其他  : 无
 *****************************************************************************/
bool 	JVC_InitSDK(int nLocStartPort,char * path);

/****************************************************************************
 *名称  : JVC_ReleaseSDK
 *功能  : 释放SDK资源，必须最后被调用
 *参数  : 无
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void 	JVC_ReleaseSDK();

/****************************************************************************
 *名称  : JVC_RegisterSCallBack
 *功能  : 设置分控端回调函数
 *参数  : [IN] ConnectCallBack   与主控连接状况回调函数
 *返回值: 无
 *其他  : 分控端回调函数包括：
 与主控端通信状态函数；      (连接状态)
 (收到实时监控数据)
 录像检索结果处理函数；      (收到录像检索结果)
 语音聊天/文本聊天函数       (远程语音和文本聊天)
 远程下载函数；              (远程下载数据)
 远程回放函数；              (远程回放数据)
 *****************************************************************************/
    void 	JVC_RegisterCallBack(FUNC_CCONNECT_CALLBACK ConnectCallBack,
                                 FUNC_CNORMALDATA_CALLBACK NormalData,
                                 FUNC_CCHECKRESULT_CALLBACK CheckResult,
                                 FUNC_CCHATDATA_CALLBACK ChatData,
                                 FUNC_CTEXTDATA_CALLBACK TextData,
                                 FUNC_CDOWNLOAD_CALLBACK DownLoad,
                                 FUNC_CPLAYDATA_CALLBACK PlayData);

/****************************************************************************
 *名称  : JVC_Connect
 *功能  : 连接某通道网络服务
 *参数  : [IN] nLocalChannel 本地通道号 >=1
 [IN] nChannel      服务通道号 >=1
 [IN] pchServerIP   当nYSTNO<0时，该参数指通道服务IP；当nYSTNO>=0时无效.
 [IN] nServerPort   当nYSTNO<0时，该参数指通道服务port；当nYSTNO>=0时无效.
 [IN] pchPassName   用户名
 [IN] pchPassWord   密码
 [IN] nYSTNO        云视通号码，不使用时置-1
 [IN] chGroup       编组号，形如"A" "AAAA" 使用云视通号码时有效
 [IN] bLocalTry     是否进行内网探测
 [IN] nTURNType     转发功能类型(禁用转发\启用转发\仅用转发)
 *返回值: 无
 *其他  : nLocalChannel <= -2 且 nChannel = -1 可连接服务端的特殊通道，
 可避开视频数据，用于收发普通数据
 *****************************************************************************/
//    void 	JVC_Connect(int nLocalChannel,
//                        int nChannel,
//                        char *pchServerIP,
//                        int nServerPort,
//                        char *pchPassName,
//                        char *pchPassWord,
//                        int nYSTNO,
//                        char *chGroup,
//                        BOOL bLocalTry,
//                        int nTURNType,
//                        BOOL bCache);

//    void JVC_Connect(int nLocalChannel,int nChannel,
//                     char *pchServerIP,int nServerPort,
//                     char *pchPassName,char *pchPassWord,
//                     int nYSTNO,char chGroup[4],
//                     BOOL bLocalTry,
//                     int nTURNType,
//                     BOOL bCache,int connectType);

void JVC_Connect(int nLocalChannel,int nChannel,
                 char *pchServerIP,int nServerPort,
                 char *pchPassName,char *pchPassWord,
                 int nYSTNO,char chGroup[4],
                 BOOL bLocalTry,
                 int nTURNType,
                 BOOL bCache,
                 int connectType,
                 BOOL isBeRequestVedio,//是否显示视频  0 不显示  1显示
                 int nVIP,//0 不是vip  1是vip
                 int nOnlyTCP);//默认是0不走tcp； 1:走tcp连接；
//
/****************************************************************************
 *名称  : JVC_DisConnect
 *功能  : 断开某通道服务连接
 *参数  : [IN] nLocalChannel 服务通道号 >=1
 *返回值: 无
 *其他  :
 *****************************************************************************/
void 	JVC_DisConnect(int nLocalChannel);

/****************************************************************************
 *名称  : JVC_SendData
 *功能  : 发送数据
 *参数  : [IN] nLocalChannel   本地通道号 >=1
 [IN] uchType          数据类型：各种请求；各种控制；各种应答
 [IN] pBuffer         待发数据内容
 [IN] nSize           待发数据长度
 *返回值: 无
 *其他  : 向通道连接的主控发送数据
 *****************************************************************************/
void 	JVC_SendData(int nLocalChannel, unsigned char uchType, unsigned char *pBuffer,int nSize);

/****************************************************************************
 *名称  : JVN_EnableLog
 *功能  : 设置写出错日志是否有效
 *参数  : [IN] bEnable  TRUE:出错时写日志；FALSE:不写任何日志
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void 	JVC_EnableLog(bool bEnable);

/****************************************************************************
 *名称  : JVC_SetLanguage
 *功能  : 设置日志/提示信息语言(英文/中文)
 *参数  : [IN] nLgType  JVN_LANGUAGE_ENGLISH/JVN_LANGUAGE_CHINESE
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void 	JVC_SetLanguage(int nLgType);

/****************************************************************************
 *名称  : JVC_TCPConnect
 *功能  : TCP方式连接某通道网络服务
 *参数  : [IN] nLocalChannel 本地通道号 >=1
 [IN] nChannel      服务通道号 >=1
 [IN] pchServerIP   当nYSTNO<0时，该参数指通道服务IP；当nYSTNO>=0时无效.
 [IN] nServerPort   当nYSTNO<0时，该参数指通道服务port；当nYSTNO>=0时无效.
 [IN] pchPassName   用户名
 [IN] pchPassWord   密码
 [IN] nYSTNO        云视通号码，不使用时置-1
 [IN] chGroup       编组号，形如"A" "AAAA" 使用云视通号码时有效
 [IN] bLocalTry     是否进行内网探测
 [IN] nConnectType  连接方式：TYPE_PC_TCP/TYPE_MO_TCP
 [IN] nTURNType     转发功能类型(禁用转发\启用转发\仅用转发)
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void 	JVC_TCPConnect(int nLocalChannel,
                       int nChannel,
                       char *pchServerIP,
                       int nServerPort,
                       char *pchPassName,
                       char *pchPassWord,
                       int nYSTNO,
                       char chGroup[4],
                       BOOL bLocalTry,
                       int nConnectType,
                       int nTURNType);


/****************************************************************************
 *名称  : JVC_GetPartnerInfo
 *功能  : 获取伙伴节点信息
 *参数  : [IN] nLocalChannel   本地通道号 >=1
 [OUT] pMsg   信息内容
 (是否多播(1)+在线总个数(4)+已连接总数(4)+[IP(16) + port(4)+连接状态(1)+下载速度(4)+下载总量(4)+上传总量(4)]
 +[...]...)
 [OUT] nSize  信息总长度
 *返回值: 无
 *其他  : 调用频率严禁太高，否则会影响视频处理速度；
 频繁程度度不能低于1秒，最好在2秒以上或更长时间，时间越长影响越小。
 *****************************************************************************/
//void 	JVC_GetPartnerInfo(int nLocalChannel, char *pMsg, int &nSize);

//    void 	JVC_RegisterRateCallBack(FUNC_CBUFRATE_CALLBACK BufRate);

/****************************************************************************
 *名称  : JVC_StartLANSerchServer
 *功能  : 开启服务可以搜索局域网中维设备
 *参数  : [IN] nLPort      本地服务端口，<0时为默认9400
 [IN] nServerPort 设备端服务端口，<=0时为默认9103,建议统一用默认值与服务端匹配
 [IN] LANSData    搜索结果回调函数
 *返回值: TRUE/FALSE
 *其他  : 开启了搜索服务才可以接收搜索结果，搜索条件通过JVC_LANSerchDevice接口指定
 *****************************************************************************/
bool 	JVC_StartLANSerchServer(int nLPort, int nServerPort, FUNC_CLANSDATA_CALLBACK LANSData);

int JVC_QueryDevice(char* pGroup,int nYST,int nTimeOut,FUNC_DEVICE_CALLBACK callBack);

/****************************************************************************
 *名称  : JVC_StopLANSerchServer
 *功能  : 停止搜索服务
 *参数  : 无
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void 	JVC_StopLANSerchServer();

/****************************************************************************
 *名称  : JVC_LANSerchDevice
 *功能  : 搜索局域网中维设备
 *参数  : [IN] chGroup     编组号，编组号+nYSTNO可确定唯一设备
 [IN] nYSTNO      搜索具有某云视通号码的设备，>0有效
 [IN] nCardType   搜索某型号的设备，>0有效,当nYSTNO>0时该参数无效
 [IN] chDeviceName搜索某个别名的设备，strlen>0有效，当nYSTNO>0时无效
 [IN] nVariety    搜索某个类别的设备，1板卡;2DVR;3IPC;>0有效,当nYSTNO>0时该参数无效
 [IN] nTimeOut    本地搜索有效时间，单位毫秒。超过该时间的结果将被舍弃，
 超时时间到达后回调函数中将得到超时提示作为搜索结束标志。
 如果不想使用SDK超时处理可以置为0，此时结果强全部返回给调用者。
 *返回值: 无
 *其他  : 当两参数同时为0时，将搜索局域网中所有中维设备
 *****************************************************************************/
// bool 	JVC_LANSerchDevice(char chGroup[4], int nYSTNO, int nCardType, int nVariety, char chDeviceName[100], int nTimeOut);
//#ifndef WIN32
//int  JVC_MOLANSerchDevice(char chGroup[4], int nYSTNO, int nCardType, int nVariety, char chDeviceName[100], int nTimeOut,unsigned int unFrequence=30);
//#else
bool JVC_MOLANSerchDevice(char chGroup[4], int nYSTNO, int nCardType, int nVariety, char chDeviceName[100], int nTimeOut,unsigned int unFrequence);

//JVC_MOLANSerchDevice([@"" UTF8String], 0, 0, 0,[@"" UTF8String], kScanDeviceKeepTimeSecond*1000,30);
//#endif
/****************************************************************************
 *名称  : JVC_SetLocalFilePath
 *功能  : 自定义本地文件存储路径，包括日志，生成的其他关键文件等
 *参数  : [IN] chLocalPath  路径 形如："C:\\jovision"  其中jovision是文件夹
 *返回值: 无
 *其他  : 参数使用内存拷贝时请注意初始化，字符串需以'\0'结束
 *****************************************************************************/
bool 	JVC_SetLocalFilePath(char chLocalPath[256]);

/****************************************************************************
 *名称  : JVC_SetDomainName
 *功能  : 设置新的域名，系统将从其获取服务器列表
 *参数  : [IN]  pchDomainName     域名
 [IN]  pchPathName       域名下的文件路径名 形如："/down/YSTOEM/yst0.txt"
 *返回值: TRUE  成功
 FALSE 失败
 *其他  : 系统初始化(JVN_InitSDK)完后设置
 *****************************************************************************/
bool 	JVC_SetDomainName(char *pchDomainName,char *pchPathName);

/****************************************************************************
 *名称  : JVC_WANGetChannelCount
 *功能  : 通过外网获取某个云视通号码所具有的通道总数
 *参数  : [IN]  chGroup   编组号
 [IN]  nYstNO    云视通号码
 [IN]  nTimeOutS 等待超时时间(秒)
 *返回值: >0  成功,通道数
 -1 失败，原因未知
 -2 失败，号码未上线
 -3 失败，主控版本较旧，不支持该查询
 *其他  : 系统初始化(JVN_InitSDK)完后 可独立调用
 *****************************************************************************/
int 	JVC_WANGetChannelCount(char chGroup[4], int nYSTNO, int nTimeOutS);

/****************************************************************************
 *名称  : JVC_StartBroadcastServer
 *功能  : 开启自定义广播服务
 *参数  : [IN] nLPort      本地服务端口，<0时为默认9500
 [IN] nServerPort 设备端服务端口，<=0时为默认9106,建议统一用默认值与服务端匹配
 [IN] BroadcastData  广播结果回调函数
 *返回值: TRUE/FALSE
 *其他  : 开启了广播服务才可以接收广播结果，广播内容通过JVC_BroadcastOnce接口指定；
 端口设置请一定注意和设备搜索相关端口作区别，否则数据将异常；
 *****************************************************************************/
//    bool 	JVC_StartBroadcastServer(int nLPort, int nServerPort, FUNC_CBCDATA_CALLBACK BCData);

/****************************************************************************
 *名称  : JVC_StopBroadcastServer
 *功能  : 停止自定义广播服务
 *参数  : 无
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void 	JVC_StopBroadcastServer();

/****************************************************************************
 *名称  : JVC_BroadcastOnce
 *功能  : 发送广播消息
 *参数  : [IN] nBCID       广播ID,由调用者定义,用于在回调函数中匹配区分本次广播
 [IN] pBuffer     广播净载数据
 [IN] nSize       广播净载数据长度
 [IN] nTimeOut    本次广播有效时间，单位毫秒。超过该时间的结果将被舍弃，
 超时时间到达后回调函数中将得到超时提示作为搜索结束标志。
 如果不想使用SDK超时处理可以置为0，此时结果强全部返回给调用者。
 *返回值: 无
 *其他  : 目前该功能暂不支持并发广播，即并发调用时最后一次广播将覆盖之前的广播；
 *****************************************************************************/
BOOL  JVC_BroadcastOnce(int nBCID, unsigned char *pBuffer, int nSize, int nTimeOut);

/****************************************************************************
 *名称  : JVC_EnableHelp
 *功能  : 启用/停用快速链接服务
 *参数  : [IN] bEnable TRUE开启/FALSE关闭
 [IN] nType  当前使用者是谁，当bEnable为TRUE时有效
 1 当前使用者是云视通小助手(独立进程)
 2 当前使用者是云视通客户端，支持独立进程的小助手
 3 当前使用者是云视通客户端，不支持独立进程的小助手
 *返回值: 无
 *其他  : 启用该功能后，网络SDK会对设定的号码进行连接提速等优化；
 启用该功能后，网络SDK会支持小助手和客户端之间进行交互；
 如果分控端支持小助手进程，则用小助手端使用nType=1，客户端使用nType=2即可；
 如果客户端不支持小助手进程，则客户端使用nType=3即可，比如手机客户端；
 *****************************************************************************/

BOOL JVC_EnableHelp(BOOL bEnable, int nType);


/****************************************************************************
 *名称  : JVC_SetHelpYSTNO
 *功能  : 设置对某些云视通号码的辅助支持
 *参数  : [IN] pBuffer 云视通号码集合，由STBASEYSTNO结构组成；比如有两个号码
 STBASEYSTNO st1,STBASEYSTNO st1;
 pBuffer的内容就是:
 memcpy(bBuffer, &st1, sizeof(STBASEYSTNO));
 memcpy(&bBuffer[sizeof(STBASEYSTNO)], &st2, sizeof(STBASEYSTNO));
 [IN] nSize   pBuffer的实际有效长度；如果是两个号码则为：
 2*sizeof(STBASEYSTNO);
 
 *返回值: 无
 *其他  : 云视通小助手端使用；
 客户端不支持小助手时客户端使用；
 
 添加后，网络SDK会对这些云视通号码进行连接提速等优化；
 这是初始设置，程序运行中客户端也会有些新的号码，
 会动态添加到内部；
 STBASEYSTNOS 云视通号码,STYSTNO定义参看JVNSDKDef.h
 *****************************************************************************/

BOOL JVC_SetHelpYSTNO(unsigned char *pBuffer, int nSize);


/****************************************************************************
 *名称  : JVC_GetHelpYSTNO
 *功能  : 获取当前已知的云视通号码清单
 *参数  : [IN/OUT] pBuffer 由调用者开辟内存；
 返回云视通号码集合，由STBASEYSTNO结构组成；比如有两个号码
 STBASEYSTNO st1,STBASEYSTNO st1;
 pBuffer的内容就是:
 memcpy(bBuffer, &st1, sizeof(STBASEYSTNO));
 memcpy(&bBuffer[sizeof(STBASEYSTNO)], &st2, sizeof(STBASEYSTNO));
 [IN/OUT] nSize   调用时传入的是pBuffer的实际开辟长度，
 调用后返回的是pBuffer的实际有效长度；如果是两个号码则为：
 2*sizeof(STBASEYSTNO);
 *返回值: -1  错误，参数有误，pBuffer为空或是大小不足以存储结果；
 0  服务未开启
 1  成功
 *其他  : 云视通小助手端使用；
 客户端不支持小助手时客户端使用；
 
 这是程序运行中已知的所有号码，即小助手会对这些号码进行连接优化支持；
 该接口仅用于查询，由于内部会自动添加，查询结果不会长期有效；
 STBASEYSTNOS 云视通号码,STYSTNO定义参看JVNSDKDef.h
 *****************************************************************************/

int JVC_GetHelpYSTNO(unsigned char *pBuffer, int *nSize);


/****************************************************************************
 *名称  : JVC_GetYSTStatus
 *功能  : 获取某个云视通号码的在线状态
 *参数  : [IN] chGroup  云视通号码的编组号；
 [IN] nYSTNO   云视通号码
 [IN] nTimeOut 超时时间(秒)，建议>=2秒
 *返回值: -1  错误，参数有误，chGroup为空或是nYSTNO<=0；
 0  本地查询太频繁，稍后重试
 1  号码在线
 2  号码不在线
 3  查询失败，还不能判定号码是否在线
 *其他  : 1.注意，该函数目前仅限用于手机,pc端暂不允许使用；
 2.该函数对同一个号码不允许频繁调用，间隔>=10s;
 3.该函数对不同号码不允许频繁调用，间隔>=1s;
 *****************************************************************************/
int JVC_GetYSTStatus(char chGroup[4], int nYSTNO, int nTimeOut);

/****************************************************************************
 *名称  : JVC_SendCMD
 *功能  : 向主控端发送一些特殊命令
 *参数  : [IN] nLocalChannel   本地通道号 >=1
 [IN] uchType         数据类型
 [IN] pBuffer         待发数据内容
 [IN] nSize           待发数据长度
 *返回值: 0  发送失败
 1  发送成功
 2  对方不支持该命令
 *其他  : 仅对普通模式链接有效；
 当前支持的有:只发关键帧命令JVN_CMD_ONLYI
 和恢复满帧命令JVN_CMD_FULL
 *****************************************************************************/

int JVC_SendCMD(int nLocalChannel, unsigned char uchType, unsigned char *pBuffer, int nSize);

void JVC_RegisterCommonCallBack(FUNC_GETDATA_CALLBACK m_pfReadDataCallBack,
                                FUNC_WRITE_CALLBACK m_pfWriteDataCallBack);
/**
 in: 700   20000
 * return:
 success:1
 *  failed:0
 */
//设置mtu接口
/**
 * success:1
 * failed:0
 */
int JVC_SetMTU(int nMtu);
//暂停小助手接口
/**
 * success:1
 * failed:0
 */
int JVC_StopHelp();


/****************************************************************************
 *名称  : JVC_StartBroadcastSelfServer
 *功能  : 开启自定义广播服务
 *参数  : [IN] nLPort      本地服务端口，<0时为默认9700
 [IN] nServerPort 设备端服务端口，<=0时为默认9108,建议统一用默认值与服务端匹配
 [IN] BCSelfData  自定义广播结果回调函数
 *返回值: TRUE/FALSE
 *其他  :
 *****************************************************************************/
bool JVC_StartBroadcastSelfServer(int nLPort, int nServerPort, FUNC_CBCSELFDATA_CALLBACK BCSelfData);


/****************************************************************************
 *名称  : JVC_StopBroadcastSelfServer
 *功能  : 停止自定义广播服务
 *参数  : 无
 *返回值: 无
 *其他  : 无
 *****************************************************************************/
void JVC_StopBroadcastSelfServer();


/****************************************************************************
 *名称  : JVC_BroadcastSelfOnce
 *功能  : 发送一次广播消息
 *参数  :
 [IN] pBuffer     广播净载数据
 [IN] nSize        广播净载数据长度
 [IN] nTimeOut  此参数目前可置为0
 *返回值: TRUE/FALSE
 *其他  :
 *****************************************************************************/
BOOL JVC_BroadcastSelfOnce(unsigned char *pBuffer, int nSize, int nTimeOut);


/****************************************************************************
 *名称  : JVC_SendSelfDataOnceFromBC
 *功能  : 从自定义广播套接字发送一次UDP消息
 *参数  :
 [IN] pBuffer     净载数据
 [IN] nSize       净载数据长度
 [IN] pchDeviceIP 目的IP地址
 [IN] nLocalPort	  目的端口
 *返回值: 无
 *其他  :
 *****************************************************************************/
BOOL JVC_SendSelfDataOnceFromBC(unsigned char *pBuffer, int nSize, char *pchDeviceIP, int nDestPort);


@end
