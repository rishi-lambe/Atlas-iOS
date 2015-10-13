//
//  ATLUIConversationListTest.m
//  Atlas
//
//  Created by Kevin Coleman on 12/16/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>
#import <Atlas/Atlas.h>
#import "ATLTestInterface.h"
#import "LYRClientMock.h"
#import "ATLSampleConversationListViewController.h"

extern NSString *const ATLAvatarImageViewAccessibilityLabel;

@interface ATLConversationListViewController ()

- (void)setupConversationDataSource;

@property (nonatomic) LYRQueryController *queryController;

@end

@interface ATLConversationListViewControllerTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLSampleConversationListViewController *viewController;

@end

@implementation ATLConversationListViewControllerTest

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10];
    
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    [[LYRMockContentStore sharedStore] resetContentStore];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    [self.testInterface dismissPresentedViewController];
    self.viewController = nil;
    
    [tester waitForAnimationsToFinish];
    
    [self resetAppearance];
    [super tearDown];
}

- (void)testToVerifyConversationListBaseUI
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    
    [tester waitForViewWithAccessibilityLabel:@"Messages"];
    [tester waitForViewWithAccessibilityLabel:@"Edit Button"];
}

//Synchronize a new conversation and verify that it live updates into the conversation list.
- (void)testToVerifyCreatingANewConversationLiveUpdatesConversationList
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
}

//Load the list and verify that all conversations returned by conversationForIdentifiers: is presented in the list.
- (void)testToVerifyConversationListDisplaysAllConversationsInLayer
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    [self newConversationWithMockUser:mockUser2 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser3 = [ATLUserMock userWithMockUserName:ATLMockUserNameSteven];
    [self newConversationWithMockUser:mockUser3 lastMessageText:@"Test Message"];
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyGlobalDeletionButtonFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    
    NSString *message1 = @"Message1";
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:message1];
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:LYRDeletionModeAllParticipants];
}

//Test swipe to delete for deleting a conversation. Verify the conversation is deleted from the table and from the Layer client.
- (void)testToVerifyLocalDeletionButtonFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:LYRDeletionModeLocal];
}

//Test editing mode and deleting several conversations at once. Verify that all conversations selected are deleted from the table and from the Layer client.
- (void)testToVerifyEditingModeAndMultipleConversationDeletionFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    LYRConversationMock *conversation2 = [self newConversationWithMockUser:mockUser2 lastMessageText:@"Test Message"];
    
    ATLUserMock *mockUser3 = [ATLUserMock userWithMockUserName:ATLMockUserNameSteven];
    LYRConversationMock *conversation3 = [self newConversationWithMockUser:mockUser3 lastMessageText:@"Test Message"];
    
    [tester tapViewWithAccessibilityLabel:@"Edit"];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", mockUser1.fullName]];
    [self deleteConversation:conversation1 deletionMode:LYRDeletionModeLocal];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", mockUser2.fullName]];
    [self deleteConversation:conversation2 deletionMode:LYRDeletionModeLocal];
    
    [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Delete %@", mockUser3.fullName]];
    [self deleteConversation:conversation3 deletionMode:LYRDeletionModeLocal];
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSOrderedSet *conversations = [self.testInterface.layerClient executeQuery:query error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(conversations.count, 0);
}

//Disable editing and verify that the controller does not permit the user to attempt to edit or engage swipe to delete.
- (void)testToVerifyDisablingEditModeDoesNotAllowUserToDeleteConversations
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setAllowsEditing:NO];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Global"]];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:[NSString stringWithFormat:@"Local"]];
}

//Customize the fonts and colors using UIAppearance and verify that the configuration is respected.
- (void)testToVerifyColorAndFontChangeFunctionality
{
    UIFont *testFont = [UIFont systemFontOfSize:20];
    UIColor *testColor = [UIColor redColor];
    
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:testFont];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:testColor];
    
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    NSString *conversationLabel = [self.testInterface conversationLabelForConversation:conversation1];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    XCTAssertEqual(cell.conversationTitleLabelFont, testFont);
    XCTAssertEqual(cell.conversationTitleLabelColor, testColor);
}

