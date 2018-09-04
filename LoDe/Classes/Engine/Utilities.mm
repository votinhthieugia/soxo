//
//  Utilities.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <sys/time.h>
#import "Utilities.h"

struct timeval Utilities::timeMark;

NSString *Utilities::fullPath(NSString *filename) {
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[filename pathComponents]];
	NSString *file = [imagePathComponents lastObject];
	[imagePathComponents removeLastObject];

	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:file
														 ofType:nil
													inDirectory:imageDirectory];

	if (fullPath == nil) {
		fullPath = filename;
	}

	return fullPath;
}

NSData *Utilities::load(NSString *filename) {
	return [NSData dataWithContentsOfMappedFile:fullPath(filename)];
}

void *Utilities::mallocAndCopy(void *source, size_t length) {
	void *data = malloc(length);
	memcpy(data, source, length);
	return data;
}

void Utilities::markTime() {
	gettimeofday(&timeMark, nil);
}

float Utilities::secondsSinceMark() {
	struct timeval now;
	gettimeofday(&now, nil);

	// Limit the framerate to 20 frames per second.
	return now.tv_sec - timeMark.tv_sec + (now.tv_usec - timeMark.tv_usec) / 1000000.0f;
}