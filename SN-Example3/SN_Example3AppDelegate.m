//
//  SN_Example3AppDelegate.m
//  SN-Example3
//
//  Created by Yuka Wada on 12/06/15.
//  Copyright (c) 2012年 CONIT CO.,LTD. All rights reserved.
//

#import "SN_Example3AppDelegate.h"

#import "SN_Example3ViewController.h"


// SN_SERVER_URLとSN_ACCESS_TOKENは、SamuraiNotification登録後に発行されますので適宜書き換えてください

 #define SN_SERVER_URL @"https://アプリに割り当てられたAPIサーバのホスト名/v2/ios/devices/"
 
 #ifdef DEBUG
 #define SN_ACCESS_TOKEN @"<SANDBOX環境token>"
 #else
 #define SN_ACCESS_TOKEN @"<LIVE環境token>"
 #endif



@implementation SN_Example3AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

// midのアクセサを自動生成します。
@synthesize mid = _mid;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     No.8
     midを取得します。
     （launchOptionsは、リモート通知によるメッセージより起動した場合のみ情報を取得できます。）
     */
    
    self.mid = nil;
    if (launchOptions) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo) {
            self.mid = [userInfo objectForKey:@"mid"];
        }
    }
    
    /*
     No.1
     Appleサーバに端末のdevicetoken取得依頼を掛けます
     （成功失敗は非同期でNo.2,No.3がコールされます）
     */

    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    // 通常の起動処理
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[SN_Example3ViewController alloc] initWithNibName:@"SN_Example3ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

/*
 No.9
 アプリ起動中に、リモート通知を受けた場合に呼び出されます。
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // midを取得します。
    self.mid = nil;
    if (userInfo) {
        self.mid = [userInfo objectForKey:@"mid"];
        
        // midをsamuraiサーバに送信するため、Appleサーバに端末のdevicetoken取得依頼を掛けます。
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }
}

#pragma mark == push result==
/*
 No.2
 push通知のappleサーバ登録が成功した場合に呼び出されます。
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /*
     Appleサーバからdevicetokenの取得に成功した場合は、
     SamuraiNotificationサーバにdevicetokenを送信します。
     
     補足：devicetokenとは、iOSプッシュ通知の仕組みにおいて、プッシュ通知の宛先となる識別子です
     */
    
    NSLog(@"Appleサーバに登録成功しました。devicetoken=[%@]",[deviceToken description]);    
    //devicetoken送信処理
    [self sendAPNsToken:deviceToken];
}

/*
 No.3
 push通知のappleサーバ登録が失敗した場合に呼び出されます。
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Appleサーバに登録失敗しました。理由[%@]",[error localizedDescription]);
}

#pragma mark == register token (samurai notification server) ==
- (void) sendAPNsToken:(NSData*)devicetoken
{
    /*
     No.4
     取得したdevicetokenをsamurai notification serverに送信します。
     （成功失敗は非同期でNo.5,No.6が呼び出されます）
     */
    
    NSLog(@"SamuraiNotificationサーバにdevicetokenを送信します");
    
    NSString *deviceTokenString = [[devicetoken description] 
                                   stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenString = [deviceTokenString 
                         stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTokenString = [deviceTokenString 
                         stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableString *body = nil;
    if (!self.mid) {
        body = [NSMutableString stringWithFormat:@"token=%@&device_token=%@", SN_ACCESS_TOKEN, deviceTokenString];
    } else {
        body = [NSMutableString stringWithFormat:@"token=%@&device_token=%@&mid=%d", SN_ACCESS_TOKEN, deviceTokenString, [self.mid integerValue]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SN_SERVER_URL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /*
     No.5
     samurai notification serverに送信成功しました。
     */
    
    NSLog(@"SamuraiNotificationサーバに送信成功しました");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    /*
     No.6
     samurai notification serverに送信失敗しました。
     */
    
    NSLog(@"SamuraiNotificationサーバに送信失敗しました。理由[%@]",[error localizedDescription]);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     No.7
     バッジを初期化します。
     ※このサンプルアプリでは起動時（バックグラウンド含む）にバッジを初期化します。
     */
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

@end
