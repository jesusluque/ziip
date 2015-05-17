//
//  MapaViewController.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 03/07/13.
//  Copyright (c) 2013 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
#import <MapKit/MapKit.h>

@interface MapaViewController : UIViewController {
    
    ChatMessage *locToShow;
    MKMapView *mapView;
}

@property (nonatomic,retain) ChatMessage *locToShow;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end
