import { vibrator } from '@kit.SensorServiceKit';
import { Logger } from './Logger';

/**
 * HapticUtil — thin wrappers around the wearable vibrator API.
 * All calls are fire-and-forget; errors are logged but not re-thrown
 * so that haptic failures never interrupt gameplay.
 */
export class HapticUtil {
  /**
   * Short single pulse — used on paddle hit.
   * Duration: 30 ms at intensity 50.
   */
  static shortVibrate(): void {
    try {
      vibrator.startVibration(
        { type: 'time', duration: 30 },
        { id: 0, usage: 'touch' }
      );
    } catch (err) {
      Logger.warn('HapticUtil', `shortVibrate failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * Double pulse — used when a point is scored.
   * Two 40 ms pulses separated by a 60 ms gap via sequential calls.
   */
  static scoreVibrate(): void {
    try {
      vibrator.startVibration(
        { type: 'time', duration: 40 },
        { id: 0, usage: 'touch' }
      );
      // Second pulse after gap — intentional delay via setTimeout
      setTimeout(() => {
        try {
          vibrator.startVibration(
            { type: 'time', duration: 40 },
            { id: 0, usage: 'touch' }
          );
        } catch (err) {
          Logger.warn('HapticUtil', `scoreVibrate second pulse failed: ${JSON.stringify(err)}`);
        }
      }, 100);
    } catch (err) {
      Logger.warn('HapticUtil', `scoreVibrate failed: ${JSON.stringify(err)}`);
    }
  }
}
