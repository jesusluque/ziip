//
//  DetalleContactoViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/6/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import "ZiipBase.h"


@class DetalleContactoViewController;
@protocol DetalleContactoDelegate <NSObject>

- (void) eleccionContacto:(NSString *)contacto;


@end


@interface DetalleContactoViewController : ZiipBase <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSMutableArray *listaContactos;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (weak) id <DetalleContactoDelegate> delegate;

- (void) recargaTableView ;
@end
