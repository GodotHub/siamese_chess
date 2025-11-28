#ifndef _STATE_HPP_
#define _STATE_HPP_

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>

class State : public godot::RefCounted
{
	GDCLASS(State, RefCounted)
	public:
		class PieceIterator
		{
			public:
				void begin();
				void next();
				int piece();
				int pos();
				bool end();
			private:
				friend State;
				State *parent;
				uint64_t bit;
				int by;
		};
		State();
		godot::Ref<State> duplicate();
		PieceIterator piece_iterator_begin();
		godot::PackedInt32Array get_all_pieces();
		int get_piece(int _by);
		int has_piece(int _by);
		void add_piece(int _by, int _piece);
		void capture_piece(int _by);
		void move_piece(int _from, int _to);
		int64_t get_bit(int _piece);
		void set_bit(int _piece, int64_t _bit);
		godot::PackedInt32Array bit_index(int _piece);
		int get_turn();
		void set_turn(int _turn);
		int get_castle();
		void set_castle(int _castle);
		int get_en_passant();
		void set_en_passant(int _en_passant);
		int get_step_to_draw();
		void set_step_to_draw(int _step_to_draw);
		int get_round();
		void set_round(int _round);
		int get_king_passant();
		void set_king_passant(int _king_passant);
		int64_t get_zobrist();
		godot::String print_board();
		godot::String print_bit_square(int _piece);
		godot::String print_bit_diamond(int _piece);
		static void _bind_methods();
	private:
		int pieces[128] = {0};
		int64_t bit[128] = {0};
		//'*'表示所有棋子
		//'!'旋转90度后的棋盘
		//'('逆时针旋转45度的棋盘
		//')'顺时针旋转45度的棋盘
		int turn = 0;
		int castle = 0xF;
		int en_passant = -1;
		int step_to_draw = 0;
		int round = 1;
		int king_passant = -1;
		int front = 0;	//兵的前进方向，前八位为白方，后八位为黑方
		int64_t zobrist = 0;
};

#endif