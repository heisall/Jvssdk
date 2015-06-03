//
//  JVCCloudSEENetworkMacro.h
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#ifndef CloudSEE_II_JVCCloudSEENetworkMacro_h
#define CloudSEE_II_JVCCloudSEENetworkMacro_h

static const int kJVCCloudSEENetworkHelperWithConnectMaxNumber = 16; //支持的连接路数

enum CONNECTRESULTTYPE{
    
    CONNECTRESULTTYPE_Succeed                        = 1,  //连接成功
    CONNECTRESULTTYPE_Disconnect                     = 2,  //断开连接成功
    CONNECTRESULTTYPE_RepeatConnect                  = 3,  //重复的连接
    CONNECTRESULTTYPE_ConnectFailed                  = 4,  //连接失败
    CONNECTRESULTTYPE_NoConnection                   = 5,  //没有连接
    CONNECTRESULTTYPE_AbnormalConnectionDisconnected = 6,  //连接异常断开
    CONNECTRESULTTYPE_ServiceStop                    = 7,  //服务停止
    CONNECTRESULTTYPE_DisconnectFailed               = 8,  //断开连接失败
    CONNECTRESULTTYPE_YstServiceStop                 = 9,  //云视通服务停止
    CONNECTRESULTTYPE_VerifyFailed                   = 10, //身份验证失败
    CONNECTRESULTTYPE_ConnectMaxNumber               = 11, //超过连接最大数
    CONNECTRESULTTYPE_ChannelIsNotOpen               = 12, //通道不存在
    
};


enum RemoteOperationType {
    
    RemoteOperationType_YTO                     = 0, //云台操作
    RemoteOperationType_CaptureImage            = 1, //抓拍
    RemoteOperationType_LocalVideo              = 2, //本地录像
    RemoteOperationType_AudioListening          = 3, //音频监听
    RemoteOperationType_VoiceIntercom           = 4, //语音对讲
    RemoteOperationType_RemotePlaybackSearch    = 5, //语音对讲
    RemoteOperationType_RemotePlaybackSEEK      = 6, //远程回放快进
    RemoteOperationType_TextChat                = 7, //文本聊天
    RemoteOperationType_SceneCapture            = 8, //场景图抓拍
};

enum DEVICEMODEL{
    
    DEVICEMODEL_SoftCard          = 0,         //软压缩卡
    DEVICEMODEL_DVR               = 1,         //DVR
    DEVICEMODEL_HardwareCard_950  = 2,         //硬压缩卡 950
    DEVICEMODEL_HardwareCard_951  = 3,         //硬压缩卡 951
    DEVICEMODEL_IPC               = 4,         //IPC
    MP4_AUDIO_DECODER_SAMR        = 5,         //MP4音频 samr
    MP4_AUDIO_DECODER_ALAW        = 6,         //MP4音频 alaw
    MP4_AUDIO_DECODER_ULAW        = 7          //MP4音频 ulaw
    
};

enum AudioType {
    
    AudioType_PCM   = 0, // 8bit  320
    AudioType_G711  = 1, // 16bit 640
    AudioType_AMR   = 2, // 16bit 960
};

enum AudioSize {
    
    AudioSize_PCM   = 320, // 8bit  320
    AudioSize_G711  = 640, // 16bit 640
    AudioSize_AMR   = 960, // 16bit 960
};

enum AudioBit {
    
    AudioBit_PCM   = 8, // 8bit  320
    AudioBit_G711  = 16, // 16bit 640
    AudioBit_AMR   = 16, // 16bit 960
};

enum VoiceInterStateType {
    
    VoiceInterStateType_Succeed  = 0,
    VoiceInterStateType_End      = 1,
    
};

enum RemotePlayBackVideoStateType {
    
    RemotePlayBackVideoStateType_Succeed = 100, //远程回放成功
    RemotePlayBackVideoStateType_Stop    = 101, //远程回放停止
    RemotePlayBackVideoStateType_End     = 102, //远程回放结束
    RemotePlayBackVideoStateType_Failed  = 103, //远程回放失败
    RemotePlayBackVideoStateType_TimeOut = 104, //远程回放超时
};

