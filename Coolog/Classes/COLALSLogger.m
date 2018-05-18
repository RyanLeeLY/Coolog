//
//  COLALSLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLALSLogger.h"

@implementation COLALSLogger
@synthesize formatterClass = _formatterClass;

+ (instancetype)logger {
    return [[COLALSLogger alloc] init];
}

- (void)log:(NSString *)logString {
    NSLog(@"%@", logString);
}
@end
