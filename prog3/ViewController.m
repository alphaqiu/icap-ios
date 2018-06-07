//
//  ViewController.m
//  prog3
//
//  Created by alpha on 18/06/07.
//  Copyright © 2018年 alpha. All rights reserved.
//

#import "ViewController.h"
#import "icap.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ICAP *decoder = [[ICAP alloc] init];
    NSError *error;
    [decoder addressConvertFrom:@"XE86G29C8IV34UOJMYWHGDSGME33YKEC3QO" didFailedWithError:&error];
    if (error != nil) {
        NSLog(@"Convert from ICAP failed, cause:%@", error);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