//Customize the row height and ensure that it is respected.
- (void)testToVerifyCustomRowHeightFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setRowHeight:100];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    NSString *conversationLabel = [self.testInterface conversationLabelForConversation:conversation1];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    XCTAssertEqual(cell.frame.size.height, 100);
}

//Customize the cell class and ensure that the correct cell is used to render the table.
-(void)testToVerifyCustomCellClassFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setCellClass:[ATLTestConversationCell class]];
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    NSString *conversationLabel = [self.testInterface conversationLabelForConversation:conversation1];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForViewWithAccessibilityLabel:conversationLabel];
    XCTAssertEqual(cell.class, [ATLTestConversationCell class]);
}

//Verify search bar does show up on screen for default `shouldDisplaySearchController` value `YES`.
- (void)testToVerifyDefaultShouldDisplaySearchControllerFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    [tester waitForViewWithAccessibilityLabel:@"Search Bar"];
}

//Verify search bar does not show up on screen if property set to `NO`.
- (void)testToVerifyShouldDisplaySearchControllerFunctionality
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self.viewController setShouldDisplaySearchController:NO];
    [self setRootViewController:self.viewController];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Search Bar"];
}

//Verify that attempting to provide a cell class that does not conform to ATLConversationPresenting results in a runtime exception.
- (void)testToVerifyCustomCellClassNotConformingToProtocolRaisesException
{
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:controller];
    [tester waitForAnimationsToFinish];
    @try {
        [controller setCellClass:[UITableViewCell class]];
    }
    @catch (NSException *exception) {
        XCTAssertEqual(exception.name, NSInternalInconsistencyException);
    }
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:controller];
    expect(^{ [controller setCellClass:[ATLTestConversationCell class]]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingCellHeighAfterViewLoadRaiseException
{
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:controller];
    expect(^{ [controller setRowHeight:40]; }).to.raise(NSInternalInconsistencyException);
}

//Verify that attempting to change the cell class after the table is loaded results in a runtime error.
- (void)testToVerifyChangingEditingSettingAfterViewLoadRaiseException
{
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:controller];
    expect(^{ [controller setAllowsEditing:YES]; }).to.raise(NSInternalInconsistencyException);
}

#pragma mark - ATLConversationListViewControllerDataSource

- (void)testToVerifyConversationListViewControllerDataSource
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.displaysAvatarItem = YES;
    [self setRootViewController:self.viewController];

    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    __block ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRConversation *conversation;
        [invocation getArgument:&conversation atIndex:3];
        expect(conversation).to.equal(conversation);
        
        NSString *conversationTitle = mockUser1.fullName;
        [invocation setReturnValue:&conversationTitle];
    }] conversationListViewController:[OCMArg any] titleForConversation:[OCMArg any]];

    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRConversation *conversation;
        [invocation getArgument:&conversation atIndex:3];
        expect(conversation).to.equal(conversation);
    }] conversationListViewController:[OCMArg any] avatarItemForConversation:[OCMArg any]];

    [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    [delegateMock verifyWithDelay:10];
}

#pragma mark - ATLConversationListViewControllerDelegate

- (void)testToVerifyDelegateIsNotifiedOfConversationSelection
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] conversationListViewController:[OCMArg any] didSelectConversation:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1]];
    [delegateMock verify];
}

- (void)testToVerifyDelegateIsNotifiedOfGlobalConversationDeletion
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    LYRDeletionMode deletionMode = LYRDeletionModeAllParticipants;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] conversationListViewController:[OCMArg any] didDeleteConversation:[OCMArg any] deletionMode:deletionMode];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:deletionMode];
    [delegateMock verify];
}

- (void)testToVerifyDelegateIsNotifiedOfLocalConversationDeletion
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    LYRDeletionMode deletionMode = LYRDeletionModeLocal;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] conversationListViewController:[OCMArg any] didDeleteConversation:[OCMArg any] deletionMode:deletionMode];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1] inDirection:KIFSwipeDirectionLeft];
    [self deleteConversation:conversation1 deletionMode:deletionMode];
    [delegateMock verify];
}

