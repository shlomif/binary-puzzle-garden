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

module Binary_Puzzle_Solver

    class Coords

        attr_reader :x, :y

        def initialize (params)
            @x = params[:x]
            @y = params[:y]

            return
        end

        def reverse
            return Coords.new(:x=>self.y,:y=>self.x)
        end

    end

    class Cell
        UNKNOWN = -1
        ZERO = 0
        ONE = 1

        VALID_STATES = {UNKNOWN => true, ZERO => true, ONE => true}

        attr_reader :state

        def initialize (params)
            @state = UNKNOWN
            if params.has_key?('state') then
                set_state(params[:state])
            end

            return
        end

        def set_state (new_state)
            if (not VALID_STATES.has_key?(new_state))
                raise RuntimeError("Invalid state " + new_state.to_s);
            end
            if (@state != UNKNOWN)
                raise RuntimeError("Cannot reassign a value to the already set state.")
            end
            @state = initial_state

            return
        end
    end

    class Board
        attr_reader :width, :height
        def initialize (params)
            @width = params[:width]
            @height = params[:height]
            @cells = (0 .. maxy()).map{ (0 .. maxx()).map{ Cell.new } }

            return
        end

        def maxx
            return width() - 1
        end

        def maxy
            return height() - 1
        end

        def _get_cell(coord)
            return @cells[coord.y][coord.x]
        end

        def set_cell_state(coord, state)
            _get_cell(coord).set_state(state)

            return
        end

        def get_cell_state(coord)
            return _get_cell(coord).state
        end
    end

    def gen_board_from_string_v1 (string)
        lines = string.lines.map { |l| l.chomp }
        line_lens = lines.map { |l| l.length }
        min_line_len = line_lens.min
        max_line_len = line_lens.max
        if (min_line_len != max_line_lin)
            raise RuntimeError("lines are not uniform in length")
        end
        width = min_line_len
        height = lines.length

        board = Board.new(:width => width, :height => height)

        (0 ... height).each do |y|
            (0 ... width).each do |x|
                c = lines[y][x]
                state = false
                if (c == '1')
                    state = Cell.ONE
                elsif (c == '0')
                    state = Cell.ZERO
                elsif (c != ' ')
                    raise RuntimeError("invalid character at line #{y+1} character #{x}")
                end

                if state
                    board.set_cell_state(Coord.new(:x => x, :y => y), state)
                end
            end
        end

        return board
    end
end

