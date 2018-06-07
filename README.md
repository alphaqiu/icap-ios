# icap-ios

本工程为iOS端转换icap格式至以太坊账户地址格式样例。

接口定义：

```objective-c
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
```

使用方法：

```objective-c
ICAP *decoder = [[ICAP alloc] init];
NSError *error;
[decoder addressConvertFrom:@"XE86G29C8IV34UOJMYWHGDSGME33YKEC3QO" didFailedWithError:&error];
if (error != nil) {
    NSLog(@"Convert from ICAP failed, cause:%@", error);
}
```

工程依赖库安装：

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'prog3' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
    pod 'JKBigInteger', '~> 0.0.1'

  # Pods for prog3

end
```

```bash
pod install
```

