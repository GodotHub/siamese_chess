#ifndef _STATE_HPP_
#define _STATE_HPP_

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <unordered_map>

class State;

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
		int by;
};

class State : public godot::RefCounted
{
	GDCLASS(State, RefCounted)
	public:
		State();
		godot::Ref<State> duplicate();
		PieceIterator piece_iterator_begin();
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
		void change_score(int delta);
		int64_t get_zobrist();
		int has_history(int64_t _zobrist);
		void push_history(int64_t _zobrist);
		int get_relative_score(int _group);
		static void _bind_methods();
	private:
		friend PieceIterator;
		int pieces[128];
		int turn;
		int castle;
		int en_passant;
		int step_to_draw;
		int round;
		int king_passant;
		std::unordered_map<int64_t, int> history;
		int64_t zobrist = 0;
		int score = 0;
};

#endif