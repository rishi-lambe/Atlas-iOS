//
//  ATLUIConversationCollectionView.m
//  Atlas
//
//  Created by Kevin Coleman on 1/30/15.
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
#import "ATLConversationCollectionView.h"
#import "CHMagnifierView.h"

@interface ATLConversationCollectionView()
@property (strong, nonatomic) NSTimer *touchTimer;
@property (strong, nonatomic) CHMagnifierView *magnifierView;


@end
@implementation ATLConversationCollectionView

NSString *const ATLConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const ATLConversationCollectionViewAccessibilityIdentifier = @"Conversation Collection View";

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    self.accessibilityIdentifier = ATLConversationCollectionViewAccessibilityIdentifier;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self registerReuseIdentifiers];
}

- (void)registerReuseIdentifiers
{
    [self registerClass:[ATLIncomingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:ATLIncomingMessageCellIdentifier];
    
    [self registerClass:[ATLOutgoingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:ATLOutgoingMessageCellIdentifier];
    
    [self registerClass:[ATLConversationCollectionViewMoreMessagesHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:ATLMoreMessagesHeaderIdentifier];
    
    [self registerClass:[ATLConversationCollectionViewHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:ATLConversationViewHeaderIdentifier];
    
    [self registerClass:[ATLConversationCollectionViewFooter class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:ATLConversationViewFooterIdentifier];
}

#pragma mark - custom method
- (void)showLoupe:(NSTimer *)timer
{
    [self.magnifierView makeKeyAndVisible];
}

#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(showLoupe:)
                                                     userInfo:nil
                                                      repeats:NO];
    
    if (self.magnifierView == nil) {
        self.magnifierView = [[CHMagnifierView alloc] init];
        self.magnifierView.viewToMagnify = self.window;
    }
    
    self.magnifierView.pointToMagnify = [[touches anyObject] locationInView:self.window];
    
    self.scrollEnabled=NO;
    /*if(_delegate && [_delegate respondsToSelector:@selector(touchesBegan:withEvent:renderView:)])
    {
        [_delegate touchesBegan:touches withEvent:event renderView:self];
    }*/
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.magnifierView.hidden == NO) {
        self.magnifierView.pointToMagnify = [[touches anyObject] locationInView:self.window];
    }
    self.scrollEnabled=NO;
    /*if(_delegate && [_delegate respondsToSelector:@selector(touchesMoved:withEvent:renderView:)])
    {
        [_delegate touchesMoved:touches withEvent:event renderView:self];
    }*/
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchTimer invalidate];
    [self.magnifierView setHidden:YES];
    self.scrollEnabled=YES;
    /*if(_delegate && [_delegate respondsToSelector:@selector(touchesEnded:withEvent:renderView:)])
    {
        [_delegate touchesEnded:touches withEvent:event renderView:self];
    }*/
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchTimer invalidate];
    [self.magnifierView setHidden:YES];
     self.scrollEnabled=YES;
   /* if(_delegate && [_delegate respondsToSelector:@selector(touchesCancelled:withEvent:renderView:)])
    {
        [_delegate touchesCancelled:touches withEvent:event renderView:self];
    }*/
}

@end
