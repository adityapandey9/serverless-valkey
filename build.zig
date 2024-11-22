const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    // Add dependencies
    const wasi_compat = b.addStaticLibrary(.{
        .name = "wasi_compat",
        .target = target,
        .optimize = mode,
        .pic = true,
        .link_libc = true,
    });
    wasi_compat.linkLibC();
    wasi_compat.addCSourceFiles(.{
        .files = &.{
            "deps/wasi_compat/wasi_compat.c",
        },
        .flags = &.{ "-std=gnu11", "-Wall", "-W", "-Wno-missing-field-initializers", "-Wstrict-prototypes", "-pedantic" },
    });

    const external_storage = b.addStaticLibrary(.{
        .name = "external_storage",
        .target = target,
        .root_source_file = b.path("zig-src/commandStore//c_interface.zig"),
        .optimize = mode,
        // .pic = true,
    });

    const hiredis = b.addStaticLibrary(.{
        .name = "hiredis",
        .target = target,
        .optimize = mode,
        .pic = true,
        .link_libc = true,
    });
    hiredis.linkLibC();
    hiredis.linkLibrary(wasi_compat);
    hiredis.addIncludePath(b.path("deps/wasi_compat/"));
    hiredis.addCSourceFiles(.{
        .files = &.{
            "deps/hiredis/alloc.c",
            "deps/hiredis/async.c",
            "deps/hiredis/hiredis.c",
            "deps/hiredis/net.c",
            "deps/hiredis/read.c",
            "deps/hiredis/sds.c",
            "deps/hiredis/sockcompat.c",
        },
        .flags = &.{ "-std=gnu11", "-Wall", "-W", "-Wno-missing-field-initializers", "-Wstrict-prototypes", "-pedantic" },
    });

    // hrd_histogram deps
    const hrd_histogram = b.addStaticLibrary(.{
        .name = "hrd_histogram",
        .target = target,
        .optimize = mode,
        .pic = true,
        .link_libc = true,
    });
    hrd_histogram.linkLibC();
    hrd_histogram.addCSourceFiles(.{
        .files = &.{
            "deps/hdr_histogram/hdr_histogram.c",
        },
        .flags = &.{ "-std=gnu11", "-Wall", "-W", "-Wno-missing-field-initializers", "-Wstrict-prototypes", "-pedantic", "-DHDR_MALLOC_INCLUDE=\"hdr_redis_malloc.h\"" },
    });

    // fpconv deps
    const fpconv = b.addStaticLibrary(.{
        .name = "fpconv",
        .target = target,
        .optimize = mode,
        .pic = true,
        .link_libc = true,
    });
    fpconv.linkLibC();
    fpconv.addCSourceFiles(.{
        .files = &.{
            "deps/fpconv/fpconv_dtoa.c",
        },
        .flags = &.{ "-std=gnu11", "-Wall", "-W", "-Wno-missing-field-initializers", "-Wstrict-prototypes", "-pedantic" },
    });

    const lua = b.addStaticLibrary(.{
        .name = "lua",
        .target = target,
        .optimize = mode,
        .pic = true,
        .link_libc = true,
    });
    lua.linkLibC();
    lua.linkLibrary(wasi_compat);
    lua.addIncludePath(b.path("deps/wasi_compat/"));
    lua.addCSourceFiles(.{
        .files = &.{
            "deps/lua/src/fpconv.c",
            "deps/lua/src/lapi.c",
            "deps/lua/src/lauxlib.c",
            "deps/lua/src/lbaselib.c",
            "deps/lua/src/lcode.c",
            "deps/lua/src/ldblib.c",
            "deps/lua/src/ldebug.c",
            "deps/lua/src/ldo.c",
            "deps/lua/src/ldump.c",
            "deps/lua/src/lfunc.c",
            "deps/lua/src/lgc.c",
            "deps/lua/src/linit.c",
            "deps/lua/src/liolib.c",
            "deps/lua/src/llex.c",
            "deps/lua/src/lmathlib.c",
            "deps/lua/src/lmem.c",
            "deps/lua/src/loadlib.c",
            "deps/lua/src/lobject.c",
            "deps/lua/src/lopcodes.c",
            "deps/lua/src/loslib.c",
            "deps/lua/src/lparser.c",
            "deps/lua/src/lstate.c",
            "deps/lua/src/lstring.c",
            "deps/lua/src/lstrlib.c",
            "deps/lua/src/ltable.c",
            "deps/lua/src/ltablib.c",
            "deps/lua/src/ltm.c",
            "deps/lua/src/lua_bit.c",
            "deps/lua/src/lua_cjson.c",
            "deps/lua/src/lua_cmsgpack.c",
            "deps/lua/src/lua_struct.c",
            "deps/lua/src/lundump.c",
            "deps/lua/src/lvm.c",
            "deps/lua/src/lzio.c",
            "deps/lua/src/strbuf.c",
        },
        .flags = &.{
            "-std=gnu11",
            "-Wall",
            "-W",
            "-Wno-missing-field-initializers",
            "-Wstrict-prototypes",
            "-pedantic",
        },
    });

    // lua.custom_args = &.{ "-D_WASI_EMULATED_SIGNAL", "-lwasi-emulated-signal", "-D_WASI_EMULATED_PROCESS_CLOCKS", "-lwasi-emulated-process-clocks" };

    // Create valkey-cli executable
    const valkey_cli = b.addExecutable(.{
        .name = "valkey-cli",
        .target = target,
        .optimize = mode,
        .link_libc = true,
    });
    valkey_cli.linkLibC();
    valkey_cli.linkLibrary(hiredis);
    valkey_cli.linkLibrary(wasi_compat);

    valkey_cli.addIncludePath(b.path("deps/hiredis"));
    valkey_cli.addIncludePath(b.path("deps/linenoise"));
    valkey_cli.addIncludePath(b.path("deps/lua/src"));
    valkey_cli.addIncludePath(b.path("deps/fpconv"));
    valkey_cli.addIncludePath(b.path("deps/hdr_histogram"));
    valkey_cli.addIncludePath(b.path("deps/wasi_compat/"));

    valkey_cli.addCSourceFiles(.{
        .files = &.{
            "src/strl.c",
            "src/adlist.c",
            "src/ae.c",
            "src/anet.c",
            "src/redisassert.c",
            "src/cli_commands.c",
            "src/cli_common.c",
            "src/crc16.c",
            "src/crc64.c",
            "src/crcspeed.c",
            "src/dict.c",
            "src/monotonic.c",
            "src/mt19937-64.c",
            "src/valkey-cli.c",
            "src/release.c",
            "src/siphash.c",
            "src/zmalloc.c",
            "deps/linenoise/linenoise.c",
        },
        .flags = &.{
            "-std=gnu11",
            "-Wall",
            "-W",
            "-Wno-missing-field-initializers",
            "-Wstrict-prototypes",
            "-pedantic",
        },
    });

    // Create valkey-server executable
    const valkey_server = b.addExecutable(.{
        .name = "valkey-server",
        .target = target,
        .root_source_file = b.path("zig-src/root.zig"),
        .optimize = mode,
        .link_libc = true,
        // .use_lld = true,
    });
    valkey_server.linkLibC();
    valkey_server.linkLibrary(hiredis);
    valkey_server.linkLibrary(lua);
    valkey_server.linkLibrary(hrd_histogram);
    valkey_server.linkLibrary(fpconv);
    valkey_server.linkLibrary(wasi_compat);
    valkey_server.linkLibrary(external_storage);

    // Link the required system libraries
    valkey_server.linkSystemLibrary("m");
    valkey_server.linkSystemLibrary("dl");
    valkey_server.linkSystemLibrary("pthread");

    valkey_server.addIncludePath(b.path("deps/hiredis"));
    valkey_server.addIncludePath(b.path("deps/lua/src"));
    valkey_server.addIncludePath(b.path("deps/fpconv"));
    valkey_server.addIncludePath(b.path("deps/hdr_histogram"));
    valkey_server.addIncludePath(b.path("deps/wasi_compat/"));
    valkey_server.addIncludePath(b.path("zig-src/commandStore"));

    valkey_server.addCSourceFiles(.{
        .files = &.{
            "src/adlist.c",
            "src/quicklist.c",
            "src/ae.c",
            "src/anet.c",
            "src/dict.c",
            "src/server.c",
            "src/sds.c",
            "src/zmalloc.c",
            "src/lzf_c.c",
            "src/lzf_d.c",
            "src/pqsort.c",
            "src/zipmap.c",
            "src/sha1.c",
            "src/ziplist.c",
            "src/release.c",
            "src/networking.c",
            "src/util.c",
            "src/object.c",
            "src/db.c",
            "src/replication.c",
            "src/rdb.c",
            "src/t_string.c",
            "src/t_list.c",
            "src/t_set.c",
            "src/t_zset.c",
            "src/t_hash.c",
            "src/config.c",
            "src/aof.c",
            "src/pubsub.c",
            "src/multi.c",
            "src/debug.c",
            "src/sort.c",
            "src/intset.c",
            "src/syncio.c",
            "src/cluster.c",
            "src/crc16.c",
            "src/endianconv.c",
            "src/slowlog.c",
            "src/eval.c",
            "src/bio.c",
            "src/rio.c",
            "src/rand.c",
            "src/memtest.c",
            "src/syscheck.c",
            "src/crcspeed.c",
            "src/crc64.c",
            "src/bitops.c",
            "src/sentinel.c",
            "src/notify.c",
            "src/setproctitle.c",
            "src/blocked.c",
            "src/hyperloglog.c",
            "src/latency.c",
            "src/sparkline.c",
            "src/valkey-check-rdb.c",
            "src/valkey-check-aof.c",
            "src/geo.c",
            "src/lazyfree.c",
            "src/module.c",
            "src/evict.c",
            "src/expire.c",
            "src/geohash.c",
            "src/geohash_helper.c",
            "src/childinfo.c",
            "src/defrag.c",
            "src/siphash.c",
            "src/rax.c",
            "src/t_stream.c",
            "src/listpack.c",
            "src/localtime.c",
            "src/lolwut.c",
            "src/lolwut5.c",
            "src/lolwut6.c",
            "src/acl.c",
            "src/tracking.c",
            "src/socket.c",
            "src/tls.c",
            "src/sha256.c",
            "src/timeout.c",
            "src/setcpuaffinity.c",
            "src/monotonic.c",
            "src/mt19937-64.c",
            "src/resp_parser.c",
            "src/call_reply.c",
            "src/script_lua.c",
            "src/script.c",
            "src/functions.c",
            "src/function_lua.c",
            "src/commands.c",
            "src/strl.c",
            "src/connection.c",
            "src/unix.c",
            "src/logreqres.c",
        },
        .flags = &.{
            "-std=gnu11",
            "-Wall",
            "-W",
            "-Wno-missing-field-initializers",
            "-Wstrict-prototypes",
            "-pedantic",
        },
    });

    // const wasm_valkey = b.addExecutable(.{
    //     .name = "wasm_valkey",
    //     // .root_source_file = b.path("zig-src/root.zig"),
    //     .target = target,
    //     .optimize = mode,
    //     .link_libc = true,
    // });

    // wasm_valkey.linkLibC();
    // wasm_valkey.linkLibrary(hiredis);
    // wasm_valkey.linkLibrary(lua);
    // wasm_valkey.linkLibrary(hrd_histogram);
    // wasm_valkey.linkLibrary(fpconv);
    // wasm_valkey.linkLibrary(wasi_compat);

    // wasm_valkey.linkSystemLibrary("m");
    // wasm_valkey.linkSystemLibrary("dl");
    // wasm_valkey.linkSystemLibrary("pthread");

    // wasm_valkey.addIncludePath(b.path("deps/hiredis"));
    // wasm_valkey.addIncludePath(b.path("deps/lua/src"));
    // wasm_valkey.addIncludePath(b.path("deps/fpconv"));
    // wasm_valkey.addIncludePath(b.path("deps/hdr_histogram"));
    // wasm_valkey.addIncludePath(b.path("deps/wasi_compat/"));
    // wasm_valkey.addIncludePath(b.path("src"));

    // wasm_valkey.addCSourceFiles(.{
    //     .files = &.{
    //         "src/adlist.c",
    //         "src/quicklist.c",
    //         "src/ae.c",
    //         "src/anet.c",
    //         "src/dict.c",
    //         "src/server.c",
    //         "src/sds.c",
    //         "src/zmalloc.c",
    //         "src/lzf_c.c",
    //         "src/lzf_d.c",
    //         "src/pqsort.c",
    //         "src/zipmap.c",
    //         "src/sha1.c",
    //         "src/ziplist.c",
    //         "src/release.c",
    //         "src/networking.c",
    //         "src/util.c",
    //         "src/object.c",
    //         "src/db.c",
    //         "src/replication.c",
    //         "src/rdb.c",
    //         "src/t_string.c",
    //         "src/t_list.c",
    //         "src/t_set.c",
    //         "src/t_zset.c",
    //         "src/t_hash.c",
    //         "src/config.c",
    //         "src/aof.c",
    //         "src/pubsub.c",
    //         "src/multi.c",
    //         "src/debug.c",
    //         "src/sort.c",
    //         "src/intset.c",
    //         "src/syncio.c",
    //         "src/cluster.c",
    //         "src/crc16.c",
    //         "src/endianconv.c",
    //         "src/slowlog.c",
    //         "src/eval.c",
    //         "src/bio.c",
    //         "src/rio.c",
    //         "src/rand.c",
    //         "src/memtest.c",
    //         "src/syscheck.c",
    //         "src/crcspeed.c",
    //         "src/crc64.c",
    //         "src/bitops.c",
    //         "src/sentinel.c",
    //         "src/notify.c",
    //         "src/setproctitle.c",
    //         "src/blocked.c",
    //         "src/hyperloglog.c",
    //         "src/latency.c",
    //         "src/sparkline.c",
    //         "src/valkey-check-rdb.c",
    //         "src/valkey-check-aof.c",
    //         "src/geo.c",
    //         "src/lazyfree.c",
    //         "src/module.c",
    //         "src/evict.c",
    //         "src/expire.c",
    //         "src/geohash.c",
    //         "src/geohash_helper.c",
    //         "src/childinfo.c",
    //         "src/defrag.c",
    //         "src/siphash.c",
    //         "src/rax.c",
    //         "src/t_stream.c",
    //         "src/listpack.c",
    //         "src/localtime.c",
    //         "src/lolwut.c",
    //         "src/lolwut5.c",
    //         "src/lolwut6.c",
    //         "src/acl.c",
    //         "src/tracking.c",
    //         "src/socket.c",
    //         "src/tls.c",
    //         "src/sha256.c",
    //         "src/timeout.c",
    //         "src/setcpuaffinity.c",
    //         "src/monotonic.c",
    //         "src/mt19937-64.c",
    //         "src/resp_parser.c",
    //         "src/call_reply.c",
    //         "src/script_lua.c",
    //         "src/script.c",
    //         "src/functions.c",
    //         "src/function_lua.c",
    //         "src/commands.c",
    //         "src/strl.c",
    //         "src/connection.c",
    //         "src/unix.c",
    //         "src/logreqres.c",
    //     },
    //     .flags = &.{
    //         "-std=gnu11",
    //         "-Wall",
    //         "-W",
    //         "-Wno-missing-field-initializers",
    //         "-Wstrict-prototypes",
    //         "-pedantic",
    //     },
    // });

    // wasm_valkey.custom_args = &.{ "-D_WASI_EMULATED_GETPID", "-D_WASI_EMULATED_SIGNAL", "-lwasi-emulated-signal", "-D_WASI_EMULATED_PROCESS_CLOCKS", "-lwasi-emulated-process-clocks", "-D_WASI_EMULATED_MMAN", "-lwasi-emulated-mman" };

    // Install artifacts
    // b.installArtifact(wasm_valkey);
    b.installArtifact(valkey_cli);
    b.installArtifact(valkey_server);
}
