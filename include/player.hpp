#ifndef PLAYER_H_INCLUDED
#define PLAYER_H_INCLUDED

#include <glm/vec4.hpp>

class Player
{
  public:
    Player(glm::vec4 initial_position, float speed)
    {
        position = initial_position;
        speed = speed;
    }

    float getSpeed();
    glm::vec4 getPosition();
    void setPosition(glm::vec4 some_position);

  private:
    glm::vec4 position;
    float speed;
};

float Player::getSpeed()
{
    return speed;
}

glm::vec4 Player::getPosition()
{
    return position;
}

void Player::setPosition(glm::vec4 some_position)
{
    position = some_position;
}

#endif // PLAYER_H_INCLUDED