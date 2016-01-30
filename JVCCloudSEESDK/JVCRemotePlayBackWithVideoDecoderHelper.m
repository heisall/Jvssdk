//
//  JVCRemotePlayBackWithVideoDecoderHelper.m
//  CloudSEE_II
//  远程回放的助手类
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCRemotePlayBackWithVideoDecoderHelper.h"
#import "JVCCloudSEENetworkMacro.h"

@implementation JVCRemotePlayBackWithVideoDecoderHelper
@synthesize nPlayBackFrametotalNumber;


char          remotePlaybackCacheBuffer[64*1024] = {0}; //存放远程回放数据原始值

-(void)dealloc {
    
    [super dealloc];
}

/**
 *  根据远程回放检索回调返回的Buffer 获取 远程回放文件列表信息
 *
 *  @param nConnectDevcieType           连接的设备类型
 *  @param remotePlaybackFileBuffer     远程回放检索回调返回的Buffer
 *  @param remotePlaybackFileBufferSize 远程回放检索回调返回的Buffer的大小
 *  @param nRemoteChannel               连接的远程通道
 *
 *  @return 远程回放文件列表信息
 */
-(NSMutableArray *)convertRemoteplaybackSearchFileListInfoByNetworkBuffer:(int)nConnectDevcieType remotePlaybackFileBuffer:(char *)remotePlaybackFileBuffer remotePlaybackFileBufferSize:(int)remotePlaybackFileBufferSize ystGroup:(NSString *) ystGroup nRemoteChannel:(int)nRemoteChannel{
    
    
    NSMutableArray *mArrayRemotePlaybackFileList = [NSMutableArray arrayWithCapacity:10];
    
    if (remotePlaybackFileBufferSize <= 0) {
        
        return mArrayRemotePlaybackFileList;
    }
    
    char *acData  = (char*)malloc(remotePlaybackFileBufferSize);
    memcpy(acData, remotePlaybackFileBuffer, remotePlaybackFileBufferSize);
    
    char acBuff[12] = {0};
    
    switch (nConnectDevcieType) {
            
        case DEVICEMODEL_SoftCard:{
            
            for (int i=0; i<=remotePlaybackFileBufferSize-7; i+=7) {
                
                NSMutableDictionary *mdicAFile = [[NSMutableDictionary alloc] init];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%02d",nRemoteChannel);
                NSString *strRemoteChannel = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteChannel forKey:KJVCYstNetWorkMacroRemotePlayBackChannel];
                [strRemoteChannel release];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%c%c:%c%c:%c%c",acData[i+1],acData[i+2],acData[i+3],acData[i+4],acData[i+5],acData[i+6]);
                NSString *strRemoteDate = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteDate forKey:KJVCYstNetWorkMacroRemotePlayBackDate];
                [strRemoteDate release];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%c",acData[i]);
                NSString *strRemoteDisk = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteDisk forKey:KJVCYstNetWorkMacroRemotePlayBackDisk];
                [strRemoteDisk release];
                
                [mArrayRemotePlaybackFileList  addObject:mdicAFile];
                
                [mdicAFile release];
                
            }
        }
            break;
            
        case DEVICEMODEL_HardwareCard_950:
        case DEVICEMODEL_HardwareCard_951:{
            
            for (int i=0; i<=remotePlaybackFileBufferSize-7; i+=7) {
                
                
                NSMutableDictionary *mdicAFile = [[NSMutableDictionary alloc] init];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%02d",nRemoteChannel);
                NSString *strRemoteChannel = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteChannel forKey:KJVCYstNetWorkMacroRemotePlayBackChannel];
                [strRemoteChannel release];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%c%c:%c%c:%c%c",acData[i+1],acData[i+2],acData[i+3],acData[i+4],acData[i+5],acData[i+6]);
                NSString *strRemoteDate = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteDate forKey:KJVCYstNetWorkMacroRemotePlayBackDate];
                [strRemoteDate release];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%c",acData[i]);
                NSString *strRemoteDisk = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteDisk forKey:KJVCYstNetWorkMacroRemotePlayBackDisk];
                [strRemoteDisk release];
                
                [mArrayRemotePlaybackFileList  addObject:mdicAFile];
                
                [mdicAFile release];
            }
        }
            break;
            
        case DEVICEMODEL_DVR:
        case DEVICEMODEL_IPC:{
            
            int nIndex = 0;
//            普通IPC
            int perUnitSize = 10;
            BOOL isCat = NO;
            [ystGroup retain];
            NSLog(@"group %@",ystGroup);
//            猫眼
            if ([ystGroup isEqualToString:@"C"]||[ystGroup isEqualToString:@"c"]) {
                perUnitSize = 12;
                isCat = YES;
            }
            [ystGroup release];
            memset(remotePlaybackCacheBuffer,0,sizeof(remotePlaybackCacheBuffer));
            
            for (int i = 0; i<=remotePlaybackFileBufferSize-perUnitSize; i+=perUnitSize) {
                
                NSMutableDictionary *mdicAFile = [[NSMutableDictionary alloc] init];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                remotePlaybackCacheBuffer[nIndex++] = acData[i];//录像所在盘
                remotePlaybackCacheBuffer[nIndex++] = acData[i+perUnitSize-3];//录像类型

                
                sprintf(acBuff,"%c%c",acData[i+perUnitSize-2],acData[i+perUnitSize-1]);//通道号
                
                NSString *strRemoteChannel = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteChannel forKey:KJVCYstNetWorkMacroRemotePlayBackChannel];
                [strRemoteChannel release];
                
                memset(acBuff, 0, sizeof(acBuff));
                
                sprintf(acBuff,"%c%c:%c%c:%c%c",acData[i+1],acData[i+2],acData[i+3],acData[i+4],acData[i+5],acData[i+6]);//日
                NSString *strRemoteDate = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteDate forKey:KJVCYstNetWorkMacroRemotePlayBackDate];
                [strRemoteDate release];
                
                memset(acBuff, 0, sizeof(acBuff));
                sprintf(acBuff,"%s%d","disk",(acData[i]-'C')/10+1);//盘符
                if(isCat){
                    sprintf(acBuff,"%s","/mnt/misc/");//盘符
                }
                NSString *strRemoteDisk = [[NSString alloc] initWithUTF8String:acBuff];
                [mdicAFile setValue:strRemoteDisk forKey:KJVCYstNetWorkMacroRemotePlayBackDisk];
                [strRemoteDisk release];
