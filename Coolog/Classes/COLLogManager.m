//
//  COLLogManager.m
//  Coolog
//
//  Created by Yao Li on 2018/5/21.
//

#import "COLLogManager.h"
#import "COLALSLogger.h"
#import "COLConsoleLogger.h"
#import "COLFileLogger.h"
#import "COLLoggerDriver.h"

@interface COLLogManager ()
@property (strong, nonatomic) COLEngine *logEngine;

@property (strong, nonatomic) COLLoggerDriver *alsLoggerDriver;
@property (strong, nonatomic) COLLoggerDriver *consoleLoggerDriver;
@property (strong, nonatomic) COLLoggerDriver *fileLoggerDriver;
@end

@implementation COLLogManager
+ (instancetype)sharedInstance {
    static COLLogManager *Singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Singleton = [[COLLogManager alloc] init];
    });
    return Singleton;
}

- (void)setup {
    _logEngine = [[COLEngine alloc] init];
    _level = COLLogLevelAll;
    _alsLoggerDriver = [[COLLoggerDriver alloc] initWithLogger:[COLALSLogger logger]
                                                     formatter:[COLLogFormatter ALSFormatter]
                                                         level:_level];
    
    _consoleLoggerDriver = [[COLLoggerDriver alloc] initWithLogger:[COLConsoleLogger logger]
                                                         formatter:[COLLogFormatter ConsoleFormatter]
                                                             level:_level];
    
    _fileLoggerDriver = [[COLLoggerDriver alloc] initWithLogger:[COLFileLogger logger]
                                                      formatter:[COLLogFormatter FileFormatter]
                                                          level:_level];
}

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message {
    [self.logEngine logWithType:type tag:tag message:message date:[NSDate date] thread:[NSThread currentThread]];
}

- (void)enableALSLog {
    [self.logEngine addDriver:self.alsLoggerDriver];
}

- (void)disableALSLog {
    [self.logEngine removeDriver:self.alsLoggerDriver];
}

- (void)enableConsoleLog {
    [self.logEngine addDriver:self.consoleLoggerDriver];
}

- (void)disableConsoleLog {
    [self.logEngine removeDriver:self.consoleLoggerDriver];
}

- (void)enableRemoteConsole {
    [(COLConsoleLogger *)self.consoleLoggerDriver.logger startRemoteLogger];
}

- (void)disableRemoteConsole {
    [(COLConsoleLogger *)self.consoleLoggerDriver.logger stopRemoteLogger];
}

- (void)enableFileLog {
    [self.logEngine addDriver:self.fileLoggerDriver];
}

- (void)disableFileLog {
    [self.logEngine removeDriver:self.fileLoggerDriver];
}

- (NSArray<NSString *> *)exportLog {
    return [(COLFileLogger *)self.fileLoggerDriver.logger exportLog];
}

- (void)setLevel:(COLLogLevel)level {
    _level = level;
    self.alsLoggerDriver.level = level;
    self.consoleLoggerDriver.level = level;
    self.fileLoggerDriver.level = level;
}
@end
