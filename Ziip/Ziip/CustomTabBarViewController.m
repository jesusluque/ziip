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
    
    NSLog(@"En el custom tabbar");
    NSArray *items = self.tabBar.items;
    

    int i=0;
    for (UITabBarItem *tbi in items) {
        NSLog(@"En el array");
        UIImage *image = tbi.image;
        
        NSString *imageName;
        if (i==0) {
            imageName= @"agendaA.png";
        } else if (i==1) {
            imageName= @"chatA.png";
        } else if ( i==2) {
            imageName= @"ajustesA.png";
        }
        UIImage *selectedImage = [UIImage imageNamed:imageName];

        NSLog(@"%@",selectedImage);
        //tbi.finishedSelectedImaget = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        //tbi.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        
        [tbi setFinishedSelectedImage: [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        i++;
        
        
    }
    
    self.tabBar.tintColor =[UIColor redColor];
    self.tabBar.backgroundColor = [UIColor redColor];
    
    
    //UIColor *color =[UIColor yellowColor];
    
    UIColor *color =[UIColor colorWithRed:130 green:81 blue:160 alpha:0];
    
    [[UITabBar appearance] setBarTintColor:color];
    
    //esto funciona, pero es una imagen
    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"backA"];
    //self.tabBar.selectedImageTintColor = [UIColor foregroundColor];
    
}

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    NSLog(@"%@",item);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end