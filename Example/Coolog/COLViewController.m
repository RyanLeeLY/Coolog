//
//  COLViewController.m
//  Coolog
//
//  Created by yao.li on 05/15/2018.
//  Copyright (c) 2018 yao.li. All rights reserved.
//

#import "COLViewController.h"
#import <Coolog/COLConsoleLogger.h>

@interface COLViewController ()

@end

@implementation COLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    COLConsoleLogger *logger = [[COLConsoleLogger alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
