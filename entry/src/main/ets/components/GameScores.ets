import { COLORS, SCORE_CONFIG, SCORES_DISPLAY_CONFIG, UI_CONFIG } from '../utils/Constants';

class Score {
  computerScore: number = 0;
  playerScore: number = 0;
}

@Builder
export function GameScores(score: Score) {
  Column() {
    Text(`${score.computerScore}`)
      .fontSize(UI_CONFIG.TEXT_SIZE)
      .fontWeight(FontWeight.Bold)
      .fontColor(COLORS.TEXT_WHITE)
    Text(`${score.playerScore}`)
      .fontSize(UI_CONFIG.TEXT_SIZE)
      .fontWeight(FontWeight.Bold)
      .fontColor(COLORS.TEXT_WHITE)
  }
  .margin({ left: SCORES_DISPLAY_CONFIG.MARGIN_LEFT_PERCENT, top: SCORES_DISPLAY_CONFIG.MARGIN_TOP_PERCENT })
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .width(SCORE_CONFIG.WIDTH)
  .height(SCORE_CONFIG.HEIGHT);
}