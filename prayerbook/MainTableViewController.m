//
//  MainTableViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "MainTableViewController.h"
#import "MyLanguage.h"
#import "OptionsTableViewController.h"
#import "PrayerViewController.h"

@interface MainTableViewController ()
-(void)updateLanguage;
@end

@implementation MainTableViewController

NSArray *titles;

- (void)updateLanguage
{
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:[NSString  stringWithFormat:@"index_%@",  [MyLanguage language] ]
                      ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    titles = [dict objectForKey:@"index"];

    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) localeChanged:(NSNotification *)paramNotification
{
    NSLog(@"Locale Changed2");
    
    [self updateLanguage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLanguage];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(localeChanged:)
     name:LANGUAGE_CHANGED_NOTIFICATION
     object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [titles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [titles[indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     
     if ([segue.identifier isEqualToString:@"Options"]) {
         UINavigationController *navigationController = segue.destinationViewController;
         OptionsTableViewController *options = [navigationController viewControllers][0];
         options.delegate = self;

     } else if ([segue.identifier isEqualToString:@"Prayer"]) {
         PrayerViewController *view = segue.destinationViewController;
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         view.index = indexPath;
         view.title = [titles[indexPath.section] objectAtIndex:indexPath.row];
         
     }
     
 }


@end
