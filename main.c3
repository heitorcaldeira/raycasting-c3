import std::io;
import std::math;
import sdl;

const CInt MAP_SIZE = 10;
def Vec2 = float[<2>];
const CInt WIDTH = 800;
const CInt HEIGHT = 600;
const CInt CELL_SIZE = WIDTH / 20;
const CInt ROWS_COUNT = HEIGHT / CELL_SIZE;
const CInt COLS_COUNT = WIDTH / CELL_SIZE;

char[MAP_SIZE][MAP_SIZE] map = {
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 1 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 },
  { 0, 1, 1, 1, 0, 0, 0, 0, 1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
};

bool running = true;

const CInt PLAYER_SIZE = 8;

struct Player {
  Vec2 pos;
  Vec2 dir;
  float fov;
}

fn void Player.draw(Player* p, Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 18, 255, 18, 255);
  sdl::renderFillRectF(renderer, &&FRect{ p.pos.x, p.pos.y, PLAYER_SIZE, PLAYER_SIZE });
}

fn void Player.drawRays(Player* p, Renderer* renderer) {
  Vec2 ray, offset;
  float rayAngle, iRay, mapIndex;
  int maxRays;
  Vec2 l = p.dir;

  rayAngle = p.fov;
  maxRays = (int)math::max(COLS_COUNT, ROWS_COUNT);

  sdl::setRenderDrawColor(renderer, 0, 0, 255, 255);

  float tan = math::tan(rayAngle);
  float aTan = tan != 0 ? -1 / math::tan(rayAngle) : 1.0;
  for (int r = 0; r < 1; r++) {
    if (rayAngle > math::PI) {
      ray.y = (double)((float)math::floor((int)(p.pos.y / CELL_SIZE)) * CELL_SIZE) - 0.0001;
      ray.x = ((p.pos.y - ray.y) * aTan) + p.pos.x;
      offset.y = -CELL_SIZE;
      offset.x = -offset.y * aTan;
    } 

    if (rayAngle < math::PI) {
      ray.y = (double)((float)math::floor((int)(p.pos.y / CELL_SIZE)) * CELL_SIZE) + CELL_SIZE - 0.0001;
      ray.x = math::floor((p.pos.y - ray.y) * aTan + p.pos.x);
      offset.y = CELL_SIZE;
      offset.x = -offset.y * aTan;
    }

    if (rayAngle == math::PI || rayAngle == 0) {
      ray.x = p.pos.x;
      ray.y = p.pos.x;
      iRay = maxRays;
    }

    while (iRay < maxRays) {
      ray += offset;
      iRay += 1;
    }

    sdl::setRenderDrawColor(renderer, 255, 0, 18, 255);
    sdl::renderDrawLineF(
      renderer,
      p.pos.x + PLAYER_SIZE * 0.5,
      p.pos.y + PLAYER_SIZE * 0.5,
      ray.x,
      ray.y
    );
  }
}

fn float degToRad(float angle) {
  return ((angle) * math::PI / 180.0);
}

Player player = {
  .pos = { WIDTH / 3, HEIGHT / 2},
  .dir = { -1, 0 },
  .fov = 0.1,
};

fn void drawWalls(Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 255, 0, 0, 255);

  for (int col = 0; col < 10; col++) {
    for (int row = 0; row < 10; row++) {
      if (map[col][row] != 0) {
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
  player.drawRays(renderer);

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
      case sdl::KEYDOWN:
        sdl::Scancode key = event.key.keysym.scancode;
        if (key == 4) { // A
          player.fov -= 0.1;
          if (player.fov < 0) player.fov += math::PI * 2;
          float x = math::cos(player.fov) * 10;
          float y = math::sin(player.fov) * 10;
          player.dir = { x, y };
        }

        if (key == 7) { // D
          player.fov += 0.1;
          if (player.fov > math::PI * 2) player.fov -= math::PI * 2;
          float x = math::cos(player.fov) * 10;
          float y = math::sin(player.fov) * 10;
          player.dir = { x, y };
        }

        if (key == 26) { // W
          player.pos += player.dir;
        }

        if (key == 22) { // S
          player.pos -= player.dir;
        }
        break;
    }
  }
}

fn void main() {
  sdl::init(sdl::INIT_VIDEO);

  Window* window = sdl::createWindow("Raycasting", 100, 100, WIDTH, HEIGHT, 0);
  Renderer* renderer = sdl::createRenderer(window, -1, 0x00000002 | 0x00000004);

  float x = math::cos(player.fov) * 10;
  float y = math::sin(player.fov) * 10;
  player.dir = { x, y };

  while (running) {
    sdl::setRenderDrawColor(renderer, 0, 0, 0, 255);
    sdl::renderClear(renderer);

    pollEvents();
    gameLoop(renderer);
  }
}
