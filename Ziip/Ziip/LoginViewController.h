//
//  LoginViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipBase.h"
#import "ConfirmacionViewController.h"

@interface LoginViewController : ZiipBase <ConfirmacionViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUsuario;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong,nonatomic) IBOutlet UIScrollView  *scrollView;
@property (weak,nonatomic) IBOutlet UIView *vistaCampos;
@property (strong,nonatomic) IBOutlet UIButton  *btnLogin;
@property (nonatomic, retain) ConfirmacionViewController *confirmacionViewController;




- (IBAction)enviar:(id)sender;

@end
