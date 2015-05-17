//
//  LoginViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipBase.h"

@interface LoginViewController : ZiipBase

@property (weak, nonatomic) IBOutlet UITextField *txtUsuario;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong,nonatomic) IBOutlet UIScrollView  *scrollView;
@property (weak,nonatomic) IBOutlet UIView *vistaCampos;
@property (strong,nonatomic) IBOutlet UIButton  *btnLogin;



- (IBAction)enviar:(id)sender;

@end
