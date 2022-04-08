#import "WechatApi.h"
#import <React/RCTLog.h>

// Define error messages
#define NOT_REGISTERED (@"registerApp required.")
#define INVOKE_FAILED (@"WeChat API invoke returns false.")


@interface WechatApi ()
@property (nonatomic, copy) NSString* appId;
@end
@implementation WechatApi {
    bool hasListeners;
}

RCT_EXPORT_MODULE()
- (void)startObserving {
    hasListeners = YES;
    
}
- (void)stopObserving {
    hasListeners = NO;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"RCTOpenURLNotification" object:nil];
              // 在register之前打开log, 后续可以根据log排查问题
              [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
                  RCTLogInfo(@"WeChatSDK: %@", log);
              }];
    }
    return self;
}

- (BOOL)handleOpenURL:(NSNotification *)aNotification
{
    NSString * aURLString =  [aNotification userInfo][@"url"];
    NSURL * aURL = [NSURL URLWithString:aURLString];

    if ([WXApi handleOpenURL:aURL delegate:self])
    {
        return YES;
    } else {
        return NO;
    }
}
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}
// 获取网络图片的公共方法
- (UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}
// 压缩图片
- (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    if (data.length > maxLength) {
        return [self compressImage:resultImage toByte:maxLength];
    }
    
    return data;
}
// 注册微信 app id
RCT_REMAP_METHOD(registerApp, appid:(NSString *)appid universalLink:(NSString*)universalLink resolver: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        self.appId = appid;
        resolve(@([WXApi registerApp: appid universalLink: universalLink]));
    } @catch (NSException *exception) {
        reject(@"-10404", [NSString stringWithFormat:@"%@ %@", exception.name, exception.userInfo], nil);
    }
}
// 检查微信是否已被用户安装, 微信已安装返回YES，未安装返回NO。
RCT_EXPORT_METHOD(isWXAppInstalled:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if ([WXApi isWXAppInstalled]) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
}
// 判断当前微信的版本是否支持OpenApi，支持返回YES，不支持返回NO。
RCT_EXPORT_METHOD(isWXAppSupportApi: (RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject) {
    if ([WXApi isWXAppSupportApi]) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
}
/*! @brief 打开微信
 * @return 成功返回YES，失败返回NO。
 */
RCT_EXPORT_METHOD(openWXApp: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if ([WXApi openWXApp]) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
}
RCT_EXPORT_METHOD(sendAuthRequest:(NSString *)scope
                  state:(NSString *)state
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    SendAuthReq * req = [[SendAuthReq alloc] init];
    req.scope = scope;
    req.state = state;
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"获取授权失败",INVOKE_FAILED,nil);
        }
    }];
    
}
// 获取当前微信SDK的版本号
RCT_EXPORT_METHOD(getApiVersion: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([WXApi getApiVersion]);
}
/*! @brief 发送请求到微信，等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持以下类型
 * SendAuthReq、SendMessageToWXReq、PayReq等。
 * @param req 具体的发送请求。
 * @param completion 调用结果回调block
 */
RCT_REMAP_METHOD(sendRequest, openid:(NSString *)openid
                 resolver: (RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    @try {
        BaseReq * req = [[BaseReq alloc] init];
        req.openID = openid;
        [WXApi sendReq:req completion:^(BOOL success) {
            if (success) {
                resolve(@YES);
            } else {
                reject(@"-10405", [NSString stringWithFormat:@"%@", INVOKE_FAILED], nil);
            }
        }];
    } @catch (NSException *exception) {
        reject(@"-10404", [NSString stringWithFormat:@"%@ %@", exception.name, exception.userInfo], nil);
    }
}
RCT_EXPORT_METHOD(shareWebpage:(NSDictionary *)data
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = data[@"webpageUrl"];
    WXMediaMessage *message = [WXMediaMessage message];
        message.title = data[@"title"];
        message.description = data[@"description"];
        NSString *thumbImageUrl = data[@"thumbImageUrl"];
        if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
            UIImage *image = [self getImageFromURL:thumbImageUrl];
            message.thumbData = [self compressImage: image toByte:32678];
        }
        message.mediaObject = webpageObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = [data[@"scene"] intValue];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享",@"网页内容失败",nil);
        }
    }];
}
RCT_EXPORT_METHOD(shareText:(NSDictionary *)data
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = YES;
        req.text = data[@"text"];
        req.scene = [data[@"scene"] intValue];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享文本",INVOKE_FAILED,nil);
        }
    }];
}
// 分享文件
RCT_EXPORT_METHOD(shareFile:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *url = data[@"url"];
    WXFileObject *file =  [[WXFileObject alloc] init];
    file.fileExtension = data[@"ext"];
    NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString: url]];
    file.fileData = fileData;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data[@"title"];
    message.mediaObject = file;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [data[@"scene"] intValue];
    
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享文件",INVOKE_FAILED,nil);
        }
    }];
}

