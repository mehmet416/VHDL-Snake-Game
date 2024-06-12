# VHDL Snake Game

This project implements a classic Snake game using VHDL, designed for the Nexys 3 FPGA board and monitored by a 640x480 VGA display. The game is built to provide a fully functional and interactive gaming experience by leveraging the capabilities of VHDL and FPGAs.

## Project Overview

This Snake game allows users to control the movement of a snake on the screen, collecting food items to increase its length and score. Key features include:

- **User Control**: Navigate the snake using the FPGA board buttons.
- **Collision Detection**: Detects collisions with boundaries and the snake's own body.
- **Random Food Generation**: Places food items randomly on the playing field.
- **Scorekeeping**: Tracks and displays the score on a seven-segment display.

## Design Components

- **Game Logic and RGB Generation**: Handles snake movement, collision detection, and score updates.
- **VGA Controllers**: Generates signals to drive the VGA display.
- **Joypad Interface**: Captures user inputs for controlling the snake.
- **Frequency Divider**: Generates necessary clock signals.

## Gameplay Video
Watch the gameplay video on YouTube: https://youtube.com/shorts/fywubfjq5C8?si=hkuCs1CAcIabdUC8

## Credits
Developed by Enes Kuzuoğlu and Mehmet Emin Algül under the supervision of Şenol Mutlu at Boğaziçi University.
