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

require 'ruby-debug'
require "binary_puzzle_solver.rb"

class Object
    def ok()
        self.should == true
    end
    def not_ok()
        self.should == false
    end
end

def get_6x6_easy_board_1()
    input_str = <<'EOF'
|1  0  |
|  00 1|
| 00  1|
|      |
|00 1  |
| 1  00|
EOF
    return Binary_Puzzle_Solver.gen_board_from_string_v1(input_str)
end

def get_6x6_easy_board_1__intermediate_board()
    str = <<'EOF'
|101010|
|010011|
|100101|
|011010|
|001101|
|110100|
EOF
    return Binary_Puzzle_Solver.gen_board_from_string_v1(str)
end

describe "construct_board" do
    it "6*6 Easy board No. 1 should" do

        board = get_6x6_easy_board_1()

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

        board = get_6x6_easy_board_1()

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

        board = get_6x6_easy_board_1()

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

        board = get_6x6_easy_board_1()

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

        board = get_6x6_easy_board_1()

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

        board = get_6x6_easy_board_1()

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

        board = get_6x6_easy_board_1()

        board.add_to_iters_quota(1_000_000_000);

        board.try_to_solve_using(
            :methods => [
                :check_and_handle_sequences_in_row,
                :check_and_handle_known_unknown_sameknown_in_row,
            ]
        );

        good_num_iters = board.num_iters_done()

        final_board = get_6x6_easy_board_1__intermediate_board()

        (0 .. board.max_idx(:y)).each do |y|
            (0 .. board.max_idx(:x)).each do |x|
                coord = Binary_Puzzle_Solver::Coord.new(:x => x, :y => y)
                board.get_cell_state(coord).should == final_board.get_cell_state(coord)
            end
        end

        resume_board = get_6x6_easy_board_1()

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

end
