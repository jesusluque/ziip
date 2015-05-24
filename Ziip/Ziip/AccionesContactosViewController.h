//
//  AccionesContactosViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 10/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "ZiipBase.h"
#import "AnonimoViewcontroller.h"
#import "ConectaViewController.h"
#import "CelestinoViewController.h"


@interface AccionesContactosViewController : ZiipBase

@property (nonatomic, retain) IBOutlet UILabel *contactoNombre;
@property (nonatomic, retain) Person *contacto;


-(IBAction) volver;

@end
