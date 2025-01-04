module player;

import std::math;
import sdl;

const CInt PLAYER_SIZE = 8;

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
  float angle = degToRad(p.fov);
  float x = (double)math::cos(angle);
  float y = (double)math::sin(angle);
  // how the f*ck can I do that?
  float[<2>] next = { x, y };
  sdl::renderDrawLineF(
    renderer,
    p.pos.x + PLAYER_SIZE * 0.5,
    p.pos.y + PLAYER_SIZE * 0.5,
    next.x,
    next.y
  );
}

fn float degToRad(float angle) {
  return ((angle) * math::PI / 180.0);
}
