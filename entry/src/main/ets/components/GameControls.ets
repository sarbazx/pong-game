import { GameStatus } from '../lib/GameController';
import { COLORS, GAME_CONFIG, UI_CONFIG } from '../utils/Constants';

interface GameControlsParams {
  gameStatus: GameStatus;
  onStart: () => void;
  onStop: () => void;
  onPause: () => void;
}

@Builder
function mediaButtonBuilder(res: Resource, onClick: () => void) {
  Button({ type: ButtonType.Normal, stateEffect: false }) {
    Image(res)
      .backgroundColor(COLORS.CANVAS_BG)
      .objectFit(ImageFit.Contain)
      .width('100%')
      .height('100%')
  }
  .onClick(onClick)
  .width(UI_CONFIG.BUTTON_SIZE)
  .height(UI_CONFIG.BUTTON_SIZE)
}

@Builder
export function GameControlsBuilder(params: GameControlsParams) {
  RelativeContainer() {
    Row() {
      if (params.gameStatus === GameStatus.playing) {
        Column() {
          mediaButtonBuilder($r('app.media.stop'), () => params.onStop())
          Blank().layoutWeight(1)
          mediaButtonBuilder($r('app.media.pause'), () => params.onPause())
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 12, bottom: 24, top: 24 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Ease }))

      }
      if (params.gameStatus !== GameStatus.playing) {
        Row() {
          mediaButtonBuilder($r('app.media.play'), () => params.onStart())
        }
        .margin({ left: 12, top: GAME_CONFIG.CANVAS_HEIGHT / 2 - GAME_CONFIG.CANVAS_OFFSET_Y })
        .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Ease }))
      }
    }
    .width('100%')
  }
  .margin({ top: GAME_CONFIG.CANVAS_OFFSET_Y + (GAME_CONFIG.CANVAS_HEIGHT / 5) })
  .width('100%')
  .height(GAME_CONFIG.CANVAS_HEIGHT / 2)
}

