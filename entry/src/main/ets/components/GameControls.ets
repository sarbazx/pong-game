import { GameStatus } from '../lib/GameController';
import { COLORS, CONTROLS_CONFIG, GAME_CONFIG, UI_CONFIG } from '../utils/Constants';

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
  Stack() {
    if (params.gameStatus === GameStatus.playing) {
      Column() {
        mediaButtonBuilder($r('app.media.stop'), () => params.onStop())
        Blank().layoutWeight(1)
        mediaButtonBuilder($r('app.media.pause'), () => params.onPause())
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .width(UI_CONFIG.BUTTON_SIZE + CONTROLS_CONFIG.BUTTON_MARGIN_LEFT)
      .height(GAME_CONFIG.CANVAS_HEIGHT)
      .padding({
        left: CONTROLS_CONFIG.BUTTON_MARGIN_LEFT,
        top: CONTROLS_CONFIG.BUTTON_MARGIN_VERTICAL,
        bottom: CONTROLS_CONFIG.BUTTON_MARGIN_VERTICAL
      })
      .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Ease }))
    }
    if (params.gameStatus !== GameStatus.playing) {
      Row() {
        mediaButtonBuilder($r('app.media.play'), () => params.onStart())
      }
      .padding({ left: CONTROLS_CONFIG.BUTTON_MARGIN_LEFT })
      .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Ease }))
    }
  }
  .alignContent(Alignment.Start)
  .width('100%')
  .height('100%')
  .hitTestBehavior(HitTestMode.Transparent)
}

