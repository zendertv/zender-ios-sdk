# Example usage

```objective-c
//
//  ViewController.m
//  ZenderDemo
//
//  Created by Patrick Debois on 30/06/2019.
//  Copyright © 2019 Zender. All rights reserved.
//

#import "ViewController.h"

@import Zender;

@interface ViewController ()<ZenderPlayerDelegate>

@property (atomic, strong) ZenderPlayer *player; // ZenderPlayer is UIViewController
@property (atomic, strong) ZenderAuthentication *authentication;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the target and channel
    NSString *channelId ;
    NSString *targetId;
    
    targetId = @"<your-target-id>"; // fill-in your own targetId
    channelId = @"<your-channel-id>"; // fill-in your own channelId

    // Create a Zender Player
    self.player= [ZenderPlayer new];
    
    // Create a player configuration
    ZenderPlayerConfig* settingsConfig = [ZenderPlayerConfig configWithTargetId:targetId channelId:channelId];
    self.player.config = settingsConfig;

    [self setupAuthentication];

    self.player.authentication = _authentication;

	// Set this class as a ZenderPlayerDelegate
    self.player.delegate = self;
    
    self.player.view.frame = self.view.frame;
    self.player.view.hidden = false;
    
	[self.player start];
    
    [self.view addSubview:self.player.view];
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark Zender Authentication
- (void)setupAuthentication {
    // Configure authentication, uncomment depending on your configuration

    /* No authentication 
    _authentication=nil;
    */

	/* Device Authentication
   _authentication = [ZenderAuthentication authenticationWith:@{
	    @"token": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
	    @"name": @"demo",
	    @"avatar": @"https://cdn.iconscout.com/public/images/icon/free/png-512/avatar-user-hacker-3830b32ad9e0802c-512x512.png"
    } provider:@"device"];
	*/ 

	/* Facebook authentication , requires the facebook framework to be integrated
	_authentication = [ZenderAuthentication authenticationWith:@{
		@"token": [FBSDKAccessToken currentAccessToken].tokenString,
	} provider:@"facebook"];
    */

	/* Google authentication , requires the google framework to be integrated
    _authentication = [ZenderAuthentication authenticationWith:@{
        @"token": <googleToken>
    } provider:@"google"];
    */

    /*
    _authentication = [ZenderAuthentication authenticationWith:@{
    @"token": signed_json_string
    } provider:@"signedProvider"];
    */
}

#pragma mark Zender Player Delegate

// Listen for player ready event
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerReady:(NSDictionary *)payload {
}

// Listen for player close event
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerClose:(NSDictionary *)payload {
    // stop the player
    [self.player stop];
    self.player.delegate = nil;
    self.player = nil;
}

// Listen for player logout event
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerAuthenticationLogout:(NSDictionary *)payload {
    // stop the player
    [self.player stop];
    self.player.delegate = nil;
    self.player = nil;
}

// Listen for player authentication required
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerAuthenticationRequired:(NSDictionary *)payload {
    // do something to login the user
}

// Listen for Quiz Share codes
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizShareCode:(NSDictionary *)payload {
    // TODO
}


@end
```

# Push notifications
The Zender Admin console provides a way to send push notifications to users to notifiy them when new streams are available.
This requires push notification certificate setup to match the bundleId of your app and allowing us to send the push notifications.


```objective-c
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

```

The push notification can contain the targetId, channelId and/or streamId allowing you to directly start a stream.
This needs to be implemented in your app to capture and handle the push notifications

```
{
    aps =     {
        alert = "Get ready for the quiz!";
        sound = default;
    };
    data =     {
        message = "Get ready for the quiz!";
        zender =         {
            channelId = "<channelId>";
            targetId = "<targetId>";
        };
    };
}
```

There is a convenience method to check if this was a Zender Notification
```
#import <Zender/Zender.h>
if ([[Zender sharedInstance] isZenderNotification:userInfo]) {
}
```

# Deeplinking
Use `[self.player redeemCodeQuiz:@"<mycode>"];` to redeem a code.

Note: This needs to be done before the player has started.

A user that redeems a code that did not yet have a code will receive a message in the player.


# Zender Streams
## Listing all upcoming streams
You can retrieve the schedule of upcoming Zender Streams as follows:

```
ZenderApiClient *_apiClient = [[ZenderApiClient alloc] initWithTargetId:targetId channelId:channelId];
_apiClient.authentication = authentication; // Reuse the authentication (see above)

[_apiClient login:^(NSError *error, ZenderSession *session) {
    if (error == nil) {
        [self->_apiClient  getStreams:^(NSError *error, NSSArray *streams) {
          // streams contains an Array of ZenderStream Objects
        }];
    }
}];
```

## Stream information
The ZenderStream object contains:
- streamId: A unique stream Id
- streamTitle: the title of the stream
- streamDescription: a longer description of the stream
- airDate : date when the stream will be live
- streamState: one of the states before, live, after

# Installation

Now add the necessary frameworks under "General/Linked Frameworks and Libraries": 
  - UIKit.framework
  - JavascriptCore.framework
  - AVFoundation.framework
  - AVKit.framework

