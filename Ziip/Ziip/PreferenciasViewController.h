//
//  PreferenciasViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 23/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"

@interface PreferenciasViewController : ZiipBase <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imagen;
@property (nonatomic, retain) IBOutlet UILabel *username;
@property (nonatomic, retain) IBOutlet UILabel *telefono;
@property (nonatomic, retain) IBOutlet UITextField *movil;
@property (nonatomic, retain) IBOutlet UIButton *editMovil;
@property (nonatomic,retain) UIImagePickerController *imagePicker;

- (IBAction) guardar;
- (IBAction) editarImagen;


@end
