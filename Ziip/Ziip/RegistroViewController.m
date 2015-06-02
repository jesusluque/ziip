//
//  RegistroViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "RegistroViewController.h"
#import "ConfirmacionMovilViewController.h"

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
    if ([self.txtEmail.text isEqualToString:@""]) {
        [self.txtEmail becomeFirstResponder];
        errores = [[NSString alloc] initWithFormat:@"%@\n%@", errores, @"El email es obligatorio."];
    } else {
        if (! [self isValidEmail:self.txtEmail.text ]) {
            errores = [[NSString alloc] initWithFormat:@"%@\n%@", errores, @"El email tiene un formato invalido."];
        }
        
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
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
        
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",errores, dict_tipo, nil];
        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        [self.confirmacionViewController configuraPantalla:confirmacion];
        [self.view addSubview:self.confirmacionViewController.view];
    } else {
        
        NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"user",@"email",@"password",@"movil", nil];
        NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.txtUsuario.text,self.txtEmail.text,self.txtPassword.text,self.movil.text, nil];
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
            UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.confirmacionViewController.view.frame = frame;
            self.confirmacionViewController.delegate = self;
            
            NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
            
            NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
            NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",[datos objectForKey:@"mensaje"], dict_tipo, nil];
            NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
            [self.confirmacionViewController configuraPantalla:confirmacion];
            [self.view addSubview:self.confirmacionViewController.view];
        }
        
    }
}

-(BOOL) isValidEmail:(NSString *)checkString {
    
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"segue_cod_movil"]) {
        ConfirmacionMovilViewController *movilViewController = (ConfirmacionMovilViewController *)[segue destinationViewController];
        movilViewController.proceso_registro = YES;
    }
}


-(void) cierraConfirmacion {
    
    [self.confirmacionViewController.view removeFromSuperview];
}


-(void) respuestaUsuario:(bool)respuesta {
    
}

@end
