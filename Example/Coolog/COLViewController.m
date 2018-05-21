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

@end

@implementation COLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[COLLogManager sharedInstance] setup];
    [[COLLogManager sharedInstance] enableFileLog];
    [[COLLogManager sharedInstance] enableConsoleLog];
#ifndef DEBUG
    [COLLogManager sharedInstance].level = COLLogLevelInfo;
#endif
}

- (IBAction)buttonOnTapped:(UIButton *)sender {
    NSMutableArray *message = [NSMutableArray array];
    for (int i=0; i<arc4random()%200; i++) {
        [message addObject:[NSString stringWithFormat:@"value%@", @(i)]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logTimeTakenToRunBlock:^{
            for (int i=0; i<1; i++) {
                CLogError(@"tag", @"%@", [message description]);
            }
        } withPrefix:@"LOG in main thread"];
    });

    for (int i=0; i<2; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CLogInfo(@"tag", @"%@", [message description]);
        });
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=0; i<1; i++) {
            CLogDebug(@"tag", @"%@", [message description]);
        }
    });
}

- (IBAction)exportButtonOnTapped:(UIButton *)sender {
    [[COLLogManager sharedInstance] exportLog];
}

- (void)logTimeTakenToRunBlock:(void(^)(void))block withPrefix:(NSString *)prefixString {
    
    double a = CFAbsoluteTimeGetCurrent();
    block();
    double b = CFAbsoluteTimeGetCurrent();
    
    unsigned int m = ((b-a) * 1000.0f); // convert from seconds to milliseconds
    
    NSLog(@"%@: %d ms", prefixString ? prefixString : @"Time taken", m);
}

- (IBAction)restartButtonOnTapped:(UIButton *)sender {
    [[COLLogManager sharedInstance] enableRemoteConsole];
}
@end
