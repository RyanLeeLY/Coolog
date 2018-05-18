//
//  COLFileLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLFileLogger.h"
#import <unistd.h>

static const NSInteger COLFileLoggerDefaultMaxL2CacheSize = 500;
static const NSInteger COLFileLoggerDefaultMaxL1CacheSize = 5000;
static const NSInteger COLFileLoggerDefaultMaxSingleFileSize = 1024 * 1024 * 30;
static NSString * const COLFileLoggerDefaultDirectoryPath = @"coolog";
static NSString * const COLFileLoggerDefaultTrashDirectoryPath = @"trash";

@interface COLFileLogger () {
    dispatch_once_t _onceToken;
}
@property (copy, nonatomic) NSString *rootDirectoryPath;
@property (assign, nonatomic) NSUInteger storagedDay;

@property (strong, nonatomic) NSMutableArray *logL1Cache;
@property (strong, nonatomic) NSMutableArray *logL2Cache;

@property (strong, nonatomic) dispatch_queue_t loggerFileQueue;
@property (strong, nonatomic) dispatch_queue_t loggerCacheQueue;
@property (strong, nonatomic) NSLock *fileHandleLock;
@property (strong, nonatomic) NSLock *cacheTransferLock;
@property (strong, nonatomic) NSLock *logL1CacheLock;
@property (strong, nonatomic) NSLock *logL2CacheLock;
@end

@implementation COLFileLogger
@synthesize formatterClass = _formatterClass;

+ (instancetype)logger {
    return [[COLFileLogger alloc] init];
}

- (instancetype)initWithDirectoryRootPath:(NSString *)path
                             storagedDay:(NSUInteger)storagedDay {
    self = [super init];
    if (self) {
        _rootDirectoryPath = path;
        _storagedDay = storagedDay;
        _loggerFileQueue = dispatch_queue_create("com.coolog.loggerFileQueue", NULL);
        _loggerCacheQueue = dispatch_queue_create("com.coolog.loggerCacheQueue", NULL);
        _maxL2CacheSize = COLFileLoggerDefaultMaxL2CacheSize;
        _maxL1CacheSize = COLFileLoggerDefaultMaxL1CacheSize;
        _maxSingleFileSize = COLFileLoggerDefaultMaxSingleFileSize;
        
        [self cleanExceptFileNames:COLFileLoggerFileNamesWithDateStrings([COLFileLogger recentDateStringsWithLength:_storagedDay])];
    }
    return self;
}

- (instancetype)init {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *rootPath = [documentsDirectory stringByAppendingPathComponent:COLFileLoggerDefaultDirectoryPath];
    return [self initWithDirectoryRootPath:rootPath storagedDay:1];
}

- (void)log:(NSString *)logString {
    [self.logL2CacheLock lock];
    [self.logL2Cache addObject:logString];
    
    if (self.logL2Cache.count > self.maxL2CacheSize) {
        dispatch_async(self.loggerFileQueue, ^{
            [self triggerTransferCache];
        });
    } else {
        [self.logL2CacheLock unlock];
    }
}

- (void)triggerTransferCache {
    NSArray *savedLogs = [self.logL2Cache copy];
    [self.logL2Cache removeAllObjects];
    [self.logL2CacheLock unlock];
    
    [self.logL1CacheLock lock];
    [savedLogs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.logL1Cache addObject:[[obj stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    if (self.logL1Cache.count > self.maxL1CacheSize) {
        dispatch_async(self.loggerFileQueue, ^{
            [self triggerWritingFile];
        });
    } else {
        [self.logL1CacheLock unlock];
    }
}

- (void)triggerWritingFile {
    NSArray *savedLogDataArray = [self.logL1Cache copy];
    [self.logL1Cache removeAllObjects];
    [self.logL1CacheLock unlock];
    
    NSString *fileName = COLFileLoggerFileName();
    [self.fileHandleLock lock];
    NSFileHandle *fileHandle = [self fileHandleWithDirctoryPath:self.rootDirectoryPath fileName:fileName];
    [fileHandle seekToEndOfFile];
    
    [savedLogDataArray enumerateObjectsUsingBlock:^(NSData * _Nonnull logData, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileHandle writeData:logData];
    }];
    
    unsigned long long fsize = [fileHandle seekToEndOfFile];
    [fileHandle closeFile];
    
    NSError *error = NULL;
    if (fsize > self.maxSingleFileSize) {
        [self moveLogFiletoTrash:fileName error:&error];
    }
    [self.fileHandleLock unlock];
}

- (NSArray<NSString *> *)exportLog {
    [self triggerTransferCache];
    [self triggerWritingFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *allFileNames = COLFileLoggerFileNamesWithDateStrings([COLFileLogger recentDateStringsWithLength:self.storagedDay]);
    NSMutableArray *filePaths = [NSMutableArray array];
    [allFileNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [self.rootDirectoryPath stringByAppendingPathComponent:obj];
        BOOL isDirectory = NO;
        BOOL rootPathExisted = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (rootPathExisted && !isDirectory) {
            [filePaths addObject:filePath];
        }
    }];
    return [filePaths copy];
}

#pragma mark - private
static inline NSString * COLFileLoggerFileName() {
    return [NSString stringWithFormat:@"%@.log", [COLFileLogger currentDateString]];
}

static inline NSArray * COLFileLoggerFileNamesWithDateStrings(NSArray *dateStrings) {
    NSMutableArray *arrayM = [NSMutableArray array];
    [dateStrings enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arrayM addObject:[NSString stringWithFormat:@"%@.log", obj]];
    }];
    return [arrayM copy];
}

