/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FBPerson : NSManagedObject
@property(retain, nonatomic) NSString *fbid;
@end


@interface PKFriendPickerViewController : UITableViewController {
}
@property(nonatomic) BOOL isFiltered;
@property(nonatomic) unsigned int viewerFriendsMostPokedSection;
@property(nonatomic) unsigned int viewerFriendsWithPokeInstalledSection;
@property(nonatomic) unsigned int viewerFriendsWithoutPokeInstalledSection;

@property(retain, nonatomic) NSArray *viewerFriendsMostPokedEntities;
@property(retain, nonatomic) NSArray *viewerFriendsWithPokeInstalledEntities;
@property(retain, nonatomic) NSArray *viewerFriendsWithoutPokeInstalledEntities;
@property(retain, nonatomic) NSArray *friendsWhoMayOrMayNotHavePokeInstalled;

@property(retain, nonatomic) NSMutableArray *selected;
@property(retain, nonatomic) NSMutableArray *filteredViewerFriendsWithPoke;

//new
- (BOOL) isSectionSelected:(unsigned int)section;
- (void) selectSection:(unsigned int)section;
- (void) selectFromButton:(UIButton *)btn;

@end

%hook PKFriendPickerViewController

- (id)tableView:(id)arg1 viewForHeaderInSection:(int)arg2 {

	UIView *orig_view = %orig;
	
	BOOL isSectionSelected = [self isSectionSelected:arg2];
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn.frame = CGRectMake(orig_view.frame.size.width-50.0, (orig_view.frame.size.height-55.0)/2.0, 55.0, 55.0);
    btn.tag = arg2;
    [btn addTarget:self action:@selector(selectFromButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:isSectionSelected ? [UIImage imageNamed:@"CellAccessoryChecked.png"] : [UIImage imageNamed:@"CellAccessoryEmpty.png"] forState:UIControlStateNormal];
    [orig_view addSubview:btn];
    return orig_view;
}

%new(v@:@@)
- (BOOL) isSectionSelected:(unsigned int)section {

	NSArray *section_content = nil;
	
	if (section == self.viewerFriendsMostPokedSection) {
		section_content = self.viewerFriendsMostPokedEntities;
	}else if (section == self.viewerFriendsWithPokeInstalledSection) {
		section_content = self.viewerFriendsWithPokeInstalledEntities;
	}else if (section == self.viewerFriendsWithoutPokeInstalledSection) {
		section_content = self.viewerFriendsWithoutPokeInstalledEntities;
	}else {
		NSLog(@"unknown section : %i",section);
		return NO;
	}

	if (section_content != nil) {
		for (FBPerson *obj in section_content) {
			if (![self.selected containsObject:obj.fbid]) {
					return NO;
    		}
		}
		return YES;
	}
	return NO;
}

%new(v@:@@)
- (void)selectSection:(unsigned int)section {

	BOOL isSectionSelected = [self isSectionSelected:section];
	if (section == self.viewerFriendsMostPokedSection) {
		for (FBPerson *obj in self.viewerFriendsMostPokedEntities) {
			if (isSectionSelected ? [self.selected containsObject:obj.fbid] : ![self.selected containsObject:obj.fbid]) {
        		isSectionSelected ? [self.selected removeObject:obj.fbid] : [self.selected addObject:obj.fbid];
    		}
		}
	}else if (section == self.viewerFriendsWithPokeInstalledSection) {
		for (FBPerson *obj in self.viewerFriendsWithPokeInstalledEntities) {
			if (isSectionSelected ? [self.selected containsObject:obj.fbid] : ![self.selected containsObject:obj.fbid]) {
    			isSectionSelected ? [self.selected removeObject:obj.fbid] : [self.selected addObject:obj.fbid];
    		}
		}
	}else if (section == self.viewerFriendsWithoutPokeInstalledSection) {
		for (FBPerson *obj in self.viewerFriendsWithoutPokeInstalledEntities) {
			if (isSectionSelected ? [self.selected containsObject:obj.fbid] : ![self.selected containsObject:obj.fbid]) {
        		isSectionSelected ? [self.selected removeObject:obj.fbid] : [self.selected addObject:obj.fbid];
    		}
		}
	}else {
		NSLog(@"unknown section : %i",section);
		return;
	}
	
	// Reload section
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
}

%new(v@:@@)
- (void) selectFromButton:(UIButton *)btn {
	[self selectSection:btn.tag];
}


// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end

