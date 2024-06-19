#ifndef HFS_KEYHANDLER_H
#define HFS_KEYHANDLER_H

#include <iostream>
#include <unordered_map>
#include <queue>
#include <cstdint>
#include <cstring>
#include <mutex>
#include <shared_mutex>

#define MIN_KEY 1
#define MAX_KEY UINT32_MAX

typedef uint32_t HFS_KEY;

class HFS_KeyHandler {
private:
    HFS_KEY currentKey;
    std::unordered_map<std::string, HFS_KEY> map;
    std::queue<HFS_KEY> queue;
    mutable std::shared_mutex mutex;

public:
    HFS_KeyHandler();

    int getNextKey();
    void makeNewEntry(HFS_KEY key, const char* path);
    void recycleKey(HFS_KEY key);
    int getKeyFromPath(const char* path,HFS_KEY &key);
    bool entryExists(const char* path);
    void eraseEntry(const char* path);
    int handleEntries(const char* path, HFS_KEY &key);
    int handleErase(const char* path,HFS_KEY key);
};

#endif 
