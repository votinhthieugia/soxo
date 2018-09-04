//
//  Compress.h
//  Copyright 2009 Alley:Labs. All rights reserved.
// 

class Compress {
public:
	// Returns a data object containing a Zlib compressed copy of the receivers
	// contents.
	static NSData *compress(NSData *data);
	
	// Returns a data object containing a Zlib decompressed copy of the receivers
	// contents.
	static NSData *decompress(NSData *data);
};