//-----------------------------------------------------------------------------
// MurmurHash2, by Austin Appleby

// Note - This code makes a few assumptions about how your machine behaves -

// 1. We can read a 4-byte value from any address without crashing
// 2. sizeof(int) == 4

// And it has a few limitations -

// 1. It will not work incrementally.
// 2. It will not produce the same results on little-endian and big-endian
//    machines.

//unsigned int murmurhash2(const void * key, int len, const unsigned int seed)
unsigned int murmurhash2(const char key[32], int len, const unsigned int seed)
{
	// 'm' and 'r' are mixing constants generated offline.
	// They're not really 'magic', they just happen to work well.

	const unsigned int m = 0x5bd1e995;
	const int r = 24;

	// Initialize the hash to a 'random' value

	unsigned int h = seed ^ len;

	// Mix 4 bytes at a time into the hash

	const unsigned char * data = (const unsigned char *)key;

	//unsigned int data_indx = 0;
	while(len >= 4)
	{
//#pragma HLS PIPELINE
		unsigned int k = *(unsigned int *)data;
		//unsigned int k = (data [data_indx+3] << 3*8) |  (data [data_indx+2] << 2*8) |
		//				 (data [data_indx+1] << 1*8) |   data [data_indx];

		k *= m;
		k ^= k >> r;
		k *= m;

		h *= m;
		h ^= k;

		//data_indx += 4;
		data += 4;
		len -= 4;
	}

	// Handle the last few bytes of the input array

	switch(len)
	{
	case 3: h ^= data[2] << 16;
	case 2: h ^= data[1] << 8;
	case 1: h ^= data[0];
//	case 3: h ^= data[data_indx + 2] << 16;
//	case 2: h ^= data[data_indx + 1] << 8;
//	case 1: h ^= data[data_indx + 0];
	        h *= m;
	};

	// Do a few final mixes of the hash to ensure the last few
	// bytes are well-incorporated.

	h ^= h >> 13;
	h *= m;
	h ^= h >> 15;

	return h;
}