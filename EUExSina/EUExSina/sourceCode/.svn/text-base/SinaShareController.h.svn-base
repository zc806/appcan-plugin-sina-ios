//
//  SinaShareController.h
//  AppCan
//
//  Created by AppCan on 12-9-14.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
//sina
#import "WBAuthorize.h"
//新浪分享
//#define SinaAppKey              @"1874274844"
//#define SinaAppSecret           @"3f4b0dbdfb45048118445cf28cdc16e3"
//#define SinaRedirectUri         @"http://ytb.shm.com.cn"
//
/*#define SinaAppKey              @"556039682"
#define SinaAppSecret           @"f0a22010740b6d8c738bb28b5c3a21cf"
#define SinaRedirectUri         @"http://www.3g2win.com/"*/

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define oauth2SianUserID                @"WeiBoUserID"
#define oauth2SinaTokenKey              @"WeiBoAccessToken"
#define oauth2SinaExpireInKey           @"WeiBoExpireTime"

@protocol SinaShareControllerDelegate <NSObject>
@optional
-(void)SinaLoginSuccess;
-(void)requestDidSucceedWithResult:(id)result;
-(void)requestDidFailedWithResult:(id)result;
@end
@interface SinaShareController : UIViewController<UIWebViewDelegate,WBAuthorizeDelegate,WBRequestDelegate>{
    UIActivityIndicatorView *_indicatorView;
    UIWebView *_webView;
    WBAuthorize *wbAuthor;
    WBRequest *wbRequest;
}
@property(nonatomic,copy)NSString *appKey;
@property(nonatomic,copy)NSString *registerUrl;
@property(nonatomic,copy)NSString *appSecret;
@property(nonatomic,assign)id<SinaShareControllerDelegate> delegate;
-(void)logIn;
-(void)shareWithContent:(NSString*)inContent;
-(void)shareWithImage:(NSString*)inPath andContent:(NSString *)inContent;
+(BOOL)isValid;
+(void)logOut;
-(void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image;
-(void)getFriendShipsList:(NSDictionary*)inDict;
-(void)shareWithImgUrl:(NSString*)inPath andContent:(NSString *)inContent;
@end