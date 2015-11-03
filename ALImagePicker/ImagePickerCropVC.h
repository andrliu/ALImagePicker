//
//  ImagePickerCropVC.h
//  ALImagePicker
//
//  Created by Andrew Liu on 10/26/15.
//  Copyright © 2015 Andrew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePickerCropVCDelegate <NSObject>

- (void)imageDidCropped:(UIImage *)image;

@end

@interface ImagePickerCropVC : UIViewController

@property UIImage *image;
@property CGFloat ratio;
@property (weak, nonatomic) id<ImagePickerCropVCDelegate> delegate;

@end
