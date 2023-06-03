import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/snake_pos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  int rowSize = 10;
  int totalNumOfSquares = 100;
  List<int> snakePos = [0, 1, 2];
  int foodPos = 55;
  int currentScore = 0;
  bool gameStarted = false;
  var currentDirection = snake_Direction.RIGHT;

  void gameStart() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
        if (gameOver()) {
          timer.cancel();

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('GAME OVER'),
                  content: Column(
                    children: [
                      Text('Your score is:' + currentScore.toString()),
                      TextField(
                        decoration:
                            InputDecoration(hintText: 'Enter your name'),
                      )
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        newGame();
                      },
                      child: Text('Submit'),
                      color: Colors.pink,
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void newGame() {
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameStarted = false;
      currentScore = 0;
    });
  }

  void submitScore() {}

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        if (snakePos.last % rowSize == 9) {
          snakePos.add(snakePos.last + 1 - rowSize);
        } else {
          snakePos.add(snakePos.last + 1);
        }
        break;
      case snake_Direction.LEFT:
        if (snakePos.last % rowSize == 0) {
          snakePos.add(snakePos.last - 1 + rowSize);
        } else {
          snakePos.add(snakePos.last - 1);
        }
        break;
      case snake_Direction.UP:
        if (snakePos.last < rowSize) {
          snakePos.add(snakePos.last - rowSize + totalNumOfSquares);
        } else {
          snakePos.add(snakePos.last - rowSize);
        }
        break;
      case snake_Direction.DOWN:
        if (snakePos.last + rowSize > totalNumOfSquares) {
          snakePos.add(snakePos.last + rowSize - totalNumOfSquares);
        } else {
          snakePos.add(snakePos.last + rowSize);
        }
        break;

      default:
    }

    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  bool gameOver() {
    List<int> snakeBody = snakePos.sublist(0, snakePos.length - 1);

    if (snakeBody.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Current Score',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      currentScore.toString(),
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ],
                ),
                const Text(
                  'High Score',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 &&
                    currentDirection != snake_Direction.UP) {
                  currentDirection = snake_Direction.DOWN;
                } else if (details.delta.dy < 0 &&
                    currentDirection != snake_Direction.DOWN) {
                  currentDirection = snake_Direction.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 &&
                    currentDirection != snake_Direction.LEFT) {
                  currentDirection = snake_Direction.RIGHT;
                } else if (details.delta.dx < 0 &&
                    currentDirection != snake_Direction.RIGHT) {
                  currentDirection = snake_Direction.LEFT;
                }
              },
              child: GridView.builder(
                itemCount: totalNumOfSquares,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowSize),
                itemBuilder: (context, index) {
                  if (snakePos.contains(index)) {
                    return SnakePixel();
                  } else if (foodPos == index) {
                    return FoodPixel();
                  } else {
                    return BlankPixel();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Center(
                child: MaterialButton(
                  child: Text('P L A Y'),
                  textColor: Colors.white,
                  color: gameStarted ? Colors.grey : Colors.pink,
                  onPressed: gameStarted ? () {} : gameStart,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
