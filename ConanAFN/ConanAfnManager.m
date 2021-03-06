//
//  ConanAfnManager.m
//  ConanAfn
//
//  Created by 柯南 on 2016/12/6.
//  Copyright © 2016年 柯南集团. All rights reserved.
//

#import "ConanAfnManager.h"
#import "ConanShowAutoDismissAlertMessageView.h"
#import "ConanSaveFilePath.h"

static ConanAfnManager *conanAfn;
#define ConanFileManager  [NSFileManager defaultManager]
@implementation ConanAfnManager

+(ConanAfnManager *)sharedInstance
{
    [[ConanNetStatus sharedInstance] listening];
    switch ([ConanNetStatus currentReachabilityStatus]) {
        case 0:
            ConanLog(@"无网");
            break;
        case 1:
            ConanLog(@"WI-FI");
            break;
        case 2:
            ConanLog(@"移动");
            break;
        case 3:
            ConanLog(@"2G");
            break;
        case 4:
            ConanLog(@"3G");
            break;
        case 5:
            ConanLog(@"4G");
            break;
            
        default:
            ConanLog(@"无网");

            break;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        conanAfn =[[ConanAfnManager alloc]initWithBaseURL:nil];
        
    });
    return conanAfn;
}

#pragma mark ============ 数据请求 =================
-(void)RequestWithURL:(ConanAfnRequestMethodType )requestType
                  Url:(NSString *)url
               Params:(NSDictionary *)senDic
         SuccessBlock:(ConanResponseSuccess )successBlock
         FailureBlock:(ConanResponseFail )failBlock
              ShowHUB:(ConanShowHUDType)showHUB
          ShowMessage:(NSString *)message
{
    switch (requestType) {
        case ConanAfnRequestMethodTypeGET://GET
            
            [self GETWithURL:url Params:senDic SuccessBlock:successBlock FailureBlock:failBlock ShowHUB:showHUB ShowMessage:message];
            break;
        case ConanAfnRequestMethodTypePOST://POST
            [self POSTWithURL:url Params:senDic SuccessBlock:successBlock FailureBlock:failBlock ShowHUB:showHUB ShowMessage:message];
            break;
            
        default:
            break;
    }
}

/*
 *GET网络请求,通过Block回调结果
 */
-(void)GETWithURL:(NSString *)url
           Params:(NSDictionary *)senDic
     SuccessBlock:(ConanResponseSuccess )successBlock
     FailureBlock:(ConanResponseFail )failBlock
          ShowHUB:(ConanShowHUDType)showHUB
      ShowMessage:(NSString *)message
{
    NSURLSessionTask *GETsessionTask = nil;
    
    [self showHud:showHUB ShowMessage:message];
    
    AFHTTPSessionManager *manager=[ConanAfnBase manager];
    
   GETsessionTask= [manager GET:url parameters:senDic progress:^(NSProgress * _Nonnull downloadProgress) {

   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [self dismissHud:showHUB];

        ConanLog(@"请求地址：%@;\n\n请求参数：%@··\n\n返回结果：%@。\n\n",url,senDic,responseObject);
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [self dismissHud:showHUB];

        ConanLog(@"error~~%@",error);
        if (failBlock) {
            failBlock(error);
        }
    }];
    
    [GETsessionTask resume];
}

/*
 *POST网络请求,通过Block回调结果
 */
-(void)POSTWithURL:(NSString *)url
            Params:(NSDictionary *)senDic
      SuccessBlock:(ConanResponseSuccess )successBlock
      FailureBlock:(ConanResponseFail )failBlock
           ShowHUB:(ConanShowHUDType)showHUB
       ShowMessage:(NSString *)message
{
    NSURLSessionTask *POSTsessionTask = nil;
    [self showHud:showHUB ShowMessage:message];

    AFHTTPSessionManager *manager=[ConanAfnBase manager];
   POSTsessionTask= [manager POST:url parameters:senDic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self dismissHud:showHUB];
        
        ConanLog(@"请求地址：%@;\n请求参数：%@··\n返回结果：%@。\n",url,senDic,responseObject);
        if (successBlock) {
            successBlock(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self dismissHud:showHUB];

        ConanLog(@"error~~%@",error);
        if (failBlock) {
            failBlock(error);
        }
    }];
    
    [POSTsessionTask resume];
}
#pragma mark ============ 文件上传和下载 =================
-(ConanURLSessionTask *)UpLoadFileWithURL:(ConanAfnRequestMethodType )requestType
                                      Url:(NSString *)url
                                 FilePath:(NSString *)filePath
                           UploadProgress:(ConanUploadProgress *)upLProgress
                             SuccessBlock:(ConanResponseSuccess )successBlock
                             FailureBlock:(ConanResponseFail )failBlock
                                  ShowHUB:(ConanShowHUDType)showHUB
                              ShowMessage:(NSString *)message
{
    switch (requestType) {
        case ConanAfnRequestMethodTypeGET:
            return nil;
            break;
            case ConanAfnRequestMethodTypePOST:
            return [self PostUpLoadFileWithURL:ConanAfnRequestMethodTypePOST Url:url FilePath:filePath UploadProgress:upLProgress SuccessBlock:^(id returnData) {
                if (successBlock) {
                    successBlock(returnData);
                }
            } FailureBlock:^(NSError *error) {
                if (failBlock) {
                    failBlock(error);
                }
            } ShowHUB:showHUB ShowMessage:message];
            break;
            
        default:
            return nil;
            break;
    }
}

