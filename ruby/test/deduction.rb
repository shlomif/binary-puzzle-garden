# Copyright (c) 2012 Shlomi Fish
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# ----------------------------------------------------------------------------
#
# This is the MIT/X11 Licence. For more information see:
#
# 1. http://www.opensource.org/licenses/mit-license.php
#
# 2. http://en.wikipedia.org/wiki/MIT_License

require "binary_puzzle_solver.rb"
require "rspec"
require "pry"

class Object
    def ok()
        self.should == true
    end
    def not_ok()
        self.should == false
    end
end

def compare_boards(got, expected)
    got.max_idx(:x).should == expected.max_idx(:x)
    got.max_idx(:y).should == expected.max_idx(:y)

    (0 .. got.max_idx(:y)).each do |y|
        (0 .. got.max_idx(:x)).each do |x|
            coord = Binary_Puzzle_Solver::Coord.new(:x => x, :y => y)
            begin
            got.get_cell_state(coord).should == expected.get_cell_state(coord)
            rescue
                puts "Wrong coord in x=#{x} y=#{y}"
                puts "Got ==\n#{got.as_string()}\n"
                puts "Expected ==\n#{expected.as_string()}\n"
                raise
            end
        end
    end

    return
end

def get_binarypuzzle_com_numbered_puzzle(params)
    return Binary_Puzzle_Solver.gen_board_from_string_v1(
        IO.read(
            File.join(
                'test', 'data', 'boards', 'binarypuzzle.com', 'numbered',
                params[:size],
                params[:difficulty],
                params[:number],
                "#{params[:stage]}.binpuz-board.txt"
            )
        )
    )
end

def get_6x6_easy_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "easy", :number => "1", :stage => "initial");
end

def get_6x6_easy_board_1__intermediate_1()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "easy", :number => "1", :stage => "intermediate_1");
end

def get_6x6_easy_board_2__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "easy", :number => "2", :stage => "initial");
end

def get_6x6_easy_board_2__intermediate_1()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "easy", :number => "2", :stage => "intermediate_1");
end

def get_6x6_medium_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "medium", :number => "1", :stage => "initial");
end

def get_6x6_medium_board_1__after_easy_moves()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "medium", :number => "1", :stage => "after_easy_moves");
end

def get_6x6_medium_board_1__after_cells_of_one_value_in_row_were_all_found()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "medium", :number => "1", :stage => "after_cells_of_one_value_in_row_were_all_found");
end

def get_6x6_medium_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "medium", :number => "1", :stage => "final");
end

def get_8x8_easy_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "8x8", :difficulty => "easy", :number => "1", :stage => "initial");
end

def get_8x8_easy_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "8x8", :difficulty => "easy", :number => "1", :stage => "final");
end

def get_8x8_medium_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "8x8", :difficulty => "medium", :number => "1", :stage => "initial");
end

def get_8x8_medium_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "8x8", :difficulty => "medium", :number => "1", :stage => "final");
end

def get_6x6_hard_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "1", :stage => "initial");
end

def get_6x6_hard_board_1__intermediate()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "1", :stage => "intermediate");
end

def get_6x6_hard_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "1", :stage => "final");
end

def get_6x6_hard_board_2__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "2", :stage => "initial");
end

def get_6x6_hard_board_2__intermediate()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "2", :stage => "intermediate");
end

def get_6x6_hard_board_2__intermediate_2()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "2", :stage => "intermediate_2");
end

def get_6x6_hard_board_3__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "3", :stage => "initial");
end

def get_6x6_hard_board_3__intermediate()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "hard", :number => "3", :stage => "intermediate");
end

def get_10x10_easy_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "10x10", :difficulty => "easy", :number => "1", :stage => "initial");
end

def get_10x10_easy_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "10x10", :difficulty => "easy", :number => "1", :stage => "final");
end


def get_10x10_hard_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "10x10", :difficulty => "hard", :number => "1", :stage => "initial");
end

def get_10x10_hard_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "10x10", :difficulty => "hard", :number => "1", :stage => "final");
end

def get_10x10_hard_board_2__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "10x10", :difficulty => "hard", :number => "2", :stage => "initial");
end

def get_10x10_hard_board_2__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "10x10", :difficulty => "hard", :number => "2", :stage => "final");
end

def get_12x12_hard_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "12x12", :difficulty => "hard", :number => "1", :stage => "initial");
end

def get_12x12_hard_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "12x12", :difficulty => "hard", :number => "1", :stage => "final");
end

def get_6x6_very_hard_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "very_hard", :number => "1", :stage => "initial");
end

