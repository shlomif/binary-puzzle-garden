require 'fileutils'

lines = File.readlines('test/deduction.rb')

first = false

f = File.open('new_file.rb', 'w')
while l = lines.shift
    if (m = /^def get_(\w+)/.match(l))
        id = m[1]

        if not first ; then
            first = true
            f.write(<<'EOF')
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
EOF
            f.write("\n")
        end
        m = /^(\d+x\d+)_(easy|medium|hard|very_hard)_board_(\d+)__(\w+)$/.match(id)
        if not m
            raise "#{l} does not match."
        end

        size, difficulty, number, stage = m[1..4]

        l = lines.shift

        if not /^\s*input_str\s+=\s+<<'EOF'\s*$/.match(l)
            raise "input_str here-doc line = #{l}"
        end

        text = '';
        while l = lines.shift and /^\|[10 ]*\|$/.match(l) do
            text += l
        end

        # puts "Got #{text}"

        dir = "./test/data/boards/binarypuzzle.com/numbered/#{size}/#{difficulty}/#{number}";
        FileUtils.mkpath dir
        File.open("#{dir}/#{stage}.binpuz-board.txt", 'w').write(text)

        while l = lines.shift and !/^end\s*$/.match(l)
            true
        end
        f.write(%Q{def get_#{id}()\n    return get_binarypuzzle_com_numbered_puzzle(:size => "#{size}", :difficulty => "#{difficulty}", :number => "#{number}", :stage => "#{stage}");\nend\n})
    else
        f.write(l)
    end
end
