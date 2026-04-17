@Entry
@Component
struct Index {
  @State navStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.navStack.pushPath({ name: 'HomePage' });
  }

  build() {
    Navigation(this.navStack) {}
    .mode(NavigationMode.Stack)
    .hideNavBar(true)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}
