import { GAME_CONFIG } from '../utils/Constants';
import { GameRenderer } from './GameRenderer';

export enum GameStatus {
  playing,
  paused,
  stopped,
}

export interface PlayerState {
  x: number;
  lastTouchX: number;
}

export interface ComputerState {
  x: number;
  speed: number;
}

export interface BallState {
  x: number;
  y: number;
  vx: number;
  vy: number;
  speed: number;
}

export class GameController {
  private static _instance: GameController | null = null;
  private _gameRenderer: GameRenderer;
  private _timer: number = 0;
  private _playerScore: number = 0;
  private _computerScore: number = 0;
  private _gameStatus: GameStatus = GameStatus.playing;
  private _player: PlayerState = {
    x: GAME_CONFIG.INITIAL_PLAYER_POS_X,
    lastTouchX: 0,
  }
  private _computer: ComputerState = {
    x: 0,
    speed: GAME_CONFIG.INITIAL_COMPUTER_SPEED,
  }
  private _ball: BallState = {
    x: 0,
    y: 0,
    vx: 0,
    vy: 0,
    speed: GAME_CONFIG.INITIAL_BALL_SPEED,
  }

  constructor(gameRenderer: GameRenderer) {
    this._gameRenderer = gameRenderer
  }

  get status(): GameStatus {
    return this._gameStatus;
  }

  static getInstance(gameRenderer: GameRenderer): GameController {
    if (GameController._instance == null) {
      GameController._instance = new GameController(gameRenderer);
    }
    return GameController._instance;
  }

  getPlayer(): PlayerState {
    return this._player;
  }

  getPlayerScore(): number {
    return this._playerScore
  };

  getComputer(): ComputerState {
    return this._computer;
  }

  getComputerScore(): number {
    return this._computerScore;
  }

  getBall(): BallState {
    return this._ball;
  }

  stopGame() {
    this.resetGame();
    clearInterval(this._timer);
    this._timer = 0;
    this._gameStatus = GameStatus.stopped;
  }

  pauseGame() {
    clearInterval(this._timer);
    this._timer = 0;
    this._gameStatus = GameStatus.paused;
  }

  startGame() {
    this.stopGame();
    this._timer = setInterval((): void => this.update(), 16); // 16 fps
    this._gameStatus = GameStatus.playing;
  }

  resetGame() {
    this._playerScore = 0;
    this._computerScore = 0;
    this._gameStatus = GameStatus.stopped;
  }

  resetPositions() {
    this._ball.x = (GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.BALL_SIZE) / 2;
    this._ball.y = (GAME_CONFIG.CANVAS_HEIGHT - GAME_CONFIG.BALL_SIZE) / 2;
    let angle = Math.random() * Math.PI / 2 + Math.PI / 4;
    let up = Math.random() > 0.5;
    this._ball.vx = this._ball.speed * Math.cos(angle) * (Math.random() > 0.5 ? 1 : -1);
    this._ball.vy = this._ball.speed * (up ? -1 : 1);
  }

  onTouch(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      this._player.lastTouchX = event.touches[0].x;
    } else if (event.type === TouchType.Move) {
      let dx = event.touches[0].x - this._player.lastTouchX;
      this._player.x += dx;
      this._player.x = Math.max(
        2,
        Math.min(GAME_CONFIG.CANVAS_WIDTH - 2 - GAME_CONFIG.PADDLE_WIDTH, this._player.x)
      );

      this._player.lastTouchX = event.touches[0].x;
    }
  }

  update() {
    // move the _ball
    this._ball.x += this._ball.vx;
    this._ball.y += this._ball.vy;

    // collision with left wall
    if (this._ball.x - GAME_CONFIG.BALL_SIZE < 0) {
      this._ball.vx = Math.abs(this._ball.vx);
    }
    // collision with right wall
    if (this._ball.x >= GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.BALL_SIZE) {
      this._ball.vx = -Math.abs(this._ball.vx);
    }
    let computerCenter = this._computer.x + GAME_CONFIG.PADDLE_WIDTH / 2;
    let ballCenter = this._ball.x + GAME_CONFIG.BALL_SIZE / 2;
    // check collision with top wall (_computer side) and increase _player score
    if (this._ball.y - GAME_CONFIG.BALL_SIZE < 0) {
      // check _computer paddle collision with _ball
      if (
        this._computer.x <= this._ball.x &&
          this._ball.x <= this._computer.x + GAME_CONFIG.PADDLE_WIDTH &&
          this._ball.y <= GAME_CONFIG.PADDLE_HEIGHT + GAME_CONFIG.BALL_SIZE
      ) {
        this._ball.vy = this._ball.speed;
        this._ball.vx += ballCenter >= computerCenter ? -this._ball.speed : this._ball.speed;
      } else {
        this._playerScore += 1;
        this._ball.vy = Math.abs(this._ball.vy);
      }
    }

    // check collision with bottom wall (_player side) and increase _computer score
    if (this._ball.y + GAME_CONFIG.BALL_SIZE >= GAME_CONFIG.CANVAS_HEIGHT) {
      // check _player paddle collision with _ball
      let playerCenter = this._player.x + GAME_CONFIG.PADDLE_WIDTH / 2;
      if (
        this._player.x <= this._ball.x &&
          this._ball.x <= this._player.x + GAME_CONFIG.PADDLE_WIDTH &&
          this._ball.y + GAME_CONFIG.BALL_SIZE + GAME_CONFIG.PADDLE_HEIGHT >= GAME_CONFIG.CANVAS_HEIGHT
      ) {
        this._ball.vy = -this._ball.speed;
        this._ball.vx += ballCenter >= playerCenter ? this._ball.speed : -this._ball.speed;
      } else {
        this._computerScore += 1;
        this._ball.vy = -Math.abs(this._ball.vy);
      }
    }

    // move _computer paddle towards _ball

    let diff = computerCenter - ballCenter;
    let move = (diff * this._computer.speed) / 100;
    this._computer.x += Math.max(this._computer.speed, move);

    // check if _computer paddle is closing on left wall
    if (this._computer.x < 0) {
      this._computer.speed = Math.abs(this._computer.speed);
    }

    // check if _computer paddle is closing on right wall
    let computerEndX = GAME_CONFIG.PADDLE_WIDTH + this._computer.x;
    if (computerEndX >= GAME_CONFIG.CANVAS_WIDTH) {
      this._computer.speed = -Math.abs(this._computer.speed);
    }

    this._gameRenderer.drawGame(this._player, this._computer, this._ball);

  }
}





