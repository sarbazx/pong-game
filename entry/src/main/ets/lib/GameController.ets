import { GAME_CONFIG, GAMEPLAY_CONFIG } from '../utils/Constants';
import { GameRenderer } from './GameRenderer';
import { HapticUtil } from '../utils/HapticUtil';
import { Logger } from '../utils/Logger';

export enum GameStatus {
  playing,
  paused,
  stopped,
  finished
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

let randSeed: number = Date.now() & 0xffffffff;

export class GameController {
  private static _instance: GameController | null = null;
  private _gameRenderer: GameRenderer;
  private _timer: number = 0;
  private _playerScore: number = 0;
  private _computerScore: number = 0;
  private _gameStatus: GameStatus = GameStatus.playing;
  private _onFinish: ((winner: string, playerScore: number, computerScore: number) => void) | null = null;
  private _player: PlayerState = {
    x: GAME_CONFIG.INITIAL_PLAYER_POS_X,
    lastTouchX: 0
  }
  private _computer: ComputerState = {
    x: 0,
    speed: GAME_CONFIG.INITIAL_COMPUTER_SPEED
  }
  private _ball: BallState = {
    x: 0,
    y: 0,
    vx: 0,
    vy: 0,
    speed: GAME_CONFIG.INITIAL_BALL_SPEED
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

  rand(): number {
    randSeed = (1664525 * randSeed + 1013904223) >>> 0;
    return randSeed / 0xffffffff;
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

  /** Returns 'player', 'computer', or null when game is not finished. */
  getWinner(): string | null {
    if (this._gameStatus !== GameStatus.finished) {
      return null;
    }
    return this._playerScore >= GAMEPLAY_CONFIG.WIN_SCORE ? 'player' : 'computer';
  }

  setRenderer(renderer: GameRenderer) {
    this._gameRenderer = renderer;
  }

  setOnFinish(cb: (winner: string, playerScore: number, computerScore: number) => void) {
    this._onFinish = cb;
  }

  stopGame() {
    Logger.info('GameController', 'stopGame');
    this.resetGame();
    clearInterval(this._timer);
    this._timer = 0;
    this._gameStatus = GameStatus.stopped;
  }

  pauseGame() {
    Logger.info('GameController', 'pauseGame');
    clearInterval(this._timer);
    this._timer = 0;
    this._gameStatus = GameStatus.paused;
  }

  private finishGame() {
    clearInterval(this._timer);
    this._timer = 0;
    this._gameStatus = GameStatus.finished;
    const winner = this.getWinner() ?? 'unknown';
    Logger.info('GameController', `finishGame — winner: ${winner}`);
    if (this._onFinish) {
      this._onFinish(winner, this._playerScore, this._computerScore);
    }
  }

  /** Increase ball speed after a successful paddle hit (capped). */
  private incrementBallSpeed() {
    const cap = GAME_CONFIG.INITIAL_BALL_SPEED * GAMEPLAY_CONFIG.MAX_BALL_SPEED_MULTIPLIER;
    if (this._ball.speed < cap) {
      this._ball.speed = Math.min(cap, this._ball.speed + GAMEPLAY_CONFIG.BALL_SPEED_INCREMENT);
    }
  }

  /** Resume after pause — does NOT reset scores or positions. */
  resumeGame() {
    Logger.info('GameController', 'resumeGame');
    clearInterval(this._timer);
    this._timer = setInterval((): void => this.update(), 16);
    this._gameStatus = GameStatus.playing;
  }

  startGame() {
    Logger.info('GameController', 'startGame');
    this.stopGame();
    this._timer = setInterval((): void => this.update(), 16); // 16 fps
    this._gameStatus = GameStatus.playing;
  }

  resetGame() {
    this._playerScore = 0;
    this._computerScore = 0;
    this._ball.speed = GAME_CONFIG.INITIAL_BALL_SPEED;
    this._gameStatus = GameStatus.stopped;
  }

  resetPositions() {
    this._ball.x = (GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.BALL_SIZE) / 2;
    this._ball.y = (GAME_CONFIG.CANVAS_HEIGHT - GAME_CONFIG.BALL_SIZE) / 2;
    let angle = this.rand() * Math.PI / 2 + Math.PI / 4;
    let up = this.rand() > 0.5;
    this._ball.vx = this._ball.speed * Math.cos(angle) * (this.rand() > 0.5 ? 1 : -1);
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
        this.incrementBallSpeed();
        HapticUtil.shortVibrate();
        this._ball.vy = this._ball.speed;
        this._ball.vx += ballCenter >= computerCenter ? -this._ball.speed : this._ball.speed;
      } else {
        this._playerScore += 1;
        HapticUtil.scoreVibrate();
        this._ball.vy = Math.abs(this._ball.vy);
        if (this._playerScore >= GAMEPLAY_CONFIG.WIN_SCORE) {
          this.finishGame();
          return;
        }
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
        this.incrementBallSpeed();
        HapticUtil.shortVibrate();
        this._ball.vy = -this._ball.speed;
        this._ball.vx += ballCenter >= playerCenter ? this._ball.speed : -this._ball.speed;
      } else {
        this._computerScore += 1;
        HapticUtil.scoreVibrate();
        this._ball.vy = -Math.abs(this._ball.vy);
        if (this._computerScore >= GAMEPLAY_CONFIG.WIN_SCORE) {
          this.finishGame();
          return;
        }
      }
    }

    // move _computer paddle towards _ball (signed, clamped step)
    let diff = ballCenter - computerCenter;
    let step = Math.min(Math.abs(this._computer.speed), Math.abs(diff));
    this._computer.x += diff > 0 ? step : -step;

    // clamp computer paddle to canvas bounds
    this._computer.x = Math.max(
      0,
      Math.min(GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.PADDLE_WIDTH, this._computer.x)
    );

    this._gameRenderer.drawGame(this._player, this._computer, this._ball);

  }
}
