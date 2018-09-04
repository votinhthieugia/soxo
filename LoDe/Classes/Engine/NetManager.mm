//
//  NetManager.mm
//  Copyright 2009 Alley:Labs. All rights reserved.
//

#import "Compress.h"
//#import "Crypto.h"
#import "NetListener.h"
#import "NetManager.h"

@implementation NetDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NetManager::handleResponse(response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NetManager::handleData(data);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NetManager::handleError(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NetManager::handleFinishLoading();
}

@end

NetDelegate *NetManager::delegate = nil;
NetListener *NetManager::listener = nil;
NSMutableData *NetManager::receivedData = nil;
NSURLConnection *NetManager::connection = nil;
BOOL NetManager::useCompression = NO;
//BOOL NetManager::useEncryption = NO;

void NetManager::sharedNew() {
	delegate = [[NetDelegate alloc] init];
	receivedData = [[NSMutableData data] retain];
}

void NetManager::sharedDelete() {
	if (connection) {
		[connection release];
		connection = nil;
	}
	[receivedData release];
	[delegate release];
}

void NetManager::setListener(NetListener *netListener) {
	listener = netListener;
}

void NetManager::get(NSString *url, BOOL compressed, BOOL encrypted) {
	cancel();

	useCompression = compressed;
//	useEncryption = encrypted;

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];

	connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
	if (!connection && listener) {
		listener->handleError(nil);
	}

	[request release];
}

void NetManager::post(NSString *url, NSData *data, BOOL compressed, BOOL encrypted) {
	cancel();

	useCompression = compressed;
//	useEncryption = encrypted;

	if (useCompression) {
		data = Compress::compress(data);
	}
//	if (useEncryption) {
//		data = Crypto::encrypt(data);
//	}

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:data];

	connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
	if (!connection && listener) {
		listener->handleError(nil);
	}

	[request release];
}

void NetManager::post(NSString *url, NSString *data, BOOL compressed, BOOL encrypted) {
	const char *utfString = [data UTF8String];
	post(url, (NSData *)[NSData dataWithBytes:utfString length:strlen(utfString)], compressed, encrypted);
}

void NetManager::cancel() {
	if (connection) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
}

void NetManager::clearData() {
	[receivedData setLength:0];
}

void NetManager::handleResponse(NSURLResponse *response) {
	[receivedData setLength:0];
}

void NetManager::handleData(NSData *data) {
	[receivedData appendData:data];
}

void NetManager::handleFinishLoading() {
	[connection release];
	connection = nil;

//	if (useEncryption) {
//		[receivedData setData:Crypto::decrypt(receivedData)];
//	}

	if (useCompression) {
		[receivedData setData:Compress::decompress(receivedData)];
	}

	if (listener) {
		listener->handleReceivedData(receivedData);
	}
}

void NetManager::handleError(NSError *error) {
	[connection release];
	connection = nil;

	if (listener) {
		listener->handleError(error);
	}
}