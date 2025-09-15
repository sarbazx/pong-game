import { COLORS, GAME_CONFIG } from '../utils/Constants';
import { GameRenderer } from '../lib/GameRenderer';
import { GameController } from '../lib/GameController';
import { GameScores } from './GameScores';
import { GameControlsBuilder } from './GameControls';

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
    this.gameController.resetPositions();
    this.gameController.startGame();
  }

  aboutToDisappear() {
    this.gameController.stopGame();
  }

  build() {
    RelativeContainer() {
      Stack() {
        GameControlsBuilder({
          gameStatus: this.gameController.status,
          onStart: () => {
            this.gameController.startGame();
          },
          onStop: () => {
            this.gameController.stopGame();
          },
          onPause: () => {
            this.gameController.pauseGame();
          },
        })

        Canvas(this.context)
          .onTouch((event: TouchEvent) => {
            this.gameController.onTouch(event);
          })
          .onReady(() => this.draw())
          .onDisAppear(() => this.gameController.stopGame())
          .position({ left: GAME_CONFIG.CANVAS_OFFSET_X, top: GAME_CONFIG.CANVAS_OFFSET_Y })
          .width(GAME_CONFIG.CANVAS_WIDTH)
          .height(GAME_CONFIG.CANVAS_HEIGHT)
        GameScores({
          computerScore: this.gameController.getComputerScore(),
          playerScore: this.gameController.getPlayerScore(),
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.CANVAS_BG)
  }
}
