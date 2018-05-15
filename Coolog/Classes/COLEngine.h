//
//  COLEngine.h
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import <Foundation/Foundation.h>
#import "COLLogger.h"
#import "COLLogFormatter.h"

@interface COLEngine : NSObject
- (void)addLogger:(id<COLLogger>)logger;

- (void)removeLogger:(id<COLLogger>)logger;

- (void)removeAllLogger;

- (void)logWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread;
@end
