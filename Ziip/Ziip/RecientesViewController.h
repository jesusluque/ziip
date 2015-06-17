//
//  RecientesViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipBase.h"
#import "DetalleRecientesViewController.h"

@interface RecientesViewController : ZiipBase <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *arrayRecientes;

@end
