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

    describe(@"stream:handleEvent:", ^{
        beforeEach(^{
            interface.inputStream = [[NSInputStream alloc] initWithData:[@"Data" dataUsingEncoding:NSUTF8StringEncoding]];
            interface.outputStream = nice_fake_for([NSOutputStream class]);
        });
        context(@"when the event is from the input stream", ^{
            context(@"when there is new data", ^{
                beforeEach(^{
                    [interface stream:interface.inputStream handleEvent:NSStreamEventHasBytesAvailable];
                });

                fit(@"should HERP DERP", ^{
                    YES should be_truthy;
                });
            });

            xcontext(@"when there is not new data", ^{
                beforeEach(^{
                    [interface stream:interface.inputStream handleEvent:NSStreamEventEndEncountered];
                });

                it(@"should do nothing", ^{
                });
            });
        });

        xcontext(@"when the event is from the output stream", ^{
            beforeEach(^{
                [interface stream:interface.outputStream handleEvent:nil];
            });

            it(@"should do nothing", ^{
            });
        });

    });
});

SPEC_END
