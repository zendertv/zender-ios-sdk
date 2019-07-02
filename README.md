# Description

This repository provides the iOS sdk version of the Zender Player.

Current version is `2.0.2`

# Find your configuration in the Zender Admin
- Logging to the admin <https://admin.zender.tv>
- Select a specific stream
- Get the information (the I icon)
- Read the targetId and channelId

 ![Zender TargetId and ChannelId](docs/images/targetId-channelId.png?raw=true "Find your Zender TargetId and ChannelId")

# Usage

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
    // This will open up the native share window
    [zenderPlayer sharePayload:payload controller:self];
}


@end
```

# Installation
## Using cocoapods
The sdk is provided via private Cocoapod repository.
Add the following to the top of your Podfile

`source 'https://github.com/zendertv/Specs.git'`

Note: The pod downloads a large zip file containing the frameworks , this might take some time

## Manual installation

### Add to Embedded Frameworks to the project
The second step is to add the frameworks as embedded frameworks:
- Select your Application Target (on the left)
- Select the General tab
- Select Add the framework via the `Embedded Binaries` (+ button)
- Select Other to add the framework
- Browse to your manually downloaded sdk file
- Add frameworks `Zender`, `ZenderPhenix` and `PhenixSdk`
- When a screen pops up to 'Choose options for adding these files' `(Deselect Copy if needed, Select Create folder references)`

![Add to Embedded Frameworks](docs/images/ios/framework-embed.png?raw=true "Add to Embedded Frameworks")

### Basic frameworks
Now add the necessary frameworks under "General/Linked Frameworks and Libraries": 
- UIKit.framework
- JavascriptCore.framework
- AVFoundation.framework
- AVKit.framework

# Additional configuration
## Strip frameworks
The Zender frameworks provides `armv7, arm64, x86_64` architecture builds.
To publish an app to the appstore, you need to strip the simulator part.

- Select your Application Target (on the left)
- Select the Build Phases tab
- Add a `Run Script` (plus sign top left) below the `Enmbedded Frameworks` section
- Enter `bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Zender.framework/strip-framework.sh"`

![Strip Frameworks](docs/images/ios/strip-frameworks.png?raw=true "Strip Framework")

### Disable bitcode
Zender depends on frameworks that are currrently not BITCODE enabled.  Therefore you need to disable it:
- Select your Application Target (on the left)
- Select the `Build Settings` tab
- Find `Enable Bitcode` and select NO

![Disable bitcode](docs/images/ios/disable-bitcode.png?raw=true "Disable bitcode")

### Orientation Portrait
The Zender player autorotates, if you don't want this behaviour you need to fix the app rotation or the controller

- Select your Application Target (on the left)
- Select the `General` tab
- Select/Deselect the required `Device Orientation` options

![Fix portrait](docs/images/ios/portrait-only.png?raw=true "Fix Portrait Modus")

### Background audio
To be able to play audio in background, add this to the background mode:

- Select your Application Target (on the left)
- Select the `Capabilities` tab
- Select `Audio, Airplay, and Picture in Picture`

![Background Audio](docs/images/ios/background-audio.png?raw=true "Background Audio")


# Push notifications
The Zender Admin console provides a way to send push notifications to users to notifiy them when new streams are available.
This requires push notification certificate setup to match the bundleId of your app and allowing us to send the push notifications.

# Sample code
```objective-c

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[Zender sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

# Deeplinking
## Sample code
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    BOOL handled = [[Zender sharedInstance] handleUniversalLink:userActivity.webpageURL completion:^(NSError *error) {
        
    }];
    
    return handled;
    
}

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
See [Changelog](CHANGELOG.md)