//                如果是猫眼 dict 将会多两个Key
                if (isCat) {
                    
                    memset(acBuff, 0, sizeof(acBuff));
                    
                    sprintf(acBuff,"%c",acData[i+7]);//缩略图
                    NSString *strCatThumb = [[NSString alloc] initWithUTF8String:acBuff];
                    [mdicAFile setValue:strCatThumb forKey:KJVCYstNetWorkMacroRemotePlayBackCatImgType];
                    [strCatThumb release];
                    
                    memset(acBuff, 0, sizeof(acBuff));
                    
                    sprintf(acBuff,"%c",acData[i+8]);//资源类型
                    NSString *strCatType = [[NSString alloc] initWithUTF8String:acBuff];
                    [mdicAFile setValue:strCatType forKey:KJVCYstNetWorkMacroRemotePlayBackCatResType];
                    [strCatType release];
                    
                }
                //远程回放文件的类型
                [mdicAFile setValue:[NSString stringWithFormat:@"%c",acData[i+perUnitSize-3]] forKey:KJVCYstNetWorkMacroRemotePlayBackType];
                
                [mArrayRemotePlaybackFileList  addObject:mdicAFile];
                
                [mdicAFile release];
            }
        }
            break;
        default:
            break;
    }
    
    free(acData);
    
    return mArrayRemotePlaybackFileList;
}

/**
 *  获取请求远程回放的一条命令
 *
 *  @param nConnectDevcieType        连接的设备类型
 *  @param requestPlayBackFileInfo   当前选中的远程回放的远程文件信息
 *  @param requestPlayBackFileDate   远程回放的日期
 *  @param requestPlayBackFileIndex  当前选中的远程文件列表的索引
 *  @param requestOutCommand         输出的发送命令
 */
