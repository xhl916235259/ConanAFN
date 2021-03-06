//
//  ConanAfnAPI.m
//  ConanAfn
//
//  Created by 柯南 on 2016/12/11.
//  Copyright © 2016年 柯南集团. All rights reserved.
//

#import "ConanAfnAPI.h"


static NSString *baseUrl = nil;

@implementation ConanAfnAPI

+(void)ConfigConanAfnBaseUrl:(NSString *)url
{
    baseUrl = url;
}

/*
 *设置BaseURL
 */
+(NSString *)setNetUrl :(NSString *)url
{
    NSString *ProductUrl=[NSString stringWithFormat:@"%@%@",baseUrl,url];
    ConanLog(@"%@",ProductUrl);
    return ProductUrl;
}



#pragma mark ==========APP AFNAPI==========

+(void)RequestWithURL:(ConanAfnRequestMethodType )requestType
                  Url:(NSString *)url
               Params:(NSDictionary *)senDic
         SuccessBlock:(ConanResponseSuccess )successBlock
         FailureBlock:(ConanResponseFail )failBlock
              ShowHUB:(ConanShowHUDType)showHUB
          ShowMessage:(NSString *)message
{
    [[ConanAfnManager sharedInstance] RequestWithURL:requestType Url:[self setNetUrl:url] Params:senDic SuccessBlock:^(id returnData) {
        if (successBlock) {
            successBlock(returnData);
        }
    } FailureBlock:^(NSError *error) {
        if (failBlock) {
            failBlock(error);
        }
    } ShowHUB:showHUB ShowMessage:message];
}

+(ConanURLSessionTask *)DownloadFileWithURL:(ConanAfnRequestMethodType )requestType
                                        Url:(NSString *)url
                                     Params:(NSDictionary *)senDic
                               SaveFileName:(NSString *)fileName
                              SaveFileCtype:(NSString *)ctype
                               SaveFileType:(NSString *)type
                               SaveFilePath:(ConanCacheFilePathType )filePathType
                                   Progress:(ConanDownloadProgress )progressBlock
                               SuccessBlock:(ConanResponseDownloadSuccess )successBlock
                               FailureBlock:(ConanResponseFail )failBlock
                                    ShowHUD:(ConanShowHUDType )showType
                                ShowMessage:(NSString *)message
{
    ConanURLSessionTask *sessionTask = nil;
    
   sessionTask = [[ConanAfnManager sharedInstance] DownloadFileWithURL:requestType Url:[self setNetUrl:url] Params:senDic SaveFileName:fileName SaveFileCtype:ctype SaveFileType:type SaveFilePath:filePathType Progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpectedToRead) {
       if(progressBlock)
       {
           progressBlock(bytesRead,totalBytesRead,totalBytesExpectedToRead);
       }
   } SuccessBlock:^(id returnData, NSString *filePath) {
       if(successBlock)
       {
           successBlock(returnData,filePath);
       }
   } FailureBlock:^(NSError *error) {
       if(failBlock)
       {
           failBlock(error);
       }
   } ShowHUD:showType ShowMessage:message];
    
    [sessionTask resume];
    
    return sessionTask;
}
@end