// 分享图片
RCT_EXPORT_METHOD(shareImage:(NSDictionary *)data resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *imageUrl = data[@"imageUrl"];
    if (imageUrl == NULL  || [imageUrl isEqual:@""]) {
        reject(@"分享图片失败",@"图片的ImageUrl 不能为空",nil);
        return;
    }
    NSRange range = [imageUrl rangeOfString:@"."];
    if ( range.length == 0)
    {
        reject(@"分享图片失败",@"图片的后缀不存在",nil);
        return;
    }
    
    // 根据路径下载图片
    UIImage *image = [self getImageFromURL:imageUrl];
    // 从 UIImage 获取图片数据
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    // 用图片数据构建 WXImageObject 对象
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = imageData;
    
    WXMediaMessage *message = [WXMediaMessage message];
    // 利用原图压缩出缩略图，确保缩略图大小不大于32KB
    message.thumbData = [self compressImage: image toByte:32678];
    message.mediaObject = imageObject;
    message.title = data[@"title"];
    message.description = data[@"description"];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [data[@"scene"] intValue];
    //    [WXApi sendReq:req];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享",@"图片失败",nil);
        }
    }];
}

// 分享音乐
RCT_EXPORT_METHOD(shareMusic:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    WXMusicObject *musicObject = [WXMusicObject object];
    musicObject.musicUrl = data[@"musicUrl"];
    musicObject.musicLowBandUrl = data[@"musicLowBandUrl"];
    musicObject.musicDataUrl = data[@"musicDataUrl"];
    musicObject.musicLowBandDataUrl = data[@"musicLowBandDataUrl"];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data[@"title"];
    message.description = data[@"description"];
    NSString *thumbImageUrl = data[@"thumbImageUrl"];
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
        // 根据路径下载图片
        UIImage *image = [self getImageFromURL:thumbImageUrl];
        message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = musicObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [data[@"scene"] intValue];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享音乐",INVOKE_FAILED,nil);
        }
    }];
}
// 分享视频
RCT_EXPORT_METHOD(shareVideo:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    WXVideoObject *videoObject = [WXVideoObject object];
    videoObject.videoUrl = data[@"videoUrl"];
    videoObject.videoLowBandUrl = data[@"videoLowBandUrl"];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data[@"title"];
    message.description = data[@"description"];
    NSString *thumbImageUrl = data[@"thumbImageUrl"];
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
        UIImage *image = [self getImageFromURL:thumbImageUrl];
        message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = videoObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [data[@"scene"] intValue];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享视频",INVOKE_FAILED,nil);
        }
    }];
}
// 分享本地图片
RCT_EXPORT_METHOD(shareLocalImage:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *imageUrl = data[@"imageUrl"];
    if (imageUrl == NULL  || [imageUrl isEqual:@""]) {
        reject(@"分享本地图片失败",@"图片的ImageUrl 不能为空",nil);
        return;
    }
    NSRange range = [imageUrl rangeOfString:@"."];
    if ( range.length == 0)
    {
        reject(@"分享本地图片失败",@"图片的后缀不存在",nil);
        return;
    }
    
    // 根据路径下载图片
    UIImage *image = [UIImage imageWithContentsOfFile:imageUrl];
    // 从 UIImage 获取图片数据
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    // 用图片数据构建 WXImageObject 对象
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = imageData;
    
    WXMediaMessage *message = [WXMediaMessage message];
    // 利用原图压缩出缩略图，确保缩略图大小不大于32KB
    message.thumbData = [self compressImage: image toByte:32678];
    message.mediaObject = imageObject;
    message.title = data[@"title"];
    message.description = data[@"description"];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [data[@"scene"] intValue];
    //    [WXApi sendReq:req];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享本地图片",INVOKE_FAILED,nil);
        }
    }];
}
// 分享小程序
RCT_EXPORT_METHOD(shareMiniProgram:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject)
{
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = data[@"webpageUrl"];
    object.userName = data[@"userName"];
    object.path = data[@"path"];
    NSString *hdImageUrl = data[@"hdImageUrl"];
    if (hdImageUrl != NULL && ![hdImageUrl isEqual:@""]) {
        UIImage *image = [self getImageFromURL:hdImageUrl];
        // 压缩图片到小于128KB
        object.hdImageData = [self compressImage: image toByte:131072];
    }
    object.withShareTicket = data[@"withShareTicket"];
    object.miniProgramType = [data[@"miniProgramType"] integerValue];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = data[@"title"];
    message.description = data[@"description"];
    //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    NSString *thumbImageUrl = data[@"thumbImageUrl"];
    if (thumbImageUrl != NULL && ![thumbImageUrl isEqual:@""]) {
        UIImage *image = [self getImageFromURL:thumbImageUrl];
        message.thumbData = [self compressImage: image toByte:32678];
    }
    message.mediaObject = object;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = [data[@"scene"] intValue];
   
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"分享小程序错误",INVOKE_FAILED,nil);
        }
    }];
}
RCT_EXPORT_METHOD(subscribeMessage:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    WXSubscribeMsgReq *req = [[WXSubscribeMsgReq alloc] init];
    req.scene = [data[@"scene"] intValue];
    req.templateId = data[@"templateId"];
    req.reserved = data[@"reserved"];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"订阅消息错误",INVOKE_FAILED,nil);
        }
    }];
    
}
// 选择发票
RCT_EXPORT_METHOD(chooseInvoice:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject)
{
    WXChooseInvoiceReq *req = [[WXChooseInvoiceReq alloc] init];
    req.appID = self.appId;
    req.timeStamp = [data[@"timeStamp"] intValue];
    req.nonceStr = data[@"nonceStr"];
    req.cardSign = data[@"cardSign"];
    req.signType = data[@"signType"];
    
    [WXApi sendReq:launchMiniProgramReq completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"选择发票错误",INVOKE_FAILED,nil);
        }
    }];
}
RCT_EXPORT_METHOD(launchMiniProgram:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject)
{
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    // 拉起的小程序的username
    launchMiniProgramReq.userName = data[@"userName"];
    // 拉起小程序页面的可带参路径，不填默认拉起小程序首页
    launchMiniProgramReq.path = data[@"path"];
    // 拉起小程序的类型
    launchMiniProgramReq.miniProgramType = [data[@"miniProgramType"] integerValue];
    [WXApi sendReq:launchMiniProgramReq completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"唤起小程序错误",INVOKE_FAILED,nil);
        }
    }];
}
// 拉起微信客服
RCT_EXPORT_METHOD(launchCustomerService:(NSDictionary *)data resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject ) {
    WXOpenCustomerServiceReq * req = [[WXOpenCustomerServiceReq alloc] init];
    req.url = data[@"url"];
    req.corpid = data[@"corpid"];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"拉起微信客服错误",INVOKE_FAILED,nil);
        }
    }];
}
RCT_EXPORT_METHOD(pay:(NSDictionary *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    PayReq* req             = [PayReq new];
    req.partnerId           = data[@"partnerId"];
    req.prepayId            = data[@"prepayId"];
    req.nonceStr            = data[@"nonceStr"];
    req.timeStamp           = [data[@"timeStamp"] unsignedIntValue];
    req.package             = data[@"package"];
    req.sign                = data[@"sign"];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            resolve(@YES);
        } else {
            reject(@"唤起微信支付",INVOKE_FAILED,nil);
        }
    }];
}