- (NSFileHandle *)fileHandleWithDirctoryPath:(NSString *)path fileName:(NSString *)fileName {
    NSString *rootPath = path;
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL rootPathExisted = [fileManager fileExistsAtPath:rootPath isDirectory:&isDirectory];
    if (!isDirectory || !rootPathExisted){
        [fileManager createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    BOOL filePathExisted = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isDirectory || !filePathExisted) {
        [[NSData data] writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    }
    return [NSFileHandle fileHandleForUpdatingAtPath:filePath];
}

- (BOOL)moveLogFiletoTrash:(NSString *)fileName error:(NSError **)error {
    NSString *srcPath = [self.rootDirectoryPath stringByAppendingPathComponent:fileName];
    NSString *dstRootPath = [self.rootDirectoryPath stringByAppendingPathComponent:COLFileLoggerDefaultTrashDirectoryPath];
    NSString *dstPath = [dstRootPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL rootPathExisted = [fileManager fileExistsAtPath:dstRootPath isDirectory:&isDirectory];
    if (!isDirectory || !rootPathExisted){
        [fileManager createDirectoryAtPath:dstRootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [fileManager removeItemAtPath:dstPath error:nil];
    return [fileManager moveItemAtPath:srcPath toPath:dstPath error:error];
}

- (void)cleanExceptFileNames:(NSArray<NSString *> *)fileNames {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:self.rootDirectoryPath isDirectory:&isDir];
    if (isExist && isDir) {
        NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:self.rootDirectoryPath error:nil];
        [dirArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *fileName = [self.rootDirectoryPath stringByAppendingPathComponent:obj];
            if (![fileNames containsObject:obj]) {
                [fileManger removeItemAtPath:fileName error:nil];
            }
        }];
        [fileManger removeItemAtPath:[self.rootDirectoryPath stringByAppendingString:COLFileLoggerDefaultTrashDirectoryPath] error:nil];
    }
}

+ (NSString *)currentDateString {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:date];
}

+ (NSArray *)recentDateStringsWithLength:(NSUInteger)length {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i=0; i<length; i++) {
        [arrayM addObject:[dateFormatter stringFromDate:date]];
        date = [NSDate dateWithTimeInterval:-24*3600 sinceDate:date];
    }
    return [arrayM copy];
}

#pragma mark - getter
- (NSMutableArray *)logL1Cache {
    if (!_logL1Cache) {
        _logL1Cache = [[NSMutableArray alloc] init];
    }
    return _logL1Cache;
}

- (NSMutableArray *)logL2Cache {
    if (!_logL2Cache) {
        _logL2Cache = [[NSMutableArray alloc] init];
    }
    return _logL2Cache;
}

- (NSLock *)fileHandleLock {
    if (!_fileHandleLock) {
        _fileHandleLock = [[NSLock alloc] init];
    }
    return _fileHandleLock;
}

- (NSLock *)cacheTransferLock {
    if (!_cacheTransferLock) {
        _cacheTransferLock = [[NSLock alloc] init];
    }
    return _cacheTransferLock;
}

- (NSLock *)logL1CacheLock {
    if (!_logL1CacheLock) {
        _logL1CacheLock = [[NSLock alloc] init];
    }
    return _logL1CacheLock;
}

- (NSLock *)logL2CacheLock {
    if (!_logL2CacheLock) {
        _logL2CacheLock = [[NSLock alloc] init];
    }
    return _logL2CacheLock;
}
@end
