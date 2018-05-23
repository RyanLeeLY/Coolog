//
//  COLDateFormatter.h
//  Coolog
//
//  Created by Yao Li on 2018/5/23.
//

#import <Foundation/Foundation.h>

@interface COLDateFormatter : NSObject
+ (instancetype)sharedInstance;

- (NSString *)dateStringWithTimeInterval:(NSTimeInterval)timeInterval;
@end