def get_6x6_very_hard_board_1__intermediate_1()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "very_hard", :number => "1", :stage => "intermediate_1");
end

def get_6x6_very_hard_board_1__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "very_hard", :number => "1", :stage => "final");
end

def get_6x6_very_hard_board_2__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "very_hard", :number => "2", :stage => "initial");
end

def get_6x6_very_hard_board_2__final()
    return get_binarypuzzle_com_numbered_puzzle(:size => "6x6", :difficulty => "very_hard", :number => "2", :stage => "final");
end

def get_12x12_very_hard_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "12x12", :difficulty => "very_hard", :number => "1", :stage => "initial");
end

def get_12x12_very_hard_board_1__intermediate_1()
    return get_binarypuzzle_com_numbered_puzzle(:size => "12x12", :difficulty => "very_hard", :number => "1", :stage => "intermediate_1");
end

def get_14x14_very_hard_board_1__initial()
    return get_binarypuzzle_com_numbered_puzzle(:size => "14x14", :difficulty => "very_hard", :number => "1", :stage => "initial");
end

def get_14x14_very_hard_board_1__intermediate_1()
    return get_binarypuzzle_com_numbered_puzzle(:size => "14x14", :difficulty => "very_hard", :number => "1", :stage => "intermediate_1");
end

def get_14x14_very_hard_board_1__intermediate_2()
    return get_binarypuzzle_com_numbered_puzzle(:size => "14x14", :difficulty => "very_hard", :number => "1", :stage => "intermediate_2");
end

describe "construct_board" do
    it "6*6 Easy board No. 1 should" do

        board = get_6x6_easy_board_1__initial()

        ONE = Binary_Puzzle_Solver::Cell::ONE
        ZERO = Binary_Puzzle_Solver::Cell::ZERO
        UNKNOWN = Binary_Puzzle_Solver::Cell::UNKNOWN

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 0, :y => 0)
        ).should == ONE
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 3, :y => 0)
        ).should == ZERO
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 1, :y => 0)
        ).should == UNKNOWN
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 2, :y => 1)
        ).should == ZERO
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 5, :y => 1)
        ).should == ONE

        # Check for dimensions of the board.
        board.limit(:y).should == 6
        board.limit(:x).should == 6
        board.max_idx(:y).should == 5
        board.max_idx(:x).should == 5

        view = board.get_view(:rotate => false)

        view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 0, :y => 0)
        ).should == ONE
        view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 3, :y => 0)
        ).should == ZERO
        view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 1, :y => 0)
        ).should == UNKNOWN
        view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 2, :y => 1)
        ).should == ZERO
        view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 5, :y => 1)
        ).should == ONE

        view.get_row_summary(:dim => :x, :idx => 3
        ).get_count(ONE).should == 1
        view.get_row_summary(:dim => :x, :idx => 3
        ).get_count(ZERO).should == 2
        view.get_row_summary(:dim => :x, :idx => 0
        ).get_count(ONE).should == 1
        view.get_row_summary(:dim => :x, :idx => 0
        ).get_count(ZERO).should == 1
        view.get_row_summary(:dim => :y, :idx => 1
        ).get_count(ZERO).should == 2
        view.get_row_summary(:dim => :y, :idx => 1
        ).get_count(ONE).should == 1

        # Check for dimensions of the view.
        view.limit(:y).should == 6
        view.limit(:x).should == 6
        view.max_idx(:y).should == 5
        view.max_idx(:x).should == 5

        rotated_view = board.get_view(:rotate => true)

        rotated_view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:y => 0, :x => 0)
        ).should == ONE
        rotated_view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:y => 3, :x => 0)
        ).should == ZERO
        rotated_view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:y => 1, :x => 0)
        ).should == UNKNOWN
        rotated_view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:y => 2, :x => 1)
        ).should == ZERO
        rotated_view.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:y => 5, :x => 1)
        ).should == ONE

        # Check for dimensions of the rotated_view.
        rotated_view.limit(:y).should == 6
        rotated_view.limit(:x).should == 6
        rotated_view.max_idx(:y).should == 5
        rotated_view.max_idx(:x).should == 5

    end
end

