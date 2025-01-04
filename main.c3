import std::io;
import std::math;
import sdl;
import player;

char[10][10] map = {
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
};

def Vec2 = float[<2>];
const CInt WIDTH = 800;
const CInt HEIGHT = 600;
const CInt CELL_SIZE = WIDTH / 20;
const CInt ROWS_COUNT = HEIGHT / CELL_SIZE;
const CInt COLS_COUNT = WIDTH / CELL_SIZE;

bool running = true;

player::Player player = {
  .pos = { WIDTH / 3, HEIGHT / 2},
  .dir = { -1, 0 },
  .fov = 90,
};

fn void drawWalls(Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 255, 0, 0, 255);

  for (int row = 0; row < 10; row++) {
    for (int col = 0; col < 10; col++) {
      if (map[row][col] != 0) {
        sdl::renderFillRectF(
          renderer,
          &&FRect{ row * (float)CELL_SIZE + 1, col * (float)CELL_SIZE + 1, CELL_SIZE - 1, CELL_SIZE - 1 }
        );
      }
    }
  }
}

fn void gameLoop(Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 18, 18, 18, 255);

  for (int row = 0; row <= ROWS_COUNT; row++) {
    sdl::renderDrawLine(renderer, 0, row * CELL_SIZE, WIDTH, row * CELL_SIZE);
  }

  for (int col = 0; col <= COLS_COUNT; col++) {
    sdl::renderDrawLine(renderer, col * CELL_SIZE, 0, col * CELL_SIZE, HEIGHT);
  }

  player.draw(renderer);
  player.drawRay(renderer);

  drawWalls(renderer);

  sdl::renderPresent(renderer);
}

fn Vec2 lerpVec2(Vec2 a, Vec2 b, float p) {
  return addVec2(a, scaleVec2(subVec2(b, a), p));
}

fn Vec2 scaleVec2(Vec2 a, float p) {
  return { a.x * p, a.y * p };
}

fn Vec2 subVec2(Vec2 a, Vec2 b) {
  return { a.x - b.x, a.y - b.y };
}

fn Vec2 addVec2(Vec2 a, Vec2 b) {
  return { a.x + b.x, a.y + b.y };
}

fn void pollEvents() {
  Event event;
  while (sdl::pollEvent(&event)) {
    switch (event.type) {
      case sdl::QUIT:
        running = false;
        break;
      case sdl::KEYDOWN:
        sdl::Scancode key = event.key.keysym.scancode;
        if (key == 4) { // A
          player.fov -= 10;
        }
        if (key == 7) { // D
          player.fov += 10;
        }
        break;
    }
  }
}

fn void main() {
  sdl::init(sdl::INIT_VIDEO);

  Window* window = sdl::createWindow("Raycasting", 100, 100, WIDTH, HEIGHT, 0);
  Renderer* renderer = sdl::createRenderer(window, -1, 0x00000002 | 0x00000004);

  while (running) {
    sdl::setRenderDrawColor(renderer, 0, 0, 0, 255);
    sdl::renderClear(renderer);

    pollEvents();
    gameLoop(renderer);
  }
}
