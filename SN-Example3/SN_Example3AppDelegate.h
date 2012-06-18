//
//  SN_Example3AppDelegate.h
//  SN-Example3
//
//  Created by Yuka Wada on 12/06/15.
//  Copyright (c) 2012年 CONIT CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SN_Example3ViewController;

@interface SN_Example3AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SN_Example3ViewController *viewController;

// midのpropertyを宣言します。
@property (strong, nonatomic) NSNumber *mid;

@end
