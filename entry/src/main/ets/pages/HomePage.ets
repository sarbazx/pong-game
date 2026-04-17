import { PongGameCanvas } from '../components/PongGameCanvas';
import { GAME_CONFIG } from '../utils/Constants';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@Component
export struct HomePage {
  @State private navStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Stack() {
        PongGameCanvas()

        Button({ type: ButtonType.Normal }) {
          Text('H')
            .fontSize(10)
            .fontColor('#FFFFFF')
        }
        .width(22)
        .height(22)
        .backgroundColor('#333333')
        .borderRadius(11)
        .position({
          x: GAME_CONFIG.CANVAS_OFFSET_X + GAME_CONFIG.CANVAS_WIDTH - 26,
          y: GAME_CONFIG.CANVAS_OFFSET_Y + 4
        })
        .onClick(() => {
          this.navStack.pushPath({ name: 'HistoryPage' });
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.navStack = ctx.pathStack;
    })
    .width('100%')
    .height('100%')
  }
}
