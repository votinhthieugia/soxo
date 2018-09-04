//
//  Global.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Engine.h"

class Global {
public:
	static const float EYE_POSITION_Z;
	
public:
	typedef struct {
		static const int FIND = 0;
		static const int OK = 1;
		static const int CANCEL = 2;
		static const int DETAIL = 3;
		static const int BACK = 4;
		static const int STAT = 5;
	} Event;
	
public:
	static void sharedNew();
	static void sharedDelete();
};

