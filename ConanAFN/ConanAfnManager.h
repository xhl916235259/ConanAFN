//
//  ConanAfnManager.h
//  ConanAfn
//
//  Created by 柯南 on 2016/12/6.
//  Copyright © 2016年 柯南集团. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ConanAfnBlock.h"
#import "ConanNetStatus.h"
#import "ConanAfnBase.h"
@interface ConanAfnManager : AFHTTPSessionManager


/*
 *网络请求管理单例
 */
+(ConanAfnManager *)sharedInstance;

/**
 *POST~~网络请求,通过Block回调结果
 *
 * @param requestType 请求类型
 * @param url 请求地址
 * @param senDic 请求参数
 * @param successBlock 请求结果返回成功的回调
 * @param failBlock 请求结果返回失败的回调
 * @param showHUB 请求方式是否显示加载视图
 */
-(void)RequestWithURL:(ConanAfnRequestMethodType )requestType
                  Url:(NSString *)url
               Params:(NSDictionary *)senDic
         SuccessBlock:(ConanResponseSuccess )successBlock
         FailureBlock:(ConanResponseFail )failBlock
              ShowHUB:(ConanShowHUDType)showHUB
          ShowMessage:(NSString *)message;

/**
 *ConanAfn~~资源上传(图片、视频、音频),通过Block回调结果
 *
 * @param requestType 请求类型
 * @param url 请求地址
 * @param filePath 文件真实地址
 * @param upLProgress 上传进度
 * @param successBlock 请求结果返回成功的回调
 * @param failBlock 请求结果返回失败的回调
 * @param showHUB 请求方式是否显示加载视图
 * @param message 在加载视图上显示的提示信息
 */
-(ConanURLSessionTask *)UpLoadFileWithURL:(ConanAfnRequestMethodType )requestType
                                      Url:(NSString *)url
                                 FilePath:(NSString *)filePath
                           UploadProgress:(ConanUploadProgress *)upLProgress
                             SuccessBlock:(ConanResponseSuccess )successBlock
                             FailureBlock:(ConanResponseFail )failBlock
                                  ShowHUB:(ConanShowHUDType)showHUB
                              ShowMessage:(NSString *)message;

/*
 *下载文件，进行本地资源保存(保存成功后为path为：type/fileName.ctype)
 *
 *@param requestType 请求类型
 *@param url 请求地址
 *@param senDic 请求参数
 *@param fileName 保存的文件名
 *@param ctype 保存的文件扩展名(后缀名)
 *@param type 保存的文件类型(图片png、视频mp4、音频mp3)(尽量英文命名)
 *@param filePathType 保存的文件位置
 *@param progressBlock 请求下载进度的回调
 *@param successBlock 请求结果返回成功的回调
 *@param failBlock 请求结果返回失败的回调
 *@param showType 请求方式是否显示加载视图
 *@param message 在加载视图上显示的提示信息(可为空)
 */

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
                                ShowMessage:(NSString *)message;

@end


