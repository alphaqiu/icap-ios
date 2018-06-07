//
//  icap.h
//  prog3
//
//  Created by alpha on 18/06/06.
//  Copyright © 2018年 alpha. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString *Base36Chars = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface ICAP :NSObject
/**
 * @brief convert icap string to ethereum account address.
 *
 * example code:
 *
 * ICAP *decoder = [[ICAP alloc] init];
 * NSError *error;
 * NSString icapString = @"XE86G29C8IV34UOJMYWHGDSGME33YKEC3QO";
 * [decoder addressConvertFrom:icapString didFailedWithError:&error];
 * if (error != nil) {
 *     NSLog(@"Convert from ICAP failed, cause:%@", error);
 * }
 *
 * @param icapString *NSString
 * @param error **NSError when invoked the function, if this reference error not nil, then the renturn string is nil.
 * @return *NSString the ethereum account address.
 */
-(NSString *) addressConvertFrom:(NSString *)icapString didFailedWithError:(NSError **)error;
@end
