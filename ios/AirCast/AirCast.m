//
//  AirCast.m
//  AirCast
//
//  Created by Renaud Bardet on 06/02/2014.
//  Copyright (c) 2014 renaudbardet. All rights reserved.
//

#import "AirCast.h"

FREContext AirCtx = nil;

@interface AirCast ()
@property ChromecastDeviceController *chromecastDeviceController;
@end

@implementation AirCast

static AirCast* sharedInstance = nil;

- (id)init {
    self = [super init];
    
    GCKLogger.sharedInstance.delegate = self;
    
    self.chromecastDeviceController = [[ChromecastDeviceController alloc] init];
    self.chromecastDeviceController.delegate = self;
    
    [self.chromecastDeviceController performScan:YES];
    
    return self;
}

- (void)logFromFunction:(const char *)function message:(NSString *)message {
    [AirCast dispatchEvent:nil withMessage:message];
}

+ (AirCast *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[AirCast alloc] init];
    }
    return sharedInstance;
}

// every time we have to send back information to the air application, invoque this method wich will dispatch an Event in air
+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message
{
    
    NSString *eventName = event ? event : @"LOGGING";
    NSString *messageText = message ? message : @"";
    FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[messageText UTF8String]);
    
}

#pragma mark - ChromecastControllerDelegate

/**
 * Called when chromecast devices are discoverd or goes offline on the network.
 */
