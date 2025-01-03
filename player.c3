module player;

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

fn void Player.renderFov(Player* p) {
}
