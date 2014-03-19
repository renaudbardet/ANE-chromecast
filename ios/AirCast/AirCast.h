//
//  AirCast.h
//  AirCast
//
//  Created by Renaud Bardet on 06/02/2014.
//  Copyright (c) 2014 renaudbardet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleCast/GoogleCast.h>
#import <GoogleCast/GCKJSONUtils.h>

#import "FlashRuntimeExtensions.h"
#import "FPANEUtils.h"
#import "ChromecastDeviceController.h"

@interface AirCast : NSObject<ChromecastControllerDelegate,GCKLoggerDelegate>

+ (id)sharedInstance;

+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message;

@end
