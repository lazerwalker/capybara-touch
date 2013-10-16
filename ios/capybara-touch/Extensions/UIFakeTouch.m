#import "UIFakeTouch.h"
#import <objc/message.h>
#import "GraphicsServices.h"
#import <dlfcn.h>
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"


@implementation UIFakeTouch

- (instancetype)initInView:(UIView *)view point:(CGPoint)point {
    if (self = [super init]) {
        self.point = point;
        self.view = view;
    }
    return self;
}
    
- (void)sendTap {
    [self sendTouchStart];
    [self sendTouchEnd];
}

- (void)sendTouchStart {
    [self sendEventForPhase:UITouchPhaseBegan];
}

- (void)sendTouchEnd {
    [self sendEventForPhase:UITouchPhaseEnded];
}

- (void)sendEventForPhase:(UITouchPhase)phase {
    CGPoint adjustedPoint = [self.view convertPoint:self.point toView:self.view.window];

    uint8_t touchEvent[sizeof(GSEventRecord) + sizeof(GSHandInfo) + sizeof(GSPathInfo)];
    struct GSTouchEvent {
        GSEventRecord record;
        GSHandInfo    handInfo;
    } * event = (struct GSTouchEvent*) &touchEvent;
    bzero(event, sizeof(event));
    event->record.type = kGSEventHand;
    event->record.subtype = kGSEventSubTypeUnknown;
    event->record.location = self.point;
    event->record.timestamp = GSCurrentEventTimestamp();
    event->record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);
    event->handInfo.type = (phase == UITouchPhaseBegan) ? kGSHandInfoTypeTouchDown : kGSHandInfoTypeTouchUp;
    event->handInfo.pathInfosCount = 1;

    bzero(&event->handInfo.pathInfos[0], sizeof(GSPathInfo));
    event->handInfo.pathInfos[0].pathIndex     = 1;
    event->handInfo.pathInfos[0].pathIdentity  = 2;
    event->handInfo.pathInfos[0].pathProximity = (phase == UITouchPhaseBegan) ? 0x03 : 0x00;
    event->handInfo.pathInfos[0].pathLocation  = adjustedPoint;

    mach_port_t port = (mach_port_t)[self getFrontMostAppPort];

    GSEventRecord* record = (GSEventRecord*) event;
    record->timestamp = GSCurrentEventTimestamp();
    GSSendEvent(record, port);
}

- (mach_port_t)getFrontMostAppPort {
    mach_port_t *port;
    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
    int (*SBSSpringBoardServerPort)() = dlsym(lib, "SBSSpringBoardServerPort");

    port = (mach_port_t *)SBSSpringBoardServerPort();
    dlclose(lib);
    void *(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result) = dlsym(lib, "SBFrontmostApplicationDisplayIdentifier");
    char appId[256];
    memset(appId, 0, sizeof(appId));
    SBFrontmostApplicationDisplayIdentifier(port, appId);
    return GSCopyPurpleNamedPort(appId);
}
@end
