import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

export interface GameRecord {
  winner: string;
  playerScore: number;
  computerScore: number;
  timestamp: number;
}

const STORE_NAME = 'game_history';
const HISTORY_KEY = 'history';
const MAX_RECORDS = 10;

let context: common.UIAbilityContext | null = null;

export function initGameHistoryStore(ctx: common.UIAbilityContext): void {
  context = ctx;
}

async function getStore(): Promise<preferences.Preferences> {
  if (!context) {
    return Promise.reject(new Error('GameHistoryStore not initialized'));
  }
  return preferences.getPreferences(context, STORE_NAME);
}

export async function saveGame(winner: string, playerScore: number, computerScore: number): Promise<void> {
  const store = await getStore();
  const raw = await store.get(HISTORY_KEY, '[]') as string;
  const history: GameRecord[] = JSON.parse(raw) as GameRecord[];
  const record: GameRecord = { winner, playerScore, computerScore, timestamp: Date.now() };
  history.unshift(record);
  if (history.length > MAX_RECORDS) {
    history.splice(MAX_RECORDS);
  }
  await store.put(HISTORY_KEY, JSON.stringify(history));
  await store.flush();
}

export async function getHistory(): Promise<GameRecord[]> {
  const store = await getStore();
  const raw = await store.get(HISTORY_KEY, '[]') as string;
  return JSON.parse(raw) as GameRecord[];
}