- (void)deviceListChanged:(NSArray*)deviceList{
    NSMutableArray* devicesJsonObject = [[NSMutableArray alloc] init];
    for ( GCKDevice* device in deviceList )
        [devicesJsonObject addObject:[AirCast deviceToJSONObject:device]];
    NSString* jsonEncodedDeviceList = [GCKJSONUtils writeJSON:devicesJsonObject];
    [AirCast dispatchEvent:@"AirCast.deviceListChanged" withMessage:jsonEncodedDeviceList];
}

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice*)device{
    NSString* jsonEncodedDevice = [GCKJSONUtils writeJSON:[AirCast deviceToJSONObject:device]];
    [AirCast dispatchEvent:@"AirCast.didConnectToDevice" withMessage:jsonEncodedDevice];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect{
    [AirCast dispatchEvent:@"AirCast.didDisconnect" withMessage:@"DISCONNECTED"];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange:(GCKMediaControlChannel*) mediaChannel{
    NSMutableDictionary* mediaChannelJsonObject = [[NSMutableDictionary alloc] init];
    if( [mediaChannel mediaStatus]!=nil)
        [mediaChannelJsonObject setValue:[AirCast mediaStatusToJSONObject:[mediaChannel mediaStatus]] forKey:@"mediaStatus"];
    NSString* jsonEncodedMediaChannel = [GCKJSONUtils writeJSON:mediaChannelJsonObject];
    [AirCast dispatchEvent:@"AirCast.didReceiveMediaStateChange" withMessage:jsonEncodedMediaChannel];
}

- (void)didReceiveCustomEvent:(NSString*)event forProtocol:(NSString*)protocol
{
    NSMutableDictionary* eventJsonObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:event,@"event",protocol,@"protocol",nil];
    [AirCast dispatchEvent:@"AirCast.didReceiveCustomEvent" withMessage:[GCKJSONUtils writeJSON:eventJsonObject]];
}

#pragma mark - utils

+ (NSDictionary*) deviceToJSONObject:(GCKDevice*) device {
    
    NSArray* properties =[NSArray arrayWithObjects:@"deviceID",@"ipAddress",@"servicePort",@"friendlyName",@"manufacturer",@"modelName", nil];
    
    NSMutableDictionary* deviceJsonObject = [NSMutableDictionary dictionaryWithDictionary:[device dictionaryWithValuesForKeys:properties]];
    
    [deviceJsonObject setObject:[NSNumber numberWithUnsignedInt:[device servicePort]] forKey:@"servicePort"];
    
    NSMutableArray* icons = [[NSMutableArray alloc] init];
    for ( GCKImage* icon in [device icons] )
        [icons addObject:[icon JSONObject]];
    [deviceJsonObject setValue:icons forKey:@"icons"];
    
    return deviceJsonObject;
    
}

+ (NSDictionary*) mediaStatusToJSONObject:(GCKMediaStatus*) mediaStatus {
    
    NSArray* properties = [NSArray arrayWithObjects:@"mediaSessionID",@"streamPosition",@"playerState",@"idleReason", nil];
    
    NSMutableDictionary* mediaStatusJsonObject = [NSMutableDictionary dictionaryWithDictionary:[mediaStatus dictionaryWithValuesForKeys:properties]];
    
    [mediaStatusJsonObject setObject:[NSNumber numberWithFloat:[mediaStatus playbackRate]] forKey:@"playbackRate"];
    [mediaStatusJsonObject setObject:[NSNumber numberWithFloat:[mediaStatus volume]] forKey:@"volume"];
    [mediaStatusJsonObject setObject:[NSNumber numberWithBool:[mediaStatus isMuted]] forKey:@"isMuted"];
    [mediaStatusJsonObject setObject:[[mediaStatus mediaInformation] JSONObject] forKey:@"mediaInformation"];
    
    return mediaStatusJsonObject;
    
}

@end

#pragma mark - ANE Functions

DEFINE_ANE_FUNCTION(init)
{
    // Initialize Cast
    NSString *appId = FPANE_FREObjectToNSString(argv[0]);
    [[[AirCast sharedInstance] chromecastDeviceController] setupWithAppId:appId];
    
    return nil;
}

DEFINE_ANE_FUNCTION(scan)
{
    /** Perform a device scan to discover devices on the network. */
    [[[AirCast sharedInstance] chromecastDeviceController] performScan:YES];
    return nil;
}

DEFINE_ANE_FUNCTION(stopScan)
{
    [[[AirCast sharedInstance] chromecastDeviceController] performScan:NO];
    return nil;
}


DEFINE_ANE_FUNCTION(connectToDevice)
{
    NSString* deviceID = FPANE_FREObjectToNSString(argv[0]);
    
    BOOL didFindDevice = [[[AirCast sharedInstance] chromecastDeviceController] connectToDeviceByID:deviceID];
    
    return FPANE_BOOLToFREObject(didFindDevice);
}

DEFINE_ANE_FUNCTION(disconnectFromDevice)
{
    [[[AirCast sharedInstance] chromecastDeviceController] disconnectFromDevice];
    return nil;
}

DEFINE_ANE_FUNCTION(loadMedia)
{
    NSURL* url          = [NSURL URLWithString:FPANE_FREObjectToNSString(argv[0])];
    NSURL* thumbnailURL = [NSURL URLWithString:FPANE_FREObjectToNSString(argv[1])];
    NSString* title     = FPANE_FREObjectToNSString(argv[2]);
    NSString* desc      = FPANE_FREObjectToNSString(argv[3]);
    NSString* mimeType  = FPANE_FREObjectToNSString(argv[4]);
    
    double t;
    FREGetObjectAsDouble(argv[5], &t);
    NSTimeInterval startTime = t;
    
    BOOL autoPlay       = FPANE_FREObjectToBOOL(argv[6]);
    
    /** Load a media on the device with supplied media metadata. */
    BOOL didLoad = [[[AirCast sharedInstance] chromecastDeviceController] loadMedia:url
                                                      thumbnailURL:thumbnailURL
                                                             title:title
                                                          subtitle:desc
                                                          mimeType:mimeType
                                                         startTime:startTime
                                                          autoPlay:autoPlay];
    return FPANE_BOOLToFREObject(didLoad);
}

DEFINE_ANE_FUNCTION(isConnected)
{
    /** Returns true if connected to a Chromecast device. */
    BOOL c = [[[AirCast sharedInstance] chromecastDeviceController] isConnected];
    return FPANE_BOOLToFREObject(c);
}

DEFINE_ANE_FUNCTION(isPlayingMedia)
{
    /** Returns true if media is loaded on the device. */
    BOOL p = [[[AirCast sharedInstance] chromecastDeviceController] isPlayingMedia];
    return FPANE_BOOLToFREObject(p);
}

DEFINE_ANE_FUNCTION(playCast)
{
    [[[AirCast sharedInstance] chromecastDeviceController] pauseCastMedia:NO];
    return nil;
}

DEFINE_ANE_FUNCTION(pauseCast)
{
    [[[AirCast sharedInstance] chromecastDeviceController] pauseCastMedia:YES];
    return nil;
}

DEFINE_ANE_FUNCTION(updateStatsFromDevice)
{
    [[[AirCast sharedInstance] chromecastDeviceController] updateStatsFromDevice];
    
    FREObject streamPosition;
    FREObject streamDuration;
    FREObject playerState;
    
    FRENewObjectFromDouble([[[AirCast sharedInstance] chromecastDeviceController] streamPosition], &streamPosition);
    FRENewObjectFromDouble([[[AirCast sharedInstance] chromecastDeviceController] streamDuration], &streamDuration);
    FRENewObjectFromInt32([[[AirCast sharedInstance] chromecastDeviceController] playerState], &playerState);
    
    NSString* JSONMediaInformation = [GCKJSONUtils writeJSON:[[[AirCast sharedInstance] chromecastDeviceController] mediaInformation]];
    FREObject mediaInformation = FPANE_NSStringToFREOBject(JSONMediaInformation);
    
    FREObject ret;
    FREObject ex;
    FRENewObject((const uint8_t*)"Object", 0, nil, &ret, &ex);
    
    FRESetObjectProperty(ret, (const uint8_t*)"streamPosition", streamPosition, ex);
    FRESetObjectProperty(ret, (const uint8_t*)"streamDuration", streamDuration, ex);
    FRESetObjectProperty(ret, (const uint8_t*)"playerState", playerState, ex);
    FRESetObjectProperty(ret, (const uint8_t*)"mediaInformation", mediaInformation, ex);
    
    return ret;
    
}

DEFINE_ANE_FUNCTION(seek)
{
    double p;
    FREGetObjectAsDouble(argv[0], &p);
    
    /** Sets the position of the playback on the Chromecast device. */
    [[[AirCast sharedInstance] chromecastDeviceController] setPlaybackPercent:p];
    return nil;
}

DEFINE_ANE_FUNCTION(stopCast)
{
    /** Stops the media playing on the Chromecast device. */
    [[[AirCast sharedInstance] chromecastDeviceController] stopCastMedia];
    return nil;
}

DEFINE_ANE_FUNCTION(setVolume)
{
    double v;
    FREGetObjectAsDouble(argv[0], &v);
    
    /** Stops the media playing on the Chromecast device. */
    [[[AirCast sharedInstance] chromecastDeviceController] changeVolume:v];
    return nil;
}

DEFINE_ANE_FUNCTION(sendCustomEvent)
{
    NSString* message = FPANE_FREObjectToNSString(argv[0]);
    NSString* protocol = FPANE_FREObjectToNSString(argv[1]);
    BOOL ret = [[[AirCast sharedInstance] chromecastDeviceController] sendCustomEvent:message forProtocol:protocol];
    return FPANE_BOOLToFREObject(ret);
}

#pragma mark - Air Initilizers

void AirCastContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                   uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    uint32_t nbFuntionsToLink = 15;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "initNE";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "scan";
    func[1].functionData = NULL;
    func[1].function = &scan;
    
    func[2].name = (const uint8_t*) "stopScan";
    func[2].functionData = NULL;
    func[2].function = &stopScan;
    
    func[3].name = (const uint8_t*) "connectToDevice";
    func[3].functionData = NULL;
    func[3].function = &connectToDevice;
    
    func[4].name = (const uint8_t*) "disconnectFromDevice";
    func[4].functionData = NULL;
    func[4].function = &disconnectFromDevice;
    
    func[5].name = (const uint8_t*) "loadMedia";
    func[5].functionData = NULL;
    func[5].function = &loadMedia;

    func[6].name = (const uint8_t*) "isConnected";
    func[6].functionData = NULL;
    func[6].function = &isConnected;

    func[7].name = (const uint8_t*) "isPlayingMedia";
    func[7].functionData = NULL;
    func[7].function = &isPlayingMedia;
    
    func[8].name = (const uint8_t*) "playCast";
    func[8].functionData = NULL;
    func[8].function = &playCast;
    
    func[9].name = (const uint8_t*) "pauseCast";
    func[9].functionData = NULL;
    func[9].function = &pauseCast;
    
    func[10].name = (const uint8_t*) "updateStatsFromDevice";
    func[10].functionData = NULL;
    func[10].function = &updateStatsFromDevice;
    
    func[11].name = (const uint8_t*) "seek";
    func[11].functionData = NULL;
    func[11].function = &seek;
    
    func[12].name = (const uint8_t*) "stopCast";
    func[12].functionData = NULL;
    func[12].function = &stopCast;
    
    func[13].name = (const uint8_t*) "setVolume";
    func[13].functionData = NULL;
    func[13].function = &setVolume;
    
    func[14].name = (const uint8_t*) "sendCustomEvent";
    func[14].functionData = NULL;
    func[14].function = &sendCustomEvent;
    
    *functionsToSet = func;
    
    AirCtx = ctx;
    
}

void AirCastContextFinalizer(FREContext ctx) { }

void AirCastInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirCastContextInitializer;
	*ctxFinalizerToSet = &AirCastContextFinalizer;
}

void AirCastFinalizer(void *extData) { }