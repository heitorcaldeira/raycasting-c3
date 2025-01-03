import std::io;
import std::math;
import sdl;
import player;

def Vec2 = float[<2>];
const CInt WIDTH = 800;
const CInt HEIGHT = 600;
const CInt CELL_SIZE = 40;
const CInt PLAYER_SIZE = 15;
const CInt ROWS_COUNT = HEIGHT / CELL_SIZE;
const CInt COLS_COUNT = WIDTH / CELL_SIZE;

char[10][10] map = {
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 1, 1, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
};

bool running = true;

player::Player p1 = {
  .pos = { 200, 300},
  .dir = { 1, 0 },
  .fov = 30,
};

player::Player p2 = {
  .pos = { 200, 300},
  .dir = { 1, 0 },
  .fov = 30,
};

fn float snap(float x, float dx) {
  if (dx > 0) return math::ceil(x);
  if (dx < 0) return math::floor(x);
  return x;
}

fn void drawLine(Renderer* renderer, Vec2 p1, Vec2 p2) {
  sdl::setRenderDrawColor(renderer, 18, 255, 18, 255);
  sdl::renderDrawLineF(
    renderer,
    p1.x + PLAYER_SIZE * 0.5,
    p1.y + PLAYER_SIZE * 0.5,
    p2.x + PLAYER_SIZE * 0.5,
    p2.y + PLAYER_SIZE * 0.5
  );
}

fn void drawWalls(Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 255, 0, 0, 255);

  for (int row = 0; row < 10; row++) {
    for (int col = 0; col < 10; col++) {
      if (map[row][col] != 0) {
        sdl::renderFillRectF(
          renderer,
          &&FRect{ row * (float)CELL_SIZE, col * (float)CELL_SIZE, CELL_SIZE, CELL_SIZE }
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

  p1.draw(renderer);
  drawLine(renderer, p1.pos, p2.pos);

  drawWalls(renderer);

  sdl::renderPresent(renderer);
}

fn void pollEvents() {
  Event event;
  while (sdl::pollEvent(&event)) {
    switch (event.type) {
      case sdl::QUIT:
        running = false;
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
