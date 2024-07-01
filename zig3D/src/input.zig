//! Simple input handling for SDL2
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const Event = enum {
    UP,
    DOWN,
    QUIT,
    ESCAPE,
    w,
    s,
    a,
    d,
    NOTHING,
};

pub fn poll() Event {
    var event: c.SDL_Event = undefined;
    _ = c.SDL_PollEvent(&event);
    switch (event.type) {
        c.SDL_QUIT => {
            return Event.QUIT;
        },
        c.SDL_KEYDOWN => {
            switch (event.key.keysym.sym) {
                c.SDLK_ESCAPE => {
                    return Event.ESCAPE;
                },
                c.SDLK_UP => {
                    return Event.UP;
                },
                c.SDLK_DOWN => {
                    return Event.DOWN;
                },
                c.SDLK_w => {
                    return Event.w;
                },
                c.SDLK_s => {
                    return Event.s;
                },
                c.SDLK_a => {
                    return Event.a;
                },
                c.SDLK_d => {
                    return Event.d;
                },
                else => {},
            }
        },
        else => {},
    }
    return Event.NOTHING;
}
