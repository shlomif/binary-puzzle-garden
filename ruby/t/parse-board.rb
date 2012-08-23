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

describe "construct_board" do
    it "6*6 Easy board No. 1 should" do

        $ws = ' '
        input_str = <<"EOF"
|1  0  |
|  00 1|
| 00  1|
|      |
|00 1  |
| 1  00|
EOF

        board = Binary_Puzzle_Solver.gen_board_from_string_v1(input_str)

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

        input_str = <<'EOF'
|1  0  |
|  00 1|
| 00  1|
|      |
|00 1  |
| 1  00|
EOF

        board = Binary_Puzzle_Solver.gen_board_from_string_v1(input_str)

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
end
