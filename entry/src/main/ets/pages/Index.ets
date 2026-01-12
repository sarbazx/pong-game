import { PongGameCanvas } from '../components/PongGameCanvas';

@Entry
@Component
struct Index {
  build() {
    RelativeContainer() {
      PongGameCanvas()
    }
  }
}
