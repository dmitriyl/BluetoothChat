//
//  ViewController.m
//  BluetoothChat
//
//  Created by Dmitriy L. on 7/6/16.
//  Copyright © 2016. All rights reserved.
//

#import "ViewController.h"
#import "Transcript.h"
#import "SessionContainer.h"

#import "InfoCell.h"
#import "ImageCell.h"

@interface ViewController () <SessionContainerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    SessionContainer *sessionContainer;
    NSMutableArray *items;
    NSMutableDictionary *imageNameIndex;
    BOOL keyboardShowned;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    items = [NSMutableArray new];
    imageNameIndex = [NSMutableDictionary new];
    [self createSession];
}

#pragma mark - private methods
- (void)createSession
{
    NSString *displayName = [NSString stringWithFormat:@"%@ %@-%@", [UIDevice currentDevice].name, [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion];
    //ServiceType must be 1–15 characters long Can contain only ASCII lowercase letters, numbers, and hyphens.
    sessionContainer = [[SessionContainer alloc] initWithDisplayName:displayName serviceType:@"BluetoothChat"];
    sessionContainer.delegate = self;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 45;
    
    Transcript *item = items[indexPath.row];
    if (item.imageUrl) {
        height = 150;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Transcript *item = items[indexPath.row];
    if (nil != item.imageUrl) {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        [cell cutomInit:item];
        return cell;
    }
    else
    {
        InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
        [cell setMessage:item];
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - SessionContainerDelegate
- (void)receivedTranscript:(Transcript *)transcript
{
    NSLog(@"receivedTranscript %@", transcript);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertTranscript:transcript];
    });
};

- (void)updateTranscript:(Transcript *)transcript
{
    NSLog(@"updateTranscript %@", transcript);
    
    // Find the data source index of the progress transcript
    NSNumber *index = [imageNameIndex objectForKey:transcript.imageName];
    NSUInteger idx = [index unsignedLongValue];
    // Replace the progress transcript with the image transcript
    [items replaceObjectAtIndex:idx withObject:transcript];
    
    // Reload this particular table view row on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)insertTranscript:(Transcript *)transcript
{
    // Add to the data source
    [items addObject:transcript];
    
    // If this is a progress transcript add it's index to the map with image name as the key
    if (nil != transcript.progress) {
        NSNumber *transcriptIndex = [NSNumber numberWithUnsignedLong:(items.count - 1)];
        [imageNameIndex setObject:transcriptIndex forKey:transcript.imageName];
    }
    
    // Update the table view
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(items.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // Scroll to the bottom so we focus on the latest message
    NSUInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITextFieldDelegate methods
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger length = textField.text.length - range.length + string.length;
    if (length > 0) {
        self.btSend.enabled = YES;
    }
    else {
        self.btSend.enabled = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

// Delegate method called when the message text field is resigned.
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Check if there is any message to send
    if (textField.text.length) {
        // Resign the keyboard
        [textField resignFirstResponder];
        
        // Send the message
        Transcript *transcript = [sessionContainer sendMessage:textField.text];
        
        if (transcript) {
            // Add the transcript to the table view data source and reload
            [self insertTranscript:transcript];
        }
        
        // Clear the textField and disable the send button
        textField.text = @"";
        self.btSend.enabled = NO;
    }
}

#pragma mark - Send btn clicked
- (IBAction)sendClicked:(UIButton *)sender
{
    if (self.tfMessage.text)
    {
        [self.tfMessage endEditing:YES];

    }
}

#pragma mark - Image btn clicked
- (IBAction)imageClicked:(UIButton*)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [sheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - UIActionSheetDelegate methods
// Override this method to know if user wants to take a new photo or select from the photo library
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if (imagePicker) {
        // set the delegate and source type, and present the image picker
        imagePicker.delegate = self;
        if (0 == buttonIndex) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (1 == buttonIndex) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else {
        // Problem with camera, alert user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Please use a camera enabled device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UIImagePickerViewControllerDelegate
// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// Override this delegate method to get the image that the user has selected and send it view Multipeer Connectivity to the connected peers.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *pngData = UIImageJPEGRepresentation(imageToSave, 1.0);
        NSDateFormatter *inFormat = [NSDateFormatter new];
        [inFormat setDateFormat:@"yyMMdd-HHmmss"];
        NSString *imageName = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        [pngData writeToFile:filePath atomically:YES]; // Write the file
        NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
        Transcript *transcript = [sessionContainer sendImage:imageUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self insertTranscript:transcript];
        });
    });
}

@end
