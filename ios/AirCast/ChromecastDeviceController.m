// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ChromecastDeviceController.h"

@interface ChromecastDeviceController ()

@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property float deviceVolume;
@property bool deviceMuted;
@property NSString *appId;
@property NSMutableDictionary *customChannels;
@end

@implementation ChromecastDeviceController

- (id)init {
  
  self = [super init];
  if (self) {
    
    // Initialize device scanner
    self.deviceScanner = [[GCKDeviceScanner alloc] init];

  }
  return self;
  
}

- (void)setupWithAppId:(NSString *)appId {
    if (self) {
        // Remember the appId.
        self.appId = appId;
    }
}


- (BOOL)isConnected {
  return self.deviceManager.isConnected;
}

- (BOOL)isPlayingMedia {
  return self.deviceManager.isConnected && self.mediaControlChannel &&
         self.mediaControlChannel.mediaStatus && (self.playerState == GCKMediaPlayerStatePlaying ||
                                                  self.playerState == GCKMediaPlayerStatePaused ||
                                                  self.playerState == GCKMediaPlayerStateBuffering);
}

- (void)performScan:(BOOL)start {

  if (start) {
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
  } else {
    [self.deviceScanner stopScan];
    [self.deviceScanner removeListener:self];
  }
}

- (BOOL)connectToDeviceByID:(NSString*)deviceID {
    
    BOOL (^isDeviceWithID)(id, NSUInteger, BOOL*) = ^(id obj, NSUInteger idx, BOOL *stop) {
        return [[(GCKDevice*)obj deviceID] isEqualToString:deviceID];
    };
    
    NSUInteger deviceIdx = [[[self deviceScanner] devices] indexOfObjectPassingTest:isDeviceWithID];
    
    if( deviceIdx == NSNotFound ) return NO;
    
    [self connectToDevice:[[[self deviceScanner] devices] objectAtIndex:deviceIdx]];
    return YES;
    
}

- (void)connectToDevice:(GCKDevice *)device {
  self.selectedDevice = device;
  self.deviceManager =
      [[GCKDeviceManager alloc] initWithDevice:self.selectedDevice clientPackageName:self.appId];
  self.deviceManager.delegate = self;
  [self.deviceManager connect];
}

- (void)disconnectFromDevice {
  NSLog(@"Disconnecting device:%@", self.selectedDevice.friendlyName);
  // New way of doing things: We're not going to stop the applicaton. We're just going
  // to leave it.
  [self.deviceManager leaveApplication];
  // If you want to force application to stop, uncomment below
  //[self.deviceManager stopApplicationWithSessionID:self.applicationMetadata.sessionID];
  [self.deviceManager disconnect];
}

- (void)updateStatsFromDevice {
  if (self.isConnected && self.mediaControlChannel && self.mediaControlChannel.mediaStatus) {
    _streamPosition = [self.mediaControlChannel approximateStreamPosition];
    _streamDuration = self.mediaControlChannel.mediaStatus.mediaInformation.streamDuration;
    _playerState = self.mediaControlChannel.mediaStatus.playerState;
    _mediaInformation = self.mediaControlChannel.mediaStatus.mediaInformation;
  }
}

- (void)changeVolume:(double)idealVolume {
  idealVolume = MIN(1.0, MAX(0.0, idealVolume));
  [self.deviceManager setVolume:idealVolume];
}

- (void)setPlaybackPercent:(float)newPercent {
  newPercent = MAX(MIN(1.0, newPercent), 0.0);

  NSTimeInterval newTime = newPercent * _streamDuration;
  if (_streamDuration > 0 && self.isConnected) {
    [self.mediaControlChannel seekToTimeInterval:newTime];
  }
}

- (void)pauseCastMedia:(BOOL)shouldPause {
  if (self.isConnected && self.mediaControlChannel && self.mediaControlChannel.mediaStatus) {
    if (shouldPause) {
      [self.mediaControlChannel pause];
    } else {
      [self.mediaControlChannel play];
    }
  }
}

- (void)stopCastMedia {
  if (self.isConnected && self.mediaControlChannel && self.mediaControlChannel.mediaStatus) {
    NSLog(@"Telling cast media control channel to stop");
    [self.mediaControlChannel stop];
  }
}

