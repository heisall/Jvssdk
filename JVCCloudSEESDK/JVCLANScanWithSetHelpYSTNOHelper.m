//
//  JVCLANScanWithSetHelpYSTNOHelper.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-10-13.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCLANScanWithSetHelpYSTNOHelper.h"
#import "JVCCloudSEENetworkInterface.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVCDeviceMacro.h"
#import "JVCCloudSEENetworkGeneralHelper.h"

@interface JVCLANScanWithSetHelpYSTNOHelper (){

    __block BOOL isScanfing;  //YES:正在搜索 NO:已结束
}

#define MAX_PATH_01 256

typedef struct STBASEYSTNO
{
    char chGroup[4];
    int  nYSTNO;
    int  nChannel;
    char chPName[MAX_PATH_01];
    char chPWord[MAX_PATH_01];
    int  nConnectStatus;
    
}STBASEYSTNO; //云视通号码基本信息，用于初始化小助手的虚连接

@end
@implementation JVCLANScanWithSetHelpYSTNOHelper
@synthesize delegate;

static JVCLANScanWithSetHelpYSTNOHelper *jvcLANScanWithSetHelpYSTNOHelper = nil;
static const int kScanLocalServerPort                   = 9400; //默认9400
static const int kScanDeviceServerPort                  = 6666;
static const int kScanDeviceKeepTimeSecond              = 1;
static const int kQueryLanDeviceChannelCountSleepTime   = 40;

NSMutableArray *CacheMArrayDeviceList;
NSMutableArray *queryMArrayDeviceList;

-(void)dealloc {

    [queryMArrayDeviceList release];
    [CacheMArrayDeviceList release];
    [super dealloc];
}

/**
 *  获取云视通网络库广播和设置设备小助手的助手类
 *
 *  @return 云视通网络库逻辑类
 */
+(JVCLANScanWithSetHelpYSTNOHelper *)sharedJVCLANScanWithSetHelpYSTNOHelper;
{
    
    @synchronized(self){
        
        if (jvcLANScanWithSetHelpYSTNOHelper == nil) {
            
            jvcLANScanWithSetHelpYSTNOHelper = [[self alloc] init];
            
            CacheMArrayDeviceList = [[NSMutableArray alloc] initWithCapacity:10];
            queryMArrayDeviceList = [[NSMutableArray alloc] initWithCapacity:10];
            JVC_StartLANSerchServer(kScanLocalServerPort, kScanDeviceServerPort,SerachLANAllDeviceInfo);
            
            return jvcLANScanWithSetHelpYSTNOHelper;
        }
    }
    
    return jvcLANScanWithSetHelpYSTNOHelper;
}

/**
 *  模式重写对象创建方法
 *
 *  @param zone 任何默认对内存的操作都是在Zone上进行的，确保只能创建一次
 *
 *  @return 单利对象
 */
+(id)allocWithZone:(struct _NSZone *)zone{
    
    @synchronized(self){
        
        if (jvcLANScanWithSetHelpYSTNOHelper == nil) {
            
            jvcLANScanWithSetHelpYSTNOHelper = [super allocWithZone:zone];
            
            return jvcLANScanWithSetHelpYSTNOHelper;
        }
    }
    
    return nil;
}

#pragma mark --------------------------------------局域网广播搜索设备方法

void SerachLANAllDeviceInfo(STLANSRESULT_01 stlanResultData) {
    
//    NSLog(@"=====00000===========%s=====",__FUNCTION__);
    
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    if (stlanResultData.nYSTNO>0) {
        
        NSMutableString *strYstNumber=[[NSMutableString alloc] initWithCapacity:10];
        
        [strYstNumber appendFormat:@"%s",stlanResultData.chGroup];
        
        if ([strYstNumber isEqualToString:@""]|| [strYstNumber isEqualToString:nil]) {
            
            [strYstNumber appendFormat:@"A%d",stlanResultData.nYSTNO];
            
        }else{
            
            [strYstNumber appendFormat:@"%d",stlanResultData.nYSTNO];
            
        }
        
        for (JVCLanScanDeviceModel *LanModel in CacheMArrayDeviceList) {
            
            if ([[LanModel.dguid uppercaseString] isEqualToString:strYstNumber]) {
                
                [strYstNumber release];
                [pool release];
                return;
            }
        }
        
        int _isNetWork=(stlanResultData.nNetMod & 0x01);
        int _isUserWIfi=stlanResultData.nCurMod ;
        
        JVCLanScanDeviceModel *lanModel=[[JVCLanScanDeviceModel alloc] init];
        
        lanModel.dguid          =strYstNumber;
        lanModel.dvip           =[NSString stringWithFormat:@"%s",stlanResultData.chClientIP];
        lanModel.dvport         =[[NSString stringWithFormat:@"%d",stlanResultData.nClientPort] intValue];
        lanModel.strDeviceName  =[NSString stringWithFormat:@"%s",stlanResultData.chDeviceName];
        lanModel.iDeviceVariety =stlanResultData.nVariety;
        lanModel.dcs            =stlanResultData.nChannelCount;
        lanModel.dvlt           = CONNECTTYPE_IP;
        if (_isUserWIfi==1) {
            
            lanModel.iCurMod=YES;
        }
        
        if (_isNetWork) {
            
            lanModel.dwifi=YES;
        }
        
        [CacheMArrayDeviceList addObject:lanModel];
        [queryMArrayDeviceList addObject:lanModel];
        
        
        [strYstNumber release];
        [lanModel release];
        
    }
    
//    NSLog(@"=====111===========%s=====",__FUNCTION__);

    if (stlanResultData.bTimoOut) {
        
        [jvcLANScanWithSetHelpYSTNOHelper performSelectorOnMainThread:@selector(sendCallBack) withObject:nil waitUntilDone:NO];
    }
    [pool release];
}