## Lock orientation
It's also good to lock the orientation of that view in portrait or landscape mode to match your media
## Handling App Background/Foreground correctly



# Releases
We adhere to the Semantic Versions scheme to indiciate releases. Versions starting with 0.x should be considered beta versions and not yet ready for production use.

# Privacy
Before using people their name, avatar and other information, they should give a consent to use their data.
It is up the implementor of the SDK to get the agreement of the user before exposing him in the Zender Player.

The data is securely stored on the Zender platform but there needs to be an agreement

# License
- All Zender Code is copyrighted and owned by Small Town Heroes BVBA. Extensions have their own license based on the license of the supplier.
- This code does not grant you ownership or a license to use it. This needs to be arranged by a specific license agreement.
- All code provided should be treated as confidential until official cleared.

# Changelog
1.0.5:
- [phenix] fix memory leak , better warning message

1.0.4:
- [player] feedback if video connection falls back to audio only or worse
- [player] no vibration when you have given a wrong answer

1.0.3:
- [player] fix of UserDevice weak attributes 
- [player] fix allowFileAccessFromFileURLs is a boolean not a string
- [player] catch [NSJSONSerialization dataWithJSONObject exceptions

1.0.2:
- [player] correctly set username on logging
1.0.1:
- [player] log the app version in all cases

1.0.0:
- [player] more logging
- [player] improved background/foreground spinner
- [player] workaround for phenix sdk memory leak, fix in sdk pending
- [player] correctly expose some missing events

0.9.13:
- [player] introduce remote logging
- [player] completely stop the stream in background
- [player] add new action shoutboxEnable, shoutboxDisable
- [player] added dependency on Systems.framework for network quality monitoring
- [player] new events onZenderEventShoutboxShoutSent,  onZenderEventQuizStart, onZenderEventQuizStop, ZenderEventQuizExtralifeUse, ZenderEventQuizExtralifeIgnore, ZenderEventQuizAnswerSubmit, ZenderEventQuizAnswerTimeout, ZenderEventQuizEliminated, ZenderEventQuizEliminatedContinue, ZenderEventAnswerCorrect , ZenderEventAnswerIncorrect

0.9.11:
- [player] fix statusbar animation
- [player] add vibrate on quiz question

0.9.10:
- [player] fix loader & avplayer aspectfill on iPhoneX
- [player] new event ZenderOnLoaderTimeout to detect potential issues

0.9.9:
- [player] fix for iPhoneX keyboard offset & correct screensize with saferareas
- [player] fix for correct display when statusbar is visible or not
- [player] remote logging over the bridge
- [player] disable display timer to avoid going to sleep during quiz
- [player] remove the Done keyboard button

0.9.8:
- [notifications] documentation of push payload
- [player] improvement to handle keyboard hide/show
- [player] improved phenix buffering visualisation
- [player] imrpoved medialaan documentation

0.9.7:
- [player] new callbacks onZenderQuizShareCode, onZenderMediaPlay, onZenderPlayerLobbyEnter, onZenderPlayerLobbyLeave, onZenderOpenUrl, onZenderUiStreamsOverview
- [logger] introduced logger object with different loglevels , added logging to API & Player
- [player] privacy, rules etc.. in settings now open in separate Safari view
- [player] Share code is now available in the onZenderQuizShareCode
- [debug] If debug is enabled, a long tap on the player will trigger a onZenderPlayerAdsShow event
- [player] fix inconsistency for registerDevice / registerDeviceToken on Player
- [player] deprecated `[ self.player registerDevice:<devicetoken>,  self.player unregisterDevice:<devicetoken> ]`
- [player] added a zender_loop.mp4 to the Zender/Core resources bundle
- [player] JS logging is now redirected to the ZenderLogger (tag=js) 
- [youtube] first provider for Youtube video support
- [player] improved buffering status
- [player] Added `videoStop` `videoStart` player methods. Useful for older devices that can't play with videoPause/videoResume
- [player] Added `onZenderLoaderHideoaderShow` `onZenderLoaderHide` events to allow for custom loaders 

0.9.6:
Changes:
- API Calls now follow Error First rule

0.9.5:
Changes:
- [Player] is now a UIViewController and longer a UIView
- [Player] stop command cleans all internal objects
- [Player][Phenix] video mode is now cover
- [Player] the statusbar is now removed
Bugfixes:
- [Player][Phenix][bugfix] phenix player is now full portrait
New Features:
- [Player] pauseVideo , resumeVideo added
- [Player] mute, unmute added
- [API] subscribe, unsubscribe a device
- [Player][Config] allows you to pass a device(token) to the PlayerConfig without subscribe/unsubscribe
- [Player] show loader until media is ready (experimental)

0.9.4:
- [API] Introduced ZenderApiClient to do API calls without starting the player
- [API] Push notifications can now be registered, unregistered without starting the player
- [API] getStreams allows you to retrieve the metadata of the current streams (ZenderStream)
- [API] login call now returns a ZenderSession
- [Player] Added onPlayerClose event to react on the close button in the player
- [Phenix] A beta version that works inside a simulator is now available
- [Auth] 
 mechanism for Medialaan is now available

0.9.1 : 
- First public beta version

