#!/bin/bash

# Set compiler and flags
ZIG="zig build-exe"
OPTIMIZATION=""
CFLAGS="-std=gnu11 -Wall -W -Wno-missing-field-initializers -Werror=deprecated-declarations -Wstrict-prototypes -pedantic -DREDIS_STATIC=static"
LDFLAGS="-cflags"
ENDFLAGS="--"

# Include paths for dependencies
INCLUDE_PATHS="-I../deps/hiredis -I../deps/lua/src -I../deps/hdr_histogram -I../deps/fpconv"

# Dependency files (Make sure these files exist in the deps directory)
DEP_LIBS="../deps/hiredis/libhiredis.a ../deps/lua/src/liblua.a ../deps/hdr_histogram/libhdrhistogram.a ../deps/fpconv/libfpconv.a"

# Source files (relative to src directory)
SRC_FILES="adlist.c quicklist.c ae.c anet.c dict.c server.c sds.c zmalloc.c lzf_c.c lzf_d.c pqsort.c zipmap.c sha1.c ziplist.c release.c networking.c util.c object.c db.c replication.c rdb.c t_string.c t_list.c t_set.c t_zset.c t_hash.c config.c aof.c pubsub.c multi.c debug.c sort.c intset.c syncio.c cluster.c crc16.c endianconv.c slowlog.c eval.c bio.c rio.c rand.c memtest.c syscheck.c crcspeed.c crc64.c bitops.c sentinel.c notify.c setproctitle.c blocked.c hyperloglog.c latency.c sparkline.c valkey-check-rdb.c valkey-check-aof.c geo.c lazyfree.c module.c evict.c expire.c geohash.c geohash_helper.c childinfo.c defrag.c siphash.c rax.c t_stream.c listpack.c localtime.c lolwut.c lolwut5.c lolwut6.c acl.c tracking.c socket.c tls.c sha256.c timeout.c setcpuaffinity.c monotonic.c mt19937-64.c resp_parser.c call_reply.c script_lua.c script.c functions.c function_lua.c commands.c strl.c connection.c unix.c logreqres.c"

# Change to src directory
cd src || { echo "Failed to change to src directory"; exit 1; }

# Compile dependencies if they are not available (Assuming Makefiles are present in deps subdirectories)
# echo "Compiling dependencies..."
# export CC="zig cc"
# export CFLAGS="$CFLAGS"
# (cd ../deps/hiredis && make) || { echo "Failed to compile hiredis"; exit 1; }
# (cd ../deps/lua && make macosx) || { echo "Failed to compile lua"; exit 1; }
# (cd ../deps/hdr_histogram && make) || { echo "Failed to compile hdr_histogram"; exit 1; }
# (cd ../deps/fpconv && make) || { echo "Failed to compile fpconv"; exit 1; }

# Compile and link the executable in one step
echo "Building valkey-server using zig build-exe"
echo "$ZIG $OPTIMIZATION $LDFLAGS $CFLAGS $ENDFLAGS $INCLUDE_PATHS $SRC_FILES $DEP_LIBS --name valkey-server"
$ZIG $OPTIMIZATION $LDFLAGS $CFLAGS $ENDFLAGS $INCLUDE_PATHS $SRC_FILES $DEP_LIBS --name valkey-server || { echo "Failed to build valkey-server"; exit 1; }

echo "Build process completed."

# Change to src directory
cd .. || { echo "Failed to change to src directory"; exit 1; }