-(void)getRequestSendPlaybackVideoCommand:(int)nConnectDevcieType requestPlayBackFileInfo:(NSMutableDictionary *)requestPlayBackFileInfo requestPlayBackFileDate:(NSDate *)requestPlayBackFileDate nRequestPlayBackFileIndex:(int)nRequestPlayBackFileIndex requestOutCommand:(char *)requestOutCommand {
    
    [requestPlayBackFileInfo retain];
    [requestPlayBackFileDate retain];
    
    
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
    NSCalendar      *calendar   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:requestPlayBackFileDate];
    
    int year=[comps year];
    int month = [comps month];
    int day = [comps day];
    
    [formatter release];
    [calendar release];
    
    char acBuff[100] = {0};
    char acChn[50]   = {0};
    char acTime[50]  = {0};
    char acDisk[50]  = {0};
    
    sprintf(acChn, "%s",[[requestPlayBackFileInfo valueForKey:KJVCYstNetWorkMacroRemotePlayBackChannel] UTF8String]);
    sprintf(acTime, "%s",[[requestPlayBackFileInfo valueForKey:KJVCYstNetWorkMacroRemotePlayBackDate] UTF8String]);
    
    if ([requestPlayBackFileInfo valueForKey:KJVCYstNetWorkMacroRemotePlayBackDisk] != nil) {
        
        sprintf(acDisk, "%s",[[requestPlayBackFileInfo valueForKey:KJVCYstNetWorkMacroRemotePlayBackDisk] UTF8String]);
    }
    
    switch (nConnectDevcieType) {
            
        case DEVICEMODEL_DVR:
        case DEVICEMODEL_IPC:{
            
            if (self.isExistStartCode) {
                
                sprintf(acBuff, "/progs/rec/%02d/%04d%02d%02d/%c%c%c%c%c%c%c%c%c.mp4",remotePlaybackCacheBuffer[nRequestPlayBackFileIndex*2]-'C',year, month, day,remotePlaybackCacheBuffer[nRequestPlayBackFileIndex*2+1],acChn[0],acChn[1],acTime[0],acTime[1],acTime[3],acTime[4],acTime[6],acTime[7]);
                
            }else{
                
                sprintf(acBuff, "/progs/rec/%02d/%04d%02d%02d/%c%c%c%c%c%c%c%c%c.sv5",remotePlaybackCacheBuffer[2*2]-'C',year, month, day,remotePlaybackCacheBuffer[2*2+1],acChn[0],acChn[1],acTime[0],acTime[1],acTime[3],acTime[4],acTime[6],acTime[7]);
            }
            
        }
            break;
            
        case DEVICEMODEL_SoftCard:{
            
            if (self.isExistStartCode) {
                
                sprintf(acBuff, "%c:\\JdvrFile\\%04d%02d%02d\\%c%c%c%c%c%c%c%c.mp4",acDisk[0],year, month, day,acChn[0],acChn[1],acTime[0],acTime[1],acTime[3],acTime[4],acTime[6],acTime[7]
                        );
                
            }else{
                
                sprintf(acBuff, "%c:\\JdvrFile\\%04d%02d%02d\\%c%c%c%c%c%c%c%c.sv4",acDisk[0],year, month, day,acChn[0],acChn[1],acTime[0],acTime[1],acTime[3],acTime[4],acTime[6],acTime[7]
                        );
            }
            
        }
            break;
        case DEVICEMODEL_HardwareCard_951:
        case DEVICEMODEL_HardwareCard_950:{
            
            if (!self.isExistStartCode) {
                
                sprintf(acBuff, "%c:\\JdvrFile\\%04d%02d%02d\\%c%c%c%c%c%c%c%c.sv6",acDisk[0],year, month, day,acChn[0],acChn[1],acTime[0],acTime[1],acTime[3],acTime[4],acTime[6],acTime[7]
                        );
            }
        }
            break;
            
        default:
            break;
    }
    
    //*requestOutCommand = acBuff;
    
    memcpy(requestOutCommand, acBuff, sizeof(acBuff));
    
    [requestPlayBackFileDate release];
    [requestPlayBackFileInfo release];
}


@end
