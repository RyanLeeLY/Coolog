//
//  COLLogger.h
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import <Foundation/Foundation.h>

@class COLLogFormatter;

@protocol COLLogger <NSObject>
@property (strong, nonatomic) Class formatterClass;

- (void)log:(NSString *)logString;
@end
