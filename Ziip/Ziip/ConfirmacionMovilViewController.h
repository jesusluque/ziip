//
//  ConfirmacionMovilViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 9/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipBase.h"

@interface ConfirmacionMovilViewController : ZiipBase

@property (nonatomic, retain) IBOutlet UITextField *codigo;
@property (nonatomic) bool proceso_registro;

-(IBAction) enviar;

@end
