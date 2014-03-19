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

#import <GoogleCast/GoogleCast.h>
#import <Foundation/Foundation.h>
#import "CustomCastChannel.h"

typedef NS_ENUM(NSInteger, ChromecastControllerFeatures) {
  // Constant for no features.
  ChromecastControllerFeaturesNone = 0x0,
  // Constant for controller device volume from hardware volume buttons.
  ChromecastControllerFeatureHWVolumeControl = 0x1,
  // Constant for adding notification support.
  ChromecastControllerFeatureNotifications = 0x2,
  // Constant for adding lock screen controls.
  ChromecastControllerFeatureLockscreenControl = 0x4
};

/**
 * The delegate to ChromecastDeviceController. Allows responsding to device and
 * media states and reflecting that in the UI.
 */
@protocol ChromecastControllerDelegate<NSObject>

@optional

/**
 * Called when chromecast devices are discoverd or goes offline on the network.
 */
- (void)deviceListChanged:(NSArray*)deviceList;

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice*)device;

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect;

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange:(GCKMediaControlChannel*) mediaChannel;

/**
 * Called when the device fires custom events.
 */
- (void)didReceiveCustomEvent:(NSString*) event forProtocol:(NSString*)protocol;

@end

/**
 * Controller for managing the Chromecast device. Provides methods to connect to
 * the device, launch an application, load media and control its playback.
 */
@interface ChromecastDeviceController : NSObject<GCKDeviceScannerListener,
                                                 GCKDeviceManagerDelegate,
                                                 GCKMediaControlChannelDelegate,
                                                 CustomCastChannelDelegate>

/** The device scanner used to detect devices on the network. */
@property(nonatomic, strong) GCKDeviceScanner* deviceScanner;

/** The device manager used to manage conencted chromecast device. */
@property(nonatomic, strong) GCKDeviceManager* deviceManager;

/** Get the friendly name of the device. */
@property(readonly, getter=getDeviceName) NSString* deviceName;

/** Length of the media loaded on the device. */
@property(nonatomic, readonly) NSTimeInterval streamDuration;

/** Current playback position of the media loaded on the device. */
@property(nonatomic, readonly) NSTimeInterval streamPosition;

/** The media player state of the media on the device. */
@property(nonatomic, readonly) GCKMediaPlayerState playerState;

/** The media information of the loaded media on the device. */
@property(nonatomic, readonly) GCKMediaInformation* mediaInformation;

/** The delegate attached to this controller. */
@property(nonatomic, assign) id<ChromecastControllerDelegate> delegate;

/** Initialize the controller and feed the app id. */
- (void)setupWithAppId:(NSString *)appId;

/** Perform a device scan to discover devices on the network. */
- (void)performScan:(BOOL)start;

/** Connect to a specific Chromecast device. */
- (BOOL)connectToDeviceByID:(NSString*)deviceID;
- (void)connectToDevice:(GCKDevice*)device;

/** Disconnect from a Chromecast device. */
- (void)disconnectFromDevice;

/** Load a media on the device with supplied media metadata. */
- (BOOL)loadMedia:(NSURL*)url
     thumbnailURL:(NSURL*)thumbnailURL
            title:(NSString*)title
         subtitle:(NSString*)subtitle
         mimeType:(NSString*)mimeType
        startTime:(NSTimeInterval)startTime
         autoPlay:(BOOL)autoPlay;

/** Returns true if connected to a Chromecast device. */
- (BOOL)isConnected;

/** Returns true if media is loaded on the device. */
- (BOOL)isPlayingMedia;

/** Pause or play the currently loaded media on the Chromecast device. */
- (void)pauseCastMedia:(BOOL)shouldPause;

/** Request an update of media playback stats from the Chromecast device. */
- (void)updateStatsFromDevice;

/** Sets the position of the playback on the Chromecast device. */
- (void)setPlaybackPercent:(float)newPercent;

/** Stops the media playing on the Chromecast device. */
- (void)stopCastMedia;

/** Increase or decrease the volume on the Chromecast device. */
- (void)changeVolume:(double)idealVolume;

/** Send events on a custom channel */
- (BOOL)sendCustomEvent:(NSString*)event forProtocol:(NSString*)protocol;

@end