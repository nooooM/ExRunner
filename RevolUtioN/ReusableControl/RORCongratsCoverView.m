//
//  RORCongratsCoverView.m
//  RevolUtioN
//
//  Created by Bjorn on 13-9-26.
//  Copyright (c) 2013年 Beyond. All rights reserved.
//

#import "RORCongratsCoverView.h"
#import "RORUtils.h"
#import "FTAnimation.h"
#import "Animations.h"

@implementation RORCongratsCoverView
@synthesize bestRecord;

- (id)initWithFrame:(CGRect)frame andLevel:(User_Running_History*)record
{
    self = [super initWithFrame:frame];
    if (self) {
        bgView = [[UIImageView alloc] initWithFrame:frame];
        bestRecord = record;
        [self doInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

-(void)doInit{
    [self setBackgroundColor:[UIColor clearColor]];
    self.alpha = 0;
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [bgView setImage:[UIImage imageNamed:@"coverview_bg.png"]];
    //        bgView.alpha = 0.5;
    [self addSubview:bgView];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 30)];
    titleLabel.backgroundColor = [UIColor darkGrayColor];
    titleLabel.font = [UIFont fontWithName:CHN_PRINT_FONT size:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = @"你这次跑步得了个";
    [self addSubview:titleLabel];
    
    levelLabel = [[UILabel alloc]initWithFrame:self.frame];
    levelLabel.backgroundColor = [UIColor clearColor];
    levelLabel.font = [UIFont fontWithName:ENG_GAME_FONT size:200];
    levelLabel.textColor = [UIColor yellowColor];
    levelLabel.textAlignment = UITextAlignmentCenter;
    levelLabel.text = MissionGradeEnum_toString[bestRecord.missionGrade.integerValue];
    levelLabel.alpha = 0;
    [self addSubview:levelLabel];
    
    
    awardTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 90, 320, 30)];
    awardTitleLabel.backgroundColor = [UIColor darkGrayColor];
    awardTitleLabel.textColor = [UIColor whiteColor];
    awardTitleLabel.font = [UIFont fontWithName:CHN_PRINT_FONT size:18];
    awardTitleLabel.text = @"获得额外的经验、积分奖励";
    awardTitleLabel.textAlignment = UITextAlignmentCenter;
    awardTitleLabel.alpha = 0;
    [self addSubview:awardTitleLabel];
    
    extraAwardLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 60, 320, 30)];
    extraAwardLabel.backgroundColor = [UIColor clearColor];
    extraAwardLabel.font = [UIFont fontWithName:ENG_GAME_FONT size:22];
    extraAwardLabel.textColor = [UIColor yellowColor];
    extraAwardLabel.textAlignment = UITextAlignmentCenter;
    extraAwardLabel.text = [NSString stringWithFormat:@"exp: %@   gold: %@", bestRecord.experience, bestRecord.scores];
    extraAwardLabel.alpha = 0;
    [self addSubview:extraAwardLabel];
    
    [self addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)doAnimation{
    [titleLabel fallIn:2 delegate:self];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:4]];
    levelLabel.alpha = 1;
    [levelLabel fallIn:0.2 delegate:self];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    awardTitleLabel.alpha = 1;
    [awardTitleLabel backInFrom:kFTAnimationLeft withFade:YES duration:0.5 delegate:self];
    extraAwardLabel.alpha = 1;
    [extraAwardLabel backInFrom:kFTAnimationRight withFade:YES duration:0.5 delegate:self];
}

-(IBAction)show:(id)sender{
    [self setEnabled:NO];
    self.alpha = 1;
    [self doAnimation];
    [self setEnabled:YES];
}

-(IBAction)hide:(id)sender{
    [Animations fadeOut:self andAnimationDuration:0.3 fromAlpha:1 andWait:NO];
    self.alpha = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
