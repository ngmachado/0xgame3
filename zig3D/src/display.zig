//! Simple SDL2 wrapper for rendering pixels to the screen
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const Size = struct {
    width: u32,
    height: u32,

    pub fn init(w: u32, h: u32) Size {
        return Size{ .width = w, .height = h };
    }

    pub fn getWidth(self: Size) u32 {
        return self.width;
    }

    pub fn getHeight(self: Size) u32 {
        return self.height;
    }
};

pub fn getCurrentDisplaySize() !Size {
    var display_mode: c.SDL_DisplayMode = undefined;
    if (c.SDL_GetCurrentDisplayMode(0, &display_mode) != 0) {
        c.SDL_Log("Unable to get Display mode: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    return Size.init(@intCast(display_mode.w), @intCast(display_mode.h));
}

pub const Display = struct {
    size: Size,
    window: ?*c.SDL_Window,
    renderer: ?*c.SDL_Renderer,
    texture: ?*c.SDL_Texture,

    pub fn init(width: u32, height: u32) !Display {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
            c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        }

        var w = width;
        var h = height;

        if (w == 0 or h == 0) {
            const display_size = try getCurrentDisplaySize();
            w = display_size.width;
            h = display_size.height;
        }

        const screen_window = c.SDL_CreateWindow("", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, @intCast(w), @intCast(h), c.SDL_WINDOW_BORDERLESS) orelse {
            c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };

        const renderer = c.SDL_CreateRenderer(screen_window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
            c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };

        const texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ARGB8888, c.SDL_TEXTUREACCESS_STREAMING, @intCast(w), @intCast(h)) orelse {
            c.SDL_Log("Unable to create texture: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };

        return Display{
            .size = Size.init(w, h),
            .window = screen_window,
            .renderer = renderer,
            .texture = texture,
        };
    }

    pub fn setFullscreen(self: *Display) !void {
        if (c.SDL_SetWindowFullscreen(self.screen_window.?, c.SDL_WINDOW_FULLSCREEN_DESKTOP) != 0) {
            c.SDL_Log("Unable to set fullscreen: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        }
    }

    pub fn render(self: *Display, pixels: *u32) !void {
        if (c.SDL_UpdateTexture(self.texture.?, null, pixels, @intCast(self.size.width * 4)) != 0) {
            c.SDL_Log("Unable to update texture: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        }

        if (c.SDL_RenderClear(self.renderer.?) != 0) {
            c.SDL_Log("Unable to clear renderer: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        }

        if (c.SDL_RenderCopy(self.renderer.?, self.texture.?, null, null) != 0) {
            c.SDL_Log("Unable to copy texture: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        }

        c.SDL_RenderPresent(self.renderer.?);
    }
    pub fn deinit(self: *Display) void {
        c.SDL_DestroyTexture(self.texture);
        c.SDL_DestroyRenderer(self.renderer);
        c.SDL_DestroyWindow(self.window);
        c.SDL_Quit();
    }
};
