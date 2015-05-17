//
//  ContactosViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface ContactosViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSMutableArray *listaPersonas;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@end
