//
//  MapaViewController.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 03/07/13.
//  Copyright (c) 2013 Manuel Rodriguez Morales. All rights reserved.
//

#import "MapaViewController.h"




@implementation MapaViewController

@synthesize locToShow;
@synthesize mapView;


-(void) viewDidLoad{
    
    [super viewDidLoad];
    NSArray *coor = [self.locToShow.text componentsSeparatedByString:@","];
    CLLocationCoordinate2D workingCoordinate;
    workingCoordinate.latitude = [[coor objectAtIndex:0] floatValue];
    workingCoordinate.longitude = [[coor objectAtIndex:1] floatValue];
    MKPointAnnotation *punto = [[MKPointAnnotation alloc]init];
    punto.coordinate = workingCoordinate;
    [mapView addAnnotation:punto];
    mapView.region = MKCoordinateRegionMakeWithDistance(workingCoordinate, 2000, 2000);
}

@end
