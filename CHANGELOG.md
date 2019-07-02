# Changelog
2.1.0:
- [player] autodetect video players
- [push notification] provide application handler for easiers integration
- [deeplinking] an application handler is now available for detecting zender universal links 

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