static  NSString  *  const KJVCYstNetWorkMacroRemotePlayBackChannel  = @"remoteChannel";  //远程回放检索出文件的通道
static  NSString  *  const KJVCYstNetWorkMacroRemotePlayBackDate     = @"time";           //远程回放检索出文件的日期
static  NSString  *  const KJVCYstNetWorkMacroRemotePlayBackDisk     = @"disk";           //远程回放检索出文件存放的磁盘
static  NSString  *  const KJVCYstNetWorkMacroRemotePlayBackType     = @"Type";           //远程回放检索出文件存放的类型（A:报警 M：移动 T:定时 N:手动）

#define REQUESTTIMEOUTSECOND  0.5

#define AP_WIFI_USERNAME @"wifiUserName"
#define AP_WIFI_PASSWORD @"wifiPassWord"
#define AP_WIFI_QUALITY  @"wifiQuality"
#define AP_WIFI_KEYSTAT  @"wifiKeyStat"
#define AP_WIFI_IESTAT   @"wifiIestat"
#define AP_WIFI_ENC      @"wifiEnc"
#define AP_WIFI_AUTH     @"wifiAuth"


enum TextChatType {
    
    TextChatType_Succeed                = 82,
    TextChatType_Stop                   = 83,
    TextChatType_paraInfo               = 1002,  //码流参数信息
    TextChatType_ApList                 = 1003,  //AP热点
    TextChatType_ApSetResult            = 1004,  //配置AP的返回值
    TextChatType_NetWorkInfo            = 1005,  //网络参数信息
    TextChatType_setStream              = 1006,  //设置码流信息
    TextChatType_setTalkModel           = 1007,  //设置家用IPC的语音对讲模式
    TextChatType_setAlarmType           = 1008,
    TextChatType_getAlarmType           = 1009,
    TextChatType_deleteAlarm            = 1010,
    TextChatType_editAlarm              = 1011,
    TextChatType_EffectInfo             = 1012,  //码流参数信息
    TextChatType_StorageMode            = 1013,  //设置录像模式
    TextChatType_setOldStream           = 1014,  //设置老设备码流信息
    TextChatType_setAlarm               = 1015,  //设置安全防护按钮的 （0：关 1：开）
    TextChatType_setMobileMonitoring    = 1016,  //设置移动侦测      （0：关 1：开）
    TextChatType_setOldMainStream       = 1017,  //设置老设备主码流的画质
    
    //惠通的设备
    TextChatType_setDeviceTimezone      = 1018,  //设置设备的时区
    TextChatType_setDevicePNMode        = 1019,  //设置设备的P/N制式切换
    TextChatType_setDeviceFlashMode     = 1020,  //设置设备的闪光灯
    TextChatType_setDeviceAPMode        = 1021,  //设置设备AP/STA（WIFI模块工作方式)
    TextChatType_Capture                = 1022,  //惠通设备抓拍
    
};

enum NetWorkType {
    
    NetWorkType_Wired    = 0,
    NetWorkType_WiFi     = 2,
};

enum JVCCloudSEENetworkMacroOldHomeIPCStreamParam{
    
    JVCCloudSEENetworkMacroOldHomeIPCStreamType720PWidth      = 1280,
    JVCCloudSEENetworkMacroOldHomeIPCStreamType720PHeight     = 720,
    JVCCloudSEENetworkMacroOldHomeIPCStreamType720PFramerate  = 15,
    JVCCloudSEENetworkMacroOldHomeIPCStreamType720MBPH        = 800,
    
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFWidth       = 352,
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFHeight      = 288,
     JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIFFramerate  = 25,
    
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1CheckWidth = 624,
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Width      = 720,
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Height     = 480,
    
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1Framerate  = 20,
   
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeMBPH         = 512,
    
};

enum JVCCloudSEENetworkMacroOldHomeIPCStreamType{
    
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeUnknown = -1,
    JVCCloudSEENetworkMacroOldHomeIPCStreamType720P    = 1,
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeD1      = 2,
    JVCCloudSEENetworkMacroOldHomeIPCStreamTypeCIF     = 3,
};


#define MOBILECHSECOND          2
#define MOBILECHDEFAULT         3
#define MOBILECHFRAMEBEGIN      @"[CH"
#define MOBILECHFRAMEEND        @"];"


typedef struct AudioFrame//音频数据结构
{
    int	iIndex;//音频数据序号
    char cb[12];//音频数据？
    
} AudioFrame;


