//
//  AppDelegate.m
//  ZenderDemo
//
//  Created by Patrick Debois on 30/06/2019.
//  Copyright © 2019 Zender. All rights reserved.
//

#import "AppDelegate.h"
@import Zender;

@import UserNotifications;


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self askForPermission];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[Zender sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    BOOL handled = [[Zender sharedInstance] handleUniversalLink:userActivity.webpageURL completion:^(NSError *error) {
        
    }];
    
    return handled;
    
}

// Convenience method for asking for push notification permissions
- (void)askForPermission {
    
    // Override point for customization after application launch.
    // Check Notification Settings on launch
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                    // This means we have not yet asked for notification permissions
                    case UNAuthorizationStatusNotDetermined:
                {
                    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        // You might want to remove this, or handle errors differently in production
                        NSAssert(error == nil, @"There should be no error");
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                            });
                            
                        }
                    }];
                }
                    break;
                    // We are already authorized, so no need to ask
                    case UNAuthorizationStatusAuthorized:
                {
                    // Just try and register for remote notifications
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                }
                    break;
                    // We are denied User Notifications
                    case UNAuthorizationStatusDenied:
                {
                    
                    // Possibly display something to the user
                    UIAlertController *useNotificationsController = [UIAlertController alertControllerWithTitle:@"Turn on notifications" message:@"This app needs notifications turned on for the best user experience" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *goToSettingsAction = [UIAlertAction actionWithTitle:@"Go to settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
                    [useNotificationsController addAction:goToSettingsAction];
                    [useNotificationsController addAction:cancelAction];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [self.window.rootViewController presentViewController:useNotificationsController animated:false completion:nil];
                    });
                    NSLog(@"We cannot use notifications because the user has denied permissions");
                    
                }
                    break;
                    // The application is provisionally authorized to post noninterruptive user notifications.
                    case UNAuthorizationStatusProvisional: {
                        // iOS 12.0 we don't worry about it now
                        break;
                    }
            }
            
        }];
    } else {
        // Fallback on earlier versions
        // Register the supported interaction types.
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
    }
}

@end
