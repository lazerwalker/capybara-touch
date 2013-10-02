#import "CTInterface.h"

@interface CTInterface (Spec)

@property (strong, nonatomic) TCPServer *server;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CTInterfaceSpec)

describe(@"CTInterface", ^{
    __block CTInterface *interface;

    beforeEach(^{
        interface = [[CTInterface alloc] init];
        interface.server = nice_fake_for([TCPServer class]);
        interface.delegate = nice_fake_for(@protocol(CTCapybaraDelegate));
    });

    describe(@"startWithPort:domain:", ^{
        beforeEach(^{
            [interface startWithPort:9001 domain:@"example.com"];
        });

        it(@"should set the port and domain", ^{
            interface.server should have_received(@selector(setPort:));
            interface.server should have_received(@selector(setDomain:)).with(@"example.com");
        });


        it(@"should set the delegate to self", ^{
            interface.server should have_received(@selector(setDelegate:)).with(interface);
        });

        it(@"should start the TCP server", ^{
            interface.server should have_received(@selector(start:));
        });
    });

    describe(@"TCPServer:didReceiveConnectionFromAddress:inputStream:outputStream", ^{
        __block NSInputStream *inputStream;
        __block NSOutputStream *outputStream;

        beforeEach(^{
            inputStream = nice_fake_for([NSInputStream class]);
            outputStream = nice_fake_for([NSOutputStream class]);

            [interface TCPServer:nil didReceiveConnectionFromAddress:nil inputStream:inputStream outputStream:outputStream];
        });

        it(@"should store the streams", ^{
            interface.inputStream should equal(inputStream);
            interface.outputStream should equal(outputStream);
        });

        it(@"should set the delegates", ^{
            inputStream should have_received(@selector(setDelegate:)).with(interface);
            outputStream should have_received(@selector(setDelegate:)).with(interface);
        });

        it(@"should make sure the streams are open", ^{
            inputStream should have_received(@selector(open));
            outputStream should have_received(@selector(open));
        });
    });

    describe(@"handling input events", ^{
        __block NSString *eventString;

        subjectAction(^{
            interface.inputStream = [[NSInputStream alloc] initWithData:[eventString dataUsingEncoding:NSUTF8StringEncoding]];
            [interface.inputStream open];

            interface.outputStream = nice_fake_for([NSOutputStream class]);

            [interface stream:interface.inputStream handleEvent:NSStreamEventHasBytesAvailable];
        });

        describe(@"visit event", ^{
            beforeEach(^{
                eventString = @"Visit\n1\n1024\nhttp://google.com";
            });

            it(@"should make a Visit call", ^{
                interface.delegate should have_received(@selector(visit:)).with(@"http://google.com");
            });
        });

    });
});

SPEC_END
