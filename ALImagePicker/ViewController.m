//
//  ViewController.m
//  ALImagePicker
//
//  Created by Andrew Liu on 10/26/15.
//  Copyright © 2015 Andrew Liu. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerCropVC.h"

@interface ViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerCropVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onPickerClicked:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Take Photo", @"Photo Library", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex){
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.delegate = self;
        picker.allowsEditing = NO;
        if (buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinner.color = [UIColor colorWithRed:((float)((0x3699f3 & 0xFF0000) >> 16))/255.0
                                    green:((float)((0x3699f3 & 0xFF00) >> 8))/255.0
                                     blue:((float)(0x3699f3 & 0xFF))/255.0 alpha:1.0];
    [spinner startAnimating];
    [self.view addSubview:spinner];
    ImagePickerCropVC *vc =  [ImagePickerCropVC new];
    vc.image = info[UIImagePickerControllerOriginalImage];
    vc.ratio = 0.56;
    vc.delegate = self;
    [self dismissViewControllerAnimated:NO completion:^{
        UINavigationController *imagePickerCropVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:imagePickerCropVC animated:YES completion:^{
            [spinner stopAnimating];
            [spinner removeFromSuperview];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageDidCropped:(UIImage *)image {
    //return cropped UIImage here
}

@end
