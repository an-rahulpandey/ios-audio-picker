/********* iOSAudioPicker.m Cordova Plugin Implementation *******/

#import "iOSAudioPicker.h"
#import <AVFoundation/AVFoundation.h>

@implementation iOSAudioPicker

- (void) getAudio:(CDVInvokedUrlCommand *)command
{
    callbackID = command.callbackId;
    NSString *msong = [command argumentAtIndex:0];
    NSString *iCloudItems = [command argumentAtIndex:1];

    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];

    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = [msong isEqualToString:@"true"];
    mediaPicker.showsCloudItems = [iCloudItems isEqualToString:@"true"];
    mediaPicker.prompt = NSLocalizedString (@"Add songs to play", "Prompt in media item picker");

    [self.viewController presentViewController:mediaPicker animated:YES completion:nil];

}

- (void) deleteSongs:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    NSString *multiple = [command argumentAtIndex:0];
    if ([multiple isEqualToString:@"true"]) {
        NSArray *filePath = [command argumentAtIndex:1];
        for(NSString *file in filePath)
        {
            NSString *result = [self delSingleSong:file];
            NSLog(@"Delete Result = %@",result);
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"deleting"];

    }
    else
    {
        NSString *filePath = [command argumentAtIndex:1];
        NSString *delResult = [self delSingleSong:filePath];
        if([delResult isEqualToString:@"deleted"])
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"deleted"];
        else
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:delResult];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (NSString *)delSingleSong:(NSString*)path
{
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            return [error localizedDescription];
        } else {
            return @"deleted";
        }
    }
    else
    {
        return [NSString stringWithFormat:@"File doesn't exists at the location %@",path];
    }
}

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{

    if (mediaItemCollection) {

        songsList = [[NSMutableArray alloc] init];

        NSArray *allSelectedSongs = [mediaItemCollection items];

        int selcount = [allSelectedSongs count];
        __block int completed = 0;

        for(MPMediaItem *song in allSelectedSongs)
        {
            BOOL artImageFound = NO;
            NSData *imgData;
            NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
            NSString *albumTitle = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
            NSURL *songurl = [song valueForProperty:MPMediaItemPropertyAssetURL];
            MPMediaItemArtwork *artImage = [song valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *artworkImage = [artImage imageWithSize:CGSizeMake(artImage.bounds.size.width, artImage.bounds.size.height)];
            if(artworkImage != nil){
                imgData = UIImagePNGRepresentation(artworkImage);
                artImageFound = YES;
            }

            NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
            NSString *genre = [song valueForProperty:MPMediaItemPropertyGenre];

            NSLog(@"title = %@",title);
            NSLog(@"albumTitle = %@",albumTitle);
            NSLog(@"artist = %@",artist);
            NSLog(@"songurl = %@",songurl);


            AVURLAsset *songURL = [AVURLAsset URLAssetWithURL:songurl options:nil];

            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

            NSString *documentDir = [path objectAtIndex:0];

            //NSLog(@"Compatible Preset for selected Song = %@", [AVAssetExportSession exportPresetsCompatibleWithAsset:songURL]);

            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songURL presetName:AVAssetExportPresetAppleM4A];

            exporter.outputFileType = @"com.apple.m4a-audio";

            NSString *filename = [NSString stringWithFormat:@"%@.m4a",title];

            NSString *outputfile = [documentDir stringByAppendingPathComponent:filename];

            [self delSingleSong:outputfile];

            NSURL *exportURL = [NSURL fileURLWithPath:outputfile];

            exporter.outputURL  = exportURL;

            [exporter exportAsynchronouslyWithCompletionHandler:^{
                int exportStatus = exporter.status;
                completed++;
                switch (exportStatus) {
                    case AVAssetExportSessionStatusFailed:{
                        NSError *exportError = exporter.error;
                        NSLog(@"AVAssetExportSessionStatusFailed = %@",exportError);
                        NSString *errmsg = [exportError description];
                        plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errmsg];
                        break;
                    }
                    case AVAssetExportSessionStatusCompleted:{

                        NSURL *audioURL = exportURL;
                        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];

                        NSLog(@"AVAssetExportSessionStatusCompleted %@",audioURL);
                        if(title != nil) {
                            [songInfo setObject:title forKey:@"title"];
                        } else {
                            [songInfo setObject:@"No Title" forKey:@"title"];
                        }
                        if(albumTitle != nil) {
                            [songInfo setObject:albumTitle forKey:@"albumTitle"];
                        } else {
                            [songInfo setObject:@"No Album" forKey:@"albumTitle"];
                        }
                        if(artist !=nil) {
                            [songInfo setObject:artist forKey:@"artist"];
                        } else {
                            [songInfo setObject:@"No Artist" forKey:@"artist"];
                        }

                        [songInfo setObject:[songurl absoluteString] forKey:@"ipodurl"];
                        if (artImageFound) {
                            [songInfo setObject:[imgData base64EncodedString] forKey:@"image"];
                        } else {
                            [songInfo setObject:@"No Image" forKey:@"image"];
                        }

                        [songInfo setObject:duration forKey:@"duration"];
                        if (genre != nil){
                          [songInfo setObject:genre forKey:@"genre"];
                        } else {
                          [songInfo setObject:@"No Genre" forKey:@"genre"];
                        }

                        [songInfo setObject:[audioURL absoluteString] forKey:@"exportedurl"];
                        [songInfo setObject:filename forKey:@"filename"];

                        [songsList addObject:songInfo];

                        //NSLog(@"Audio Data = %@",songsList);
                        NSLog(@"Export Completed = %d out of Total Selected = %d",completed,selcount);
                        if (completed == selcount) {
                            plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:songsList];
                            [self.commandDelegate sendPluginResult:plresult callbackId:callbackID];
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusCancelled:{
                        NSLog(@"AVAssetExportSessionStatusCancelled");
                        plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cancelled"];
                        break;
                    }
                    case AVAssetExportSessionStatusUnknown:{
                        NSLog(@"AVAssetExportSessionStatusCancelled");
                        plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown"];
                        break;
                    }
                    case AVAssetExportSessionStatusWaiting:{
                        NSLog(@"AVAssetExportSessionStatusWaiting");
                        plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Waiting"];
                        break;
                    }
                    case AVAssetExportSessionStatusExporting:{
                        NSLog(@"AVAssetExportSessionStatusExporting");
                        plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Exporting"];
                        break;
                    }

                    default:{
                        NSLog(@"Didnt get any status");
                        break;
                    }
                }
            }];
        }

    }

    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
