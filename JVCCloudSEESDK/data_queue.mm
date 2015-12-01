#include "data_queue.h"
#define APPLE_PLATFORM
///#include "jnierr.h"
///#include "aetimer.h"
/*外部初始化 before invoke main 避免频繁的锁争夺,提高性能*/
///DataQueue* DataQueue::dq_instance_ = new DataQueue();
DataQueue::DataQueue(char *semName) {
	/*define&init the variables*/
	int ret = 0;
	merrno_ = 0;
	max_queue_size_ = 1024;
    
	/*init the queue_mutex*/
	ret = pthread_mutex_init(&queue_mutex_, NULL);

	if (ret != 0) {
        
        printf("%s:pthread_mutex_init error:%s(%d) at %s, line %d.", __func__, strerror(errno), ret, __FILE__, __LINE__);
		//exit(1);
        return;
	}

#ifdef APPLE_PLATFORM
    dataqueue_sem_ = sem_open(semName, O_CREAT, 0644, 0 );
    
    semName_ = (char *)malloc(strlen(semName)+1);
    strcpy(semName_, semName);
    
    //
    if( dataqueue_sem_ == SEM_FAILED )
    {
        switch( errno )
        {
            case EEXIST:
                printf( "Semaphore with name '%s' already exists.\n", "inName" );
                break;
                
            default:
                printf( "Unhandled error: %d.\n", errno );
                break;
        }
        
        //
//        assert(false);
        return;
    }
#else
    ret = sem_init(dataqueue_sem_, 0, 0);
#endif
    ///g_dqueue_size = 0;
}

int DataQueue::PushData(void *p_data) {
    
	int ret = 0;
    
	pthread_mutex_lock(&queue_mutex_);

	do {
        
		if (d_queue_.size() > max_queue_size_ - 1) {
			//ret = DQUEUE_ERR_VOERFLOW;
			//merrno_ = ret;
			ret = -1;
			///LOGW(\
					"%s:the queue size is to the max %d, at %s, line %d.", __func__, ret, __FILE__, __LINE__);
			break;
		}

		d_queue_.push(p_data);
        
	} while (0);

	pthread_mutex_unlock(&queue_mutex_);

	return ret;
}

void * DataQueue::PopData() {
    
    sem_wait(dataqueue_sem_);
    
	void *p_data = NULL;
    
	pthread_mutex_lock(&queue_mutex_);
	if (!d_queue_.empty()) {
        
		p_data = d_queue_.front();
		d_queue_.pop();
	}
	pthread_mutex_unlock(&queue_mutex_);

	return p_data;
}

int DataQueue::GetQueueDataSize() {
    
	int dsize = 0;
    
	pthread_mutex_lock(&queue_mutex_);
	dsize = d_queue_.size();
	pthread_mutex_unlock(&queue_mutex_);
    
	return dsize;
}

int DataQueue::ClearQueue() {
    
	pthread_mutex_lock(&queue_mutex_);
    
    int dsize = d_queue_.size();

	while (dsize > 0) {
        
		void *p = d_queue_.front();
		free(p);
		p = NULL;
		d_queue_.pop();
		dsize--;
	}
    
	pthread_mutex_unlock(&queue_mutex_);

	return 0;
}

bool DataQueue::IsQueueEmpty(){
    
    pthread_mutex_lock(&queue_mutex_);
    bool bres = d_queue_.empty();
    pthread_mutex_unlock(&queue_mutex_);

    return bres;
}

DataQueue::~DataQueue() {
    
	ClearQueue();
    pthread_mutex_destroy(&queue_mutex_);
#ifdef APPLE_PLATFORM
    sem_close(dataqueue_sem_);
    sem_unlink(semName_);
    free(semName_);
#else
	if (sem_destroy(dataqueue_sem_) != 0) {
		///LOGE\
				"sem_destroy error:%s(%d), at %s, line %d.", strerror(errno), errno, __FILE__, __LINE__);
	}
#endif

}

