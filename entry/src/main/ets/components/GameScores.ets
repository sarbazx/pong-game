import { COLORS, SCORE_CONFIG, UI_CONFIG } from '../utils/Constants';

@Component
export struct GameScores {
  @Prop computerScore: number = 0;
  @Prop playerScore: number = 0;

  build() {
    Column() {
      Text(`${this.computerScore}`)
        .fontSize(UI_CONFIG.TEXT_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor('#B0B0B0')
      Text(`${this.playerScore}`)
        .fontSize(UI_CONFIG.TEXT_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.TEXT_WHITE)
    }
    .margin({ left: '50%', top: '35%' })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(SCORE_CONFIG.WIDTH)
    .height(SCORE_CONFIG.HEIGHT);

  }
}