#include "dice.hpp"

int Dice::get_number()
{
    return a + b;
}

int Dice::next()
{
    a = rng() % 6;
    b = rng() % 6;
}
