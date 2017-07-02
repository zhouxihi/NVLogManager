#基于CocoaLumberjack封装的一个自定义日志系统, 可以实现替换xocode控制台输出, 并实现log分级, 写入文件, 上传后台等功能 

##使用方法:
需要pod 'CocoaLumberjack'
<pre><code>
pod 'CocoaLumberjack'
</pre></code>

##并在pch文件中添加一下代码
#import "NVLogManager.h"

##目前定义的几种日志级别
<pre><code>
typedef enum : NSUInteger {
    
    kNVLogLevelError = 0,
    kNVLogLevelWarn,
    kNVLogLevelInfo,
    kNVLogLevelDebug,
    kNVLogLevelOff
} NVLogLevel;
</pre></code>

##上传频率
<pre><code>
typedef enum : NSUInteger {
    
    kNVFrequencyYear = 0,
    kNVFrequencyMonth,
    kNVFrequencyWeek,
    kNVFrequencyDay,

} NVLogFrequency;
</pre></code>

##基本方法介绍, 具体请参看NVLogManager.h
<pre><code>
/**
 获取单例

 @return 单例
 */
+ (instancetype)shareInstance;

/**
 开启日志文件系统, 默认日志文件保存1个月
 */
- (void)enableFileLogSystem;

/**
 开启自定义日志文件系统

 @param direct 日志文件文件夹地址
 @param freshFrequency 日志刷新频率
 */
- (void)enableFileLogSystemWithDirectory:(NSString *)direct freshTimeInterval:(NVLogFrequency)freshFrequency;

/**
 获取当前的日志文地址
注意日志文件名称含有空格

 @return 日志文件地址
 */
- (NSString *)getCurrentLogFilePath;

/**
 删除日志文件, 
 注意调用删除日志文件的方法后, 要在下次启动才会产生新的日志文件

 @return 删除的结果
 */
- (BOOL)clearFileLog;

/**
 停止所有Log系统, 并清除日志文件
 */
- (void)stopLog;

/**
 上传Log文件, 注意日志文件名称含有空格

 @param uploadBlock 上传的Block
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock;

/**
 设置定期上传文件, 不会立即发送 注意日志文件名称含有空格

 @param uploadBlock 上传文件的block
 @param uploadFrequency 上传频率
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock
                 withFrequency:(NVLogFrequency)uploadFrequency;
</pre></code>
