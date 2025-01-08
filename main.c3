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
const P2 = math::PI / 2;
const P3 = 3 * math::PI / 2;

char[MAP_SIZE][MAP_SIZE] map = {
  { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
  { 1, 1, 1, 0, 0, 1, 1, 1, 0, 1 },
  { 1, 0, 0, 1, 0, 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
  { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
};

bool running = true;
Vec2 move = { 0, 0 };

const CInt PLAYER_SIZE = 8;

struct Player {
  Vec2 pos;
  Vec2 dir;
  float fov;
}

Vec2 ray, offset;

fn void Player.draw(Player* p, Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 18, 255, 18, 255);
  sdl::renderDrawLineF(renderer, p.pos.x + PLAYER_SIZE * 0.5, p.pos.y + PLAYER_SIZE * 0.5, p.pos.x + p.dir.x * 5, p.pos.y + p.dir.y * 5);
  sdl::renderFillRectF(renderer, &&FRect{ p.pos.x, p.pos.y, PLAYER_SIZE, PLAYER_SIZE });
}

fn float distance(Vec2 a, Vec2 b) {
  return math::sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y));
}

fn void Player.drawRays(Player* p, Renderer* renderer) {
  sdl::renderSetScale(renderer, 1, 1);
  float rayAngle, mp, finalDist;
  int iRay;
  int maxRays;
  Vec2 l = p.dir;

  rayAngle = p.fov - degToRad(30);
  if (rayAngle < 0) rayAngle += math::PI * 2;

  if (rayAngle > math::PI * 2) rayAngle -= math::PI * 2;
  maxRays = 10;

  for (int r = 0; r < 60; r++) {
    iRay = 0;
    float distV = 100000000;
    float vx = p.pos.x;
    float vy = p.pos.y;
    float nTan = -math::tan(rayAngle);
    if (rayAngle > P2 && rayAngle < P3) {
      ray.x = (double)((float)math::floor((int)(p.pos.x / CELL_SIZE)) * CELL_SIZE) - 0.001;
      ray.y = ((p.pos.x - ray.x) * nTan) + p.pos.y;
      offset.x = -CELL_SIZE;
      offset.y = -offset.x * nTan;
    } 

    if (rayAngle < P2 || rayAngle > P3) {
      ray.x = (double)((float)math::floor((int)(p.pos.x / CELL_SIZE)) * CELL_SIZE) + CELL_SIZE;
      ray.y = math::floor((p.pos.x - ray.x) * nTan + p.pos.y);
      offset.x = CELL_SIZE;
      offset.y = -offset.x * nTan;
    }

    if (rayAngle == math::PI || rayAngle == 0) {
      ray.x = p.pos.x;
      ray.y = p.pos.x;
      iRay = maxRays;
    }

    while (iRay < maxRays) {
      int row = (int)math::floor(ray.x / CELL_SIZE);
      int col = (int)math::floor(ray.y / CELL_SIZE);

      if (row >= 0 && col >= 0 && row < MAP_SIZE && col < MAP_SIZE && map[col][row] == 1) {
        vx = ray.x;
        vy = ray.y;
        distV = distance(p.pos, { vx, vy });
        iRay = maxRays;
      } else {
        ray += offset;
        iRay += 1;
      }
    }

    float distH = 100000000;
    float hx = p.pos.x;
    float hy = p.pos.y;
    float aTan = -1 / math::tan(rayAngle);
    iRay = 0;
    if (rayAngle > math::PI) {
      ray.y = (double)((float)math::floor((int)(p.pos.y / CELL_SIZE)) * CELL_SIZE) - 0.001;
      ray.x = ((p.pos.y - ray.y) * aTan) + p.pos.x;
      offset.y = -CELL_SIZE;
      offset.x = -offset.y * aTan;
    } 

    if (rayAngle < math::PI) {
      ray.y = (double)((float)math::floor((int)(p.pos.y / CELL_SIZE)) * CELL_SIZE) + CELL_SIZE;
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
      int row = (int)math::floor(ray.x / CELL_SIZE);
      int col = (int)math::floor(ray.y / CELL_SIZE);

      if (row >= 0 && col >= 0 && row < MAP_SIZE && col < MAP_SIZE && map[col][row] == 1) {
        hx = ray.x;
        hy = ray.y;
        distH = distance(p.pos, { hx, hy });
        iRay = maxRays;
      } else {
        ray += offset;
        iRay += 1;
      }
    }

    if (distV < distH) {
      ray = { vx, vy };
      finalDist = distV;
      sdl::setRenderDrawColor(renderer, 0, 50, 50, 255);
    }
    if (distH < distV) {
      ray = { hx, hy };
      finalDist = distH;
      sdl::setRenderDrawColor(renderer, 0, 230, 230, 255);
    }

    if (finalDist == 0) finalDist = 0.0001;
    float ca = p.fov - rayAngle;
    if (ca < 0) ca += math::PI * 2;
    if (ca > math::PI * 2) ca -= math::PI * 2;
    float lineHeigth = (MAP_SIZE * HEIGHT) / finalDist;
    float lineOffset = 300 - lineHeigth / 2;


    rayAngle += degToRad(1);
    if (rayAngle < 0) rayAngle += math::PI * 2;
    if (rayAngle > math::PI * 2) rayAngle -= math::PI * 2;
    sdl::renderFillRectF(
        renderer,
        &&FRect{ (float)r * WIDTH / 60, lineOffset, 3+ WIDTH / 60, lineHeigth }
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
  sdl::renderSetScale(renderer, 0.3, 0.3);

  for (int row = 0; row <= ROWS_COUNT; row++) {
    sdl::renderDrawLine(renderer, 0, row * CELL_SIZE, WIDTH, row * CELL_SIZE);
  }

  for (int col = 0; col <= COLS_COUNT; col++) {
    sdl::renderDrawLine(renderer, col * CELL_SIZE, 0, col * CELL_SIZE, HEIGHT);
  }

  drawWalls(renderer);

  player.draw(renderer);
  player.drawRays(renderer);

  int xOff = 0;
  int yOff = 0;

  if (player.dir.x < 0) {
    xOff = -20;
  } else {
    xOff = 20;
  }

  if (player.dir.y < 0) {
    yOff = -20;
  } else {
    yOff = 20;
  }

  int iPlayerX = (int)math::floor(player.pos.x / CELL_SIZE);
  int ipYAddOffset = (int)math::floor((player.pos.y + yOff) / CELL_SIZE);
  int ipYSubOffset = (int)math::floor((player.pos.y - yOff) / CELL_SIZE);
  int ipXAddOffset = (int)math::floor((player.pos.x + xOff) / CELL_SIZE);
  int ipXSubOffset = (int)math::floor((player.pos.x - xOff) / CELL_SIZE);

  if (move.y == 1) {
    if (map[ipYAddOffset][iPlayerX] == 0) {
      player.pos += player.dir / 2;
    }

    if (map[ipYAddOffset][ipXAddOffset] == 0) {
      player.pos += player.dir / 2;
    }
  }
  if (move.y == -1) {
    if (map[ipYSubOffset][iPlayerX] == 0) {
      player.pos -= player.dir / 2;
    }

    if (map[ipYSubOffset][ipXSubOffset] == 0) {
      player.pos -= player.dir / 2;
    }
  }
  if (move.x == 1) {
    player.fov += 0.05;
    if (player.fov > math::PI * 2) player.fov -= math::PI * 2;
    float x = math::cos(player.fov) * 10;
    float y = math::sin(player.fov) * 10;
    player.dir = { x, y };
  }

  if (move.x == -1) {
    player.fov -= 0.05;
    if (player.fov < 0) player.fov += math::PI * 2;
    float x = math::cos(player.fov) * 10;
    float y = math::sin(player.fov) * 10;
    player.dir = { x, y };
  }

  sdl::renderPresent(renderer);
}

fn void pollEvents() {
  Event event;
  while (sdl::pollEvent(&event)) {
    switch (event.type) {
      case sdl::QUIT:
        running = false;
        break;
      case sdl::KEYUP:
        move = { 0, 0 };
      case sdl::KEYDOWN:
        sdl::Scancode key = event.key.keysym.scancode;
        if (key == 4) { // A
          move = { -1, 0 };
        }

        if (key == 7) { // D
          move = { 1, 0 };
        }

        if (key == 26) { // W
          move = { 0, 1 };
        }

        if (key == 22) { // S
          move = { 0, -1 };
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
    sdl::setRenderDrawColor(renderer, 18, 18, 18, 255);
    sdl::renderClear(renderer);

    pollEvents();
    gameLoop(renderer);
  }
}
