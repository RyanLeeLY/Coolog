//
//  COLLogManager.h
//  Coolog
//
//  Created by Yao Li on 2018/5/21.
//

#import "COLEngine.h"
#import "COLLoggerDriver.h"

@interface COLLogManager : NSObject
@property (strong, nonatomic, readonly) COLEngine *logEngine;

@property (assign, nonatomic) COLLogLevel level;

+ (instancetype)sharedInstance;

- (void)setup;

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message;

/**
 Enable Apple Log System.
 启用Apple Log System。
 */
- (void)enableALSLog;

/**
 Disable Apple Log System.
 关闭Apple Log System。
 */
- (void)disableALSLog;

/**
 Enable console log. We suggest don't Console Log when Apple Log System is enabled.
 启用控制台log。我们建议这个功能不要同ALS同时开启。
 */
- (void)enableConsoleLog;

/**
 Disable console log.
 关闭控制台log。
 */
- (void)disableConsoleLog;

/**
 Enable the browser log tool. The function requires the authorization of networking.
 打开浏览器log调试功能。该功能须要APP网络访问权限。
 */
- (void)enableRemoteConsole;

/**
 Disable the browser log tool.
 关闭浏览器log调试功能。
 */
- (void)disableRemoteConsole;

/**
 Enable file log. Logs will be written in files.
 打开文件log功能，将log写入文件
 */
- (void)enableFileLog;

/**
 Disable file log.
 关闭文件log功能
 */
- (void)disableFileLog;

/**
 All the logs in memory will be written in files immediately.
 将log输出到文件.

 @return log files' path 返回所有的log文件路径
 */
- (NSArray<NSString *> *)exportLog;
@end
