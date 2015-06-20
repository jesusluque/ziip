//
//  PreferenciasViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 23/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "RSKImageCropper.h"

@interface PreferenciasViewController : ZiipBase <UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imagen;
@property (nonatomic, retain) IBOutlet UILabel *username;
@property (nonatomic, retain) IBOutlet UILabel *telefono;
@property (nonatomic, retain) IBOutlet UITextField *movil;
@property (nonatomic, retain) IBOutlet UIButton *editMovil;
@property (nonatomic,retain) UIImagePickerController *imagePicker;
@property (nonatomic,retain) RSKImageCropViewController *imageCropVC;

- (IBAction) guardar;
- (IBAction) editarImagen;

-(IBAction) logout;

@end
