# 0xgame3

# 3D Graphics Rendering Pipeline in Zig


## Overview

Zig 3D is a graphics rendering pipeline implemented in Zig, designed to handle loading, processing, and rendering 3D meshes.
The pipeline features modules for handling different aspects of 3D graphics rendering, including input processing, mesh transformation, rasterization, and post-processing effects.

This is a **work in progress**, and the project is still in the early stages of development. The goal is to create a simple, efficient, and easy-to-use 3D graphics rendering pipeline that can be used for a variety of applications, including games, simulations, and visualizations.

Visit my public notes at [Axe Notes](https://publish.obsidian.md/axe/public/vault/3D+Graphics+Rendering+Pipeline+in+Zig) for more information.

## Motivation

I'm using this project as a way to learn more about 3D graphics rendering as well as Zig programming language. I'm also using it as a way to experiment with different rendering techniques and algorithms.

## Features

- [x] Mesh loading
- [x] Mesh transformation
- [x] Rasterization
- [ ] Ray Tracing
- [ ] Texturing
- [ ] Lighting
- [ ] Post-processing effects
- [ ] User input handling
- [ ] Camera controls
- [ ] Scene management
- [ ] Shader support
- [ ] Multi-threading support
- [ ] GPU acceleration


## Under the hood

The pipeline is built around a simple 3D graphics rendering engine that uses the following components:

- **Mesh**: Represents a 3D model, consisting of vertices, normals, and texture coordinates.
- **Rasterizer**: Converts 3D models into 2D images by projecting them onto the screen.
- **Shader**: Applies lighting and texturing effects to the rasterized image.
- **Renderer**: Combines the rasterizer and shader to render the final image.
- **Input**: Handles user input, such as keyboard and mouse events.
- **Camera**: Controls the view of the scene by moving and rotating the camera.
- **Scene**: Manages the objects in the scene, including the camera, lights, and meshes.


## Screenshots

Here is some screenshots of the current state of the project:

### Clipping

![Mesh Clipping](./zig3D/assets/screenshots/clipping.png)

![Mesh Clipping](./zig3D/assets/screenshots/clipping-camera_plane.png)

### Big Mesh

![Big Mesh](./zig3D/assets/screenshots/big-mesh1.png)

![Big Mesh](./zig3D/assets/screenshots/big-mesh2.png)

## More information

To learn more about the Zig programming language, visit the official website at [ziglang.org](https://ziglang.org/).
To learn more about the SDL2 library, visit the official website at [libsdl.org](https://www.libsdl.org/).

## Dependencies

```zig
.dependencies = .{
        .SDL = .{
            .url = "https://github.com/pwbh/SDL/archive/refs/tags/release-2.30.3.tar.gz",
            .hash = "122023e44c8cd24dc7275d01181cab31e386504149f06105c14d66754c03137f2145",
        },
    },
```


