import { getHistory, GameRecord } from '../utils/GameHistoryStore';
import { COLORS } from '../utils/Constants';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from '@ohos.arkui.ArcList';
import { ComponentContent, LengthMetrics } from '@kit.ArkUI';

class GameRecordsDataSource implements IDataSource {
  private records: GameRecord[] = [];
  private listeners: DataChangeListener[] = [];

  setData(data: GameRecord[]): void {
    this.records = data;
    this.listeners.forEach(l => l.onDataReloaded());
  }

  totalCount(): number {
    return this.records.length;
  }

  getData(index: number): GameRecord {
    return this.records[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) {
      this.listeners.splice(idx, 1);
    }
  }
}

@Builder
export function HistoryPageBuilder() {
  HistoryPage()
}

@Builder
function headerBuilder() {
  Text('History')
    .fontSize(13)
    .fontWeight(FontWeight.Bold)
    .fontColor(COLORS.LINE_WHITE)
    .margin({ top: 8, bottom: 6 })
}

@Component
export struct HistoryPage {
  @State private navStack: NavPathStack = new NavPathStack();
  private dataSource: GameRecordsDataSource = new GameRecordsDataSource();
  private context: UIContext = this.getUIContext();
  private header: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(headerBuilder));
  @State private isEmpty: boolean = false;

  aboutToAppear(): void {
    getHistory().then((list: GameRecord[]) => {
      this.isEmpty = list.length === 0;
      this.dataSource.setData(list);
    }).catch(() => {
      this.isEmpty = true;
      this.dataSource.setData([]);
    });
  }

  formatTime(ts: number): string {
    const d = new Date(ts);
    const hh = d.getHours().toString().padStart(2, '0');
    const mm = d.getMinutes().toString().padStart(2, '0');
    const dd = d.getDate().toString().padStart(2, '0');
    const mo = (d.getMonth() + 1).toString().padStart(2, '0');
    return `${dd}/${mo} ${hh}:${mm}`;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          if (this.isEmpty) {
            Text('No games yet')
              .fontSize(11)
              .fontColor(COLORS.TEXT_WHITE)
              .margin({ top: 20 })
          } else {
            ArcList({ header: this.header }) {
              LazyForEach(this.dataSource, (rec: GameRecord) => {
                ArcListItem() {
                  Row() {
                    Text(rec.winner === 'player' ? 'You' : 'CPU')
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(rec.winner === 'player' ? '#4CAF50' : '#F44336')
                      .margin({ right: 10 })
                    Text(`${rec.playerScore}–${rec.computerScore}`)
                      .fontSize(11)
                      .fontColor(COLORS.LINE_WHITE)
                      .textAlign(TextAlign.Center)
                      .margin({ right: 10 })
                    Text(this.formatTime(rec.timestamp))
                      .fontSize(9)
                      .fontColor(COLORS.TEXT_WHITE)
                      .margin({ right: 10 })
                      .textAlign(TextAlign.End)
                  }
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                  .width('100%')
                  .padding({
                    left: 8,
                    right: 8,
                    top: 3,
                    bottom: 3
                  })
                }
              }, (rec: GameRecord) => rec.timestamp.toString())
            }
            .space(LengthMetrics.px(4))
            .width('100%')
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(COLORS.CANVAS_BG)

        Button({ type: ButtonType.Normal }) {
          Text('<')
            .fontSize(14)
            .fontColor(COLORS.LINE_WHITE)
        }
        .width(28)
        .height(28)
        .backgroundColor(Color.Transparent)
        .margin({ left: 4, top: 4 })
        .onClick(() => {
          this.navStack.pop();
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(COLORS.CANVAS_BG)
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.navStack = ctx.pathStack;
    })
  }
}
