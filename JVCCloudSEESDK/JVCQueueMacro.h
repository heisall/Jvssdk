//
//  JVCQueueMacro.h
//  CloudSEE
//
//  Created by chenzhenyang on 14-9-17.
//  Copyright (c) 2014年 miaofaqiang. All rights reserved.
//

#ifndef CloudSEE_JVCQueueMacro_h
#define CloudSEE_JVCQueueMacro_h

enum OPERATION_TYPE{
    
    OPERATION_TYPE_ERROR = 0,
    OPERATION_TYPE_S     = 1,
    
};

typedef struct frame{
    
    unsigned char * buf;
    int             nSize;
    bool            is_i_frame; //是否是I帧
    bool            is_b_frame; //是否是B帧
    int             nFrameType;
    
}frame;


#endif
