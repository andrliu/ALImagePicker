//
//  ImagePickerCropVC.m
//  ALImagePicker
//
//  Created by Andrew Liu on 10/26/15.
//  Copyright © 2015 Andrew Liu. All rights reserved.
//

#import "ImagePickerCropVC.h"

@interface ImagePickerCropVC () <UIGestureRecognizerDelegate>

@property UIImageView   *imageView;
@property UIView        *coverView;
@property CGFloat       scale;
@property BOOL          isFullWidth;
@property CGRect        scaledImageSize;

@end

@implementation ImagePickerCropVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,
                                                                  64,
                                                                  self.view.frame.size.width,
                                                                  self.view.frame.size.height - 128)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor colorWithRed:((float)((0xf5f5f5 & 0xFF0000) >> 16))/255.0
                                                     green:((float)((0xf5f5f5 & 0xFF00) >> 8))/255.0
                                                      blue:((float)(0xf5f5f5 & 0xFF))/255.0 alpha:1.0];
    self.image = [self fixOrientation];
    self.scale = [self contentScaleFactor];
    if (self.isFullWidth) {
        self.scaledImageSize = CGRectMake(0,
                                          (self.imageView.frame.size.height - self.image.size.height * self.scale) / 2,
                                          self.image.size.width * self.scale,
                                          self.image.size.height* self.scale);
    }
    else {
        self.scaledImageSize = CGRectMake((self.imageView.frame.size.width - self.image.size.width * self.scale) / 2,
                                          0,
                                          self.image.size.width * self.scale,
                                          self.image.size.height* self.scale);
    }
    
    self.imageView.image = self.image;
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    self.coverView = [[UIView alloc]initWithFrame:CGRectMake(self.scaledImageSize.origin.x,
                                                             (self.imageView.frame.size.height - self.scaledImageSize.size.width * self.ratio) / 2,
                                                             self.scaledImageSize.size.width,
                                                             self.scaledImageSize.size.width * self.ratio)];
    self.coverView.backgroundColor = [UIColor clearColor];
    self.coverView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.coverView.layer.borderWidth = 1.0f;
    self.coverView.userInteractionEnabled = YES;
    [self.imageView addSubview:self.coverView];
    
    UIPanGestureRecognizer *drag =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    drag.delegate = self;
    [self.coverView addGestureRecognizer:drag];
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    pinch.delegate = self;
    [self.coverView addGestureRecognizer:pinch];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancel)];
    
    UIButton *cropButton = [[UIButton alloc]initWithFrame:CGRectMake(0,
                                                                     self.view.frame.size.height-64,
                                                                     self.view.frame.size.width,
                                                                     64)];
    [cropButton setTitle:@"Crop" forState:UIControlStateNormal];
    cropButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0f];
    [cropButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cropButton.backgroundColor = [UIColor colorWithRed:((float)((0x3699f3 & 0xFF0000) >> 16))/255.0
                                                 green:((float)((0x3699f3 & 0xFF00) >> 8))/255.0
                                                  blue:((float)(0x3699f3 & 0xFF))/255.0 alpha:1.0];;
    [cropButton addTarget:self action:@selector(crop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cropButton];  
}

- (void)crop {
    CGFloat cropX = (self.coverView.frame.origin.x - self.scaledImageSize.origin.x) / self.scale;
    CGFloat cropY = (self.coverView.frame.origin.y - self.scaledImageSize.origin.y) / self.scale;
    CGFloat cropWidth = self.coverView.frame.size.width / self.scale;
    CGFloat cropHeight = self.coverView.frame.size.height / self.scale;
    
    CGRect cropRegion = CGRectMake(cropX, cropY, cropWidth, cropHeight);
    CGImageRef subImage = CGImageCreateWithImageInRect(self.image.CGImage, cropRegion);
    UIImage *cropImage = [UIImage imageWithCGImage:subImage];
    [self.delegate imageDidCropped:cropImage];
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer {
    if (UIGestureRecognizerStateBegan == recognizer.state ||
        UIGestureRecognizerStateChanged == recognizer.state) {
        CGFloat sizeWidth = self.coverView.frame.size.width * recognizer.scale;
        CGFloat sizeHeight = self.coverView.frame.size.height * recognizer.scale;
        CGFloat originX = self.coverView.center.x - sizeWidth / 2;
        CGFloat originY = self.coverView.center.y - sizeHeight / 2;
        if (originX >= self.scaledImageSize.origin.x &&
            originY >= self.scaledImageSize.origin.y &&
            originX + sizeWidth <= self.scaledImageSize.origin.x + self.scaledImageSize.size.width &&
            originY + sizeHeight <= self.scaledImageSize.origin.y + self.scaledImageSize.size.height) {
            self.coverView.frame = CGRectMake(originX, originY, sizeWidth, sizeHeight);
        }
        recognizer.scale = 1;
    }
}

- (void)moveImage:(UIPanGestureRecognizer *)recognizer {
    if (UIGestureRecognizerStateBegan == recognizer.state ||
        UIGestureRecognizerStateChanged == recognizer.state) {
        CGPoint translation = [recognizer translationInView:self.coverView];
        if (self.coverView.frame.origin.x + translation.x >= self.scaledImageSize.origin.x &&
            self.coverView.frame.origin.y + translation.y >= self.scaledImageSize.origin.y &&
            self.coverView.frame.origin.x + self.coverView.frame.size.width + translation.x <= self.scaledImageSize.origin.x + self.scaledImageSize.size.width &&
            self.coverView.frame.origin.y + self.coverView.frame.size.height + translation.y <= self.scaledImageSize.origin.y + self.scaledImageSize.size.height) {
            self.coverView.center = CGPointMake(self.coverView.center.x + translation.x,
                                                self.coverView.center.y + translation.y);
        }
        [recognizer setTranslation:CGPointZero inView:self.coverView];
    }
}

- (CGFloat)contentScaleFactor {
    CGFloat widthScale = self.imageView.frame.size.width / self.image.size.width;
    CGFloat heightScale = self.imageView.frame.size.height / self.image.size.height;
    CGFloat scale = MIN(widthScale, heightScale);
    if (scale == widthScale) {
        self.isFullWidth = YES;
    }
    return scale;
}

- (UIImage *)fixOrientation {
    // No-op if the orientation is already correct
    if (self.image.imageOrientation == UIImageOrientationUp) {
        return self.image;
    }
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.image.size.width, self.image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.image.size.width, self.image.size.height,
                                             CGImageGetBitsPerComponent(self.image.CGImage), 0,
                                             CGImageGetColorSpace(self.image.CGImage),
                                             CGImageGetBitmapInfo(self.image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.image.size.height,self.image.size.width), self.image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.image.size.width,self.image.size.height), self.image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
