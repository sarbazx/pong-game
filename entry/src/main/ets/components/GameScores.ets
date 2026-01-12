import { COLORS, SCORE_CONFIG, UI_CONFIG } from '../utils/Constants';

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
      .fontColor('#B0B0B0')
    Text(`${score.playerScore}`)
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