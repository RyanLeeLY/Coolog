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
@end

@implementation COLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _logEngine = [[COLEngine alloc] init];
    [_logEngine addLogger:[[COLALSLogger alloc] init]];
}

- (IBAction)buttonOnTapped:(UIButton *)sender {
    [self.logEngine logWithTag:@"tag" type:COLLogTypeInfo message:[@[@"value", @"value"] description] date:[NSDate date] thread:[NSThread currentThread]];
}
@end
