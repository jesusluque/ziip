//
//  LoginViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    
    NSLog(@"%f",self.view.frame.size.width);
    [super viewDidLoad];
    self.btnLogin.layer.cornerRadius = 5;
    self.btnLogin.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    //Detección de toques en el scroll view
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(scrollViewPulsado)];
    [tapRecognizer setCancelsTouchesInView:NO];
    [[self scrollView] addGestureRecognizer:tapRecognizer];
    
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if([nextResponder isEqual:self.btnLogin]){
        [self enviar:nextResponder];
        [textField resignFirstResponder];
    }
    else if(nextResponder){
        [nextResponder becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return NO;
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self performSelector:@selector(scrollToView:) withObject:self.btnLogin afterDelay:0.1];
}


- (void)keyboardDidShow: (NSNotification *) notification{
    
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height + 10, 0.0);
    self.scrollView.contentInset = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    
    if(!CGRectContainsPoint(aRect, self.btnLogin.frame.origin)){
        [self performSelector:@selector(scrollToView:) withObject:self.btnLogin afterDelay:0.1];
    }
}


- (void) scrollToView:(UIView *)aView {
    
    [self.scrollView scrollRectToVisible:aView.frame animated:YES];
}


- (void)keyboardDidHide: (NSNotification *) notification{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}


- (void) scrollViewPulsado {
    
    [[self vistaCampos] endEditing:YES];
}


- (IBAction)enviar:(id)sender {
    
    NSString *errores=@"";
    if ([self.txtUsuario.text isEqualToString:@""]) {
        [self.txtUsuario becomeFirstResponder];
        errores = [[NSString alloc] initWithFormat:@"%@\n%@", errores, @"El usuario es obligatorio."];
    }
    
    if ([self.txtPassword.text isEqualToString:@""]) {
        if([errores isEqualToString:@""]){
            [self.txtPassword becomeFirstResponder];
        }
        errores = [[NSString alloc] initWithFormat:@"%@\n%@", errores, @"La contraseña es obligatoria."];
    }
    
    if (![errores isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:errores
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles: nil];
        
        [alertView show];
    } else {
        
        NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"user",@"password", nil];
        NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.txtUsuario.text,self.txtPassword.text, nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"pushToken"]) {
            [parametros addObject:@"pushToken"];
            [valores addObject:[defaults objectForKey:@"pushToken"]];
            [parametros addObject:@"device"];
            [valores addObject:[defaults objectForKey:@"ios"]];
        }
        
        
        
        [defaults setObject:self.txtUsuario.text forKey:@"user"];
        [defaults setObject:self.txtPassword.text forKey:@"password"];
        [defaults synchronize];
        [self.r send:@"login" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:NO];
    }
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"login"]) {
        if ([[datos objectForKey:@"status"]isEqualToString:@"ok"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[datos objectForKey:@"token"] forKey:@"api_auth_token"];
            [defaults synchronize];
            [self performSegueWithIdentifier:@"segue_principal" sender: self];
            
            
        } else  {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:[datos objectForKey:@"mensaje"]
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles: nil];
            [alertView show];
        }
        
    }
}

@end
