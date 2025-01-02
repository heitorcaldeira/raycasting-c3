import std::io;
import std::math;
import sdl;

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
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 1, 1, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
};

bool running = true;

Vec2 p1 = { 200, 300 };
Vec2 p2 = { 300, 203 };

fn float snap(float x, float dx) {
  if (dx > 0) return math::ceil(x);
  if (dx < 0) return math::floor(x);
  return x;
}

fn void rayStep(Renderer* renderer, Vec2 p1, Vec2 p2) {
  Vec2 p = (p2 - p1);
  float len = math::sqrt(p.x * p.x + p.y * p.y);

  Vec2 norm;
  if (len == 0) {
    norm = { 0, 0 };
  }

  norm = Vec2 { p.x / len, p.y / len } * 20;

  // y = m*x + n
  Vec2 d = p2 - p1;
  if (d.x != 0) {
    float k = d.y / d.x;
    float c = p1.y - k * p1.x;
    float x3 = snap(p2.x, d.x);
    float y3 = x3 * k + c;
    drawPlayer(renderer, { x3, y3 });
  } else {
    drawPlayer(renderer, p2);
  }
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

fn void drawPlayer(Renderer* renderer, Vec2 playerPos) {
  sdl::setRenderDrawColor(renderer, 18, 255, 18, 255);
  sdl::renderFillRectF(renderer, &&FRect{ playerPos.x, playerPos.y, PLAYER_SIZE, PLAYER_SIZE });
}

fn void gameLoop(Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 18, 18, 18, 255);

  for (int row = 0; row <= ROWS_COUNT; row++) {
    sdl::renderDrawLine(renderer, 0, row * CELL_SIZE, WIDTH, row * CELL_SIZE);
  }

  for (int col = 0; col <= COLS_COUNT; col++) {
    sdl::renderDrawLine(renderer, col * CELL_SIZE, 0, col * CELL_SIZE, HEIGHT);
  }

  drawPlayer(renderer, p1);
  drawPlayer(renderer, p2);
  drawLine(renderer, p1, p2);

  rayStep(renderer, p1, p2);

  sdl::renderPresent(renderer);
}

fn void pollEvents() {
  Event event;
  while (sdl::pollEvent(&event)) {
    switch (event.type) {
      case sdl::QUIT:
        running = false;
        break;
      case sdl::MOUSEMOTION:
        p2.x = (float)event.button.x - PLAYER_SIZE * 0.5;
        p2.y = (float)event.button.y - PLAYER_SIZE * 0.5;
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
