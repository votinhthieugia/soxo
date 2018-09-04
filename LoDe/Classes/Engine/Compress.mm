//
//  Compress.mm
//  Copyright 2009 Alley:Labs. All rights reserved.
//

#import "Compress.h"
#import "zlib.h"

// 16K chunks for expansion
const int CHUNK_LENGTH = 16384;

NSData *Compress::compress(NSData *data) {
    if ([data length] == 0) {
		return data;
	}

    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
	
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION

    if (deflateInit(&strm, Z_BEST_COMPRESSION) != Z_OK) {
		return nil;
	}

    NSMutableData *compressed = [NSMutableData dataWithLength:CHUNK_LENGTH];
    do {
        if (strm.total_out >= [compressed length]) {
            [compressed increaseLengthBy:CHUNK_LENGTH];
		}

        strm.next_out = (Bytef *)[compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out;

        deflate(&strm, Z_FINISH);
    } while (strm.avail_out == 0);

    deflateEnd(&strm);

    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

NSData *Compress::decompress(NSData *data) {
    if ([data length] == 0) {
		return data;
	}
	
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
	
    NSMutableData *decompressed = [NSMutableData dataWithLength:full_length + half_length];
    BOOL done = NO;
    int status;
	
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
	
    if (inflateInit(&strm) != Z_OK) {
		return nil;
	}
	
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy:half_length];
		}
        strm.next_out = (Bytef *)[decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        // Inflate another chunk.
        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
			done = YES;
		} else if (status != Z_OK) {
			break;
		}
    }
    if (inflateEnd(&strm) != Z_OK) {
		return nil;
	}
	
    // Set real length.
    if (done) {
        [decompressed setLength:strm.total_out];
        return [NSData dataWithData:decompressed];
    } else {
		return nil;
	}
}