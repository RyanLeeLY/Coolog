//
//  COLALSLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLNSLogger.h"

@implementation COLNSLogger
+ (instancetype)logger {
    return [[COLNSLogger alloc] init];
}

- (void)log:(NSString *)logString {
    NSLog(@"%@", logString);
}
@end
