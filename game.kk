import std/os/readline
fun flatten(grid : list<list<char>>) : list<char> {
    match grid {
        Nil -> Nil
        Cons(x : list<char>, xs : list<list<char>>) -> x ++ xs.flatten()
    }
}

fun char(c: maybe<char>) : exn char {
    match c {
        Nothing -> throw("Invalid character")
        Just(chr) -> chr
    }
}

fun unwrap(value : maybe<a>) : exn a {
    match value {
        Nothing -> throw("Value was Nothing")
        Just(x) -> x
    }
}

struct coord 
    x: int
    y: int

fun show(c : coord) : string {
    "(" ++ c.x.show() ++ ", " ++ c.y.show() ++ ")"
}

fun member(x : coord, xs : list<coord>) : bool {
    match xs {
        Nil -> False
        Cons(y, ys) -> x == y || member(x, ys)
    }
}

fun (==)(c1 : coord, c2 : coord) : bool {
    c1.x == c2.x && c1.y == c2.y
}

fun parse(str : string, moves : list<coord>) : <console, exn|_e>coord {
    match str.list() {
        Cons('0', Cons(' ', Cons('0', Nil))) -> Coord(0,0)
        Cons('0', Cons(' ', Cons('1', Nil))) -> Coord(0,1)
        Cons('0', Cons(' ', Cons('2', Nil))) -> Coord(0,2)
        Cons('1', Cons(' ', Cons('0', Nil))) -> Coord(1,0)
        Cons('1', Cons(' ', Cons('1', Nil))) -> Coord(1,1)
        Cons('1', Cons(' ', Cons('2', Nil))) -> Coord(1,2)
        Cons('2', Cons(' ', Cons('0', Nil))) -> Coord(2,0)
        Cons('2', Cons(' ', Cons('1', Nil))) -> Coord(2,1)
        Cons('2', Cons(' ', Cons('2', Nil))) -> Coord(2,2)
        _ -> {
            println("Invalid move, please try again")
            gen_move(moves)
        }
    }
}

fun gen_move(moves : list<coord>) : <console, exn|_e> coord {
    val move : coord = parse(readline(), moves)

    if moves.any() fn (c : coord) { c == move } {
        println("Invalid move, please try again")
        gen_move(moves)
    } else {
        move
    }
    
}

fun create-board() : list<list<char>> {
    [['.','.','.'],['.','.','.'],['.','.','.']]
}

fun get_board_position(board : list<list<char>>, coord : coord) : maybe<char> {
    match board[coord.y] {
        Nothing -> Nothing
        Just(row) -> row[coord.x]
    }
}

fun draw_board (grid : list<list<char>>) {
    grid.foreach() fn (row : list<char>) {
        row.foreach() fn (c : char) {
            print(c)
        }
        print("\n")
    }
}

fun mark_board(board : list<list<char>>, coord : coord, mark : char) : <exn> list<list<char>> {
    var new_row : list<char> := match board[coord.y] {
        Nothing -> throw("Invalid coordinate: " ++ coord.show())
        Just(row) -> row.take(coord.x) ++ [mark] ++ row.drop(coord.x + 1)
    }
    board.take(coord.y) ++ [new_row] ++ board.drop(coord.y + 1)
}

fun check_full(board : list<list<char>>) : bool {
    var full : bool := True
    board.foreach() fn (row : list<char>) {
        match row.find() fn (c :char) {
            match c {
                '.' -> True
                _ -> False
            }
        }{
            Just(_) -> full := False
            Nothing -> full := full
        }
    }
    full
}

fun check_win(board : list<list<char>>, mark : char) : <div, exn|_e> bool {
    var win : bool := False
    var i : int := 0
    while {i < 3} {
        if board.get_board_position(Coord(i,0)).unwrap() == mark && board.get_board_position(Coord(i,1)).unwrap() == mark && board.get_board_position(Coord(i,2)).unwrap() == mark {
            win := True
        }
        if board.get_board_position(Coord(0,i)).unwrap() == mark && board.get_board_position(Coord(1,i)).unwrap() == mark && board.get_board_position(Coord(2,i)).unwrap() == mark {
            win := True
        }
        i := i + 1
    }
    if board.get_board_position(Coord(0,0)).unwrap() == mark && board.get_board_position(Coord(1,1)).unwrap() == mark && board.get_board_position(Coord(2,2)).unwrap() == mark {
        win := True
    }
    if board.get_board_position(Coord(0,2)).unwrap() == mark && board.get_board_position(Coord(1,1)).unwrap() == mark && board.get_board_position(Coord(2,0)).unwrap() == mark {
        win := True
    }

    win
}

fun play_turn(board: list<list<char>>, moves : list<coord>, mark : char, other-mark: char, ai : bool) {
    val coord : coord = gen_move(moves)
    val moves : list<coord> = moves ++ [coord]
    val board : list<list<char>> = board.mark_board(coord, mark)
    if board.check_win(mark) {
        println("Player " ++ mark.show() ++ " wins!")
        println("Final board:")
        board.draw_board()
    }
    elif board.check_full() {
        println("Draw!")
        println("Final board:")
        board.draw_board()
    }
    else {
        println("Next turn:")
        board.draw_board()
        if ai then {
            board.play_ai_turn(moves, other-mark, mark, True)
            ()
        }
        else {
            board.play_turn(moves, other-mark, mark, False)
            ()
        }
    }
}