describe "rudimentary_deduction" do
    it "6*6 Easy board No. 1 should" do

        board = get_6x6_easy_board_1__initial()

        # ONE = Binary_Puzzle_Solver::Cell::ONE
        # ZERO = Binary_Puzzle_Solver::Cell::ZERO
        # UNKNOWN = Binary_Puzzle_Solver::Cell::UNKNOWN

        view = board.get_view(:rotate => false)
        view.check_and_handle_sequences_in_row(:idx => 1)

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 1, :y => 1)
        ).should == ONE
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 4, :y => 1)
        ).should == ONE

        board.num_moves_done.should == 2

    end

    it "6*6 Easy board No. 1 should" do

        board = get_6x6_easy_board_1__initial()

        view = board.get_view(:rotate => true)
        view.check_and_handle_sequences_in_row(:idx => 5)

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 5, :y => 0)
        ).should == ZERO
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 5, :y => 3)
        ).should == ZERO

        board.num_moves_done.should == 2

    end

    it "6*6 Easy board No. 1 should flush moves properly" do

        board = get_6x6_easy_board_1__initial()

        # ONE = Binary_Puzzle_Solver::Cell::ONE
        # ZERO = Binary_Puzzle_Solver::Cell::ZERO
        # UNKNOWN = Binary_Puzzle_Solver::Cell::UNKNOWN

        view = board.get_view(:rotate => false)
        view.check_and_handle_sequences_in_row(:idx => 1)

        board.flush_moves()

        view = board.get_view(:rotate => true)
        view.check_and_handle_sequences_in_row(:idx => 5)

        # Checking that the moves were flushed.
        board.num_moves_done.should == 2

    end

    it "6*6 Easy board No. 1 should" do

        board = get_6x6_easy_board_1__initial()

        # ONE = Binary_Puzzle_Solver::Cell::ONE
        # ZERO = Binary_Puzzle_Solver::Cell::ZERO
        # UNKNOWN = Binary_Puzzle_Solver::Cell::UNKNOWN

        view = board.get_view(:rotate => false)
        view.check_and_handle_sequences_in_row(:idx => 1)

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 1, :y => 1)
        ).should == ONE
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 4, :y => 1)
        ).should == ONE

        board.num_moves_done.should == 2

        m = board.get_new_move(0)

        # Move has (x=1,y=1) coordinate.
        m.coord.x.should == 1
        m.coord.y.should == 1
        m.dir.should == :x
        m.val.should == ONE

        m = board.get_new_move(1)

        # Move has (x=1,y=1) coordinate.
        m.coord.x.should == 4
        m.coord.y.should == 1
        m.dir.should == :x
        m.val.should == ONE

    end

    it "6*6 Easy board No. 1 should" do

        board = get_6x6_easy_board_1__initial()

        # ONE = Binary_Puzzle_Solver::Cell::ONE
        # ZERO = Binary_Puzzle_Solver::Cell::ZERO
        # UNKNOWN = Binary_Puzzle_Solver::Cell::UNKNOWN

        view = board.get_view(:rotate => true)
        view.check_and_handle_known_unknown_sameknown_in_row(:idx => 1)

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 1, :y => 3)
        ).should == ONE

        board.num_moves_done.should == 1

        m = board.get_new_move(0)

        # Move has (x=1,y=1) coordinate.
        m.coord.x.should == 1
        m.coord.y.should == 3
        m.dir.should == :y
        m.val.should == ONE

    end

    it "6*6 Easy process should" do

        board = get_6x6_easy_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
            ]
        );

        good_num_iters = board.num_iters_done()

        final_board = get_6x6_easy_board_1__intermediate_1()

        compare_boards(board, final_board)

        resume_board = get_6x6_easy_board_1__initial()

        resume_board.add_to_iters_quota(10);

        resume_board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
            ]
        );

        resume_board.add_to_iters_quota(1_000_000_000)

        resume_board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
            ]
        );

        resume_board.num_iters_done.should == good_num_iters
    end

    it "Solving 6*6 Easy board No. 2 should" do

        board = get_6x6_easy_board_2__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
            ]
        );

        final_board = get_6x6_easy_board_2__intermediate_1()

        compare_boards(board, final_board)
    end

    it "Solving 6*6 Medium board No. 1 should" do

        board = get_6x6_medium_board_1__initial()

        board.validate().should == :non_final

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
            ]
        );

        first_intermediate_board = get_6x6_medium_board_1__after_easy_moves()

        compare_boards(board, first_intermediate_board)

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
            ]
        )

        second_intermediate_board = get_6x6_medium_board_1__after_cells_of_one_value_in_row_were_all_found()

        compare_boards(board, second_intermediate_board)

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
            ]
        )

        final_board = get_6x6_medium_board_1__final()

        compare_boards(board, final_board)

        board.validate().should == :final
    end

    it "Solving 8*8 Easy board No. 1 should" do

        board = get_8x8_easy_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
            ]
        );

        final_board = get_8x8_easy_board_1__final()

        compare_boards(board, final_board)
    end

    it "Solving 8*8 Medium board No. 1 should" do

        board = get_8x8_medium_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
            ]
        );

        final_board = get_8x8_medium_board_1__final()

        # binding.pry
        compare_boards(board, final_board)
    end

    it "Solving 6*6 Hard board No. 1 should" do

        board = get_6x6_hard_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
            ]
        );

        intermediate_board = get_6x6_hard_board_1__intermediate();

        # binding.pry
        compare_boards(board, intermediate_board)

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
            ]
        );

        intermediate_board_2 = get_6x6_hard_board_1__final();

        # binding.pry
        compare_boards(board, intermediate_board_2)
    end

    it "Solving 6*6 Hard board No. 2 should" do

        board = get_6x6_hard_board_2__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
            ]
        );

        intermediate_board = get_6x6_hard_board_2__intermediate();

        # binding.pry
        compare_boards(board, intermediate_board)

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        )

        final_board = get_6x6_hard_board_2__intermediate_2();

        # binding.pry
        compare_boards(board, final_board)
    end

    it "Solving 6*6 Hard board No. 3 should" do

        board = get_6x6_hard_board_3__initial()

        board.add_to_iters_quota(1_000_000_000);

        # binding.pry
        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        )

        intermediate_board = get_6x6_hard_board_3__intermediate()
        # binding.pry

        compare_boards(board, intermediate_board)
    end

    it "Solving 10*10 Easy board No. 1 should" do

        board = get_10x10_easy_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        );

        final_board = get_10x10_easy_board_1__final()

        compare_boards(board, final_board)
    end

    it "Solving 10*10 Hard board No. 1 should" do

        board = get_10x10_hard_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        );

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 9, :y => 1)
        ).should == ONE

        final_board = get_10x10_hard_board_1__final()

        # binding.pry

        compare_boards(board, final_board)
    end

    it "Solving 10*10 Hard board No. 2 should" do

        board = get_10x10_hard_board_2__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        );

        final_board = get_10x10_hard_board_2__final()

        # binding.pry

        compare_boards(board, final_board)
    end

    it "Solving 12*12 Hard board No. 1 should" do

        board = get_12x12_hard_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        );

        final_board = get_12x12_hard_board_1__final()

        # binding.pry

        compare_boards(board, final_board)
    end

    it "Solving 6*6 Very Hard board No. 1 should" do

        board = get_6x6_very_hard_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
            ]
        );

        intermediate_board = get_6x6_very_hard_board_1__intermediate_1()

        # binding.pry

        compare_boards(board, intermediate_board)

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
                :check_try_placing_last_of_certain_digit_in_row_to_avoid_dups,
            ]
        );

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 1, :y => 3)
        ).should == ONE
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 2, :y => 3)
        ).should == ZERO

        final_board = get_6x6_very_hard_board_1__final()

        compare_boards(board, final_board)
    end

    it "Solving 6*6 Very Hard board No. 2 should" do

        board = get_6x6_very_hard_board_2__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
                :check_try_placing_last_of_certain_digit_in_row_to_avoid_dups,
            ]
        );

        final_board = get_6x6_very_hard_board_2__final()

        # binding.pry

        compare_boards(board, final_board)
    end

    it "Solving 12*12 Very Hard board No. 1 should" do

        board = get_12x12_very_hard_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
                :check_try_placing_last_of_certain_digit_in_row_to_avoid_dups,
            ]
        );

        final_board = get_12x12_very_hard_board_1__intermediate_1()

        # binding.pry

        compare_boards(board, final_board)
    end

    it "Solving 14*14 Very Hard board No. 1 should" do

        board = get_14x14_very_hard_board_1__initial()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
                :check_try_placing_last_of_certain_digit_in_row_to_avoid_dups,
            ]
        );

        intermediate_board = get_14x14_very_hard_board_1__intermediate_1()

        # binding.pry

        compare_boards(board, intermediate_board)

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
                :check_and_handle_cells_of_one_value_in_row_were_all_found,
                :check_exceeded_numbers_while_accounting_for_two_unknown_gaps,
                :check_try_placing_last_of_certain_digit_in_row,
                :check_try_placing_last_of_certain_digit_in_row_to_avoid_dups,
                :check_remaining_gap_of_three_with_implicits,
            ]
        );

        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 4, :y => 5)
        ).should == ONE
        board.get_cell_state(
            Binary_Puzzle_Solver::Coord.new(:x => 6, :y => 5)
        ).should == ONE

        intermediate_board = get_14x14_very_hard_board_1__intermediate_2()

        compare_boards(board, intermediate_board)
    end
end
