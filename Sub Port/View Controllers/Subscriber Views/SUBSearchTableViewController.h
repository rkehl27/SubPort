//
//  SUBSearchTableViewController.h
//  Sub Port
//
//  Created by Rebecca Kehl on 4/28/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUBSearchTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate>

- (id)initWithContentList:(NSMutableArray *)contentList;

@end
