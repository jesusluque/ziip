//
//  ListadoContactosViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/6/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipBase.h"
#import "ContactosCell.h"

@interface ListadoContactosViewController : ZiipBase <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic) NSMutableArray *listaContactos;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;


@end
