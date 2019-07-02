# Advanced documentation
## Internals
The main ZenderPlayer is a UIViewController. It contains currently four subviews: (1) Image, (2) Video, (3) Webview , (4) HUD

All Media is displayed natively in the app for performance reasons and allows the use of specialized video players.

The webview layer will load the overlay on top of the Image and Video layers. This means that the whole API interaction logic is handled by the Webview.
Through a javascript/native bridge data and events are exposed to the native app. This allows for fast updates and makes it easy to get new functionality without having to update the app.

- Within the webview jockey:// is used to communicate over the bridge
- The webview asks to native that it's ready. It does so by sending 'zender:ready'. When the webview responds back with 'zender:ready' they can continue
- The theming and locales are injected over a javascript function that is inject at the document of the html

# Streams
## To initialize a specific stream:

```
@import Zender;

NSString *targetId  = @"ttttttttt-tttt-tttt-tttt-ttttttttt";
NSString *channelId = @"ccccccccc-cccc-cccc-cccc-ccccccccc";
NSString *streamI@d = @"sssssssss-ssss-ssss-ssss-sssssssss";
ZenderPlayerConfig *config = [ZenderPlayerConfig configWith:targetId channelId:channelId streamId:streamId];
self.player.config=config ;

```
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

The ZenderStream object contains:
- streamId: A unique stream Id
- streamTitle: the title of the stream
- streamDescription: a longer description of the stream
- airDate : date when the stream will be live
- streamState: one of the states before, live, after

# Player
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

## Overriding player endpoints
```
NSString *playerEndpoint = @"https://player2-native.zender.tv";
NSString *apiEndpoint = @"https://api.zender.tv";

[config overridePlayerEndpointPrefix:playerEndpoint];
[config overrideApiEndpoint:apiEndpoint];
```

# Analytics
The Zender Admin console has an overview of different analytics. We can additionally support Google Analytics out the box.
For this the `GA trackedId` needs to be added to the admin console.

For further analytics or integration in your own system you can listen to the events exposed by the ZenderPlayerDelegate.

Note: 
- Depending on the video provider this will actually stop the streaming or not
- Phenix Player just stops the rendering not the data streaming (this will be improved in future versions)


## Events/Delegate
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

## Push Notification format
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

# Debugging

## Debug Webview
Delay the bridge to attach safari webview debugger
```
[config setBridgeWaitTime:10000];
[config enableDebug:TRUE];

```

## Logger
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



# Video Players
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

## Implement your own VideoPlayer (Deprecated , needs better documentation)
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
