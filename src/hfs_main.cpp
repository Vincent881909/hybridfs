#define FUSE_USE_VERSION 26

#include "../include/hfs.h"
#include "../include/hfs_state.h"
#include "../include/hfs_utils.h"
#include <iostream>
#include <fuse.h>
#include <assert.h>
#include <string.h>
#include "rocksdb/db.h"
#include <assert.h>
#include <unistd.h>

struct fuse_operations hfs_oper = {
  .getattr = hfs_getattr,
  .readdir = hfs_readdir,
  .init = hfs_init,
  .create = hfs_create,
  .utimens = hfs_utimens

};

int main(int argc, char *argv[]){

    std::string mountdir(argv[1]);
    std::string metadir(argv[2]);
    std::string datadir(argv[3]);

    char *fuse_argv[20];
    int fuse_argc = 0;
    fuse_argv[fuse_argc++] = argv[0];
    char fuse_mount_dir[100];
    strcpy(fuse_mount_dir, mountdir.c_str());
    fuse_argv[fuse_argc++] = fuse_mount_dir;
    fuse_argv[fuse_argc++] = "-f"; //Run Fuse in the Foreground
    fuse_argv[fuse_argc++] = "-d"; //Verbose debug output
    fuse_argv[fuse_argc++] = "-s"; //Single threaded mode
    fuse_argv[fuse_argc++] = "-o"; // Allow access to other users
    fuse_argv[fuse_argc++] = "allow_other"; // Allow access to other users
    int fuse_state;
    
    u_int dataThreshold = 4096;
    rocksdb::DB* metaDataDB = createMetaDataDB(metadir);
    HFS_FileSystemState hfsState(mountdir,metadir,datadir,dataThreshold, metaDataDB);

    printf("Calling fuse_main...\n");
    fuse_state = fuse_main(fuse_argc, fuse_argv, &hfs_oper, &hfsState);
    printf("fuse_main has exited with code: %d\n", fuse_state);

    return fuse_state;
}

