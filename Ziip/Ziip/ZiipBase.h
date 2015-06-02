//
//  ZiipBase.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZiipRequest.h"
#import "Define.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "PublicidadViewController.h"


@interface ZiipBase : UIViewController <ZiipRequestDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIView *publicidad;

//@property (nonatomic, retain) PublicidadViewController *publicidadViewController;

@property (nonatomic, retain) ZiipRequest *r;
@property (nonatomic,retain) ImageCache *imageCache;
@property (nonatomic, retain) AppDelegate *miDelegado;
@end