- (void)testToVerifyDelegateIsNotifiedOfSearch
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    [tester waitForTimeInterval:0.5];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    
    __block NSString *searchText = @"T";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] conversationListViewController:[OCMArg any] didSearchForText:searchText completion:[OCMArg any]];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1]  inDirection:KIFSwipeDirectionDown];
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
    [delegateMock verify];
}

- (void)testToVerifyCustomDeletionColorAndText
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self newConversationWithMockUser:mockUser1 lastMessageText:@"Test Message"];
    [tester waitForAnimationsToFinish];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSString *deletionTitle = @"Test";
        [invocation setReturnValue:&deletionTitle];
    }] conversationListViewController:[OCMArg any] textForButtonWithDeletionMode:LYRDeletionModeAllParticipants];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        UIColor *green = [UIColor greenColor];
        [invocation setReturnValue:&green];
    }] conversationListViewController:[OCMArg any] colorForButtonWithDeletionMode:LYRDeletionModeAllParticipants];
    
    [tester swipeViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation1]  inDirection:KIFSwipeDirectionLeft];
    [delegateMock verify];
    
    UIView *deleteButton = [tester waitForViewWithAccessibilityLabel:@"Test"];
    XCTAssertEqual(deleteButton.backgroundColor, [UIColor greenColor]);
}

- (void)testToVerifyDefaultQueryConfigurationDataSourceMethod
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    __block LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&query];
    }] conversationListViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];
    
    [self.viewController setupConversationDataSource];
    [delegateMock verifyWithDelay:10];
}

- (void)testToVerifyQueryConfigurationTakesEffect
{
    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.allowsEditing = YES;
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationListViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    __block NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    __block LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        query.sortDescriptors = @[sortDescriptor];
        [invocation setReturnValue:&query];
    }] conversationListViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];
    
     [self.viewController setupConversationDataSource];
    [delegateMock verifyWithDelay:2];
    XCTAssertEqual(self.viewController.queryController.query.sortDescriptors[0], sortDescriptor);
}

//- (void)testToVerifyAvatarImageURLLoad
//{
//    self.viewController = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
//    self.viewController.displaysAvatarItem = YES;
//    [self setRootViewController:self.viewController];
//    
//    ATLAvatarImageView *imageView = (ATLAvatarImageView *)[tester waitForViewWithAccessibilityLabel:ATLAvatarImageViewAccessibilityLabel];
//    expect(imageView.image).will.beTruthy;
//}

- (LYRConversationMock *)newConversationWithMockUser:(ATLUserMock *)mockUser lastMessageText:(NSString *)lastMessageText
{
    LYRConversationMock *conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser.participantIdentifier] lastMessageText:lastMessageText];
    [tester waitForViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation]];
    return conversation;
}

- (void)deleteConversation:(LYRConversationMock *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    switch (deletionMode) {
        case LYRDeletionModeAllParticipants:
            [tester waitForViewWithAccessibilityLabel:@"Global"];
            [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Global"]];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation]];
            break;
        case LYRDeletionModeLocal:
            [tester waitForViewWithAccessibilityLabel:@"Local"];
            [tester tapViewWithAccessibilityLabel:[NSString stringWithFormat:@"Local"]];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:[self.testInterface conversationLabelForConversation:conversation]];
            break;
        default:
            break;
    }
}

- (void)setRootViewController:(UITableViewController *)controller
{
    [self.testInterface presentViewController:controller];
    [tester waitForAnimationsToFinish];
}

- (void)resetAppearance
{
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:[UIFont systemFontOfSize:14]];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:[UIColor blackColor]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelFont:[UIFont systemFontOfSize:12]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelColor:[UIColor grayColor]];
    [[ATLConversationTableViewCell appearance] setDateLabelFont:[UIFont systemFontOfSize:12]];
    [[ATLConversationTableViewCell appearance] setDateLabelColor:[UIColor grayColor]];
    [[ATLConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:[UIColor cyanColor]];
    [[ATLConversationTableViewCell appearance] setCellBackgroundColor:[UIColor whiteColor]];
    
}

@end