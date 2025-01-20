const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("bgfx", .{
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addStaticLibrary(.{
        .name = "bgfx",
        .root_module = mod,
    });

    const t = target.result;
    const is_debug = mod.optimize == .Debug;

    mod.addCSourceFiles(.{
        .flags = &cpp_flags,
        .files = &cpp_src,
    });
    mod.link_libcpp = true;

    mod.addCMacro("__STDC_LIMIT_MACROS", "");
    mod.addCMacro("__STDC_FORMAT_MACROS", "");
    mod.addCMacro("__STDC_CONSTANT_MACROS", "");
    mod.addCMacro(if (is_debug) "_DEBUG" else "NDEBUG", "");
    mod.addCMacro("BX_CONFIG_DEBUG", if (is_debug) "1" else "0");
    mod.addCMacro("BGFX_CONFIG_MULTITHREADED", "1");

    mod.addIncludePath(b.path("include"));
    mod.addIncludePath(b.path("3rdparty"));
    mod.addIncludePath(b.path("3rdparty/khronos"));
    mod.addIncludePath(b.path("3rdparty/directx-headers/include/directx/"));
    // mod.addIncludePath(b.path("src"));
    // mod.addIncludePath(b.path("3rdparty/directx-headers/include/wsl/stubs/"));

    for (deps) |dep|
        mod.linkLibrary(b.dependency(dep, .{}).artifact(dep));

    if (t.os.tag == .windows)
        for (windeps) |dep|
            mod.linkSystemLibrary(dep, .{});

    lib.installHeadersDirectory(b.path("include"), ".", .{});
    b.installArtifact(lib);
}

const cpp_flags = [_][]const u8{
    "-std=c++17",
    "-fno-sanitize=undefined",
};

const cpp_src = [_][]const u8{
    "src/amalgamated.cpp",
};

const deps = [_][]const u8{
    "bx",
    "bimg",
};

const windeps = [_][]const u8{
    "gdi32",
    // "psapi",
    // "comdlg32",
};
