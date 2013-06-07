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

        def self.get_state_char(val)
            if val == ZERO
                return '0'
            elsif val == ONE
                return '1'
            else
                raise RuntimeError, "get_state_char() called on Unset state"
            end
        end

        def get_char()
            return Cell.get_state_char(state)
        end
    end

    # A summary for a row or column.
    class RowSummary
        attr_reader :limit, :half_limit
        def initialize (limit)
            @limit = limit

            if (limit % 2 != 0)
                raise RuntimeError, "Limit must be even"
            end

            @half_limit = limit / 2

            @counts = {
                Cell::ZERO => 0,
                Cell::ONE => 0,
            }

            return
        end

        def get_count (value)
            return @counts[value]
        end

        def is_full(value)
            return (get_count(value) == half_limit())
        end

        def inc_count (value)
            new_val = (@counts[value] += 1)

            if (new_val > half_limit())
                raise GameIntegrityException, "Too many #{value}"
            end

            return
        end

        def are_both_not_exceeded()
            return (get_count(Cell::ZERO) <= half_limit() and
                    get_count(Cell::ONE) <= half_limit())
        end

        def are_both_full()
            return (is_full(Cell::ZERO) and is_full(Cell::ONE))
        end

        def find_full_value()
            if are_both_full()
                return nil
            elsif (is_full(Cell::ZERO))
                return Cell::ZERO
            elsif (is_full(Cell::ONE))
                return Cell::ONE
            else
                return nil
            end
        end

    end

    class Move
        attr_reader :coord, :dir, :reason, :val
        def initialize (params)
            @coord = params[:coord]
            @dir = params[:dir]
            @reason = params[:reason]
            @val = params[:val]
        end
    end

    class Board

        attr_reader :iters_quota, :num_iters_done

        def initialize (params)
            @dim_limits = {:x => params[:x], :y => params[:y]}
            @cells = dim_range(:y).map {
                dim_range(:x).map{ Cell.new }
            }
            @row_summaries = {
                :x => dim_range(:x).map { RowSummary.new(limit(:y)); },
                :y => dim_range(:y).map { RowSummary.new(limit(:x)); }
            }
            @complete_rows_map = {
                :x => Hash.new,
                :y => Hash.new
            }
            @old_moves = []
            @new_moves = []

            @iters_quota = 0
            @num_iters_done = 0

            @state = {:method_idx => 0, :view_idx => 0, :row_idx => 0, };

            return
        end

        def dim_range(dim)
            return (0 .. max_idx(dim))
        end

        def add_to_iters_quota(delta)
            @iters_quota += delta
        end

        def rotate_dir(dir)
            if dir == :x
                return :y
            else
                return :x
            end
        end

        def num_moves_done()
            return @new_moves.length
        end

        def flush_moves()
            @old_moves += @new_moves
            @new_moves = []

            return
        end

        def get_moves
            return @old_moves
        end

        def add_move(m)
            @new_moves.push(m)

            return
        end

        def get_new_move(idx)
            return @new_moves[idx]
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

        def list_views
            return [false, true].map { |v| get_view(:rotate => v) }
        end

        def set_cell_state(coord, state)
            _get_cell(coord).set_state(state)

            mymap = @complete_rows_map
            list_views().each do |v|
                row_dim = v.row_dim()
                real_row_dim = v.mapped_row_dim()
                row_idx = coord.method(real_row_dim).call()
                summary = v.get_row_summary(:dim => row_dim, :idx => row_idx)

                # puts "Coord = (x=#{coord.x},y=#{coord.y}) row_dim = #{row_dim} RowIdx = #{row_idx} mapped_row_dim = #{v.mapped_row_dim}"
                summary.inc_count(state)

                if summary.are_both_full() then
                    str = v.get_row_handle(row_idx).get_string()
                    mymap[real_row_dim][str] ||= []
                    arr = mymap[real_row_dim][str]
                    arr << row_idx
                    if (arr.length > 1) then
                        raise GameIntegrityException, "Duplicate rows at dim #{row_dim} #{arr.join(',')}"
                    end
                end
            end
            return
        end

        def get_cell_state(coord)
            return _get_cell(coord).state
        end

        # There is an equivalence between the dimensions, so
        # a view allows us to view the board rotated.
        def get_view(params)
            return Board_View.new(self, params[:rotate])
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

        def opposite_value(val)
            if (val == Cell::ZERO)
                return Cell::ONE
            elsif (val == Cell::ONE)
                return Cell::ZERO
            else
                raise RuntimeError, "'#{val}' must be zero or one."
            end
        end

        def try_to_solve_using (params)
            methods_list = params[:methods]
            views = list_views()

            catch :out_of_iters do
                first_iter = true

                while first_iter or num_moves_done() > 0
                    first_iter = false
                    flush_moves()
                    while (@state[:method_idx] < methods_list.length)
                        m = methods_list[@state[:method_idx]]
                        while (@state[:view_idx] < views.length)
                            v = views[@state[:view_idx]]
                            while (@state[:row_idx] <= v.max_idx(v.row_dim()))
                                row_idx = @state[:row_idx]
                                @state[:row_idx] += 1
                                v.method(m).call(:idx => row_idx)
                                @iters_quota -= 1
                                @num_iters_done += 1
                                if iters_quota == 0
                                    throw :out_of_iters
                                end
                            end
                            @state[:view_idx] += 1
                            @state[:row_idx] = 0
                        end
                        @state[:method_idx] += 1
                        @state[:view_idx] = 0
                    end
                    @state[:method_idx] = 0
                end
            end

            return
        end

        def as_string()
            return dim_range(:y).map { |y|
                ['|'] +
                    dim_range(:x).map { |x|
                    s = get_cell_state(
                        Coord.new(:y => y, :x => x)
                    )
                    ((s == Cell::UNKNOWN) ? ' ' : s.to_s())
                } +
                ["|\n"]
            }.inject([]) { |a,e| a+e }.join('')
        end

        def validate()
            is_final = true

            list_views().each do |v|
                view_final = v.validate_rows()
                is_final &&= view_final
            end

            if is_final
                return :final
            else
                return :non_final
            end
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

        def rotate_coord(coord)
            return coord.rotate
        end

        def _calc_mapped_item(item, rotation_method)
            if @rotation then
                return method(rotation_method).call(item)
            else
                return item
            end
        end

        def _calc_mapped_coord(coord)
            return _calc_mapped_item(coord, :rotate_coord)
        end

        def _calc_mapped_dir(dir)
            return _calc_mapped_item(dir, :rotate_dir)
        end

        def _get_cell(coord)
            return @board._get_cell(_calc_mapped_coord(coord))
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

        def mapped_row_dim()
            return _calc_mapped_dir(row_dim())
        end

        def get_row_handle(idx)
            return RowHandle.new(self, idx)
        end

        def _append_move(params)
            coord = params[:coord]
            dir = params[:dir]

            @board.add_move(
                Move.new(
                    # TODO : Extract a function for the coord rotation.
                    :coord => _calc_mapped_coord(coord),
                    :val => params[:val],
                    :reason => params[:reason],
                    :dir => _calc_mapped_dir(dir)
                )
            )

            return
        end

        def set_cell_state(coord, state)
            @board.set_cell_state(
                _calc_mapped_coord(coord), state
            )
        end

        def perform_and_append_move(params)
            set_cell_state( params[:coord], params[:val] )
            _append_move(params)
        end

        def check_and_handle_sequences_in_row(params)
            row_idx = params[:idx]

            row = get_row_handle(row_idx)

            prev_cell_states = []

            max_in_a_row = 2

            handle_prev_cell_states = lambda { |x|
                if prev_cell_states.length > max_in_a_row then
                    raise GameIntegrityException, "Too many #{prev_cell_states[0]} in a row"
                elsif (prev_cell_states.length == max_in_a_row)
                    coords = Array.new
                    start_x = x - max_in_a_row - 1;
                    if (start_x >= 0)
                        coords << row.get_coord(start_x)
                    end
                    if (x <= row.max_idx())
                        coords << row.get_coord(x)
                    end
                    coords.each do |c|
                        if (get_cell_state(c) == Cell::UNKNOWN)
                            perform_and_append_move(
                                :coord => c,
                                :val => opposite_value(prev_cell_states[0]),
                                :reason => "Vicinity to two in a row",
                                :dir => col_dim()
                            )
                        end
                    end
                end

                return
            }

            row.iter_of_handles().each do |h|
                 x = h.x
                 cell_state = h.get_cell.state

                 if cell_state == Cell::UNKNOWN
                     handle_prev_cell_states.call(x)
                     prev_cell_states = []
                 elsif ((prev_cell_states.length == 0) or
                        (prev_cell_states[-1] != cell_state)) then
                     handle_prev_cell_states.call(x)
                     prev_cell_states = [cell_state]
                 else
                     prev_cell_states << cell_state
                 end
            end
            handle_prev_cell_states.call(row.max_idx + 1)

            return
        end

        def check_and_handle_known_unknown_sameknown_in_row(params)
            row_idx = params[:idx]

            prev_cell_states = []

            max_in_a_row = 2

            row = get_row_handle(row_idx)

            (1 .. (row.max_idx - 1)).each do |x|

                get_coord = lambda { |offset| row.get_coord(x+offset); }
                get_state = lambda { |offset| row.get_state(x+offset); }

                if (get_state.call(-1) != Cell::UNKNOWN and
                    get_state.call(0) == Cell::UNKNOWN and
                    get_state.call(1) == get_state.call(-1))
                    then

                    perform_and_append_move(
                        :coord => get_coord.call(0),
                        :val => opposite_value(get_state.call(-1)),
                        :reason => "In between two identical cells",
                        :dir => col_dim()
                    )
                end

            end

            return
        end

        def check_and_handle_cells_of_one_value_in_row_were_all_found(params)
            row_idx = params[:idx]

            row = get_row_handle(row_idx)

            full_val = row.get_summary().find_full_value()

            if (full_val)
                opposite_val = opposite_value(full_val)

                row.iter_of_handles().each do |cell_h|
                    x = cell_h.x
                    cell = cell_h.get_cell

                    cell_state = cell.state

                    if cell_state == Cell::UNKNOWN
                        perform_and_append_move(
                            :coord => row.get_coord(x),
                            :val => opposite_val,
                            :reason => "Filling unknowns in row with an exceeded value with the other value",
                            :dir => col_dim()
                        )
                    end
                end
            end

            return
        end

        def check_exceeded_numbers_while_accounting_for_two_unknown_gaps(params)
            row_idx = params[:idx]

            row = get_row_handle(row_idx)

            gaps = {}

            next_gap = []

            add_gap = lambda {
                l = next_gap.length
                if (l > 0)
                    if not gaps[l]
                        gaps[l] = []
                    end
                    gaps[l] << next_gap
                    next_gap = []
                end
            }

            row.iter_of_handles().each do |cell_h|
                if (cell_h.get_state == Cell::UNKNOWN)
                    next_gap << cell_h.x
                else
                    add_gap.call()
                end
            end

            add_gap.call()

            if (gaps.has_key?(2)) then
                implicit_counts = {Cell::ZERO => 0, Cell::ONE => 0,}
                gaps[2].each do |gap|
                    x_s = []
                    if (gap[0] > 0)
                        x_s << gap[0]-1
                    end
                    if (gap[-1] < row.max_idx)
                        x_s << gap[-1]+1
                    end

                    bordering_values = {Cell::ZERO => 0, Cell::ONE => 0,}
                    x_s.each do |x|
                        bordering_values[row.get_state(x)] += 1
                    end

                    for v in [Cell::ZERO, Cell::ONE] do
                       if bordering_values[opposite_value(v)] > 0
                           implicit_counts[v] += 1
                       end
                    end
                end

                summ = row.get_summary()

                v = [Cell::ZERO, Cell::ONE].find {
                    |v| summ.get_count(v) + implicit_counts[v] \
                        == summ.half_limit()
                }

                if v then
                    gap_keys = gaps.keys.select { |x| x != 2 }
                    opposite_val = opposite_value(v)
                    gap_keys.each do |k|
                        gaps[k].each do |gap|
                            gap.each do |x|
                                perform_and_append_move(
                                    :coord => row.get_coord(x),
                                    :val => opposite_val,
                                    :reason => \
                                    "Analysis of gaps and their neighboring values",
                                    :dir => row.col_dim()
                                )
                            end
                        end
                    end
                end
            end
        end

        def _do_values_have_a_three_in_a_row(params)
            row_idx = params[:idx]
            v_s = params[:v_s]

            return {
                :verdict => ((0 .. (v_s.length - 3)).to_a.index { |i|
                    (1 .. 2).all? { |offset| v_s[i] == v_s[i+offset] }
                }),
                :reason => "Trying opposite value that is the last remaining results in three-in-a-row",
            }
        end

        def check_try_placing_last_of_certain_digit_in_row(params)
            row_idx = params[:idx]

            return _generic_check_try_placing_last_digit(
                :idx => row_idx,
                :callback_method => :_do_values_have_a_three_in_a_row,
            )
        end

        def _generic_check_try_placing_last_digit(params)
            row_idx = params[:idx]
            callback_method = params[:callback_method]

            row = get_row_handle(row_idx)

            summary = row.get_summary()

            v = [Cell::ZERO, Cell::ONE].find {
                |v| summary.get_count(v) == summary.half_limit() - 1
            }

            if not(v) then
                return
            end

            oppose_v = opposite_value(v)

            values = row.iter_of_states().to_a
            coords = row.where_values_are(Cell::UNKNOWN)

            coords_copy = Array.new(coords)

            for x in coords do
                v_s = Array.new(values)
                for x_to_fill in coords_copy do
                    v_s[x_to_fill] = ((x_to_fill == x) ? v : oppose_v)
                end

                # Is there a three in a row?
                result = method(callback_method).call(
                    :idx => row_idx, :v_s => v_s
                )

                if (result[:verdict])
                    perform_and_append_move(
                        :coord => row.get_coord(x),
                        :val => oppose_v,
                        :reason => result[:reason],
                        :dir => col_dim()
                    )
                    return
                end
            end

            return
        end

        def validate_rows()
            is_final = true

            dim_range(row_dim()).each do |row_idx|
                row = get_row_handle(row_idx)
                ret = row.validate(:foo => false)
                is_final &&= ret[:is_final]
            end

            return is_final
        end

        private :_do_values_have_a_three_in_a_row, :_generic_check_try_placing_last_digit
    end

    class RowHandle
        attr_reader :view, :idx
        def initialize (init_view, init_idx)
            @view = init_view
            @idx = init_idx
        end

        def get_summary()
            return view.get_row_summary(:idx => idx, :dim => row_dim());
        end

        def self.calc_iter_of_states_str(iter)
            return iter.map { |v| Cell.get_state_char(v) }.join('')
        end

        def get_string()
            return RowHandle.calc_iter_of_states_str(
                iter_of_handles().map { |cell_h| cell_h.get_state() }
            )
        end

        def col_dim()
            return view.col_dim()
        end

        def row_dim()
            return view.row_dim()
        end

        def max_idx()
            return view.max_idx(view.col_dim())
        end

        def get_coord(x)
            return Coord.new(col_dim() => x, row_dim() => idx)
        end

        def get_state(x)
            return view.get_cell_state(get_coord(x))
        end

        def get_cell(x)
            return view._get_cell(get_coord(x))
        end

        def iter
            return view.dim_range(col_dim()).map { |x|
                [x, get_cell(x)]
            }
        end

        def get_cell_handle(x)
            return CellHandle.new(self, x)
        end

        def iter_of_handles
            return view.dim_range(col_dim()).map { |x| get_cell_handle(x) }
        end

        def iter_of_states
            return iter_of_handles.map { |x| x.get_state() }
        end

        def where_values_are(v)
            return iter_of_handles.select { |x|
                x.get_state() == v }.map { |h| h.x }
        end

        def check_for_duplicated()
            summary = get_summary()

            if not summary.are_both_not_exceeded() then
                raise GameIntegrityException, "Value exceeded"
            elsif summary.are_both_full() then
                return true
            else
                return false
            end
        end


        def check_for_too_many_consecutive()
            count = 0
            prev_cell_state = Cell::UNKNOWN

            handle_seq = lambda {
                if ((prev_cell_state == Cell::ZERO) || \
                    (prev_cell_state == Cell::ONE)) then
                    if count > 2 then
                        raise GameIntegrityException, \
                            "Too many #{prev_cell_state} in a row"
                    end
                end
            }

            iter_of_handles().each do |cell_h|
                cell_state = cell_h.get_state
                if cell_state == prev_cell_state then
                    count += 1
                else
                    handle_seq.call()
                    count = 1
                    prev_cell_state = cell_state
                end
            end

            handle_seq.call()

            return
        end

        def validate(params)
            check_for_too_many_consecutive()

            return { :is_final => check_for_duplicated(), };
        end
    end

    class CellHandle

        attr_reader :row_handle, :x

        def initialize (row_handle, x)
            @row_handle = row_handle
            @x = x

            return
        end

        def get_coord()
            return row_handle.get_coord(x)
        end

        def get_state()
            return row_handle.get_state(x)
        end

        def get_cell()
            return row_handle.get_cell(x)
        end

        def get_char()
            return get_cell().get_char()
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

        board.dim_range(:y).each do |y|
            l = lines[y]
            if not l =~ /^\|[01 ]+\|$/
                raise RuntimeError, "Invalid format for line #{y+1}"
            end
            board.dim_range(:x).each do |x|
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

