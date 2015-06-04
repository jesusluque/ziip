//
//  ContactosViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "ZiipBase.h"

@interface ContactosViewController : ZiipBase <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSMutableArray *listaPersonas;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) Person *contactoSeleccionado;

@property (nonatomic, retain) NSString *accion;
@property (nonatomic, retain) NSString *email1;
@property (nonatomic, retain) NSString *telefono1;
@property (nonatomic, retain) NSString *contacto1_nombre;


@end
