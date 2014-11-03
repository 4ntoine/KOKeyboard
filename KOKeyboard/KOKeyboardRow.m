//
//  ExtraKeyboardRow.m
//  KeyboardTest
//
//  Created by Kuba on 28.06.12.
//  Copyright (c) 2012 Adam Horacek, Kuba Brecka
//
//  Website: http://www.becomekodiak.com/
//  github: http://github.com/adamhoracek/KOKeyboard
//	Twitter: http://twitter.com/becomekodiak
//  Mail: adam@becomekodiak.com, kuba@becomekodiak.com
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "KOKeyboardRow.h"
#import "KOSwipeButton.h"

@interface KOKeyboardRow ()

@property(nonatomic, retain) UITextView *textView;
@property(nonatomic, assign) CGRect startLocation;

@end

@implementation KOKeyboardRow
{
    NSMutableArray *_buttons;
}

@synthesize textView, startLocation;

- (void) setTabInsertString: (NSString*)string {
    for (KOSwipeButton *eachButton in self.buttons) {
        eachButton.tabString = string;
    }
}

+ (KOKeyboardRow *)applyToTextView:(UITextView *)t withConfig:(id<KOKeyboardConfig>)config {

    KOKeyboardRow *v = [[KOKeyboardRow alloc] initWithFrame:CGRectMake(0, 0, [config barWidth], [config barHeight]) inputViewStyle:UIInputViewStyleKeyboard];
    [v setBackgroundColor:[UIColor clearColor]];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    v.textView = t;
    
    int leftMargin = ([config barWidth] - [config buttonWidth] * [config buttonCount] - [config buttonSpacing] * ([config buttonCount] - 1)) / 2;

    v.buttons = [[NSMutableArray alloc] init];

    for (int i = 0; i < [config buttonCount]; i++) {
        CGRect frame = CGRectMake(
                                  leftMargin + i * ([config buttonSpacing] + [config buttonWidth]),
                                  [config topMargin] + ([config barHeight] - [config buttonHeight]) / 2,
                                  [config buttonWidth],
                                  [config buttonHeight]);
        KOSwipeButton *b = [[KOSwipeButton alloc] initWithFrame:frame andConfig:config];
        b.keys = [config buttonKeys:i];
        b.delegate = v;
        b.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [v addSubview:b];
        [v.buttons addObject:b];
    }

    t.inputAccessoryView = v;

    return v;
}

- (void)insertText:(NSString *)text {
    
    if (self.listener != nil) {
        if (![self.listener willKeyboardInsert:text])
            return;
    }
    
    [textView insertText:text];
    
    if (self.listener != nil)
        [self.listener didKeyboardInsert:text];
}

- (void)trackPointStarted {
    startLocation = [textView caretRectForPosition:textView.selectedTextRange.start];
}

- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting {
    CGRect loc = startLocation;

    loc.origin.y += textView.font.lineHeight;

    UITextPosition *p1 = [textView closestPositionToPoint:loc.origin];

    loc.origin.x -= xdiff;
    loc.origin.y -= ydiff;

    UITextPosition *p2 = [textView closestPositionToPoint:loc.origin];

    if (!selecting) {
        p1 = p2;
    }
    UITextRange *r = [textView textRangeFromPosition:p1 toPosition:p2];

    textView.selectedTextRange = r;
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

- (void)selectionComplete {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UITextRange *selectionRange = [textView selectedTextRange];
    CGRect selectionStartRect = [textView caretRectForPosition:selectionRange.start];
    CGRect selectionEndRect = [textView caretRectForPosition:selectionRange.end];
    CGPoint selectionCenterPoint = (CGPoint) {(selectionStartRect.origin.x + selectionEndRect.origin.x) / 2, (selectionStartRect.origin.y + selectionStartRect.size.height / 2)};
    [menuController setTargetRect:[textView caretRectForPosition:[textView closestPositionToPoint:selectionCenterPoint withinRange:selectionRange]] inView:textView];
    [menuController setMenuVisible:YES animated:YES];
}

@end
