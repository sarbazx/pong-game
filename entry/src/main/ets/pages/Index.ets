import { PongGameCanvas } from '../components/PongGameCanvas';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      PongGameCanvas()
    }
  }
}