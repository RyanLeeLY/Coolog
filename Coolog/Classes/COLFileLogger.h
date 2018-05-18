//
//  COLFileLogger.h
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import <Foundation/Foundation.h>
#import "COLLogger.h"

@interface COLFileLogger : NSObject <COLLogger>
/**
 Default value is 500.
 L2Cache(NSString) -> L1Cache(NSData) -> File
 */
@property (assign, nonatomic) NSInteger maxL2CacheSize;

/**
 Default value is 5000.
 L2Cache(NSString) -> L1Cache(NSData) -> File
 */
@property (assign, nonatomic) NSInteger maxL1CacheSize;

/**
 Bytes. Default value is 1024*1024*30 bytes.
 */
@property (assign, nonatomic) unsigned long long maxSingleFileSize;


/**
 Init method.

 @param path Path of log files
 @param storagedDay Storaged days of log files. Default value is 1.
 @return COLFileLogger instance
 */
- (instancetype)initWithDirectoryRootPath:(NSString *)path storagedDay:(NSUInteger)storagedDay NS_DESIGNATED_INITIALIZER;

/**
 All cached logs will be written to file immediately.

 @return All the log File's paths
 */
- (NSArray<NSString *> *)exportLog;
@end
