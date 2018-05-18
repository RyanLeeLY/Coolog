//
//  COLConsoleLogger.h
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import <Foundation/Foundation.h>
#import "COLLogger.h"

@interface COLConsoleLogger : NSObject <COLLogger>
@property (assign, atomic, readonly) BOOL remoteEnabled;

- (instancetype)initWithPort:(NSUInteger)port NS_DESIGNATED_INITIALIZER;

- (void)startRemoteLogger;

- (void)stopRemoteLogger;
@end
