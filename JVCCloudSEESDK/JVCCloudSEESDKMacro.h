//
//  Header.h
//  JVCCloudSEESDK
//
//  Created by chenzhenyang on 14-12-31.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#ifndef JVCCloudSEESDK_Header_h
#define JVCCloudSEESDK_Header_h

//连接类型
#define TYPE_3GMO_UDP     5 //连接手机码流
#define TYPE_3GMOHOME_UDP 6 //采用PC身份连接 可以连接和PC一样的码流

#define JVN_REQ_CHECK       0x10//请求录像检索
#define JVN_CMD_PLAYSTOP    0x36//停止播放
#define JVN_CMD_PLAYPAUSE   0x37//暂停播放
#define JVN_CMD_PLAYGOON    0x38//继续播放
#define JVN_REQ_CHAT        0x40//请求语音聊天
#define JVN_CMD_CHATSTOP    0x43//停止语音聊天
#define JVN_REQ_TEXT        0x50//请求文本聊天
#define JVN_CMD_VIDEO       0x70//实时监控
#define JVN_RSP_PLAYOVER    0x32//回放完成

//远程回放检索的字典key
static  NSString  * const KJVCRemotePlayBackChannel  = @"remoteChannel";  //远程回放检索出文件的通道
static  NSString  * const KJVCRemotePlayBackDate     = @"time";           //远程回放检索出文件的日期
static  NSString  * const KJVCRemotePlayBackDisk     = @"disk";           //远程回放检索出文件存放的磁盘
static  NSString  * const KJVCRemotePlayBackType     = @"Type";           //远程回放检索出文件存放的类型（A:报警 M：移动 T:定时 N:手动） 部分设备存在

static  NSString  * const kkeyDeviceNum              = @"LandeviceNum";   //局域网搜索的云视通号
static  NSString  * const kkeyDeviceIP               = @"landeviceIP";    //局域网搜索的IP
static  NSString  * const kkeyDevicePort             = @"port";           //局域网搜索的port

//连接返回的状态信息
enum JVCConnectResult{
    
    JVCConnectResultSucceed               = 1,//连接成功
    JVCConnectResultDisconnect            = 2,//断开连接成功
    JVCConnectResultFailed                = 4,//连接失败
    JVCConnectResultExceptionDisconnected = 6,//连接异常断开
    JVCConnectResultServiceStop           = 7,//服务停止
    JVCConnectResultDisconnectFailed      = 8,//断开连接失败
    JVCConnectResultYstServiceStop        = 9,//云视通服务停止
    JVCConnectResultVerifyFailed          = 10,//身份验证失败
    JVCConnectResultConnectMaxNumber      = 11,//超过连接最大数
    JVCConnectResultNotExistChannel       = 12,//通道不存在
};

//远程操作的类型
enum JVCRemoteOperationType {
    
    JVCRemoteOperationTypeYTO                     = 0, //云台操作
    JVCRemoteOperationTypeVoiceIntercom           = 4, //语音对讲
    JVCRemoteOperationTypeRemotePlaybackSEEK      = 6, //远程回放快进
};

/**
 *  云台操作的枚举类型
 */
enum JVCYTCTRType
{
    JVCYTCTRTypeUp    = 1,  //上
    JVCYTCTRTypeDown  = 2,  //下
    JVCYTCTRTypeLeft  = 3,  //左
    JVCYTCTRTypeRight = 4,  //右
    JVCYTCTRTypeAuto  = 5,  //自动
    JVCYTCTRTypeGQD   = 6,  //光圈大
    JVCYTCTRTypeGQX   = 7,  //光圈小
    JVCYTCTRTypeBJD   = 8,  //变焦大
    JVCYTCTRTypeBJX   = 9,  //变焦小
    JVCYTCTRTypeBBD   = 10, //变倍大
    JVCYTCTRTypeBBX   = 11, //变倍小
    
    
    JVCYTCTRTypeStop  = 20  //上面的命令加上JVCYTCTRTypeStop为该命令的停止命令
};

//远程回放的状态类型
enum JVCRemotePlayBackVideoStateType {
    
    JVCRemotePlayBackVideoStateTypeSucceed = 100, //远程回放成功
    JVCRemotePlayBackVideoStateTypeStop    = 101, //远程回放停止
    JVCRemotePlayBackVideoStateTypeEnd     = 102, //远程回放结束
    JVCRemotePlayBackVideoStateTypeFailed  = 103, //远程回放失败
    JVCRemotePlayBackVideoStateTypeTimeOut = 104, //远程回放超时
};

//语音对讲状态
enum JVCVoiceInterStateType {
    
    JVCVoiceInterStateType_Succeed  = 0,
    JVCVoiceInterStateType_End      = 1,
    
};

//语音对讲请求
enum JVCTextChatType {
    
    JVCTextChatType_Succeed                = 82,
    JVCTextChatType_Stop                   = 83,
    JVCTextChatType_setTalkModel           = 1007,  //设置家用IPC的语音对讲模式
};

//设备设备的对讲模式
enum JVCHomeIPCTalkType {
    
    JVCHomeIPCTalkTypeTalk    = 1, // 1:设备播放声音，不采集声音
    JVCHomeIPCTalkTypeNoTalk  = 0, // 0:设备采集 不播放声音
};

static const  int KJVCMediaColumNUm                = 3;//一行的最大值
static const  NSString *kKYCustomPhotoAlbumName    = @"test_photo";
static const  NSString *kKYCustomVideoAlbumName    = @"test_Video";

/**
 *  图片浏览枚举
 */
enum PHOTOBROWSING{
    
    TYPE_PHOTO   = 0,
    TYPE_VIDEO   = 1,
    TYPE_ANOTHER = 2,
};

enum resultType{
    
    RESULT_ERROR      = 0,
    RESULT_SUCCESSFUL = 1
    
};

enum MATH_TYPE{
    
    MATH_TYPE_PHOTO = 0,
    MATH_TYPE_VIDEO = 1,
};




#endif
