//
//  COLFileLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLFileLogger.h"
#import <unistd.h>

static const NSInteger COLFileLoggerDefaultMaxL2CacheSize = 1024 * 16;
static const NSInteger COLFileLoggerDefaultMaxL1CacheSize = 1024 * 256;
static const NSInteger COLFileLoggerDefaultMaxSingleFileSize = 1024 * 1024 * 100;
static NSString * const COLFileLoggerDefaultDirectoryPath = @"coolog";
static NSString * const COLFileLoggerDefaultTrashDirectoryPath = @"trash";

@interface COLFileLogger () {
    dispatch_once_t _onceToken;
}
@property (copy, nonatomic) NSString *rootDirectoryPath;
@property (assign, nonatomic) NSUInteger storagedDay;

@property (strong, nonatomic) NSMutableData *logL1Cache;
@property (strong, nonatomic) NSMutableString *logL2Cache;

@property (strong, nonatomic) NSOperationQueue *loggerQueue;
@property (strong, nonatomic) dispatch_queue_t loggerFileQueue;
@property (strong, nonatomic) dispatch_queue_t loggerCacheQueue;
@property (strong, nonatomic) NSLock *fileHandleLock;

@property (strong, nonatomic) NSCondition *logL2Condition;
@property (strong, nonatomic) NSCondition *logL1Condition;
@end

@implementation COLFileLogger
+ (instancetype)logger {
    return [[COLFileLogger alloc] init];
}

- (instancetype)initWithDirectoryRootPath:(NSString *)path
                             storagedDay:(NSUInteger)storagedDay {
    self = [super init];
    if (self) {
        _rootDirectoryPath = path;
        _storagedDay = storagedDay;
        _loggerQueue = [[NSOperationQueue alloc] init];
        _loggerQueue.maxConcurrentOperationCount = 1;
        _loggerQueue.qualityOfService = NSQualityOfServiceBackground;
        _loggerFileQueue = dispatch_queue_create("com.coolog.loggerFileQueue", NULL);
        _loggerCacheQueue = dispatch_queue_create("com.coolog.loggerCacheQueue", NULL);
        _maxL2CacheSize = COLFileLoggerDefaultMaxL2CacheSize;
        _maxL1CacheSize = COLFileLoggerDefaultMaxL1CacheSize;
        _maxSingleFileSize = COLFileLoggerDefaultMaxSingleFileSize;
        
        _logL1Cache = [[NSMutableData alloc] init];
        _logL2Cache = [[NSMutableString alloc] init];
        _fileHandleLock = [[NSLock alloc] init];
        _logL2Condition = [[NSCondition alloc] init];
        _logL1Condition = [[NSCondition alloc] init];
        
        dispatch_async(_loggerCacheQueue, ^{
            [self transferCacheTask];
        });
        
        dispatch_async(_loggerFileQueue, ^{
            [self writingFileTask];
        });

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
    __weak typeof(self) _self = self;
    [self.loggerQueue addOperationWithBlock:^{
        __strong typeof(_self) self = _self;
        [self.logL2Condition lock];
        [self.logL2Cache appendFormat:@"%@\n", logString];
        
        if (self.logL2Cache.length >= self.maxL2CacheSize) {
            [self.logL2Condition signal];
        }
        [self.logL2Condition unlock];
    }];
}

- (void)transferCacheTask {
    while (1) {
        @autoreleasepool {
            [self.logL2Condition lock];
            
            if (self.logL2Cache.length < self.maxL2CacheSize) {
                [self.logL2Condition wait];
            }
            NSString *savedLogs = [self.logL2Cache copy];
            [self.logL2Cache setString:@""];
            [self.logL2Condition unlock];
            
            [self.logL1Condition lock];
            [self.logL1Cache appendData:[savedLogs dataUsingEncoding:NSUTF8StringEncoding]];
            
            if (self.logL1Cache.length >= self.maxL1CacheSize) {
                [self.logL1Condition signal];
            }
            [self.logL1Condition unlock];
        }
    }
}

- (void)triggerTransferCache {
    [self.logL2Condition lock];
    
    NSString *savedLogs = [self.logL2Cache copy];
    [self.logL2Cache setString:@""];
    [self.logL2Condition unlock];
    
    [self.logL1Condition lock];
    [self.logL1Cache appendData:[savedLogs dataUsingEncoding:NSUTF8StringEncoding]];
    [self.logL1Condition unlock];
}

- (void)writingFileTask {
    while (1) {
        @autoreleasepool {
            [self.logL1Condition lock];
            if (self.logL1Cache.length < self.maxL1CacheSize) {
                [self.logL1Condition wait];
            }
            NSData *savedLogsData = [self.logL1Cache copy];
            [self.logL1Cache setData:[NSData data]];
            [self.logL1Condition unlock];
            
            NSString *fileName = COLFileLoggerFileName();
            [self.fileHandleLock lock];
            NSFileHandle *fileHandle = [self fileHandleWithDirctoryPath:self.rootDirectoryPath fileName:fileName];
            [fileHandle seekToEndOfFile];
            
            [fileHandle writeData:savedLogsData];
            
            unsigned long long fsize = [fileHandle seekToEndOfFile];
            [fileHandle closeFile];
            
            NSError *error = NULL;
            if (fsize > self.maxSingleFileSize) {
                [self moveLogFiletoTrash:fileName error:&error];
            }
            [self.fileHandleLock unlock];
        }
    }
}

- (void)triggerWritingFile {
    [self.logL1Condition lock];
    NSData *savedLogsData = [self.logL1Cache copy];
    [self.logL1Cache setData:[NSData data]];
    [self.logL1Condition unlock];
    
    if (savedLogsData.length == 0) {
        return;
    }
    
    NSString *fileName = COLFileLoggerFileName();
    [self.fileHandleLock lock];
    NSFileHandle *fileHandle = [self fileHandleWithDirctoryPath:self.rootDirectoryPath fileName:fileName];
    [fileHandle seekToEndOfFile];
    
    [fileHandle writeData:savedLogsData];
    
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
@end
