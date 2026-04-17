import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { GameController, GameStatus } from '../main/ets/lib/GameController';
import { GameRenderer } from '../main/ets/lib/GameRenderer';
import { GAME_CONFIG, GAMEPLAY_CONFIG } from '../main/ets/utils/Constants';

/**
 * Minimal stub CanvasRenderingContext2D so GameRenderer can be instantiated
 * without a real canvas in the local unit test environment.
 */
class StubContext {
  fillStyle: string = '';
  strokeStyle: string = '';
  lineWidth: number = 0;
  fillRect(_x: number, _y: number, _w: number, _h: number): void {}
  strokeRect(_x: number, _y: number, _w: number, _h: number): void {}
  beginPath(): void {}
  moveTo(_x: number, _y: number): void {}
  lineTo(_x: number, _y: number): void {}
  stroke(): void {}
  arc(_x: number, _y: number, _r: number, _sa: number, _ea: number): void {}
  fill(): void {}
  closePath(): void {}
}

function makeController(): GameController {
  // Reset singleton so each test starts clean
  (GameController as ESObject)['_instance'] = null;
  const ctx = new StubContext() as ESObject as CanvasRenderingContext2D;
  const renderer = new GameRenderer(ctx);
  return GameController.getInstance(renderer);
}

export default function localUnitTest() {
  describe('localUnitTest', () => {
    let controller: GameController;

    beforeEach(() => {
      controller = makeController();
    });

    afterEach(() => {
      // Clean up any running timer
      try { controller.stopGame(); } catch (_) {}
      (GameController as ESObject)['_instance'] = null;
    });

    // P3-T2a: resetPositions places ball at canvas centre with non-zero velocity
    it('resetPositions_ballAtCenter', 0, () => {
      controller.resetPositions();
      const ball = controller.getBall();
      const expectedX = (GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.BALL_SIZE) / 2;
      const expectedY = (GAME_CONFIG.CANVAS_HEIGHT - GAME_CONFIG.BALL_SIZE) / 2;
      expect(ball.x).assertEqual(expectedX);
      expect(ball.y).assertEqual(expectedY);
      // velocity should be non-zero
      expect(Math.abs(ball.vx) + Math.abs(ball.vy) > 0).assertTrue();
    });

    // P3-T2b: onTouch moves player paddle and clamps to canvas bounds
    it('onTouch_moveAndClamp', 0, () => {
      // Simulate a Down then Move event moving the paddle 50px right from initial position
      const downEvent = {
        type: TouchType.Down,
        touches: [{ x: 50, y: 100 }]
      } as TouchEvent;
      controller.onTouch(downEvent);

      const moveEvent = {
        type: TouchType.Move,
        touches: [{ x: 100, y: 100 }]
      } as TouchEvent;
      controller.onTouch(moveEvent);

      const player = controller.getPlayer();
      // Should have moved right by 50
      const expectedX = GAME_CONFIG.INITIAL_PLAYER_POS_X + 50;
      // Clamp: max is CANVAS_WIDTH - 2 - PADDLE_WIDTH = 150 - 2 - 24 = 124
      const clamped = Math.max(2, Math.min(GAME_CONFIG.CANVAS_WIDTH - 2 - GAME_CONFIG.PADDLE_WIDTH, expectedX));
      expect(player.x).assertEqual(clamped);
    });

    it('onTouch_clampLeft', 0, () => {
      // Move paddle far to the left
      const downEvent = { type: TouchType.Down, touches: [{ x: 100, y: 100 }] } as TouchEvent;
      controller.onTouch(downEvent);
      const moveEvent = { type: TouchType.Move, touches: [{ x: 0, y: 100 }] } as TouchEvent;
      controller.onTouch(moveEvent);
      const player = controller.getPlayer();
      expect(player.x >= 2).assertTrue();
    });

    it('onTouch_clampRight', 0, () => {
      const downEvent = { type: TouchType.Down, touches: [{ x: 0, y: 100 }] } as TouchEvent;
      controller.onTouch(downEvent);
      const moveEvent = { type: TouchType.Move, touches: [{ x: 999, y: 100 }] } as TouchEvent;
      controller.onTouch(moveEvent);
      const player = controller.getPlayer();
      expect(player.x <= GAME_CONFIG.CANVAS_WIDTH - 2 - GAME_CONFIG.PADDLE_WIDTH).assertTrue();
    });

    // P3-T2c: ball bounces off left wall (vx sign flip to positive)
    it('update_ballBouncesOffLeftWall', 0, () => {
      controller.resetPositions();
      const ball = controller.getBall();
      // Place ball touching left wall with leftward velocity
      ball.x = GAME_CONFIG.BALL_SIZE - 1; // just inside left collision threshold
      ball.vx = -2;
      ball.vy = 1;
      // Manually call update once (timer not needed for unit test)
      (controller as ESObject)['update']();
      expect(controller.getBall().vx > 0).assertTrue();
    });

    // P3-T2c: ball bounces off right wall (vx sign flip to negative)
    it('update_ballBouncesOffRightWall', 0, () => {
      controller.resetPositions();
      const ball = controller.getBall();
      ball.x = GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.BALL_SIZE;
      ball.vx = 2;
      ball.vy = 1;
      (controller as ESObject)['update']();
      expect(controller.getBall().vx < 0).assertTrue();
    });

    // P3-T2d: resumeGame does not reset scores
    it('resumeGame_preservesScores', 0, () => {
      // Manually set scores via private fields through ESObject cast
      (controller as ESObject)['_playerScore'] = 3;
      (controller as ESObject)['_computerScore'] = 2;
      controller.pauseGame();
      controller.resumeGame();
      expect(controller.getPlayerScore()).assertEqual(3);
      expect(controller.getComputerScore()).assertEqual(2);
      expect(controller.status).assertEqual(GameStatus.playing);
      controller.stopGame();
    });

    // P3-T2e: win condition triggers GameStatus.finished at WIN_SCORE
    it('winCondition_playerWins', 0, () => {
      controller.resetPositions();
      const ball = controller.getBall();
      // Set player score to one below win threshold
      (controller as ESObject)['_playerScore'] = GAMEPLAY_CONFIG.WIN_SCORE - 1;
      // Position ball at top wall with no computer paddle overlap
      ball.x = GAME_CONFIG.CANVAS_WIDTH / 2;
      ball.y = GAME_CONFIG.BALL_SIZE; // at top, will trigger scoring
      ball.vx = 0;
      ball.vy = -2;
      // Move computer far away to avoid paddle collision
      (controller as ESObject)['_computer'].x = GAME_CONFIG.CANVAS_WIDTH - GAME_CONFIG.PADDLE_WIDTH - 1;
      (controller as ESObject)['update']();
      expect(controller.status).assertEqual(GameStatus.finished);
      expect(controller.getWinner()).assertEqual('player');
    });

    it('winCondition_computerWins', 0, () => {
      controller.resetPositions();
      const ball = controller.getBall();
      (controller as ESObject)['_computerScore'] = GAMEPLAY_CONFIG.WIN_SCORE - 1;
      // Position ball at bottom wall with no player paddle overlap
      ball.x = GAME_CONFIG.CANVAS_WIDTH / 2;
      ball.y = GAME_CONFIG.CANVAS_HEIGHT - GAME_CONFIG.BALL_SIZE;
      ball.vx = 0;
      ball.vy = 2;
      // Move player paddle far away
      (controller as ESObject)['_player'].x = 0;
      (controller as ESObject)['update']();
      expect(controller.status).assertEqual(GameStatus.finished);
      expect(controller.getWinner()).assertEqual('computer');
    });
  });
}
