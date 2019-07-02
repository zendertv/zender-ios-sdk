
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
    [settingsConfig enableDebug:TRUE];
    
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
    
    /* No authentication , handle later with onZenderPlayerAuthentication Required
     _authentication=nil;
     */
    
    /* Device Authentication , creates a user based on a unique deviceId
     _authentication = [ZenderAuthentication authenticationWith:@{
     @"token": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
     @"name": @"demo",
    // @"avatar": @"https://cdn.iconscout.com/public/images/icon/free/png-512/avatar-user-hacker-3830b32ad9e0802c-512x512.png"
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
