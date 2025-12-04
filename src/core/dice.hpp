#ifndef _DICE_HPP_
#define _DICE_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/object.hpp>
#include <random>
//全局类，双陆棋给的骰子也就两个

class Dice : public godot::Object
{
	GDCLASS(Dice, godot::Object)
	public:
		int get_number();
		int next();
	private:
		std::mt19937_64 rng;
		int a;
		int b;
};

#endif