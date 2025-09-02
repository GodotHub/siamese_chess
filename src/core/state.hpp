#ifndef _STATE_HPP_
#define _STATE_HPP_

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <generator>
#include <coroutine>

class State : public godot::RefCounted
{
	GDCLASS(State, RefCounted)
	public:
		State();
		godot::Ref<State> duplicate();
		std::generator<int> get_all_pieces_iterative();
		godot::PackedInt32Array get_all_pieces();
		godot::Array get_pieces_info();
		int get_piece(int _by);
		int has_piece(int _by);
		void add_piece(int _by, int _piece);
		void capture_piece(int _by);
		void move_piece(int _from, int _to);
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
		static void _bind_methods();
	private:
		int pieces[128];
		int turn;
		int castle;
		int en_passant;
		int step_to_draw;
		int round;
		int king_passant;
		int64_t zobrist = 0;
};

#endif