//
//  SinaShareController.m
//  AppCan
//
//  Created by AppCan on 12-9-14.
//  Copyright (c) 2012年 AppCan. All rights reserved.
//

#import "SinaShareController.h"
#import "WBSDKGlobal.h"
#import "WBUtil.h"
@interface SinaShareController ()

@end

@implementation SinaShareController
@synthesize delegate = _delegate;
@synthesize registerUrl = _registerUrl;
@synthesize appSecret = _appSecret;
@synthesize appKey = _appKey;
#pragma mark -
#pragma mark lifeCircle
#pragma mark -
- (void)dealloc {
	//for view
	[_indicatorView release];
    [_webView removeFromSuperview];
    [_webView release];
    _webView = nil;
	//for data
    if (wbAuthor) {
        wbAuthor.delegate = self;
        [wbAuthor release];
        wbAuthor = nil;
    }
    if (wbRequest) {
        wbRequest.delegate = nil;
        [wbRequest release];
        wbRequest = nil;
    }
    [super dealloc];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	//for view
	[_indicatorView release];
	_indicatorView = nil;
    [_webView removeFromSuperview];
    [_webView release];
    _webView = nil;
	//for data
    if (wbAuthor) {
        wbAuthor.delegate = self;
        [wbAuthor release];
        wbAuthor = nil;
    }
    if (wbRequest) {
        wbRequest.delegate = nil;
        [wbRequest release];
        wbRequest = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"新浪微博";
	[self initData];
	[self initNavBtns];
	[self initViews];
	[self showIndicator:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
// for views
#pragma mark -
#pragma mark for views
#pragma mark -
- (void)initNavBtns {
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *leftBar =[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonSystemItemCancel target:self action:@selector(leftNavBtnClicked)];
    self.navigationItem.leftBarButtonItem = leftBar;
    [leftBar release];
    if (_webView) {
        [_webView removeFromSuperview];
    }
    
}

- (void)initViews {	
}


- (void)showIndicator:(BOOL)show_ {
	if (show_) {
		if (!_indicatorView) {
			_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			_indicatorView.frame = CGRectMake(150, 190, 20, 20);
			[_indicatorView startAnimating];
		}
		[self.view addSubview:_indicatorView];
	}
	else {
		[_indicatorView removeFromSuperview];
	}	
}

-(void)webViewShow{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    _webView = [[UIWebView alloc] initWithFrame:bounds];
    
    _webView.scalesPageToFit = YES;
    _webView.userInteractionEnabled = YES;
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
}
- (void)haveNoData {
	[self showIndicator:NO];
}

#pragma mark -
#pragma mark for event
#pragma mark -
- (void)leftNavBtnClicked {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)rightNavBtnClicked {
}

- (void)titleNavBtnClicked {
}

#pragma mark -
#pragma mark for data
#pragma mark -
- (void)initData {
}

- (void)cleanData {
}
+(BOOL)isValid{
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    id userId = [ud objectForKey:oauth2SianUserID];
    id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
    id expireDate = [ud objectForKey:oauth2SinaExpireInKey];
    if (!userId || !tokenkey || !expireDate) {
        return NO;
    }
    NSDate *curDate = [NSDate date];
    NSDate *earlyDate =[curDate earlierDate:(NSDate*)expireDate];
    if ([earlyDate isEqualToDate:curDate]) {
        return YES;
    }
    return NO;
}
-(void)logIn{
    //授权模式
    if (!wbAuthor) {
        wbAuthor = [[WBAuthorize alloc] initWithAppKey:self.appKey appSecret:self.appSecret];
        [wbAuthor setRedirectURI:self.registerUrl];
        //[wbAuthor setRedirectURI:@"http://"];
        wbAuthor.delegate = self;
        [self webViewShow];
    }
    [wbAuthor startAuthorize:_webView];

}
+(void)logOut{
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:oauth2SianUserID];
    [ud removeObjectForKey:oauth2SinaTokenKey];
    [ud removeObjectForKey:oauth2SinaExpireInKey];
    [ud synchronize];   
}

-(void)shareWithContent:(NSString *)inContent{
    [self sendWeiBoWithText:inContent image:nil];
}

-(void)shareWithImage:(NSString*)inPath andContent:(NSString *)inContent {
       [self sendWeiBoWithText:inContent image:[UIImage imageWithContentsOfFile:inPath]];
}
-(void)shareWithImgUrl:(NSString*)inPath andContent:(NSString *)inContent {
    [self sendWeiBoWithText:inContent imageURL:inPath];
}
#pragma mark  sina private 
#pragma mark Request

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields{
    if (wbRequest) {
        [wbRequest release];
        wbRequest = nil;
    }
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    NSString *tokenkey =[ud objectForKey:oauth2SinaTokenKey];

    wbRequest = [WBRequest requestWithAccessToken:tokenkey
                                                 url:[NSString stringWithFormat:@"%@%@", kWBSDKAPIDomain, methodName]
                                          httpMethod:httpMethod
                                              params:params
                                        postDataType:postDataType
                                    httpHeaderFields:httpHeaderFields
                                            delegate:self];
    [wbRequest retain];
	[wbRequest connect];
}

-(void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    //NSString *sendText = [text URLEncodedString];
	[params setObject:(text ? text : @"") forKey:@"status"];
    if (image)
    {
		[params setObject:image forKey:@"pic"];
        [self loadRequestWithMethodName:@"statuses/upload.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kWBRequestPostDataTypeMultipart
                       httpHeaderFields:nil];
    } else {
        [self loadRequestWithMethodName:@"statuses/update.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kWBRequestPostDataTypeNormal
                       httpHeaderFields:nil];
    }
}
-(void)sendWeiBoWithText:(NSString *)inContent imageURL:(NSString *)inImgUrl{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    //NSString *sendText = [text URLEncodedString];
	[params setObject:(inContent ? inContent : @"") forKey:@"status"];
    [params setObject:inImgUrl forKey:@"url"];
    [self loadRequestWithMethodName:@"statuses/upload_url_text.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kWBRequestPostDataTypeNormal
                       httpHeaderFields:nil];
}
-(void)getFriendShipsList:(NSDictionary*)inDict{
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    NSString *userId =[ud objectForKey:oauth2SianUserID];
    if(!userId){
        return;
    }
    //https://api.weibo.com/2/friendships/friends/bilateral.json
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    //NSString *sendText = [text URLEncodedString];
	[params setObject:userId forKey:@"uid"];
    [params setObject:@"50" forKey:@"count"];
    if (inDict && [inDict count]>0) {
        [params addEntriesFromDictionary:inDict];
    }
    [self loadRequestWithMethodName:@"friendships/friends/bilateral.json"
                             httpMethod:@"GET"
                                 params:params
                           postDataType:kWBRequestPostDataTypeNone
                        httpHeaderFields:nil];
}
#pragma mark -
#pragma mark for delegate
#pragma mark -
#pragma mark for UIWebViewDelegate
/*
 * 当前网页视图被指示载入内容时得到通知，返回yes开始进行加载
 */
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { 
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        if (![code isEqualToString:@"21330"])
        {
            [self showIndicator:NO];
            [wbAuthor requestAccessTokenWithAuthorizeCode:code];
            return NO;
        }
        

    }
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
	[self showIndicator:YES];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self showIndicator:NO];
    NSString *url = _webView.request.URL.absoluteString;
    NSLog(@"web view finish load URL %@", url);
}

