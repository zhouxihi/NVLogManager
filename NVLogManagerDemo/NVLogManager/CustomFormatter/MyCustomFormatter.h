//
//  MyCustomFormatter.h
//  LumberjackDemo
//
//  Created by Jackey on 2017/6/3.
//  Copyright © 2017年 com.zhouxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCustomFormatter : NSObject <DDLogFormatter> {
    
    int loggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end
