//
//  PerfilUsuarioViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 16/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "PerfilUsuarioViewController.h"

@interface PerfilUsuarioViewController ()

@end

@implementation PerfilUsuarioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.username.text = self.ultimoMensaje.userName;
    [self.imagen setImage:[self.imageCache getCachedImage:self.ultimoMensaje.img]];
    if ([self.ultimoMensaje.bloqueado intValue]==0) {
        [self.btnBloquear setTitle:@"Bloquear usuario" forState:UIControlStateNormal];

    } else {
        [self.btnBloquear setTitle:@"Desloquear usuario" forState:UIControlStateNormal];

        
    }
}


- (IBAction)bloquear{
 
    NSLog(@"%@",self.ultimoMensaje.bloqueado);
    if ([self.ultimoMensaje.bloqueado intValue]==0) {
        NSLog(@"Bloqueamos");
        [self.delegate bloquear:self.ultimoMensaje.userId estado:@(1)];
        [self.btnBloquear setTitle:@"Desloquear usuario" forState:UIControlStateNormal];
        self.ultimoMensaje.bloqueado=@(1);
        
    } else {
        NSLog(@"Desbloqueamos");
        [self.delegate bloquear:self.ultimoMensaje.userId estado:@(0)];
        [self.btnBloquear setTitle:@"Bloquear usuario" forState:UIControlStateNormal];
        self.ultimoMensaje.bloqueado=@(0);
    }
}


@end
