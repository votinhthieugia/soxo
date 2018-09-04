//
//  Utilities.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEGREES_TO_RADIANS(x) ((x) / 180.0f * (float)M_PI)
#define RADIANS_TO_DEGREES(x) ((x) / (float)M_PI * 180.0f)
#define SIGN_OF_FLOAT(x) ((x > 0.0f) - (x < 0.0f))
#define SIGN_OF_INT(x) ((x > 0) - (x < 0))

class Utilities {
private:
	static struct timeval timeMark;

public:
	static NSString *fullPath(NSString *filename);
	static NSData *load(NSString *filename);
	static void *mallocAndCopy(void *source, size_t length);
	static void markTime();
	static float secondsSinceMark();
};

class Math {
public:
	static inline float toAngle(float x, float y) {
		float angle = 90.0f + RADIANS_TO_DEGREES(atan2f(y, x));
		return angle < 0.0f ? angle + 360.0f : angle;
	}
};