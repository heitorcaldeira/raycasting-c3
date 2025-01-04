module player;

import std::math;
import sdl;

const CInt PLAYER_SIZE = 8;

struct Player {
  float[<2>] pos;
  float[<2>] dir;
  float fov;
}

fn void Player.draw(Player* p, Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 18, 255, 18, 255);
  sdl::renderFillRectF(renderer, &&FRect{ p.pos.x, p.pos.y, PLAYER_SIZE, PLAYER_SIZE });
}

fn void Player.drawRay(Player* p, Renderer* renderer) {
  sdl::setRenderDrawColor(renderer, 255, 0, 18, 255);
  float[<2>] l = p.dir;

  sdl::renderDrawLineF(
    renderer,
    p.pos.x + PLAYER_SIZE * 0.5,
    p.pos.y + PLAYER_SIZE * 0.5,
    p.pos.x + l.x * 5,
    p.pos.y + l.y * 5
  );
}

fn float degToRad(float angle) {
  return ((angle) * math::PI / 180.0);
}
