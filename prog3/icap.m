//
//  icap.m
//  prog3
//
//  Created by alpha on 18/06/06.
//  Copyright © 2018年 alpha. All rights reserved.
//

#import "icap.h"
#import "JKBigInteger.h"
#import "keccak.h"

@interface ICAP()
@property(nonatomic,copy) NSError *errICAPLength;
@property(nonatomic,copy) NSError *errICAPEncoding;
@property(nonatomic,copy) NSError *errICAPChecksum;
@property(nonatomic,copy) NSError *errICAPCountryCode;
@property(nonatomic,copy) NSError *errICAPAssetIdent;
@property(nonatomic,copy) NSError *errICAPInstCode;
@property(nonatomic,copy) NSError *errICAPClientIdent;
@property(nonatomic,copy) NSError *errICAPNotImplement;
@property(nonatomic, copy) JKBigInteger *big97;
@property(nonatomic, copy) JKBigInteger *big1;

-(NSString *) expandWithIso13616Protocol:(NSString *)string didFailedWithError:(NSError **)error;
-(NSError *)  validCheckSum:(NSString *)icapString;
-(NSString *) parse:(NSString *)icapString didFailedWithError:(NSError **)error;
-(NSString *) parseIndirect:(NSString *)icapString didFailedWithError:(NSError **)error;
@end

@implementation ICAP
-(instancetype) init
{
    self = [super init];
    NSString *domain = @"la.box.icap";
    _errICAPLength       = [self createErrorWith:@"invalid ICAP length" errorCode:1501 andDomain:domain];
    _errICAPEncoding     = [self createErrorWith:@"invalid ICAP encoding" errorCode:1502 andDomain:domain];
    _errICAPChecksum     = [self createErrorWith:@"invalid ICAP checksum" errorCode:1053 andDomain:domain];
    _errICAPCountryCode  = [self createErrorWith:@"invalid ICAP country code" errorCode:1504 andDomain:domain];
    _errICAPAssetIdent   = [self createErrorWith:@"invalid ICAP asset identifier" errorCode:1505 andDomain:domain];
    _errICAPInstCode     = [self createErrorWith:@"invalid ICAP institution code" errorCode:1506 andDomain:domain];
    _errICAPClientIdent  = [self createErrorWith:@"invalid ICAP client identifier" errorCode:1507 andDomain:domain];
    _errICAPNotImplement = [self createErrorWith:@"not implement" errorCode:1508 andDomain:domain];
    
    _big97 = [[JKBigInteger alloc] initWithString:@"97"];
    _big1  = [[JKBigInteger alloc] initWithString:@"1"];
    return self;
}

-(NSError *) createErrorWith:(NSString *)description errorCode:(NSInteger)code andDomain:(NSString *)value
{
    NSDictionary *userInfo = [[NSDictionary alloc]
                              initWithObjectsAndKeys:description,
                              @"NSLocalizedDescriptionKey", NULL];
    return [NSError errorWithDomain:value code:code userInfo:userInfo];
}

-(NSString *) addressConvertFrom:(NSString *)icapString didFailedWithError:(NSError **)error
{
    switch ([icapString length]) {
        case 35:
        case 34:
            return [self parse:icapString didFailedWithError:error];
        case 20:
            return [self parseIndirect:icapString didFailedWithError:error];
        default:
            *error = _errICAPLength;
            return NULL;
    }
}

-(NSString *) parse:(NSString *)icapString didFailedWithError:(NSError **)error
{
    if (![icapString hasPrefix:@"XE"]) {
        *error = _errICAPCountryCode;
        return NULL;
    }
    
    *error = [self validCheckSum:icapString];
    if (*error != nil) {
        return NULL;
    }
    
    // checksum is ISO13616, Ethereum address is base-36
    JKBigInteger *bigAddr = [[JKBigInteger alloc] initWithString:[icapString substringFromIndex:4] andRadix:36];
    NSLog(@"%@", bigAddr);
    
    // hex string
    NSString *checksum = [self checksumWithKeccak256:[bigAddr stringValueWithRadix:16]];
    NSLog(@"checksum: %@", checksum);
    
    return checksum;
}

- (NSString *)checksumWithKeccak256:(NSString *)value
{
    int bytes = (int)(256 / 8);
    const char *string = [value UTF8String];
    int size = (int) strlen(string);
    uint8_t md[bytes];
    keccak((uint8_t*)string, size, md, bytes);
    NSMutableString *address = [[NSMutableString alloc] initWithCapacity:size + 4];
    [address appendFormat:@"%@", @"0x"];
    
    uint32_t len = (uint32_t)size;
    for(uint32_t i=0; i<len; i++) {
        uint8_t hashByte = md[i/2];
        if (i%2 == 0) {
            hashByte = hashByte >> 4;
        } else {
            hashByte &= 0xf;
        }
        
        if (string[i] > '9' && hashByte > 7) {
            [address appendFormat:@"%c", string[i] - 32];
        } else {
            [address appendFormat:@"%c", string[i]];
        }
    }
    
    return address;
}

-(NSString *) parseIndirect:(NSString *)icapString didFailedWithError:(NSError **)error
{
    if (![icapString hasPrefix:@"XE"]) {
        *error = _errICAPCountryCode;
        return NULL;
    }
    
    if (![[icapString substringWithRange:NSMakeRange(4, 7)] isEqualToString:@"ETH"]) {
        *error = _errICAPAssetIdent;
        return NULL;
    }
    
    *error = [self validCheckSum:icapString];
    if (*error != nil) {
        return NULL;
    }
    
    *error = _errICAPNotImplement;
    return NULL;
}

-(BOOL) validBase36:(NSString *)icapString
{
    int len = (int)[icapString length];
    int i;
    for (i=0; i<len;i++) {
        unichar c = [icapString characterAtIndex:i];
        if (c < 48 || (c > 57 && c < 65) || c > 90) {
            return false;
        }
    }
    
    return true;
}

-(NSString *) expandWithIso13616Protocol:(NSString *)string didFailedWithError:(NSError **)error;
{
    if (![self validBase36:string]) {
        *error = _errICAPEncoding;
        return nil;
    }
    
    int i;
    int len = (int)[string length];
    NSMutableArray *parts = [[NSMutableArray alloc]init];
    for (i=0; i<len; i++) {
        unichar c = [string characterAtIndex:i];
        if (c >= 65) {
            parts[i] = [NSString stringWithFormat:@"%d", (int)(c-55)];
        } else {
            parts[i] = [[NSString alloc]initWithCharacters:&c length:1];
        }
    }
    
    return [parts componentsJoinedByString:@""];
}

-(NSError *) validCheckSum:(NSString *)icapString
{
    NSError *error;
    NSArray *serialized = [[NSArray alloc]initWithObjects:
                           [icapString substringFromIndex:4],
                           [icapString substringToIndex:4], nil];
    
    NSString *expand = [self expandWithIso13616Protocol:
                        [serialized componentsJoinedByString:@""] didFailedWithError:&error];
    if (error != nil) {
        return error;
    }
    
    JKBigInteger *checkSumNum = [[JKBigInteger alloc] initWithString:expand];
    if (NSOrderedSame == [[checkSumNum remainder:_big97] compare:_big1]) {
        return nil;
    }
    
    return _errICAPChecksum;
}
@end
