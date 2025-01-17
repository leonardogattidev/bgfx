const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bx_lib = b.lazyDependency("bx", .{ .target = target, .optimize = .ReleaseSafe }).?.artifact("bx");
    const bimg_lib = b.lazyDependency("bimg", .{ .target = target, .optimize = .ReleaseSafe }).?.artifact("bimg");

    const bgfx_lib = b.addStaticLibrary(.{
        .name = "bgfx",
        .target = target,
        .optimize = optimize,
        // .root_source_file = b.path("bindings/zig/bgfx.zig"),
    });
    const bgfx_mod = bgfx_lib.root_module;
    bgfx_mod.addCSourceFiles(.{ .files = &src_files, .flags = &.{"-std=c++17"} });
    bgfx_mod.addCMacro("BX_CONFIG_DEBUG", "0"); // Release
    bgfx_mod.addIncludePath(b.path("include"));
    bgfx_mod.addIncludePath(b.path("src"));
    bgfx_mod.addIncludePath(b.path("3rdparty"));
    bgfx_mod.addIncludePath(b.path("3rdparty/khronos"));
    bgfx_mod.addIncludePath(b.path("3rdparty/directx-headers/include/wsl/stubs/"));
    bgfx_mod.addIncludePath(b.path("3rdparty/directx-headers/include/directx/"));
    bgfx_mod.linkLibrary(bx_lib);
    bgfx_mod.linkLibrary(bimg_lib);
    bgfx_mod.linkSystemLibrary("x11", .{});

    bgfx_lib.installLibraryHeaders(bx_lib);
    bgfx_lib.installLibraryHeaders(bimg_lib);
    bgfx_lib.installHeadersDirectory(b.path("include"), ".", .{});
    b.installArtifact(bgfx_lib);
}

const src_files = [_][]const u8{
    // "src/amalgamated.cpp",
    "src/topology.cpp",
    "src/bgfx.cpp",
    "src/glcontext_egl.cpp",
    "src/renderer_gnm.cpp",
    "src/dxgi.cpp",
    "src/renderer_d3d11.cpp",
    "src/renderer_agc.cpp",
    "src/debug_renderdoc.cpp",
    "src/shader_spirv.cpp",
    "src/nvapi.cpp",
    "src/shader_dxbc.cpp",
    "src/vertexlayout.cpp",
    "src/renderer_gl.cpp",
    "src/renderer_nvn.cpp",
    "src/glcontext_html5.cpp",
    "src/glcontext_wgl.cpp",
    "src/renderer_d3d12.cpp",
    "src/renderer_noop.cpp",
    "src/renderer_vk.cpp",
    "src/shader.cpp",
};
