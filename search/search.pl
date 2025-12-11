search(Actions) :-
    initial(StartRoom),
    update_keys(StartRoom, [], StartKeys),
    bfs([[StartRoom, StartKeys, []]], [], RevPath),
    reverse(RevPath, Actions).

bfs([[Room, _Keys, Path] | _], _Visited, Path) :-
    treasure(Room).

bfs([[Room, Keys, _] | RestQueue], Visited, Actions) :-
    member([Room, Keys], Visited),
    bfs(RestQueue, Visited, Actions).

bfs([[Room, Keys, Path] | RestQueue], Visited, Actions) :-
    \+ member([Room, Keys], Visited),
    findall(
        [NextRoom, NewKeys, [move(Room, NextRoom) | Path]],
        (
            next_room(Room, NextRoom),
            can_go(Room, NextRoom, Keys),
            update_keys(NextRoom, Keys, NewKeys),
            \+ member([NextRoom, NewKeys], Visited)
        ),
        Children
    ),
    append(RestQueue, Children, NewQueue),
    bfs(NewQueue, [[Room, Keys] | Visited], Actions).

bfs([], _, _) :- fail.

next_room(A, B) :- door(A, B).
next_room(A, B) :- door(B, A).
next_room(A, B) :- locked_door(A, B, _).
next_room(A, B) :- locked_door(B, A, _).

can_go(A, B, Keys) :-
    locked_door(A, B, Color),
    member(Color, Keys).
can_go(A, B, Keys) :-
    locked_door(B, A, Color),
    member(Color, Keys).
can_go(A, B, _Keys) :-
    door(A, B).
can_go(A, B, _Keys) :-
    door(B, A).

update_keys(Room, KeysIn, KeysOut) :-
    findall(Color, key(Room, Color), NewKeys),
    append(KeysIn, NewKeys, KeysOut).