/**
 *  局域网广播设备接口（本网段）
 *
 *  @param stlanResultData 返回的结构体
 */
void JVCLANScanWithSetHelpYSTNOHelperQueryDevce(STLANSRESULT_01 *stlanResultData){

//    NSLog(@"=0001=%s=====",__FUNCTION__);
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    
    if (stlanResultData->nYSTNO>0) {
        
        NSMutableString *strYstNumber=[[NSMutableString alloc] initWithCapacity:10];
        
        [strYstNumber appendFormat:@"%s",stlanResultData->chGroup];
        
        if ([strYstNumber isEqualToString:@""]|| [strYstNumber isEqualToString:nil]) {
            
            [strYstNumber appendFormat:@"A%d",stlanResultData->nYSTNO];
            
        }else{
            
            [strYstNumber appendFormat:@"%d",stlanResultData->nYSTNO];
            
        }
        
        for (JVCLanScanDeviceModel *LanModel in CacheMArrayDeviceList) {
            
            if ([[LanModel.dguid uppercaseString] isEqualToString:strYstNumber]) {
                
                [strYstNumber release];
                [pool release];
                return;
            }
        }
        
        int _isNetWork=(stlanResultData->nNetMod & 0x01);
        int _isUserWIfi=stlanResultData->nCurMod ;
        
        JVCLanScanDeviceModel *lanModel=[[JVCLanScanDeviceModel alloc] init];
        
        lanModel.dguid   = strYstNumber;
        lanModel.dvip    = [NSString stringWithFormat:@"%s",stlanResultData->chClientIP];
        lanModel.dvport  = [[NSString stringWithFormat:@"%d",stlanResultData->nClientPort] intValue];
        lanModel.strDeviceName  = [NSString stringWithFormat:@"%s",stlanResultData->chDeviceName];
        lanModel.iDeviceVariety = stlanResultData->nVariety;
        lanModel.dcs=stlanResultData->nChannelCount;
        lanModel.dvlt           = CONNECTTYPE_IP;
        
        if (stlanResultData->nPrivateSize>0) {
            JVCCloudSEENetworkGeneralHelper *ystNetworkHelperCMObj = [JVCCloudSEENetworkGeneralHelper shareJVCCloudSEENetworkGeneralHelper];
            NSMutableDictionary *params = [ystNetworkHelperCMObj convertpBufferToMDictionary:stlanResultData->chPrivateInfo];
            if (params.count>0) {
                if (params[@"timer_count"]!=nil&&[params[@"timer_count"] intValue]>0) {
                    lanModel.timer_count=1;
                }else{
                    lanModel.timer_count=-1;
                }
            }else{
                lanModel.timer_count=-1;
            }
        }

        
        if (_isUserWIfi==1) {
            
            lanModel.iCurMod=YES;
        }
        
        if (_isNetWork) {
            
            lanModel.dwifi=YES;
        }
        
        [CacheMArrayDeviceList addObject:lanModel];
        
//          NSLog(@"%s--------endLanserach#########53=%@--------",__FUNCTION__,strYstNumber);
        
        [strYstNumber release];
        [lanModel release];
        
    }
    
//    NSLog(@"%s--------1111p2p2p2p1--------",__FUNCTION__);

    if (stlanResultData->bTimoOut) {
        
//        NSLog(@"%s--------endLanserach--------",__FUNCTION__);
        [jvcLANScanWithSetHelpYSTNOHelper performSelectorOnMainThread:@selector(sendCallBack) withObject:nil waitUntilDone:NO];
    }
    [pool release];
}

/**
 *  返回广播获取的设备集合
 */
