//
//  OFRootViewController.m
//  
//
//  Created by Kevin Coleman on 4/21/15.
//
//

#import "OFRootViewController.h"

@interface OFRootViewController ()

@property (nonatomic) UIButton *sendMessageButton;
@end

@implementation OFRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sendMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    self.sendMessageButton.layer.cornerRadius = 8;
    [self.sendMessageButton setTitle:@"Send Message" forState:UIControlStateNormal];
    [self.sendMessageButton setBackgroundColor:[UIColor blueColor]];
    [self.sendMessageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendMessageButton];
    self.sendMessageButton.center = self.view.center;
}

- (void)sendMessage:(UIButton *)sender
{
    NSLog(@"Sending Message");
    [self.sendMessageButton setTitle:@"Sending..." forState:UIControlStateNormal];
    [self.sendMessageButton setBackgroundColor:[UIColor orangeColor]];
    
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"test"]);
    NSInputStream *stream = [NSInputStream inputStreamWithData:imageData];
    
    LYRMessagePart *part1 = [LYRMessagePart messagePartWithMIMEType:@"image/jpeg" stream:stream];
    
    NSError *error = nil;
    LYRConversation *conversation = [self.client newConversationWithParticipants:[NSSet setWithObject:@"test"] options:nil error:&error];
    LYRMessage *message = [self.client newMessageWithParts:@[part1] options:nil error:&error];
    [conversation sendMessage:message error:&error];
    
    LYRProgress *progress1 = part1.progress;
    while (1 > progress1.totalUnitCount) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    }
    
    while (progress1.completedUnitCount < progress1.totalUnitCount) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        [self.sendMessageButton setTitle:[NSString stringWithFormat:@"%f complete", progress1.fractionCompleted] forState:UIControlStateNormal];
        NSLog(@"LYRProgress1 %@", progress1);
    }
    
    NSLog(@"Message Sent!");
    
    [self.sendMessageButton setBackgroundColor:[UIColor greenColor]];
    [self.sendMessageButton setTitle:@"Done!" forState:UIControlStateNormal];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sendMessageButton setBackgroundColor:[UIColor blueColor]];
        [self.sendMessageButton setTitle:@"Send Message" forState:UIControlStateNormal];
    });
}

@end
