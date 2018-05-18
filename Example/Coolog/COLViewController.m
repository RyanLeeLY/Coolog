//
//  COLViewController.m
//  Coolog
//
//  Created by yao.li on 05/15/2018.
//  Copyright (c) 2018 yao.li. All rights reserved.
//

#import "COLViewController.h"
#import <Coolog/Coolog.h>

@interface COLViewController ()
@property (strong, nonatomic) COLEngine *logEngine;

@property (strong, nonatomic) COLFileLogger *fileLogger;
@end

@implementation COLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _logEngine = [[COLEngine alloc] init];
    _fileLogger = [COLFileLogger logger];
    [_logEngine addLogger:self.fileLogger];
//    [_logEngine addLogger:[COLALSLogger logger]];
    [_logEngine addLogger:[COLConsoleLogger logger]];
}

- (IBAction)buttonOnTapped:(UIButton *)sender {
    NSMutableArray *message = [NSMutableArray array];
    for (int i=0; i<arc4random()%40; i++) {
        [message addObject:[NSString stringWithFormat:@"value%@", @(i)]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logTimeTakenToRunBlock:^{
            for (int i=0; i<1; i++) {
                [self.logEngine logWithTag:@"tag" type:arc4random() % 5 message:[message description] date:[NSDate date] thread:[NSThread currentThread]];
            }
        } withPrefix:@"LOG in main thread"];
    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (int i=0; i<200; i++) {
//            [self.logEngine logWithTag:@"tag" type:COLLogTypeInfo message:[@[@"value", @"value"] description] date:[NSDate date] thread:[NSThread currentThread]];
//        }
//    });
}

- (IBAction)exportButtonOnTapped:(UIButton *)sender {
    [self.fileLogger exportLog];
}

- (void)logTimeTakenToRunBlock:(void(^)(void))block withPrefix:(NSString *)prefixString {
    
    double a = CFAbsoluteTimeGetCurrent();
    block();
    double b = CFAbsoluteTimeGetCurrent();
    
    unsigned int m = ((b-a) * 1000.0f); // convert from seconds to milliseconds
    
    NSLog(@"%@: %d ms", prefixString ? prefixString : @"Time taken", m);
}
@end
