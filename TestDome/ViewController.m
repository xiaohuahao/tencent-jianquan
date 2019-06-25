//
//  ViewController.m
//  TestDome
//
//  Created by 张豪 on 2019/6/25.
//  Copyright © 2019 张豪. All rights reserved.
//

#import "ViewController.h"
#import "AFNetWorking.h"
#import<CommonCrypto/CommonDigest.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    
    NSString *app_id = @"你应用的APPID";
    NSString *APPKEY = @"你应用的APPKEY";
    NSString *time_stamp = [self getNowTime];
    NSString *nonce_str = [self randomStringWithLength:10];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary: @{
                                                                                    @"app_id":app_id,
                                                                                    @"time_stamp":time_stamp,
                                                                                    @"nonce_str":nonce_str,
                                                                                    @"session":@"10000",
                                                                                    @"question":@"你好？"
                                                                                    }];
    
    
    NSString *paramsAppend = [self sortedDictionary:params withAPPKEY:APPKEY];
    NSString *sign = [self md5:paramsAppend];
    params[@"sign"] = [sign uppercaseString];
    
    [self post:@"https://api.ai.qq.com/fcgi-bin/nlp/nlp_textchat" andData:params andCallback:^(id JSON) {
        NSLog(@"--%@", JSON);
    }];
}

#pragma mark --- 请求
- (void)post:(NSString *)url
     andData:(NSDictionary *)params
 andCallback:(void (^)(id JSON))callback{
    __block  AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",nil];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (callback) {
            callback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(error.code == -1009) {
            if (callback) {
                callback(nil);
            }
        } else if(error.code == -1001) {
            //网络超时
            if (callback) {
                callback(nil);
            }
            
        } else {
            if (callback) {
                callback(nil);
            }
            NSLog(@"Error: %@", error);
        }
    }];
}

#pragma mark --- 生成随机字符串
-(NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

#pragma mark --- 获取当前时间戳---10位
- (NSString *)getNowTime{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", time];
    
    return timeSp;
}

#pragma mark --- 字典的升序排列
- (NSString *)sortedDictionary:(NSDictionary *)dict withAPPKEY:(NSString *)APPKEY{
    //对数组进行排序
    NSArray *sortArray = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //通过排列的key值获取value
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortsing in sortArray) {
        NSString *valueString = [dict objectForKey:sortsing];
        valueString = [valueString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [valueArray addObject:valueString];
    }
    
    NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
        [signArray addObject:keyValueStr];
    }
    
    NSString *appendKey = [NSString stringWithFormat:@"%@=%@",@"app_key",APPKEY];
    [signArray addObject:appendKey];
    
    NSString *sign = [signArray componentsJoinedByString:@"&"];
    
    return sign;
}

#pragma mark --- md5加密
- (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
           
    return  output;
}



@end




