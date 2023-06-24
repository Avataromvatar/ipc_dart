#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>

#include "pipe.h"



//Битовые дефайны
#define BIT(bit_no) (1<<(bit_no))
#define BIT_CLEAR(var,bit_no) (var) &= ~(BIT(bit_no))
#define BIT_SET(var,bit_no) ((var)|=(BIT(bit_no)))
#define BIT_GET(var,bit_no) ((var) & (BIT(bit_no)))
#define BIT_SWITCH(var,bit_no) (var) ^= (BIT(bit_no))
#define BIT_BOOL_GET(var,bit_no) (((var) & (BIT(bit_no)))?1:0)




#define IPC_FOR_WRITE 0x01
#define IPC_FOR_READ 0x02
#define IPC_FOR_READ_AND_WRITE 0x03
#define IPC_NON_BLOCK 0x04
#define IPC_CREATE 0x08



struct sIPCPipe
{
    int fd;
    int id;
    char *path;
    int flagsOpen;
    int flagsOrigin;
};
int _libFlagToSys(int flags)
{
    int ret = 0;
    if (flags & IPC_FOR_READ_AND_WRITE)
    {
        ret |= O_RDWR;
    }
    else if (flags & IPC_FOR_WRITE)
    {
        ret |= O_WRONLY;
    }
    else if (flags & IPC_FOR_READ)
    {
        ret |= O_RDONLY;
    }
    if (flags & IPC_CREATE)
    {
        ret |= O_CREAT;
    }
    if (flags & IPC_NON_BLOCK)
    {
        ret |= O_NONBLOCK;
    }
}
/// @brief This is inner func what create fifo
/// @param path 
/// @return 0 if ok and errno if not
int _createNamedPipe(char *path)
{
    /*Создаем FIFO*/
    /*https://www.opennet.ru/man.shtml?topic=mkfifo&category=3&russian=0
    EACCES
(один из каталогов в pathname не разрешает доступ на поиск или выполнение);
EEXIST
(pathname уже существует);
ENAMETOOLONG
(либо общая длина pathname больше, чем PATH_MAX, либо компонент "имя файла" имеет большую по сравнению с NAME_MAX длину. В системе GNU не существует предела общей длины имени файла, но некоторые файловые системы могут установить пределы длины данных компонентов.);
ENOENT
(компонента каталога pathname не существует или он является "разорванной" символьной ссылкой);
ENOSPC
(в каталоге или файловой системе недостаточно места для нового файла);
ENOTDIR
(компонент, указанный как каталог в pathname, фактически не является каталогом);
EROFS
(pathname обращается к файловой системе, доступной только для чтения).
*/
    int err = mkfifo(path, O_RDWR);
    if (err == -1)
    {

        fprintf(stderr, "Error mkfifo Path:%s Flags:%d Error:%d\n", path, O_RDWR, errno);
        return errno;
    }
    return 0;
}
/// @brief This inner function what open file
/// @param path 
/// @param flags sys flags
/// @return file discriptor (int>0) if ok and -errno if not
int _openPipe(char *path, int flags)
{
    int mode=flags;
    mode &=~O_CREAT;
    
    int fd = open(path,mode);
    if(fd<=0)
    {
        if(errno == ENOENT && flags&O_CREAT==O_CREAT)
        {
           int err =  _createNamedPipe(path);
           if(err==0)
           {
                return _openPipe(path,mode);
           }
           return -1;
        }
        fprintf(stderr, "Error open  pipe Path:%s Flags:%d Error:%d\n", path, flags, errno);
        return -1;
    }
    else{
        return fd;
    }
}
int openNamedPipe(char *path, int flags)
{
    int sysFlag = _libFlagToSys(flags);
    int fd = _openPipe(path,sysFlag);
    return fd;
}
int closePipe(int fd)
{
    int err = close(fd);
    if(err!=0)
    {
        err = errno;
    }
    return err;
}
int unlinkPipe(char *path)
{
    int err = unlink(path);
    if(err!=0)
    {
        err = errno;
    }
    return err;
}
int onNonBlock(int fd,char on)
{
   int flags = fcntl(fd, F_GETFL, 0);
   if (flags == -1) return flags;
   flags = on ?  (flags | O_NONBLOCK):(flags & ~O_NONBLOCK) ;
   return fcntl(fd, F_SETFL, flags);
}

int __forkStart = 0;

// void readyToRead(int fd,void (*callback)(int id, int len))
// {
//     for
// }
int writeToPipe(int fd, char *srcBuffer, int len)
{
    int count =  write(fd, srcBuffer, len);
    return count;
}
int waitData(int fd,unsigned int waitSec,unsigned int waituSec)
{
  
            fd_set rfds;
        struct timeval tv;
        int retval;
        FD_ZERO(&rfds);
        FD_SET(fd, &rfds);
        /* Ждемc */
        tv.tv_sec = waitSec;
        tv.tv_usec = waituSec;
        retval = select(1, &rfds, NULL, NULL, &tv);
        if (retval)
        {
            //  printf("Данные доступны.\n");
            /* Теперь FD_ISSET(0, &rfds) вернет истинное значение. */
            // count = read(fd,targetBuffer,maxLen);
            return 1;
        }
        return -1;
}

    
int readFromPipe(int fd, char *targetBuffer, unsigned int maxLen)
{
        int count = read(fd,targetBuffer,maxLen);
        return count;
}
int getLastError()
{
    return errno;
}
