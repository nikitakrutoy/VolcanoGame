# VolcanoGame

This game was made as part of Wargaming Academy 2021 entry task. It is my first game made with Godot so I focused on learning as much as possible about engine while making the game. Futhermode i tried to add a little bit of enviroment to the game, despite that original task was very abstract and only described the puzzle rules. I also provide a prototype game which only include the puzzle without enviroment, in case the reviewer wouldn't have time to check extra stuff that i made.


I haven't finished some of my ideas due to deadline for the task and my intense studing at university, therefore the game is unoptimized and looks ugly in current state imho. I also used 2k textures for more details which is ofcourse super inefficient, but i guess it is ok for now. It is only for around 10 object thought.


## Gameplay

You are moving colored cells on a grid with mouse swipes. Your goal is to align color of the columns with the colors in the header of the grid.

## Prototype

Prototype files can be found in [scripts/Prototype](scripts/Prototype), [scenes/Prototype](scenes/Prototype), [img](img) and [data](data)

## Design

New levels can be easely created with TileSets and GridMaps with predefined cells. Header cells should be positioned in negative area. Inside GridMap cell should be positioned at default depth. Field class ([Field.gd](scripts/Field.gd) and [field.gd](scripts/Prototype/field.gd)) will process GridMap and place new cells in the world according to their aligment and Field position in the world. See examples at [scenes/Prototype/Level1.tscn](scenes/Prototype/Level.tscn) and [scenes/Level1.tscn](scenes/Level.tscn)

## Models 
[Here](https://disk.yandex.ru/d/rxTUKe9F_WpUGA) are blend files of used models, but they are pretty dirty.

I used [this](https://www.youtube.com/watch?v=EQwdHSr4Qgk&t=1693s&ab_channel=CBaileyFilm) tutorial to create volcano.

## Addons

[Clouds](https://bitbucket.org/arlez80/cloud-shader/src/master/)

## Videos

[![VolcanoGame](https://github.com/nikitakrutoy/VolcanoGame/blob/master/screenshots/VolcanoGame.jpg)](https://youtu.be/CkM8oZhI0wU)

[![Prototype](https://github.com/nikitakrutoy/VolcanoGame/blob/master/screenshots/VolcanoGamePrototype.jpg)](https://youtu.be/gOJ0RxHKt70)


