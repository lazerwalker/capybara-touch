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

    describe(@"sendSuccessMessage", ^{
        context(@"when the output stream is ready to write", ^{
            it(@"should send a success message via the output stream", ^{
                interface.outputStream = nice_fake_for([NSOutputStream class]);
                interface.outputStream stub_method(@selector(hasSpaceAvailable)).and_return(YES);

                [interface sendSuccessMessage];

                interface.outputStream should have_received(@selector(write:maxLength:));
            });
        });

        context(@"when the output stream is not ready", ^{
            beforeEach(^{
                interface.outputStream = nice_fake_for([NSOutputStream class]);
                interface.outputStream stub_method(@selector(hasSpaceAvailable)).and_return(NO);

                [interface sendSuccessMessage];
            });

            it(@"should not try to write", ^{
                interface.outputStream should_not have_received(@selector(write:maxLength:));
            });

            context(@"when the output stream is then readied", ^{
                it(@"should write", ^{
                    [interface stream:interface.outputStream handleEvent:NSStreamEventHasSpaceAvailable];

                    interface.outputStream should have_received(@selector(write:maxLength:));
                });
            });
        });
    });

    describe(@"handling input events", ^{
        context(@"when the message is complete", ^{
            __block NSString *eventString;

            subjectAction(^{
                interface.inputStream = [[NSInputStream alloc] initWithData:[eventString dataUsingEncoding:NSUTF8StringEncoding]];
                [interface.inputStream open];

                interface.outputStream = nice_fake_for([NSOutputStream class]);

                [interface stream:interface.inputStream handleEvent:NSStreamEventHasBytesAvailable];
            });

            describe(@"visit", ^{
                beforeEach(^{
                    eventString = @"Visit\n1\n17\nhttp://google.com";
                });

                it(@"should make the appropriate call", ^{
                    interface.delegate should have_received(@selector(visit:)).with(@"http://google.com");
                });
            });

            describe(@"find xpath ", ^{
                __block NSString *xpath;

                beforeEach(^{
                    xpath = @".//*[self::input | self::textarea][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'radio' or ./@type = 'checkbox' or ./@type = 'hidden' or ./@type = 'file')][(((./@id = 'gbqfq' or ./@name = 'gbqfq') or ./@placeholder = 'gbqfq') or ./@id = //label[normalize-space(string(.)) = 'gbqfq']/@for)] | .//label[normalize-space(string(.)) = 'gbqfq']//.//*[self::input | self::textarea][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'radio' or ./@type = 'checkbox' or ./@type = 'hidden' or ./@type = 'file')]'";

                    eventString = [@"FindXpath\n1\n519\n" stringByAppendingString:xpath];
                });

                it(@"should make the appropriate call", ^{
                    interface.delegate should have_received(@selector(findXpath:)).with(xpath);
                });
            });

            describe(@"reset", ^{
                beforeEach(^{
                    eventString = @"Reset\n0\n";
                });

                it(@"should make the appropriate call", ^{
                    interface.delegate should have_received(@selector(reset));
                });
            });

            describe(@"node", ^{
                beforeEach(^{
                    eventString = @"Node\n2\n10\nisAttached\n5\n[\"1\"]";
                });
                
                it(@"should make the appropriate call", ^{
                    interface.delegate should have_received(@selector(javascriptCommand:)).with(@[@"isAttached", @"[\"1\"]"]);
                });
            });

            describe(@"current URL", ^{
                beforeEach(^{
                    eventString = @"CurrentUrl\n0";
                });

                it(@"should make the appropriate call", ^{
                    interface.delegate should have_received(@selector(currentURL));
                });
            });

            describe(@"body", ^{
                beforeEach(^{
                    eventString = @"Body\n0";
                });

                it(@"should make the appropriate call", ^{
                    interface.delegate should have_received(@selector(body));
                });
            });
        });

        context(@"when the message is not complete but is later completed", ^{
            it(@"should make a valid call", ^{
                NSString *firstHalf = @"Node\n2\n";
                interface.inputStream = [[NSInputStream alloc] initWithData:[firstHalf dataUsingEncoding:NSUTF8StringEncoding]];
                [interface.inputStream open];
                interface.outputStream = nice_fake_for([NSOutputStream class]);

                [(id<CedarDouble>)interface.delegate reset_sent_messages];

                [interface stream:interface.inputStream handleEvent:NSStreamEventHasBytesAvailable];
                [(id<CedarDouble>)interface.delegate sent_messages] should be_empty;

                NSString *secondHalf = @"3\nfoo\n1\n1";
                interface.inputStream = [[NSInputStream alloc] initWithData:[secondHalf dataUsingEncoding:NSUTF8StringEncoding]];
                [interface.inputStream open];

                [interface stream:interface.inputStream handleEvent:NSStreamEventHasBytesAvailable];
                interface.delegate should have_received(@selector(javascriptCommand:)).with(@[@"foo",@"1"]);
            });
        });
    });
});

SPEC_END
