//
//  NetManager.h
//  Copyright 2009 Alley:Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

class NetListener;

@interface NetDelegate : NSObject {
}

@end

class NetManager {
private:
	static NetDelegate *delegate;
	static NetListener *listener;
	static NSMutableData *receivedData;
	static NSURLConnection *connection;
	static BOOL useCompression;
//	static BOOL useEncryption;

public:
	static void sharedNew();
	static void sharedDelete();

public:
	static void setListener(NetListener *listener);
	static void get(NSString *url, BOOL compressed = NO, BOOL encrypted = NO);
	static void post(NSString *url, NSData *data, BOOL compressed = NO, BOOL encrypted = NO);
	static void post(NSString *url, NSString *data, BOOL compressed = NO, BOOL encrypted = NO);
	static void cancel();
	static void clearData();

public:
	static void handleResponse(NSURLResponse *response);
	static void handleData(NSData *data);
	static void handleFinishLoading();
	static void handleError(NSError *error);
};