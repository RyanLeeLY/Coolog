//
//  COLALSLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLALSLogger.h"

@implementation COLALSLogger
@synthesize formatterClass = _formatterClass;

- (void)log:(NSString *)logString {
    NSLog(@"%@", logString);
}
@end