static NSString const *kDeviceFrameFlagKey        =  @"MobileStreamQos";  // 1:高清 2：标清 3：流畅 0:默认不支持切换码流
static NSString const *kDeviceOldFrameFlagKey     =  @"MainStreamQos";    // 1:高清 2：标清 3：流畅 0:默认不支持切换码流(老板本)
static NSString const *kDeviceMobileFrameFlagKey  =  @"MobileQuality";    // 1:高清 2：标清 3：流畅 0:默认不支持切换码流
static NSString const *kDeviceTalkModelFlagKey    =  @"talkSwitch";       // 0:设备采集 不播放声音 1:设备播放声音，不采集声音

static NSString const *kDeviceAlarmType           =  @"type";             // 1:门磁  2手环
static NSString const *KEFFECTFLAG                =  @"effect_flag";      //图像翻转的
static NSString const *KStorageMode               =  @"storageMode";      //设置录像的模式
static NSString const *kDeviceMotionDetecting     =  @"bMDEnable";        //移动侦测
static NSString const *kDeviceAlarm               =  @"bAlarmEnable";     //安全防护
static NSString const *kDeviceAlarmTime0          =  @"alarmTime0";       //安全防护时间段
static NSString const *kDeviceAlarmStart          =  @"dayStart";         //开始时间
static NSString const *kDeviceAlarmEnd            =  @"dayEnd";           //结束时间
static NSString const *kDeviceModify              =  @"DeviceModify";     //修改设备用户名密码

//惠通设备的相应键值
static NSString const *kDevicePNMode              =  @"PNMode";           //制式切换
static NSString const *kDeviceFlashMode           =  @"FlashMode";        //闪光灯切换
static NSString const *kDeviceTimezone            =  @"timezone";         //设置时区
static NSString const *kDeviceApModeOn            =  @"apModeOn";         //设置AP和STA


static NSString const *KOldHomeIPCHeight          =  @"height";           //高
static NSString const *KOldHomeIPCWidth           =  @"width";            //宽

/**
 设备的画面制式
 */
enum JVCCloudSEENetworkDevicePNModeType {

    JVCCloudSEENetworkDevicePNModeTypeP = 0, //P制式
    JVCCloudSEENetworkDevicePNModeTypeN = 1, //N
};

/**
 设备的闪光灯模式
 */
enum JVCCloudSEENetworkDeviceFlashMode{
    
    JVCCloudSEENetworkDeviceFlashModeAuto  = 0,  //自动
    JVCCloudSEENetworkDeviceFlashModeOpen  = 1,  //打开
    JVCCloudSEENetworkDeviceFlashModeClose = 2   //关闭
};

typedef NS_ENUM(int, JVCOEMCellType)
{
    JVCOEMCellType_SAFE             =   0,//设备防护
    JVCOEMCellType_PNMode           =   2,//pn制
    JVCOEMCellType_FlashModel       =   3,//闪光灯
    JVCOEMCellType_TimerZone        =   4,//时区
    JVCOEMCellType_Modify           =   1,//修改设备用户名密码

};

/**
 设备WIFI工作方式
 */
enum JVCCloudSEENetworkDeviceAPMode{
    
    JVCCloudSEENetworkDeviceAPModeSta = 0,  //STA模式
    JVCCloudSEENetworkDeviceAPModeAP  = 1,  //AP模式
};


enum JVCCloudSEENetworkCaptureImageType {
    
    JVCCloudSEENetworkCaptureImageTypeWithCapture = 0, //抓拍
    JVCCloudSEENetworkCaptureImageTypeWithScene   = 1, //场景图
};


static NSString const *kConnectDefaultUsername       = @"jwifiApuser";
static NSString const *kConnectDefaultPassword       = @"^!^@#&1a**U";
static NSString const *kConnectDefaultIP             = @"10.10.0.1";
static const  int      kConnectDefaultPort           = 9101;

enum CONNECTTYPE{
    
    CONNECTTYPE_YST=0,
    CONNECTTYPE_IP=1,
    CONNECTTYPE_Stream=2,
    
};

typedef NS_ENUM(int , VoiceType) {

    VoiceType_Speaker =0,//扬声器
    VoiceType_Liseten =1,//听筒

};

#endif