-(void)sendCallBack{
    
//    NSLog(@"====%s-------calldelegate-001------",__FUNCTION__);

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(SerachLANAllDevicesAsynchronousRequestWithDeviceListDataCallBack:)]) {
        
//        NSLog(@"%s-------calldelegate--002-----",__FUNCTION__);

        [self.delegate SerachLANAllDevicesAsynchronousRequestWithDeviceListDataCallBack:CacheMArrayDeviceList];
    }
    
     isScanfing = FALSE;
}

/**
 *  搜索局域网设备的函数（本局域网）
 */
-(void)SerachLANAllDevicesAsynchronousRequestWithDeviceListData{
    
//    NSLog(@"=====11111000000===========%s=====",__FUNCTION__);

    if (!isScanfing) {
//        NSLog(@"=====222222000000===========%s=====",__FUNCTION__);

        [CacheMArrayDeviceList removeAllObjects];
        
        isScanfing = TRUE;
        
        JVC_MOLANSerchDevice([@"" UTF8String], 0, 0, 0,[@"" UTF8String], kScanDeviceKeepTimeSecond*1000,30);
        
    }
}

/**
 *  查询局域网设备的通道数，根据广播获取
 *
 *  @param strYstNumber 云视通号
 *
 *  @return 设备的通道数 大于0 有效 <子线程调用>
 */
-(int)queryLanDeviceChannelCount:(NSString *)strYstNumber{
    
    [strYstNumber retain];
    
    int nChannelCount = 0;
    [queryMArrayDeviceList removeAllObjects];
    
   [self SerachLANAllDevicesAsynchronousRequestWithDeviceListData];
    
    while (TRUE) {
        
        if (isScanfing) {
            
            usleep(kQueryLanDeviceChannelCountSleepTime);
        
            
        }else{
        
            break;
        }
    }
    
    for (JVCLanScanDeviceModel *model  in queryMArrayDeviceList) {
    
        if ([model.dguid.uppercaseString isEqualToString:strYstNumber]) {
            
            nChannelCount = model.dcs;
        }
    }
    
    [strYstNumber release];
    
    return nChannelCount;
    
}

/**
 *  搜索局域网设备的函数(本网段)
 */
-(void)SerachAllDevicesAsynchronousRequestWithDeviceListData{
    
    [CacheMArrayDeviceList removeAllObjects];
    
    JVC_QueryDevice("",0,1000, JVCLANScanWithSetHelpYSTNOHelperQueryDevce);
}

/**
 *  设置小助手
 *
 *  @param devicesMArray devicesMArray
 */
-(void)setDevicesHelper:(NSArray *)devicesMArray{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [devicesMArray retain];
        
        unsigned char bBuffer[([devicesMArray count])*sizeof(STBASEYSTNO)];
        
        for (int i=0; i<devicesMArray.count; i++) {
            
            JVCLocalCacheModel *model=[devicesMArray objectAtIndex:i];
            
            int kk;
            
            for (kk=0; kk<model.strYstNumber.length; kk++) {
                
                unsigned char c=[model.strYstNumber characterAtIndex:kk];
                
                if (c<='9' && c>='0') {
                    
                    break;
                }
            }
            
            NSString *sGroup=[model.strYstNumber substringToIndex:kk];
            NSString *iYstNum=[model.strYstNumber substringFromIndex:kk];
            STBASEYSTNO stinfo;
            
            if ([sGroup isEqualToString:NULL]||[sGroup isEqualToString:nil]||[iYstNum intValue]<=0) {
                
                return;
            }
            
            memset(stinfo.chGroup, 0, 4);
            memcpy(stinfo.chGroup, [sGroup UTF8String], strlen([sGroup UTF8String]));
            
            stinfo.nYSTNO         = [iYstNum intValue];
            stinfo.nChannel       =1 ;
            stinfo.nConnectStatus = 0;
            
            memset(stinfo.chPName, 0, MAX_PATH_01);
            memcpy(stinfo.chPName, [model.strUserName UTF8String], strlen([model.strUserName UTF8String]));
            
            memset(stinfo.chPWord, 0, MAX_PATH_01);
            memcpy(stinfo.chPWord, [model.strPassWord UTF8String], strlen([model.strPassWord UTF8String]));
            
            if (i==0) {
                
                memcpy(bBuffer, &stinfo, sizeof(STBASEYSTNO));
                
            }else{
                
                memcpy(&bBuffer[i*sizeof(STBASEYSTNO)], &stinfo, sizeof(STBASEYSTNO));
            }
        }
        
        JVC_SetHelpYSTNO((unsigned char *)bBuffer,devicesMArray.count*sizeof(STBASEYSTNO));
        
        [devicesMArray release];
        
    });
}

@end
