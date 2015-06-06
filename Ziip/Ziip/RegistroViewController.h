//
//  RegistroViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "ConfirmacionViewController.h"

@interface RegistroViewController : ZiipBase <ConfirmacionViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *txtUsuario;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword2;
@property (weak, nonatomic) IBOutlet UITextField *movil;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexo;
@property (strong,nonatomic) IBOutlet UIScrollView  *scrollView;
@property (weak,nonatomic) IBOutlet UIView *vistaCampos;
@property (nonatomic, retain) ConfirmacionViewController *confirmacionViewController;


- (IBAction)enviar:(id)sender;
-(IBAction) volver;

@end
