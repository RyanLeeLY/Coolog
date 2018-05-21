//
//  COLLogManager.h
//  Coolog
//
//  Created by Yao Li on 2018/5/21.
//

#import "COLEngine.h"
#import "COLLoggerDriver.h"

@interface COLLogManager : NSObject
@property (assign, nonatomic) COLLogLevel level;

+ (instancetype)sharedInstance;

- (void)setup;

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message;

/**
 打开Apple Log System。
 */
- (void)enableALSLog;

/**
 关闭Apple Log System。
 */
- (void)disableALSLog;

/**
 打开控制台Log，不建议与Apple Log System同时开启。
 */
- (void)enableConsoleLog;

/**
 关闭控制台Log
 */
- (void)disableConsoleLog;

/**
 打开浏览器log调试功能。该功能须要APP网络访问权限。
 */
- (void)enableRemoteConsole;

/**
 关闭浏览器log调试功能。
 */
- (void)disableRemoteConsole;

/**
 打开文件log功能，将log写入文件
 */
- (void)enableFileLog;

/**
 关闭文件log功能
 */
- (void)disableFileLog;

/**
 将log输出到文件

 @return 返回所有的log文件路径
 */
- (NSArray<NSString *> *)exportLog;
@end
