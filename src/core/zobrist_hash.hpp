#ifndef _ZOBRIST_HASH_HPP_
#define _ZOBRIST_HASH_HPP_

#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/object.hpp>

class ZobristHash : public godot::Object
{
	GDCLASS(ZobristHash, Object)
	public:
		ZobristHash();  //随机数打表
		static ZobristHash *get_singleton();
		int64_t hash_piece(int _piece, int _by);
		void print_randomized();
		static void _bind_methods();
	private:
		static ZobristHash *singleton;
		//已知棋子是32位、位置是8位……
		//棋子只取小8位，总共16位
		int64_t randomized[65536];
};

#endif