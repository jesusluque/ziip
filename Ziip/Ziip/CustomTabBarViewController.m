//
//  CustomTabBarViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 17/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "Define.h"

@interface CustomTabBarViewController ()

@end

@implementation CustomTabBarViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSArray *items = self.tabBar.items;
    

    int i=0;
    for (UITabBarItem *tbi in items) {
        UIImage *image = tbi.image;
        
        NSString *imageName;
        /*if (i==0) {
            imageName= @"agendaA.png";
        } else
        */
        if (i==0) {
            imageName= @"jicziipA.png";
        } else if (i==1) {
            imageName= @"agendaA.png";
            
        } else if (i==2) {
            imageName= @"jicrecentA.png";
        } else if (i==3) {
            imageName= @"jicchatA.png";
        } else if (i==4) {
            imageName= @"jicsettingA.png";
        }
        UIImage *selectedImage = [UIImage imageNamed:imageName];
        [tbi setFinishedSelectedImage: [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] withFinishedUnselectedImage:image ];
        
        
        i++;
        
        
    }
    
    
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor foregroundColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor foregroundColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
}



- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"did selecte item");
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:      (UIViewController *)viewController
{
    NSLog(@"Selected view controller");
}
@end