/*
 * 页面加载失败时得到通知，可根据不同的错误类型反馈给用户不同的信息
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showIndicator:NO];
    NSLog(@"no network:errcode is %d, domain is %@", error.code, error.domain);
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        [_webView removeFromSuperview];
	}
}

#pragma mark - WBAuthorizeDelegate Methods
- (void)authorize:(WBAuthorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds{
    NSLog(@"theAccessToken=%@",theAccessToken);
    NSLog(@"theUserID=%@",theUserID);
    NSLog(@"seconds=%d",seconds);
    NSDate *expirationDate =nil;
    if (seconds==0) {
        expirationDate = [NSDate distantFuture];
    }else{
        expirationDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:theAccessToken forKey:oauth2SinaTokenKey];
    [ud setObject:theUserID forKey:oauth2SianUserID];
    [ud setObject:expirationDate forKey:oauth2SinaExpireInKey];

    [ud synchronize];
    [self dismissModalViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(SinaLoginSuccess)])
    {
        [_delegate SinaLoginSuccess];
    }
    
}
- (void)authorize:(WBAuthorize *)authorize didFailWithError:(NSError *)error{
    
}
#pragma mark - WBRequestDelegate Methods
- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{
    NSLog(@"result=%@",[result description]);
    if (_delegate && [_delegate respondsToSelector:@selector(requestDidSucceedWithResult:)])
    {
        [_delegate requestDidSucceedWithResult:result];
    }
}

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(requestDidFailedWithResult:)])
    {
        [_delegate requestDidFailedWithResult:error];
    }
}
@end
