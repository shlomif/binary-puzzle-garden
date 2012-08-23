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

    class GameIntegrityException < RuntimeError
    end

    class Coord

        attr_reader :x, :y

        def initialize (params)
            @x = params[:x]
            @y = params[:y]

            return
        end

        def rotate
            return Coord.new(:x=>self.y,:y=>self.x)
        end

    end

    class Cell
        UNKNOWN = -1
        ZERO = 0
        ONE = 1

        VALID_STATES = {UNKNOWN => true, ZERO => true, ONE => true}

        attr_reader :state

        def initialize (params={})
            @state = UNKNOWN
            if params.has_key?('state') then
                set_state(params[:state])
            end

            return
        end

        def set_state (new_state)
            if (not VALID_STATES.has_key?(new_state))
                raise RuntimeError, "Invalid state " + new_state.to_s;
            end
            if (@state != UNKNOWN)
                raise RuntimeError, "Cannot reassign a value to the already set state."
            end
            @state = new_state

            return
        end
    end

    # A summary for a row or column.
    class RowSummary
        attr_reader :limit
        def initialize (limit)
            @limit = limit

            if (limit % 2 != 0)
                raise RuntimeError, "Limit must be even"
            end

            @counts = {
                Binary_Puzzle_Solver::Cell::ZERO => 0,
                Binary_Puzzle_Solver::Cell::ONE => 0,
            }

            return
        end

        def get_count (value)
            return @counts[value]
        end

        def inc_count (value)
            new_val = (@counts[value] += 1)

            if (new_val > limit()/2)
                raise GameIntegrityException, "Too many #{value}"
            end

            return
        end

    end

    class Board
        attr_reader :num_moves_done
        def initialize (params)
            @dim_limits = {:x => params[:x], :y => params[:y]}
            @cells = (0 .. max_idx(:y)).map {
                (0 .. max_idx(:x)).map{ Cell.new }
            }
            @row_summaries = {
                :x => (0 .. max_idx(:x)).map { RowSummary.new(limit(:y)); },
                :y => (0 .. max_idx(:y)).map { RowSummary.new(limit(:x)); }
            }
            flush_moves()
            return
        end

        def flush_moves()
            @num_moves_done = 0
        end

        def increment_num_moves_done()
            @num_moves_done += 1
        end

        def limit(dim)
            return @dim_limits[dim]
        end

        def max_idx(dim)
            return limit(dim) - 1
        end

        def _get_cell(coord)

            x = coord.x
            y = coord.y

            if (y < 0)
                raise RuntimeError, "y cannot be lower than 0."
            end

            if (x < 0)
                raise RuntimeError, "x cannot be lower than 0."
            end

            if (y > max_idx(:y))
                raise RuntimeError, "y cannot be higher than max_idx."
            end

            if (x > max_idx(:x))
                raise RuntimeError, "x cannot be higher than max_idx."
            end

            return @cells[y][x]
        end

        def set_cell_state(coord, state)
            _get_cell(coord).set_state(state)
            get_row_summary(:dim => :x, :idx => coord.x).inc_count(state)
            get_row_summary(:dim => :y, :idx => coord.y).inc_count(state)
            return
        end

        def get_cell_state(coord)
            return _get_cell(coord).state
        end

        # There is an equivalence between the dimensions, so
        # a view allows us to view the board rotated.
        def get_view(params)
            return Binary_Puzzle_Solver::Board_View.new(self, params[:rotate])
        end

        def get_row_summary(params)
            idx = params[:idx]
            dim = params[:dim]

            if (idx < 0)
                raise RuntimeError, "idx cannot be lower than 0."
            end
            if (idx > max_idx(dim))
                raise RuntimeError, "idx cannot be higher than max_idx."
            end
            return @row_summaries[dim][idx]
        end
    end

    class Board_View < Board
        def initialize (board, rotation)
            @board = board
            @rotation = rotation
            if rotation
                @dims_map = {:x => :y, :y => :x}
            else
                @dims_map = {:x => :x, :y => :y}
            end

            return
        end

        def _get_cell(coord)
            return @board._get_cell(
                if @rotation then coord.rotate else coord end
            )
        end

        def limit(dim)
            return @board.limit(@dims_map[dim])
        end

        def get_row_summary(params)
            return @board.get_row_summary(
                :idx => params[:idx],
                :dim => @dims_map[params[:dim]]
            )
        end

        def row_dim()
            return :y
        end

        def col_dim()
            return :x
        end

        def check_and_handle_sequences_in_row(params)
            row_idx = params[:idx]

            prev_cell_states = []

            max_in_a_row = 2

            handle_prev_cell_states = lambda { |x|
                if prev_cell_states.length > max_in_a_row then
                    raise GameIntegrityException, "Too many #{prev_cell_states[0]} in a row"
                elsif (prev_cell_states.length == max_in_a_row)
                    coords = Array.new
                    start_x = x - max_in_a_row - 1;
                    if (start_x >= 0)
                        coords.push(Binary_Puzzle_Solver::Coord.new(
                            col_dim() => start_x, row_dim() => row_idx
                        ))
                    end
                    if (x < max_idx(col_dim()))
                        coords.push(Binary_Puzzle_Solver::Coord.new(
                            col_dim() => x, row_dim() => row_idx
                        ))
                    end
                    coords.each do |c|
                        if (get_cell_state(c) == Binary_Puzzle_Solver::Cell::UNKNOWN)
                            # TODO : Add a suitable "move" or "deduction"
                            # object to the queue.
                            new_value =
                               if prev_cell_states[0] == Binary_Puzzle_Solver::Cell::ZERO then
                                   Binary_Puzzle_Solver::Cell::ONE
                               else
                                   Binary_Puzzle_Solver::Cell::ZERO
                               end
                            set_cell_state(c, new_value);
                            @board.increment_num_moves_done()
                            #append_move(
                            #    :coord => c,
                            #    :val => new_value,
                            #    :reason => "Vicinity to two in a row",
                            #)
                        end
                    end
                end

                return
            }

            (0 .. max_idx(col_dim())).each do |x|
                 coord = Binary_Puzzle_Solver::Coord.new(
                     col_dim() => x, row_dim() => row_idx
                 )
                 cell_state = get_cell_state(coord)

                 if cell_state == Binary_Puzzle_Solver::Cell::UNKNOWN
                     handle_prev_cell_states.call(x)
                     prev_cell_states = []
                 elsif ((prev_cell_states.length == 0) or (prev_cell_states[-1] != cell_state)) then
                     handle_prev_cell_states.call(x)
                     prev_cell_states = [cell_state]
                 else
                     prev_cell_states << cell_state
                 end
            end
            handle_prev_cell_states.call(max_idx(col_dim()) + 1)

            return
        end

    end

    def Binary_Puzzle_Solver.gen_board_from_string_v1(string)
        lines = string.lines.map { |l| l.chomp }
        line_lens = lines.map { |l| l.length }
        min_line_len = line_lens.min
        max_line_len = line_lens.max
        if (min_line_len != max_line_len)
            raise RuntimeError, "lines are not uniform in length"
        end
        width = min_line_len - 2
        height = lines.length

        board = Board.new(:x => width, :y => height)

        (0 ... height).each do |y|
            l = lines[y]
            if not l =~ /^\|[01 ]+\|$/
                raise RuntimeError, "Invalid format for line #{y+1}"
            end
            (0 ... width).each do |x|
                c = l[x+1,1]
                state = false
                if (c == '1')
                    state = Cell::ONE
                elsif (c == '0')
                    state = Cell::ZERO
                end

                if state
                    board.set_cell_state(Coord.new(:x => x, :y => y), state)
                end
            end
        end

        return board
    end
end

