//
//  DetalleContactoViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/6/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import "DetalleContactoViewController.h"
#import "ContactosCell.h"


@implementation DetalleContactoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.listaContactos = [[NSMutableArray alloc] initWithObjects: nil];
}

- (void) recargaTableView {
    [self.myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.listaContactos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *contacto = [self.listaContactos objectAtIndex:indexPath.row];
    static NSString *simpleTableIdentifier = @"ContactosCell";
    ContactosCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[ContactosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.nombre.text = contacto;
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [self.delegate eleccionContacto:[self.listaContactos objectAtIndex:indexPath.row]];
    
}

@end
