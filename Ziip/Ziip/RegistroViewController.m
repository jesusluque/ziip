//
//  RegistroViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "RegistroViewController.h"


@implementation RegistroViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(IBAction) volver {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)enviar:(id)sender {
    
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
    if (![self.txtPassword.text isEqualToString:self.txtPassword2.text]) {
        if([errores isEqualToString:@""]){
            [self.txtPassword becomeFirstResponder];
        }
        errores = [[NSString alloc] initWithFormat:@"%@\n%@", errores, @"Las contraseña deben de ser idénticas."];
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
        
        NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"user",@"password",@"movil", nil];
        NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.txtUsuario.text,self.txtPassword.text,self.movil.text, nil];
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
        [self.r send:@"alta" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:NO];
    }
 
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"alta"]) {
        if ([[datos objectForKey:@"status"]isEqualToString:@"ok"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[datos objectForKey:@"token"] forKey:@"api_auth_token"];
            [defaults synchronize];
            if ([self.movil.text isEqualToString:@""]){
                [self performSegueWithIdentifier:@"segue_principal" sender: self];
            } else {
                [self performSegueWithIdentifier:@"segue_cod_movil" sender: self];
            }
            
            
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