fun play_ai_turn(board : list<list<char>>, moves : list<coord>, mark : char, other-mark : char, player : bool) {
    val coord : coord = board.gen_ai_move(moves, mark, other-mark)
    val moves : list<coord> = moves ++ [coord]
    val board : list<list<char>> = board.mark_board(coord, mark)
    if board.check_win(mark) {
        println("Player " ++ mark.show() ++ " wins!")
        println("Final board:")
        board.draw_board()
    }
    elif board.check_full() {
        println("Draw!")
        println("Final board:")
        board.draw_board()
    }
    else {
        println("Next turn:")
        board.draw_board()
        if player {
            board.play_turn(moves, other-mark, mark, True)
            ()
        }
        else {
            board.play_ai_turn(moves, other-mark, mark, False)
            ()
        }
    }
}

struct move
    move : coord
    score: int

fun show(m : move) : string {
    "(" ++ m.move.show() ++ ", " ++ m.score.show() ++ ")"
}

fun (==)(m1 : move, m2 : move) : bool {
    m1.move == m2.move && m1.score == m2.score
}

fun maximum-move(a : move, b : move) : move {
    if a.score > b.score {
        a
    }
    else {
        b
    }
}

fun print-move(m : move) {
    println("Move: " ++ m.move.show() ++ " Score: " ++ m.score.show())
}

fun eval_board(board : list<list<char>>, mark: char, other-mark : char) {
    if board.check_win(mark) {
        10
    }
    elif board.check_win(other-mark) {
        -10
    }
    else {
        0
    }
}

fun gen_ai_move(board : list<list<char>>, moves : list<coord>, mark : char, other-mark : char) {
    val best_move : move = Move(Coord(-1,-1), -1000)
    [0,1,2].foldl(best_move) fn (bstMove : move, i : int) {
        [0,1,2].foldl(bstMove) fn (bstMve : move, j : int) {
            if Coord(i,j).member(moves) then {
                bstMve
            }
            else {
                val new_board : list<list<char>> = board.mark_board(Coord(i,j), mark)
                val new-max = maximum-move(bstMve, Move(Coord(i,j), new_board.minimax(moves ++ [Coord(i,j)], 0, False, mark, other-mark)))
                new-max
            }
        }
    }.move
}

fun minimax(board : list<list<char>>, moves: list<coord>, depth : int, isMaximizingPlayer : bool, mark : char, other-mark : char) : <div,exn|_e> int {
    val score : int = board.eval_board(mark, other-mark)
    if score == 10 then {
        score
    }
    elif score == -10 then {
        score
    }
    elif board.check_full() then {
        0
    }
    else {
        if isMaximizingPlayer {
            val bestVal: int = -1000
            [0,1,2].foldl(bestVal) fn (bstVal : int, i : int) {
                [0,1,2].foldl(bstVal) fn (bstVl : int, j : int) {
                    if Coord(i,j).member(moves) then {
                        bstVl
                    }
                    else {
                        val new_board : list<list<char>> = board.mark_board(Coord(i,j), mark)
                        val value : int = new_board.minimax(moves ++ [Coord(i,j)], depth + 1, !isMaximizingPlayer, mark, other-mark)
                        max(bstVl, value)
                    }
                }
            }
        }
        else {
            val bestVal: int = 1000
            [0,1,2].foldl(bestVal) fn (bstVal : int, i : int) {
                [0,1,2].foldl(bstVal) fn (bstVl : int, j : int) {
                    if Coord(i,j).member(moves) {
                        bstVl
                    }
                    else {
                        val new_board : list<list<char>> = board.mark_board(Coord(i,j), other-mark)
                        val value : int = new_board.minimax(moves ++ [Coord(i,j)], depth + 1, !isMaximizingPlayer, mark, other-mark)
                        min(bstVl, value)
                    }
                }
            }
        }
    }
}

fun start-two-player-game() {
    println("Player X, enter your move as a pair of number like this 0 0")
    create-board().play_turn([], 'x', 'o', False)
}

fun start-one-player-game() {
    println("Player X, enter your move as a pair of number like this 0 0")
    create-board().play_turn([], 'x', 'o', True)
}

fun zero-player-game() {
    create-board().play_ai_turn([], 'x', 'o', False)
}

fun main () {
    println("Welcome to Tic Tac Toe!")
    println("Please select a game mode:")
    println("1. Two player")
    println("2. One player")
    println("3. Zero player")
    match readline().list() {
        Cons('1', Nil) -> start-two-player-game()
        Cons('2', Nil) -> start-one-player-game()
        Cons('3', Nil) -> zero-player-game()
        _ -> {
            println("Invalid game mode, please try again")
            main()
        }
    }
}