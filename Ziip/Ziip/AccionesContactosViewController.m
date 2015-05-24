//
//  AccionesContactosViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 10/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "AccionesContactosViewController.h"

@interface AccionesContactosViewController ()

@end

@implementation AccionesContactosViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contactoNombre.text = self.contacto.fullName;
}


-(IBAction) volver {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"anonimo_segue"]) {
        AnonimoViewController *accionViewController = (AnonimoViewController *)[segue destinationViewController];
         accionViewController.contacto = self.contacto;
    } else if ([[segue identifier] isEqualToString:@"celestino_segue"]) {
        CelestinoViewController *accionViewController = (CelestinoViewController *)[segue destinationViewController];
        accionViewController.contacto = self.contacto;
    } else if ([[segue identifier] isEqualToString:@"conecta_segue"]) {
        ConectaViewController *accionViewController = (ConectaViewController *)[segue destinationViewController];
        accionViewController.contacto = self.contacto;
    }
 
}


@end