#pragma mark WXAPI-Delegate
- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
        NSString *appParameter = launchReq.message.messageExt;
        NSMutableDictionary *body = @{@"errCode":@0}.mutableCopy;
        body[@"type"] = @"LaunchFromWX.Req";
        body[@"lang"] =  launchReq.lang;
        body[@"country"] = launchReq.country;
        body[@"extMsg"] = appParameter;
        if (hasListeners) {
            [self sendEventWithName:RCTWXEventNameWeChatReq body:body];
        }
    }
}
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *r = (SendMessageToWXResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"lang"] = r.lang;
        body[@"country"] =r.country;
        body[@"type"] = @"SendMessageToWX.Resp";
        if (hasListeners) {
            [self sendEventWithName:RCTWXEventName body:body];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *r = (SendAuthResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"state"] = r.state;
        body[@"lang"] = r.lang;
        body[@"country"] =r.country;
        body[@"type"] = @"SendAuth.Resp";
                
        if (resp.errCode == WXSuccess) {
            if (self.appId && r) {
                // ios第一次获取不到appid会卡死，加个判断OK
                [body addEntriesFromDictionary:@{@"appid":self.appId, @"code":r.code}];
                [self sendEventWithName:RCTWXEventName body:body];
            }
        } else {
            [self sendEventWithName:RCTWXEventName body:body];
        }
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *r = (PayResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"type"] = @(r.type);
        body[@"returnKey"] =r.returnKey;
        body[@"type"] = @"PayReq.Resp";
        [self sendEventWithName:RCTWXEventName body:body];
        
    } else if([resp isKindOfClass:[WXLaunchMiniProgramResp class]]) {
        WXLaunchMiniProgramResp *r = (WXLaunchMiniProgramResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"extMsg"] = r.extMsg;
        body[@"type"] = @"WXLaunchMiniProgramReq.Resp";
        [self sendEventWithName:RCTWXEventName body:body];
    } else if([resp isKindOfClass:[WXOpenCustomerServiceResp class]]) {
        WXOpenCustomerServiceResp *r = (WXOpenCustomerServiceResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"extMsg"] = r.extMsg;
        body[@"type"] = @"WXOpenCustomerServiceReq.Resp";
        [self sendEventWithName:RCTWXEventName body:body];
    } else if ([resp isKindOfClass:[WXChooseInvoiceResp class]]){
        WXChooseInvoiceResp *r = (WXChooseInvoiceResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (WXCardItem* cardItem in r.cardAry) {
            NSMutableDictionary *item = @{@"cardId":cardItem.cardId,@"encryptCode":cardItem.encryptCode,@"appId":cardItem.appID}.mutableCopy;
            [arr addObject:item];
        }
        body[@"cards"] = arr;
        body[@"type"] = @"WXChooseInvoiceResp.Resp";
        [self sendEventWithName:RCTWXEventName body:body];
    }
}
@end
