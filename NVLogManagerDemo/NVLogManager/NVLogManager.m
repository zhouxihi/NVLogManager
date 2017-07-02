//
//  NVLogManager.m
//  NVLogManagerDemo
//
//  Created by Jackey on 2017/6/3.
//  Copyright © 2017年 com.zhouxi. All rights reserved.
//

#import "NVLogManager.h"
#import "MyCustomFormatter.h"

@interface NVLogManager ()

@property (nonatomic, strong) UploadFileLogBlock    uploadBlock;

@property (nonatomic, assign) NVLogFrequency        uploadFrequency;

@property (nonatomic, assign) NSTimeInterval        lastUploadTimeInterval;

@property (nonatomic, assign) BOOL                  LogFileEnabled;

@property (nonatomic, strong) DDFileLogger          *fileLogger;

@property (nonatomic, assign) double                logFreshTimer;

@end

@implementation NVLogManager

static NVLogManager *_instance = nil;

/**
 创建单例

 @return 单例
 */
+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[super allocWithZone:NULL] init];
        
        [DDLog addLogger:[DDASLLogger sharedInstance]]; //add log to Apple System Logs
        [DDLog addLogger:[DDTTYLogger sharedInstance]]; //add log to Xcode console
        
        [DDTTYLogger sharedInstance].logFormatter = [[MyCustomFormatter alloc] init];
    });
    
    _instance.lastUploadTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastUploadTimeInterval"] ? [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastUploadTimeInterval"] : 0;
    
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    
    return [NVLogManager shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    
    return [NVLogManager shareInstance];
}

/**
 开启日志文件系统
 */
- (void)enableFileLogSystem {
    
    _LogFileEnabled = YES;
    
    _fileLogger = [[DDFileLogger alloc] init];
    
    _fileLogger.rollingFrequency                       = 60 * 60 * 24 * 30;
    //_fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    _fileLogger.logFormatter                           = [[MyCustomFormatter alloc] init];
    
    [DDLog addLogger:_fileLogger];
}

/**
 开启自定义文件系统
 
 @param direct 日志文件夹
 @param freshFrequency 日志刷新时间
 */
- (void)enableFileLogSystemWithDirectory:(NSString *)direct freshTimeInterval:(NVLogFrequency)freshFrequency; {
    
    _LogFileEnabled = YES;
    
    DDLogFileManagerDefault *logFileManager = \
                    [[DDLogFileManagerDefault alloc] initWithLogsDirectory:direct];
    
    _fileLogger                             = \
                    [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    
    
    switch (freshFrequency) {
        case kNVFrequencyYear:
            
            _logFreshTimer = 60 * 60 * 24 * 365;
            break;
            
        case kNVFrequencyMonth:
            
            _logFreshTimer = 60 * 60 * 24 * 30;
            break;
            
        case kNVFrequencyWeek:
            
            _logFreshTimer = 60 * 60 * 24 * 7;
            break;
            
        case kNVFrequencyDay:
            
            _logFreshTimer = 60 * 60 * 24;
            break;
            
        default:
            
            _logFreshTimer = 60 * 60 * 24 * 30;
            break;
    }

    
    _fileLogger.rollingFrequency = _logFreshTimer;
    //_fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:_fileLogger];
}

/**
 获取当前的日志文件文件夹
 
 @return 日志文件夹地址
 */
- (NSString *)getCurrentLogFilePath {
    
    if (_LogFileEnabled && _fileLogger) {
        
        return _fileLogger.currentLogFileInfo.filePath;
    } else {
        
        return @"";
    }
}

/**
 删除日志文件,
 注意调用删除日志文件的方法后, 要在下次启动才会产生新的日志文件
 
 @return 删除的结果
 */
- (BOOL)clearFileLog {
    
    if ([self getCurrentLogFilePath].length > 1) {
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager removeItemAtPath:[self getCurrentLogFilePath] error:&error];
        
        if (!error) {
            
            return true;
        } else {
            
            return false;
        }
    }
    
    return true;
}

/**
 停止所有Log系统
 */
- (void)stopLog {
    
    [self clearFileLog];
    _LogFileEnabled = NO;
    
    [DDLog removeAllLoggers];
    
}

/**
 上传Log文件
 
 @param uploadBlock 上传的Block
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock {
    
    if ([self getCurrentLogFilePath].length > 1 && _LogFileEnabled) {
        
        uploadBlock([self getCurrentLogFilePath]);
    }
}

/**
 设置定期上传文件, 不会立即发送
 
 @param uploadBlock 上传文件的block
 @param uploadFrequency 上传频率
 */
- (void)uploadFileLogWithBlock:(UploadFileLogBlock)uploadBlock
                 withFrequency:(NVLogFrequency)uploadFrequency {
    
    self.uploadBlock     = uploadBlock;
    self.uploadFrequency = uploadFrequency;
    
    if (_LogFileEnabled) {
        
        if (!self.lastUploadTimeInterval) {
            
            //获取当前的时间戳
            self.lastUploadTimeInterval = [[NSDate date] timeIntervalSince1970];
            
            //存储时间戳
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setDouble:self.lastUploadTimeInterval forKey:@"LastUploadTimeInterval"];
        }
        
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        
        NSInteger days;
        switch (uploadFrequency) {
            case kNVFrequencyYear:
                days = 365;
                break;
                
            case kNVFrequencyMonth:
                days = 30;
                break;
                
            case kNVFrequencyWeek:
                days = 7;
                break;
                
            case kNVFrequencyDay:
                days = 1;
                break;
                
            default:
                break;
        }
        
        if (currentTimeInterval - self.lastUploadTimeInterval > 60 * 60 * 24 * days) {
            
            [self uploadFileLogWithBlock:uploadBlock];
        }
    }
}

/**
 log 错误信息
 
 @param message 错误信息
 */
- (void)logEror:(NSString *)message {
    
    DDLogError(@"%@", message);
}

/**
 Log 警告信息
 
 @param message 警告信息
 */
- (void)logWarn:(NSString *)message {
    
    DDLogWarn(@"%@", message);
}

/**
 log 普通信息
 
 @param message 普通信息
 */
- (void)logInfo:(NSString *)message {
    
    DDLogInfo(@"%@", message);
}

/**
 log 调试信息
 
 @param message 调试信息
 */
- (void)logDebug:(NSString *)message {
    
    DDLogDebug(@"%@", message);
}


@end