- (void)openCustomChannelWithProtocol:(NSString*) protocol {
    if(self.isConnected && [self.customChannels valueForKey:protocol] == nil) {
        CustomCastChannel *customChannel = [[CustomCastChannel alloc] initWithNamespace:protocol];
        customChannel.delegate = self;
        [self.customChannels setValue:customChannel forKey:protocol];
        [self.deviceManager addChannel:customChannel];
    }
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  NSLog(@"connected!!");
  
  [self.deviceManager launchApplication:self.appId];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
                      sessionID:(NSString *)sessionID
            launchedApplication:(BOOL)launchedApplication {

  NSLog(@"application has launched");
  self.customChannels = [[NSMutableDictionary alloc] init];
  self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
  self.mediaControlChannel.delegate = self;
  [self.deviceManager addChannel:self.mediaControlChannel];
  [self.mediaControlChannel requestStatus];

  self.applicationMetadata = applicationMetadata;

  if ([self.delegate respondsToSelector:@selector(didConnectToDevice:)]) {
    [self.delegate didConnectToDevice:self.selectedDevice];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToLaunchCastApplicationWithError:(NSError *)error {
  [self deviceDisconnected];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectWithError:(GCKError *)error {
  [self deviceDisconnected];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
  NSLog(@"Received notification that device disconnected");
  [self deviceDisconnected];
}

- (void)deviceDisconnected {
  self.mediaControlChannel = nil;
  [self.customChannels removeAllObjects];
  self.customChannels = nil;
  self.deviceManager = nil;
  self.selectedDevice = nil;

  if ([self.delegate respondsToSelector:@selector(didDisconnect)]) {
    [self.delegate didDisconnect];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
  self.applicationMetadata = applicationMetadata;
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    volumeDidChangeToLevel:(float)volumeLevel
                   isMuted:(BOOL)isMuted {
  NSLog(@"New volume level of %f reported!", volumeLevel);
  self.deviceVolume = volumeLevel;
  self.deviceMuted = isMuted;
}

#pragma mark - GCKDeviceScannerListener
- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"device found!! %@", device.friendlyName);
  
  if ([self.delegate respondsToSelector:@selector(deviceListChanged:)]) {
    [self.delegate deviceListChanged:[self.deviceScanner devices]];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"device offline %@", device.friendlyName);
    
    if ([self.delegate respondsToSelector:@selector(deviceListChanged:)]) {
        [self.delegate deviceListChanged:[self.deviceScanner devices]];
    }
}

#pragma - GCKMediaControlChannelDelegate methods

- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
    didCompleteLoadWithSessionID:(NSInteger)sessionID {

}

- (void)mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel {
  [self updateStatsFromDevice];
  NSLog(@"Media control channel status changed");
    if ([self.delegate respondsToSelector:@selector(didReceiveMediaStateChange:)]) {
        [self.delegate didReceiveMediaStateChange:mediaControlChannel];
  }
}

- (void)mediaControlChannelDidUpdateMetadata:(GCKMediaControlChannel *)mediaControlChannel {
  [self updateStatsFromDevice];
  NSLog(@"Media control channel metadata changed");

    if ([self.delegate respondsToSelector:@selector(didReceiveMediaStateChange:)]) {
        [self.delegate didReceiveMediaStateChange:mediaControlChannel];
  }
}

- (BOOL)loadMedia:(NSURL *)url
     thumbnailURL:(NSURL *)thumbnailURL
            title:(NSString *)title
         subtitle:(NSString *)subtitle
         mimeType:(NSString *)mimeType
        startTime:(NSTimeInterval)startTime
         autoPlay:(BOOL)autoPlay {
  if (!self.deviceManager || !self.deviceManager.isConnected) {
    return NO;
  }

  GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
  if (title) {
    [metadata setString:title forKey:kGCKMetadataKeyTitle];
  }

  if (subtitle) {
    [metadata setString:subtitle forKey:kGCKMetadataKeySubtitle];
  }

  if (thumbnailURL) {
    [metadata addImage:[[GCKImage alloc] initWithURL:thumbnailURL width:200 height:100]];
  }

  GCKMediaInformation *mediaInformation =
      [[GCKMediaInformation alloc] initWithContentID:[url absoluteString]
                                          streamType:GCKMediaStreamTypeNone
                                         contentType:mimeType
                                            metadata:metadata
                                      streamDuration:0
                                          customData:nil];
  [self.mediaControlChannel loadMedia:mediaInformation autoplay:autoPlay playPosition:startTime];

  return YES;
}

#pragma mark - CustomCastChannelDelegate methods
- (void)didReceiveTextMessage:(NSString*) message forProtocol:(NSString*) protocol {
    if ([self.delegate respondsToSelector:@selector(didReceiveCustomEvent:forProtocol:)]) {
        [self.delegate didReceiveCustomEvent:message forProtocol:protocol];
    }
}

#pragma mark - CustomCastChannel
- (BOOL)sendCustomEvent:(NSString *)event forProtocol:(NSString *)protocol
{
    // ensure the channel is open
    [self openCustomChannelWithProtocol:protocol];
    if( [self.deviceManager isConnected] && [self.customChannels valueForKey:protocol]!=nil)
    {
        CustomCastChannel* channel = [self.customChannels valueForKey:protocol];
        return [channel sendTextMessage:event];
    }
    else
        return NO;
}

#pragma mark - implementation

- (NSString *)getDeviceName {
  if (self.selectedDevice == nil)
    return @"";
  return self.selectedDevice.friendlyName;
}

- (void)playMedia {
  [self pauseCastMedia:NO];
}

- (void)pauseMedia {
  [self pauseCastMedia:YES];
}
@end
