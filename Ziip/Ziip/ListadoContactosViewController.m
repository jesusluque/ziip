//
//  ListadoContactosViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/6/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import "ListadoContactosViewController.h"

@implementation ListadoContactosViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.listaContactos= [[NSMutableArray alloc] initWithObjects: nil];
    [self recargaContactos];

}


- (void)recargaContactos {
    
    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects: nil];
    [self.r send:@"getContactos" tipo_peticion:@"GET" withParams:parametros andValues:valores enviarToken:YES];
}


- (void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"getContactos"]) {
        
        self.listaContactos = [datos objectForKey:@"contactos"];
        [self.myTableView reloadData];
    }
}


-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self recargaContactos];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.listaContactos count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    NSDictionary *contacto = [self.listaContactos objectAtIndex:indexPath.row];
    static NSString *simpleTableIdentifier = @"ContactosCell";
    ContactosCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[ContactosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.nombre.text = [contacto objectForKey:@"usuario"];
    
    [cell.imageView setImage:[self.imageCache getCachedImage:[contacto objectForKey:@"imagen"]]];
    return cell;
    
}



@end
