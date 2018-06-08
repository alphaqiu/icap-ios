
之前我写了一篇关于[ICAP: 互换客户端地址协议](https://segmentfault.com/a/1190000015143188)的文章。文章中介绍和详细解析了关于ICAP协议算法，并给出Go语言版本的具体实现。实际上以太坊全节点[Geth](https://github.com/ethereum/go-ethereum)提供了WEB3接口，来转换ICAP格式地址（`web3.fromICAP("XE86G29C8IV34UOJMYWHGDSGME33YKEC3QO")`）。

```bash
> web3
{
  ... ...
  BigNumber: function a(e,n),
  fromICAP: function(icap),
  isAddress: function(address),
  isChecksumAddress: function(address),
  sha3: function(string, options),
  toBigNumber: function(number),
  toChecksumAddress: function(address)
  ... ...
}

> web3.fromICAP("XE86G29C8IV34UOJMYWHGDSGME33YKEC3QO")
"8982b139b2fca9452eae977827fb12280a9a1bf0"
>
```

不过这种方式转换ICAP格式地址，在客户端与服务端交互上有些繁琐，特别是在手机端操作时。手机端完全可以利用每一台终端设备来处理这个转换工作，直接将ICAP格式地址发送给服务端处理全部转换逻辑显得没有必要。另外，`web3.fromICAP`只能转换出非含校验和的以太坊账户地址，仍需要调用`web3.toChecksumAddress`来完成剩余工作。

因此，在这个大前提下，[BOX企业数字资产保险箱 员工版APP](https://github.com/boxproject/box-Staff-Manager)开发了基于ICAP协议算法的一套iOS库。该库可以直接在手机端完成转换工作，不需要与后端web3接口交互。可能Geth已有iOS版本相关的库（`pod Geth`)，不过由于这个库太大，一直没有下载成功，也没有办法验证其功能是否包含ICAP功能。使用本库的还有一个好处是简单明了，不必依赖大型库，同时转换出的以太坊地址支持checksum。

我是一位Gopher，浅尝iOS，代码目标不是做一个完整的手机APP，旨在实现ICAP格式协议地址转换成以太坊账户地址。代码在这里被找到 https://github.com/alphaqiu/icap-ios

# icap-ios

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