-(ConanURLSessionTask *)PostUpLoadFileWithURL:(ConanAfnRequestMethodType )requestType
                                      Url:(NSString *)url
                                 FilePath:(NSString *)filePath
                           UploadProgress:(ConanUploadProgress *)upLProgress
                             SuccessBlock:(ConanResponseSuccess )successBlock
                             FailureBlock:(ConanResponseFail )failBlock
                                  ShowHUB:(ConanShowHUDType)showHUB
                              ShowMessage:(NSString *)message
{
    NSURL *Url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]];

    NSURLRequest *requestUrl = [NSURLRequest requestWithURL:Url];
    
    NSURL *filePathUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",filePath]];
    
    AFHTTPSessionManager *manager=[ConanAfnBase manager];

    ConanURLSessionTask *conanSessionTask = nil;
    
    [manager uploadTaskWithRequest:requestUrl fromFile:filePathUrl progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [[ConanAfnBase AllTasks] removeObject:conanSessionTask];
        [ConanAfnBase SuccessResponse:responseObject Callback:successBlock];
        
    }];
    
    if (conanSessionTask) {
        [[ConanAfnBase AllTasks] addObject:conanSessionTask];
    }
    
    return conanSessionTask;
}



-(ConanURLSessionTask *)DownloadFileWithURL:(ConanAfnRequestMethodType )requestType
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
    switch (requestType) {
        case ConanAfnRequestMethodTypeGET:
            return [self GetDownloadFileWithURL:requestType Url:url Params:senDic SaveFileName:fileName SaveFileCtype:ctype SaveFileType:type SaveFilePath:filePathType Progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpectedToRead) {
                if (progressBlock) {
                    progressBlock(bytesRead,totalBytesRead,totalBytesExpectedToRead);
                }
            } SuccessBlock:^(id returnData, NSString *filePath) {
                if(successBlock)
                {
                    successBlock(returnData,filePath);
                }
            } FailureBlock:^(NSError *error) {
                if (failBlock) {
                    failBlock(error);
                }
            } ShowHUD:showType ShowMessage:message];
            
            break;
        case ConanAfnRequestMethodTypePOST:
            return [self PostDownloadFileWithURL:requestType Url:url Params:senDic SaveFileName:fileName SaveFileCtype:ctype SaveFileType:type SaveFilePath:filePathType Progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpectedToRead) {
                if (progressBlock) {
                    progressBlock(bytesRead,totalBytesRead,totalBytesExpectedToRead);
                }
            } SuccessBlock:^(id returnData, NSString *filePath) {
                if(successBlock)
                {
                    successBlock(returnData,filePath);
                }
            } FailureBlock:^(NSError *error) {
                if (failBlock) {
                    failBlock(error);
                }
            } ShowHUD:showType ShowMessage:message];
            
            break;
            
        default:
            return nil;
            break;
    }

}


