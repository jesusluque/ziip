//
//  AnonimoViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "Person.h"
#import "ConfirmacionViewController.h"

@interface SeleccionaContactoViewController : ZiipBase <ConfirmacionViewControllerDelegate>

@property (nonatomic, retain) Person *contacto;
@property (nonatomic, retain) NSString *accion;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *telefono;
@property (nonatomic, retain) NSString *telefono1;
@property (nonatomic, retain) NSString *email1;
@property (nonatomic, retain)  NSString *contacto1_nombre;
@property (nonatomic, retain) ConfirmacionViewController *confirmacionViewController;

-(IBAction) enviar;

@end
