//
//  AppController.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Director.h"

@interface AppController : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	Director *director;
}

@property (nonatomic, retain) UIWindow *window;

@end