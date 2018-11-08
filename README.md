# WebGL Confetti

- [brianustas.com/webgl-confetti/](http://brianustas.com/webgl-confetti/) (tested in Chrome)
- Initial release: 02/03/13
- Author: [Brian Ustas](http://brianustas.com)

Interactive confetti simulation written with raw WebGl.

![](https://github.com/ustasb/webgl_confetti/blob/master/webgl_confetti.jpg)

Features:

- Scene can be rotated with the mouse.
- Emitter's emitting-rate can be controlled via a slider.
- Emitter and floor are 3D models made of triangles.
- The particles can collide with the floor.
- Fully shader-based

## Usage

First build the Docker image:

    docker build -t webgl_confetti .

Compile SASS and CoffeeScript with:

    rake docker_build_dist

    # To recompile assets when files change (uses fswatch):

    rake docker_build_dist_and_watch

Serve assets via a local server:

    cd src && python -m SimpleHTTPServer

Navigate to `http://localhost:8000` in your browser.

## Production

To build the `public/` folder:

    rake docker_build_public

Open `public/index.html`.
