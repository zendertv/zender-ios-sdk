# Installation
The Zender sdk consists of a "core" package which contains all of the base functionality. (Chat,Poll,Quiz...)
In addition to this "core" package extensions that allow for enhanced functionality. This allows us to keep the "core" light and allow you to add extensions only when needed or when a specific license is required.

Current version is `1.0.5` . For now both Core and Extensions will follow the release schedule.

## Zender Core
### Pod Install
Adding Zender is as easy as adding the following to your Podfile

If you have access to the github repo
```
pod 'Zender/Core' , :git => 'git@github.com:zendertv/zender-ios-sdk.git', :tag => 'v1.0.5'
```

Or if you received the sdk via a zip file

```
pod 'Zender/Core' , :path => '<where you unzipped the zender sdk>'
```


Additional extensions will be provided as subspects of this pod

### Manual install
First unzip the distribution file typically structured like `zender-ios-sdk-vXX_YY_ZZ.zip`


Then Import the files under `Zender/ZenderCore` into your xcode project

Now add the necessary frameworks under "General/Linked Frameworks and Libraries": 
  - UIKit.framework
  - JavascriptCore.framework
  - AVFoundation.framework
  - AVKit.framework

## Extension: Zender Phenix
Zender will use the iOS AVPlayer to playback media. The Phenix Extension will allow you to use the [Phenix RTS](https://phenixrts.com) Low latency video player. In order to use this for trial licenses an NDA needs to be signed.

### Pod Install
Note: some files of the Phenix Framework are quite large. They are too large to be added as regular files to services like Github. You can use the Git LFS (Large File Extension) to solve this. See <https://git-lfs.github.com/> for more details.

Phenix is working on a Podfile, in the meanwhile we have forked the project and added one for your convenience

If you have access to the github repo
```
pod 'Zender/Core' , :git => 'git@github.com:zendertv/zender-ios-sdk.git', :tag => 'v1.0.5'
pod 'Zender/Phenix' , :git => 'git@github.com:zendertv/zender-ios-sdk.git', :tag => 'v1.0.5'
pod 'PhenixSdk' , :git => 'git@github.com:zendertv/phenix-ios-sdk.git', :tag => 'v2018-10-25'
```

Or if you received the sdk via a zip file
```
pod 'Zender/Core' , :path => '<where you unzipped the zender sdk>'
pod 'Zender/Phenix' , :path => '<where you unzipped the zender sdk>'
pod 'PhenixSdk' , :path => '<whre you unzipped the phenix sdk>
```

### Manual install

First unzip the distribution file typically structured like `zender-ios-sdk-vXX_YY_ZZ.zip`

Then Import the files under `Zender/ZenderPhenix` into your xcode project.

Next you need to add the PhenixPlayer framework to your project. The installation is described at <https://phenixrts.com/docs/ios/#setup>. It boils down to:
- Import the PhenixSdk.framework in your project
- Add the framework to the embedded binaries/framework
- Configure the Headers Search path to find the correct headers

As described in the documentation, the out of the box framework comes into two flavors Simulator and Device. You can combine both in a universal framework file that you can strip out later with a build script
```
cd Phenix/lib
rm -rf Universal
mkdir -p Universal/PhenixSdk.framework/Headers
cp -rp iPhoneOS/PhenixSdk.framework/Headers/* Universal/PhenixSdk.framework/Headers/
lipo -create -output "Universal/PhenixSdk.framework/PhenixSdk" iPhoneOS/PhenixSdk.framework/PhenixSdk iPhoneSimulator/PhenixSdk.framework/PhenixSdk
```

# Example Use
## Initialize ZenderPlayer
The class "ZenderPlayer" provides the Zender interaction functionality.
```
#import <Zender/ZenderPlayer.h>
#import <Zender/ZenderPlayerConfig.h>

@property (strong, nonatomic) ZenderPlayer *player;

self.player = [ZenderPlayer new];
```

## Configuration ZenderPlayer
To initialize a ZenderPlayer you need to provide it with:
- a targetId: this is a unique identifier for your organization
- a channelId: this is a unique identifier of the channel within your organization (f.i. a specific show)

These values will be provided to you for demo purposes and can be found the in the admin console.

To initialize a channel and have the player autoswitch between public streams
```
#import <Zender/ZenderPlayerConfig.h>

NSString *targetId  = @"ttttttttt-tttt-tttt-tttt-ttttttttt";
NSString *channelId = @"ccccccccc-cccc-cccc-cccc-ccccccccc";
ZenderPlayerConfig *config = [ZenderPlayerConfig configWith:targetId channelId:channelId];
self.player.config=config ;

```

To initialize a specific stream:

```
#import <Zender/ZenderPlayerConfig.h>

NSString *targetId  = @"ttttttttt-tttt-tttt-tttt-ttttttttt";
NSString *channelId = @"ccccccccc-cccc-cccc-cccc-ccccccccc";
NSString *streamI@d = @"sssssssss-ssss-ssss-ssss-sssssssss";
ZenderPlayerConfig *config = [ZenderPlayerConfig configWith:targetId channelId:channelId streamId:streamId];
self.player.config=config ;

```

## Setup authentication
Zender support several authentication mechanisms out of the box: Facebook, Google, Instagram. These require configuration in the admin console to setup the correct applicationId and secrets.
An alternative for demo purposes is to use the "device" authentication. This is a loose for of authentication where the app can set a unique identifier to identify a user.

*Device authentication*
```
#import <Zender/ZenderAuthentication.h>

ZenderAuthentication *deviceAuthentication = [ZenderAuthentication authenticationWith:@{
    @"token": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
    @"name": username,
    @"avatar": @"https://example.com/myavatar.png"
} provider:@"device"];

self.player.authentication=deviceAuthentication; 
```

*Facebook authentication:*
```
ZenderAuthentication *FBAuthentication = [ZenderAuthentication authenticationWith:@{
    @"token": [FBSDKAccessToken currentAccessToken].tokenString,
} provider:@"facebook"];
self.player.authentication=FBAuthentication; 

```

*Google authentication:*
```
ZenderAuthentication *googleAuthentication = [ZenderAuthentication authenticationWith:@{
    @"token": <googleToken>
} provider:@"google"];
self.player.authentication=googleAuthentication; 

```

*SignedProvider authentication:*
This provider allows you to pass your own user data (signed by your backend) so zender backend can verify the validity
```
Jsonstring signed_json_string = {"uid":"_guid_.....==","uid_signature":"......q6qg=","signature_date":"15......"}
ZenderAuthentication *signedAuthentication = [ZenderAuthentication authenticationWith:@{
  @"token": signed_json_string
} provider:@"signedProvider"];
self.player.authentication=signedAuthentication; 
```


## Setup the video player(s)
Zender offers the unique ability to dynamically change video players depending on the media Url provided.
This allows you to easily add your own video player, switch between the native ,commercial video players and social players like youtube.

The order that you add the players matters: it will use the first player that matches the url/media type. Therefore it is good to add the AVPlayer as a catch all after all other players.
Also AVPlayer allows you trigger local media bundled inside the app (like an error or placeholder video)

*Native AVPlayer: (catchall)*
```
#import <Zender/ZenderAVPlayerController.h>

ZenderAVPlayerController zenderAVPlayer = [ZenderAVPlayerController new];
[self.player.config.registerVideoController:zenderAVPlayer];
```

*Phenix Video Player: (supports urls phenix: `<channel-name>`)*
```
#import <Zender/ZenderPhenixPlayerController.h>

ZenderPhenixPlayerController zenderPhenixPlayer = [ZenderPhenixController new];
[self.player.config.registerVideoController:zenderPhenixPlayer];
```

*Youtube Video Player: (supports youtube urls)*
```
#import <Zender/ZenderYoutubePlayerController.h>

ZenderYoutubePlayerController zenderYoutubePlayer = [ZenderYoutubeController new];
[self.player.config.registerVideoController:zenderYoutubePlayer];
```


## Add ZenderPlayer to a subview

ZenderPlayer is UIViewController so you can add it as easy as a subview

```
self.player.view.frame = self.view.bounds;
[self.view addSubview:self.player.view];
```

When streaming vertical video we advice to lock the view/app in Portrait mode.

Now you can start/stop the player to load

```
[self.player start];
[self.player stop];
```


## Mute/Unmute Sound
You can mute/unmute the sound of the ZenderPlayer & Video (for example to play an advertisement)

```
[self.player mute];
[self.player unmute];
```

## Pause/Resume video
If you'd like to pause the playing of the video (to overlay stuff) use the following:
```
[self.player pauseVideo];
[self.player resumeVideo];
```

Note: 
- Depending on the video provider this will actually stop the streaming or not
- Phenix Player just stops the rendering not the data streaming (this will be improved in future versions)

## Lock orientation
It's also good to lock the orientation of that view in portrait or landscape mode to match your media

```
//Lock ViewController to Portrait Mode
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

```
- (BOOL)shouldAutorotate {
    return FALSE;
}

```

## Hide the statusbar
The ZenderPlayer is a UIViewController and sets the statusbarhidden. 
- (BOOL)prefersStatusBarHidden {
    return YES;
}
```

Depending on your Info.plist settings this might not be enough.
Check that `View controller-based status bar appearance` is set to TRUE to allow it to override the status bar

## Handling App Background/Foreground correctly
When the app goes to background/foreground it will pause/resume the video.

The phenix video player requires the permission "play audio in background".
Add the following setting:

`Required Background Modes : App plays audio or streams audio/video using AirPlay`

You can do this in Xcode via the Project/Targets/Capabilities/Background Modes screen

## Disposing a player
The Zender Player provides a close button. You can listen on the event `onPlayerClose` to dispose the player
```
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerClose:(NSDictionary *)payload;
```

Just remove the reference to the player and the player will be collected by the ARC system
```
[self.player stop];
self.player = nil;
```

# Events/Delegate
Events happening in the ZenderPlayer are exposed and can be handled by a `ZenderPlayerDelegate` add this to your class.

```
@interface ZenderExamplePlayerViewController()<ZenderPlayerDelegate>

self.player.delegate = self;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onPlayerReady:(NSDictionary *)payload {
}
```

The payload provided is currently a raw JSON payload, we will convert this to specific Event classes. So don't rely on the structure yet.

```
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderReady:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderFail:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerFail:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerReady:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerClose:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerLobbyEnter:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPlayerLobbyLeave:(NSDictionary *)payload;
//- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderStreamLobbyEnter:(NSDictionary *)payload;
//- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderStreamLobbyLeave:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAuthenticationInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAuthenticationRequired:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAuthenticationClear:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAuthenticationFail:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAuthenticationSuccess:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderTargetsInit:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderChannelsStreamsInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderChannelsStreamsPublish:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderChannelsStreamsUnpublish:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderStreamsInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderStreamsUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderStreamsDelete:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderStreamsStats:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderMediaInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderMediaUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderMediaDelete:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderMediaPlay:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxReplies:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxShout:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxShouts:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxShoutsDelete:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxShoutSent:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxDisable:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderShoutboxEnable:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderEmojisInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderEmojisUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderEmojisStats:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderEmojisTrigger:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAvatarsStats:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAvatarsTrigger:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsDelete:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsReset:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsVote:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsResults:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderPollsResultsAnimate:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizInit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizUpdate:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizStart:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizStop:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizReset:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizDelete:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizQuestion:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizAnswer:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizAnswerTimeout:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizAnswerSubmit:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizAnswerCorrect:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizAnswerIncorrect:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizExtralifeUse:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizExtralifeIgnore:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizEliminated:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizEliminatedContinue:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizWinner:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizLoser:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizQuestionResults:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizShareCode:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizResults:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderUiStreamsOverview:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderOpenUrl:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderAdsShow:(NSDictionary *)payload;

- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderLoaderShow:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderLoaderHide:(NSDictionary *)payload;
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderLoaderTimeout:(NSDictionary *)payload;

```

# Zender Streams
## Listing all streams
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

# Analytics
The Zender Admin console has an overview of different analytics. We can additionally support Google Analytics out the box.
For this the `GA trackedId` needs to be added to the admin console.

For further analytics or integration in your own system you can listen to the events exposed by the ZenderPlayerDelegate.


# Push notifications
The Zender Admin console provides a way to send push notifications to users to notifiy them when new streams are available.
This requires push notification certificate setup to match the bundleId of your app and allowing us to send the push notifications.

## Creating a userDevice object
    ZenderUserDevice *userDevice = [ZenderUserDevice new];
    userDevice.token = @"<a valid device token>";
 
 
## Configure the ZenderPlayer with the correct Device
In the menu of the Zender player you can enable/disable push notifications. To match the correct device token , you need to specify the correct deviceToken in the configuration.

[self.player.config setUserDevice:userDevice];

## Using ZenderApiClient
If you'd like to enable/disable push notifications from your own views without starting the player you can use the `ZenderApiClient`

To register/unregister a device:
```
    ZenderApiClient *apiClient = [[ZenderApiClient alloc] initWithTargetId:targetId channelId:channelId];
    apiClient.authentication = authentication; // Reuse the authentication (see above)
    

    [apiClient login:^(NSError *error, ZenderSession *session) {
        if (error == nil) {
            [apiClient registerDevice:userDevice andCompletionHandler:^(NSError *error) {
                if (error == nil) {
                } else {
                }
            }];
        }
    }];

```

## Getting the deviceToken
The deviceToken is the token you receive when your applications registeres for notifications. Typically in:
```
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"push notification token %@",deviceToken);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"push Error: %@", error.description);
}
```

## Quiz codes / Extra life codes
### Share Code
When a user want to share his code `onZenderQuizShareCode` will be triggered with `shareCode` in the payload
```
- (void)zenderPlayer:(ZenderPlayer *)zenderPlayer onZenderQuizShareCode:(NSDictionary *)payload {
    NSString *shareCode = [payload valueForKey:@"shareCode"];
    NSString *shareText = [payload valueForKey:@"text"];
    [self shareText:text andImage:nil andUrl:nil];
}
```

The format of text can be dynamiccaly changed in the locale settings

### Redeem Code
Use `[self.player redeemCodeQuiz:@"<mycode>"];` to redeem a code.

Note: This needs to be done before the player has started.

A user that redeems a code that did not yet have a code will receive a message in the player.

## Deeplinking
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


# Theming
The theming of the views is done outside the app. This can be easily updated from the admin console.  This allows for dynamic themeability for special events.

To see the full list of theming options see [Theming options](theming.md)

# Localisation
The localisation of the views is done outside of the app. This can be easily updated from the admin coonsole. This allows for dynamic changes.

There are currently two options to detect the user their language:
- Zender Player will use the language of the os.
- The language is force from the admin in a certain language

To see the full list of theming options see [Localisation options](localisation.md)

# Swift / Objective-C
```
 #ifndef Zender_Bridging_Header_h
 #define Zender_Bridging_Header_h

 #include <Zender/ZenderConstants.h>
 #include <Zender/ZenderPlayer.h>
 #include <Zender/ZenderPlayerConfig.h>
 #include <Zender/ZenderAuthentication.h>
 #include <Zender/ZenderAVPlayerController.h>
 #include <Zender/ZenderApiClient.h>
 #include <Zender/ZenderPhenixPlayerController.h>
 #include <Zender/ZenderPhenixPlayerConfig.h>

 #endif /* Zender_Bridging_Header_h */

```

# Debugging
## Overriding player endpoints
```
NSString *playerEndpoint = @"https://player2-native.zender.tv";
NSString *apiEndpoint = @"https://api.staging.zender.tv";

[config overridePlayerEndpointPrefix:playerEndpoint];
[config overrideApiEndpoint:apiEndpoint];
```

## Debug Webview
Delay the bridge to attach safari webview debugger
```
[config setBridgeWaitTime:10000];
[config enableDebug:TRUE];

```

## Zender
Zender providers a logger that can be dynamically configured:

```
#import <Zender/ZenderLogger.h>
[[ZenderLogger shared] setLevel:ZenderLogger_LEVEL_DEBUG];
```

Default level is `ZenderLogger_LEVEL_INFO`

Available levels:
```
static const int ZenderLogger_LEVEL_VERBOSE = 10;
static const int ZenderLogger_LEVEL_DEBUG = 20;
static const int ZenderLogger_LEVEL_INFO = 30;
static const int ZenderLogger_LEVEL_WARN = 40;
static const int ZenderLogger_LEVEL_ERROR = 50;
static const int ZenderLogger_LEVEL_FATAL = 50;
static const int ZenderLogger_LEVEL_NONE = 100;
```

Corresponding logging macros are available for internal Zender Classes:
```
ZLog_Verbose(<tag>, <format>, <arguments ...>)
ZLog_Debug(<tag>, <format>, <arguments ...>)
ZLog_Info(<tag>, <format>, <arguments ...>)
ZLog_Warn(<tag>, <format>, <arguments ...>)
ZLog_Error(<tag>, <format>, <arguments ...>)
ZLog_Fatal(<tag>, <format>, <arguments ...>)
ZLog_None(<tag>, <format>, <arguments ...>)
```

In debug mode a long tap on the player will trigger an `onZenderPlayerAdsShow event`

## Phenix
To enable videoplayback, set the following environment variable (via Xcode menu: Product -> Scheme -> Edit Scheme… -> Run -> Arguments -> Environment Variables):

`Name: PHENIX_LOGGING_CONSOLE_LOG_LEVEL Value: Debug`

To reduce output, you can change the value to Info or Warn for instance

# Implement your own VideoPlayer (Deprecated , needs better documentation)
You need to subclass `ZenderVideoController` and implement the following methods:
- loadVideo: load the requested Url
- prepare : start the video playing
- mute: mutes the sound of the video
- unmute: unmutes the sound of the video
- pause: pauzes the video
- resume: resumes playing the video
- start : start the video playing
- stop : stop the Video playing
- cleanup: to stop and release all objects
- canPlay: to indicate which Url it responds to

In addition it should handle the ZenderVideoControllerDelegate handler:
```
- (void)zenderVideoControllerReadyToPlay:(ZenderVideoController *)zenderVideoController;
- (void)zenderVideoControllerDidFinishPlaying:(ZenderVideoController *)zenderVideoController;
- (void)zenderVideoController:(ZenderVideoController *)zenderVideoController onVideoError:(NSError *)error;
- (void)zenderVideoController:(ZenderVideoController *)zenderVideoController onVideoBuffering:(BOOL)isBuffering;
```

# Internals
The main ZenderPlayer is a UIViewController. It contains currently four subviews: (1) Image, (2) Video, (3) Webview , (4) HUD

All Media is displayed natively in the app for performance reasons and allows the use of specialized video players.

The webview layer will load the overlay on top of the Image and Video layers. This means that the whole API interaction logic is handled by the Webview.
Through a javascript/native bridge data and events are exposed to the native app. This allows for fast updates and makes it easy to get new functionality without having to update the app.

- Within the webview jockey:// is used to communicate over the bridge
- The webview asks to native that it's ready. It does so by sending 'zender:ready'. When the webview responds back with 'zender:ready' they can continue
- The theming and locales are injected over a javascript function that is inject at the document of the html

# Releases
We adhere to the Semantic Versions scheme to indiciate releases. Versions starting with 0.x should be considered beta versions and not yet ready for production use.

# TODO 
## Functional

- Loader timeouts
- Loader override videoFile
- Handle at capacity error
- Handle Backend Errors (while player is starting)
- Handle stream load errors (retry message)
- Handle not compatible error
- Handle maintenance message

- Restart play button if loop disabled 
- Dynamically override PlayerEndpoint 
- Zender usage Analytics 
- Zender usage logging

- Media 9:16 / 16:9 Aspect ratio handling
- Dynamic Device rotation handling

## TODO Tech

- Consistent ZenderError ids
- Improved media switching

- Local Emojis
- Custom Video Provider documentation

- Provide Example Swift code
- Appledoc style documentation will be provided
- Finish Theming and Localisation documentation
- The events are currently exposed but the payload provided is a raw payload, we will further type this into specific events
- The registration of videocontrollers will be extended so you can specify the pattern yourself. This will allow new video urls to be easily used

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

