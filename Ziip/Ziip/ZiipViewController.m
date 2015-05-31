//
//  ZiipViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 30/5/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import "ZiipViewController.h"
#import "SeleccionaContactoViewController.h"

@interface ZiipViewController ()

@end

@implementation ZiipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SeleccionaContactoViewController *accionViewController = (SeleccionaContactoViewController *)[segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"anonimo_segue"]) {
        accionViewController.accion = @"anonimo";
        
    } else if ([[segue identifier] isEqualToString:@"celestino_segue"]) {
        accionViewController.accion = @"celestino";
        
    } else if ([[segue identifier] isEqualToString:@"conecta_segue"]) {
        accionViewController.accion = @"conecta";
    }
    
}


@end
