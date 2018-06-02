#ifndef SPOTLIGHT_H_INCLUDED
#define SPOTLIGHT_H_INCLUDED

#include <glm/vec4.hpp>

class Spotlight
{

  public:
    Spotlight(glm::vec4 initial_position, glm::vec4 down_offset, glm::vec4 left_offset, float inner_angle, float outer_angle)
    {
        position = initial_position;
        down_offset = down_offset;
        left_offset = left_offset;
        inner_angle = inner_angle;
        outer_angle = outer_angle;
    }

  private:
    // Spotlight position attributes
    glm::vec4 position;
    glm::vec4 down_offset;
    glm::vec4 left_offset;

    // Light angles
    float inner_angle;
    float outer_angle;
};

#endif // SPOTLIGHT_H_INCLUDED