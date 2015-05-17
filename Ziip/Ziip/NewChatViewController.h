//
//  newChatViewController.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AbroadsterRequest.h"
#import "ZiipBase.h"

#import "UserCell.h"
//#import "ImageCache.h"



@class NewChatViewController;
@protocol NewChatDelegate <NSObject>

- (void)nuevaConversacion:(NSDictionary *)datos;

@end

@interface NewChatViewController : ZiipBase <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate> {
    NSMutableArray *usuarios;
    UITableView *myTableView;
    __weak id <NewChatDelegate> delegate;
    ImageCache *imageCache;
    UISearchBar *searchBar;
    bool fromSearch;
}

@property (nonatomic) bool fromSearch;
@property (nonatomic) bool more;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) ImageCache *imageCache;
@property (nonatomic,retain) NSMutableArray *usuarios;
@property (nonatomic,retain)  IBOutlet UITableView *myTableView;
@property (weak) id <NewChatDelegate> delegate;

@end
