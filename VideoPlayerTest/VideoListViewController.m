//
//  VideoListViewController.m
//  TBMediaPlayerTest
//
//  Created by shiping chen on 15-7-20.
//  Copyright (c) 2015年 shiping chen. All rights reserved.
//

#import "VideoListViewController.h"
#import "AliVcMoiveViewController.h"


@interface VideoListViewController ()<AliVcAccessKeyProtocol>
{
}

@end

@implementation VideoListViewController

@synthesize videolists,datasource;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([self isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    
    return filenamelist;
}

- (BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

- (void)loadLocalVideo
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    
    NSMutableArray* video_extension = [[NSMutableArray alloc] init];
    [video_extension addObject:@"mp4"];
    [video_extension addObject:@"mkv"];
    [video_extension addObject:@"rmvb"];
    [video_extension addObject:@"rm"];
    [video_extension addObject:@"avs"];
    [video_extension addObject:@"mpg"];
    [video_extension addObject:@"3g2"];
    [video_extension addObject:@"asf"];
    [video_extension addObject:@"mov"];
    [video_extension addObject:@"avi"];
    [video_extension addObject:@"wmv"];
    [video_extension addObject:@"flv"];
    [video_extension addObject:@"m4v"];
    [video_extension addObject:@"swf"];
    [video_extension addObject:@"webm"];
    [video_extension addObject:@"3gp"];
    
    for(NSString* ext in video_extension) {
        
        NSArray *filename = [self getFilenamelistOfType:ext
                                            fromDirPath:docDir];
        
        for (NSString* name in filename) {
            
            NSMutableString* fullname = [NSMutableString stringWithString:docDir];
            [fullname appendString:@"/"];
            [fullname appendString:name];
            
            [videolists setObject:fullname forKey:name];
        }
    }
    
    datasource = [videolists allKeys];
}

- (void)loadRemoteVideo
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    NSString *videolistPath = [docDir stringByAppendingFormat:@"/videolist.txt"];
    FILE *file = fopen([videolistPath UTF8String], "rb");
    if(file == NULL)
        return;
    
    char VideoPath[200] = {0};
    fgets(VideoPath, 200, file);
    
    do{
        VideoPath[strlen(VideoPath)] = '\0';
        NSString *srcFile = [NSString stringWithUTF8String:VideoPath];
        
        NSRange range1 = [srcFile rangeOfString:@"["];
        NSRange range2 = [srcFile rangeOfString:@"]"];
        if(range1.location == NSNotFound || range2.location == NSNotFound)
            continue;
        NSRange rangeName;
        rangeName.location = range1.location+1;
        rangeName.length = range2.location-range1.location-1;
        NSString* filename = [srcFile substringWithRange:rangeName];
        
        NSRange range;
        range = [srcFile rangeOfString:@"http:"];
        if(range.location == NSNotFound){ //m3u8
            range = [srcFile rangeOfString:@"rtmp:"];
            if(range.location == NSNotFound){ //rtmp
                continue;
            }
        }
    
        NSString* m3u8file = [srcFile substringFromIndex:range.location];
        NSRange rangeEnd = [srcFile rangeOfString:@"\n"];
        if(rangeEnd.location != NSNotFound) {
            rangeEnd.location = 0;
            rangeEnd.length = m3u8file.length-1;
            m3u8file = [m3u8file substringWithRange:rangeEnd];
        }
        rangeEnd = [srcFile rangeOfString:@"\r"];
        if(rangeEnd.location != NSNotFound) {
            rangeEnd.location = 0;
            rangeEnd.length = m3u8file.length-1;
            m3u8file = [m3u8file substringWithRange:rangeEnd];
        }
        
        [videolists setObject:m3u8file forKey:filename];
        
    
    }while (fgets(VideoPath, 200, file));
    
    fclose(file);
}

NSString* accessKeyID = @"TP39f3ECyVV2d8sF";
NSString* accessKeySecret = @"mALMKv2sO2TcWur50uSCgcahvUziHC";

-(AliVcAccesskey*)getAccessKeyIDSecret
{
    AliVcAccesskey* accessKey = [[AliVcAccesskey alloc] init];
    accessKey.accessKeyId = accessKeyID;
    accessKey.accessKeySecret = accessKeySecret;
    return accessKey;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videolists = [[NSMutableDictionary alloc]init];
    [self loadRemoteVideo];
    [self loadLocalVideo];
    
    [AliVcMediaPlayer setAccessKeyDelegate:self];
 
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //---------- CELL BACKGROUND IMAGE -----------------------------
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    UIImage *image = [UIImage imageNamed:@"LightGrey@2x.png"];
    imageView.image = image;
    cell.backgroundView = imageView;
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
    
//    cell.textLabel.text = [datasource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = @"测试";
    //Arrow
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TBMoiveViewController* currentView = [[TBMoiveViewController alloc] init];
//    NSString* source = [datasource objectAtIndex:indexPath.row];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString* vs = [videolists objectForKey:source];
    
//    if([fileManager fileExistsAtPath:vs]){
        NSURL* url = [NSURL URLWithString:@"http://124.192.151.146/videos/v0/20160722/73/1d/640a2e441c71a72c603e3c478af4f802.mp4?key=0ba9a7b811dbe50f4f1ec69776c24a965&src=iqiyi.com&m=v&qd_src=ih5&qd_tm=1469501233044&qd_ip=218.241.135.218&qd_sc=61915589d991e802211afb0f550a0b11&ip=218.241.135.218&uuid=a0a0596-5796cf31-23&qypid=512321800_31"];
        [currentView SetMoiveSource:url];
//    }
//    else {
//        NSURL* url = [NSURL URLWithString:vs];
//        [currentView SetMoiveSource:url];
//    }
    
    [self presentViewController:currentView animated:YES completion:nil ];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
