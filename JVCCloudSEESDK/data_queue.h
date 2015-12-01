/**
 *
 * DataQueue - 生产者与消费者之间的数据缓存队列
 *
 * @auther: liukp
 *
 **/

#ifndef __DATA_QUEUE_H
#define __DATA_QUEUE_H

#include <queue>
#include <pthread.h>
#include <semaphore.h>
#include <sys/errno.h>
#include <assert.h>

using namespace std;

class DataQueue {
    
public:
    
    DataQueue(char *semName);
	~DataQueue();
    
	/*将数据压入队列*/
	int PushData(void *p_data);
    
	/*从队列中取出数据*/
	void * PopData();

	/*获取队列中的数据数量*/
	int GetQueueDataSize();
    
	/*判断队列是否为空*/
	bool IsQueueEmpty();
    
	/*清空队列*/
	int ClearQueue();
    
	int GetErrno() {
		return merrno_;
	}
	;
	sem_t *GetSemaphore() {
		return dataqueue_sem_;
	}
	;
    
    sem_t *dataqueue_sem_;
    /*
	static DataQueue* GetInstance() {
		if (dq_instance_ == NULL) {
			dq_instance_ = new DataQueue();
		}
		return dq_instance_;
	}
	static void Destroy();
	*/
private:
	///static DataQueue* dq_instance_;

	pthread_mutex_t queue_mutex_;
	pthread_mutexattr_t queue_mutex_attr_;
	queue<void *> d_queue_;
	int max_queue_size_;
	int merrno_;
    char *semName_;
};

#endif/*__DATA_QUEUE_H*/
