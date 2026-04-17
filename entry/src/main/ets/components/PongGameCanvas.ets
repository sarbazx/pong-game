import { COLORS, GAME_CONFIG, UI_CONFIG } from '../utils/Constants';
import { GameRenderer } from '../lib/GameRenderer';
import { GameController, GameStatus } from '../lib/GameController';
import { GameScores } from './GameScores';
import { GameControlsBuilder } from './GameControls';
import { initGameHistoryStore, saveGame } from '../utils/GameHistoryStore';
import { common } from '@kit.AbilityKit';

@Component
export struct PongGameCanvas {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private gameRenderer: GameRenderer = new GameRenderer(this.context);
  @State private gameController: GameController = GameController.getInstance(this.gameRenderer);

  draw() {
    this.gameRenderer.drawGame(
      this.gameController.getPlayer(),
      this.gameController.getComputer(),
      this.gameController.getBall(),
    )
  }

  aboutToAppear(): void {
    initGameHistoryStore(getContext(this) as common.UIAbilityContext);
    this.gameController.setRenderer(this.gameRenderer);
    this.gameController.setOnFinish((winner: string, playerScore: number, computerScore: number) => {
      saveGame(winner, playerScore, computerScore).catch(() => {});
    });
    this.gameController.resetPositions();
    this.gameController.startGame();
  }

  aboutToDisappear() {
    this.gameController.stopGame();
  }

  build() {
    Stack() {
      Canvas(this.context)
        .onTouch((event: TouchEvent) => {
          this.gameController.onTouch(event);
        })
        .onReady(() => this.draw())
        .onDisAppear(() => this.gameController.stopGame())
        .position({ x: GAME_CONFIG.CANVAS_OFFSET_X, y: GAME_CONFIG.CANVAS_OFFSET_Y })
        .width(GAME_CONFIG.CANVAS_WIDTH)
        .height(GAME_CONFIG.CANVAS_HEIGHT)

      if (this.gameController.status === GameStatus.finished) {
        Column() {
          Text(this.gameController.getWinner() === 'player' ? 'You Win!' : 'You Lose!')
            .fontSize(UI_CONFIG.TEXT_SIZE)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.LINE_WHITE)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.None)
      }

      GameScores({
        computerScore: this.gameController.getComputerScore(),
        playerScore: this.gameController.getPlayerScore()
      })

      GameControlsBuilder({
        gameStatus: this.gameController.status,
        onStart: () => {
          if (this.gameController.status === GameStatus.paused) {
            this.gameController.resumeGame();
          } else {
            this.gameController.resetGame();
            this.gameController.resetPositions();
            this.gameController.startGame();
          }
        },
        onStop: () => {
          this.gameController.stopGame();
        },
        onPause: () => {
          this.gameController.pauseGame();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.CANVAS_BG)
  }
}