-(ConanURLSessionTask *)GetDownloadFileWithURL:(ConanAfnRequestMethodType )requestType
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
                                   ShowMessage:(NSString *)message{
    
    AFHTTPSessionManager *manager=[ConanAfnBase manager];
    //增加Serializer设置，文件下载，以防止下载失败
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *filePath = [ConanSaveFilePath ConanConanSaveFilePath:filePathType FileType:type FileName:fileName FileCtype:ctype];
    
    NSString *file = [ConanSaveFilePath ConanConanSaveFilePath:filePathType FileType:type FileName:@"" FileCtype:@""];
    
    BOOL isExist = [ConanFileManager fileExistsAtPath:file];
    
    if (!isExist)
    {
        [ConanFileManager createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }

    ConanURLSessionTask *conanSessionTask = nil;
    
    [manager GET:url parameters:senDic progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount,downloadProgress.totalUnitCount,downloadProgress.totalUnitCount-downloadProgress.completedUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         ConanLog(@"请求地址：\n%@;\n请求参数：\n%@\n返回路径filePath：\n%@",url,senDic,filePath);
        if (successBlock) {
            NSData *fileData =responseObject;
            BOOL wroteToFileIsSuccess = [fileData writeToFile:filePath atomically:YES];
            
            if (wroteToFileIsSuccess) {
                NSLog(@"wroteToFileIsSuccess~~success");
                successBlock(responseObject,filePath);
            } else {
                NSLog(@"wroteToFileIsSuccess~~failure");
                successBlock(responseObject,@"");
            }

        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ConanLog(@"332error~~%@",error);
        if (failBlock) {
            failBlock(error);
        }
    }];

    [conanSessionTask resume];
    return conanSessionTask;
}

-(ConanURLSessionTask *)PostDownloadFileWithURL:(ConanAfnRequestMethodType )requestType
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
                                    ShowMessage:(NSString *)message{
    
    AFHTTPSessionManager *manager=[ConanAfnBase manager];
    //增加Serializer设置，文件下载，以防止下载失败
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *filePath = [ConanSaveFilePath ConanConanSaveFilePath:filePathType FileType:type FileName:fileName FileCtype:ctype];
    
    NSString *file = [ConanSaveFilePath ConanConanSaveFilePath:filePathType FileType:type FileName:@"" FileCtype:@""];
    
    BOOL isExist = [ConanFileManager fileExistsAtPath:file];
    
    if (!isExist)
    {
        [ConanFileManager createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    ConanURLSessionTask *conanSessionTask = nil;

  conanSessionTask = [manager POST:url parameters:senDic progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.completedUnitCount,uploadProgress.totalUnitCount,uploadProgress.totalUnitCount-uploadProgress.completedUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ConanLog(@"请求地址：\n%@;\n请求参数：\n%@\n返回路径filePath：\n%@",url,senDic,filePath);
        if (successBlock) {
            NSData *fileData =responseObject;
            BOOL wroteToFileIsSuccess = [fileData writeToFile:filePath atomically:YES];
            
            if (wroteToFileIsSuccess) {
                NSLog(@"wroteToFileIsSuccess~~success");
                successBlock(responseObject,filePath);
            } else {
                NSLog(@"wroteToFileIsSuccess~~failure");
                successBlock(responseObject,@"");
            }
            
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
    
    [conanSessionTask resume];
    return conanSessionTask;
}



#pragma mark ============ 弹框展示与消失 =================
-(void)showHud : (ConanShowHUDType )showHud  ShowMessage:(NSString *)message
{
    switch (showHud ) {
            
        case ConanShowHUD:
            [[ConanAfnBase sharedInstance].conanHud showAnimated:YES];
            break;
        case ConanShowHUDMessage:
            [ConanAfnBase sharedInstance].conanHud.label.text = message;
            break;
        case ConanShowAutoDismissLoadingMessage:
            [ConanShowAutoDismissAlertMessageView ConanShowLoading:message];
            break;
        case ConanShowAutoDismissSuccessMessage:
            [ConanShowAutoDismissAlertMessageView ConanShowSuccessMessage:message];
            break;
        case ConanShowAutoDismissFailMessage:
            [ConanShowAutoDismissAlertMessageView ConanShowFailMessage:message];
            break;
        case ConanShowNothing:
            ConanLog(@"ConanShowNothing");
            break;
            
        default:
            ConanLog(@"ConanShowHUDTypeDefault");
            break;
    }
}

-(void)dismissHud :(ConanShowHUDType )disMissHud
{
    switch (disMissHud) {
            
        case ConanShowHUD:
            [[ConanAfnBase sharedInstance].conanHud hideAnimated:YES];
            break;
        case ConanShowHUDMessage:
            [[ConanAfnBase sharedInstance].conanHud hideAnimated:YES];
            break;
        case ConanShowAutoDismissLoadingMessage:
            [ConanShowAutoDismissAlertMessageView ConanShowDismissHud];
            break;
        case ConanShowAutoDismissSuccessMessage:
            [ConanShowAutoDismissAlertMessageView ConanShowDismissHud];
            break;
        case ConanShowAutoDismissFailMessage:
           [ConanShowAutoDismissAlertMessageView ConanShowDismissHud];
            break;

        case ConanShowNothing:
            ConanLog(@"ConanShowNothing");
            break;
            
        default:
            ConanLog(@"ConanShowHUDTypeDefault");
            break;
    }

}

@end
