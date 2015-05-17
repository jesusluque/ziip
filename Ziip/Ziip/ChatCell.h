//
//  ChatCell.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKIt/UIKit.h>
#import <Foundation/Foundation.h>
#import "ChatMessage.h"
//#import "ImageCache.h"



@class ChatCell;
@protocol ChatCellDelegate <NSObject>

//- (void) verLocalizacion:(ChatMessage *)msg;
//- (void) optionsMensaje:(ChatCell *) cell;

@end

@interface ChatCell : UITableViewCell
/*{
    UILabel *texto;
    ChatMessage *message;
    NSString *myId;
    __weak id <ChatCellDelegate> delegate;
    //ImageCache *imageCache;
    UILabel *lblTexto2;
    UISegmentedControl *segmentedControl;
}
 */

//@property (nonatomic,retain) IBOutlet UILabel *texto;
@property (nonatomic,retain) ChatMessage *message;
@property (nonatomic,retain) NSString *myId;
@property (weak) id <ChatCellDelegate> delegate;
//@property (nonatomic,retain) ImageCache *imageCache;
@property (nonatomic,retain) UILabel *lblTexto2;
@property (nonatomic,retain) UISegmentedControl *segmentedControl;

#define MAX_WIDTH 210
#define TOP_MARGIN 5
#define BOTTON_MARGIN 15
#define LEFT_MARGIN 10
#define RIGTH_MARGIN 10

@end