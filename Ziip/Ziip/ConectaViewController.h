//
//  ConectaViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "ZiipBase.h"
#import "ConfirmacionViewController.h"


@interface ConectaViewController : ZiipBase <ConfirmacionViewControllerDelegate>


@property (nonatomic, retain) Person *contacto;
@property (nonatomic, retain)  NSString *email;
@property (nonatomic, retain)  NSString *telefono;
@property (nonatomic, retain) ConfirmacionViewController *confirmacionViewController;
@property (nonatomic, retain)  NSString *contacto_nombre;
@property (nonatomic, retain) IBOutlet UILabel *mensajeA;

-(IBAction) enviar;


@end
