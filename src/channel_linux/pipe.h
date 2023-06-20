#ifndef IPC_PIPE_HPP
#define IPC_PIPE_HPP
// abstract class IPCNamedPipe {
//   int get openFlags;
//   int get maxBuffer;
//   String? get name;
//   Future<void> openPipe(int flags, {String? path, int maxPipeBuffer = 65536});
//   Future<void> closedPipe({bool andDelete = false});
//   Future<void> write(Uint8List bytes);
//   Future<Uint8List?> read();
//   Future<Sink<Uint8List>> writeStream();
//   Future<Stream<Uint8List>> readStream();
// }

    int openNamedPipe(char *path,int flags);
    int closePipe(int fd);
    int unlinkPipe(char *path);
    int setNonBlock(int fd);
    // void readyToRead(int fd,void (*callback)(int id,int len));
    int writeToPipe(int fd,char *srcBuffer,int len);
    int readFromPipe(int fd, char *targetBuffer, unsigned int maxLen, char needWait=0,unsigned int waitSec=5,unsigned int waituSec=0);
    int getLastError();



#endif