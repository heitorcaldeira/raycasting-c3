module player;

import std::math;
import sdl;

const CInt PLAYER_SIZE = 15;

struct Player {
  float[<2>] pos;
  float[<2>] dir;
  CInt fov;
}

fn void Player.draw(Player* p, Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 18, 255, 18, 255);
  sdl::renderFillRectF(renderer, &&FRect{ p.pos.x, p.pos.y, PLAYER_SIZE, PLAYER_SIZE });
}

fn void Player.drawRay(Player* p, Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 0, 255, 18, 255);
  float px = p.pos.x;
  float py = p.pos.y;
  float dx = p.dir.x;
  float dy = p.dir.y;
  float length = math::sqrt(dx*dx + dy*dy);

  if (length < 1e-6f) {
    dx = 1.0f;
    dy = 0.0f;
    length = 1.0f;
  }

  dx /= length;
  dy /= length;

  float halfAngleRad = degToRad((float)(p.fov / 2.0));

  // We'll compute cos/sin once for +halfAngle, once for -halfAngle
  float cosPlus  = math::cos(+halfAngleRad);
  float sinPlus  = math::sin(+halfAngleRad);
  float cosMinus = math::cos(-halfAngleRad);
  float sinMinus = math::sin(-halfAngleRad);

  // 4) Rotate (dx, dy) by +halfAngle
  float r1x = dx * cosPlus  - dy * sinPlus;
  float r1y = dx * sinPlus  + dy * cosPlus;

  //    Rotate (dx, dy) by -halfAngle
  float r2x = dx * cosMinus - dy * sinMinus;
  float r2y = dx * sinMinus + dy * cosMinus;

  // 5) Choose some length to actually draw
  float drawLen = 800.0f;

  // Compute end-points for each line
  float x1 = px + drawLen * r1x;
  float y1 = py + drawLen * r1y;
  float x2 = px + drawLen * r2x;
  float y2 = py + drawLen * r2y;

  sdl::renderDrawLineF(renderer, p.pos.x + PLAYER_SIZE * 0.5, p.pos.y + PLAYER_SIZE * 0.5, x1, y1);
  sdl::renderDrawLineF(renderer, p.pos.x + PLAYER_SIZE * 0.5, p.pos.y + PLAYER_SIZE * 0.5, x2, y2);
}

fn float degToRad(float angle) {
  return ((angle) * math::PI / 180.0);
}
