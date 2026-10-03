export type Character = 'ironclad' | 'warden';
export type Stage = 'ascent' | 'act_two' | 'guardian_trial';
export type Phase = 'title' | 'character_select' | 'stage_select' | 'battle' |
  'battle_victory' | 'battle_defeat' | 'card_reward' | 'rest' | 'victory' | 'defeat' |
  'map' | 'event' | 'shop' | 'card_removal' | 'treasure';
export type Action =
  | { kind: 'begin' | 'end_turn' | 'continue' | 'skip_reward' | 'rest' }
  | { kind: 'choose_character'; character: 'Ironclad' | 'Warden' }
  | { kind: 'choose_stage'; stage: 'Ascent' | 'ActTwo' | 'GuardianTrial' }
  | { kind: 'play_card'; handIndex: number; targetIndex: number }
  | { kind: 'use_potion'; potionIndex: number; targetIndex: number }
  | { kind: 'choose_reward'; rewardIndex: number }
  | { kind: 'choose_node'; nodeId: number }
  | { kind: 'choose_event'; optionIndex: number }
  | { kind: 'buy'; offerIndex: number }
  | { kind: 'remove_card'; deckIndex: number }
  | { kind: 'choose_relic'; relicIndex: number }
  | { kind: 'open_card_removal' | 'cancel_removal' | 'leave_shop' };
export interface Choice { id: string; label: string; action: Action }
export interface Card {
  id: string; name: string; type: 'Attack' | 'Skill' | 'Power'; cost: number;
  printedCost: number; description: string; baseDamage: number; baseBlock: number;
  exhaust: boolean; needsTarget: boolean;
}
export interface Pile { count: number; cards: Array<{ id: string; count: number }> }
export interface Fighter {
  name: string; hp: number; maxHp: number; block: number; energy: number; maxEnergy: number;
  strength: number; weak: number; vulnerable: number;
}
export interface Battle {
  turn: number; player: Fighter; hand: Array<Card & { handIndex: number; playable: boolean }>;
  enemies: Array<{ enemyIndex: number; id: string; alive: boolean; unique: boolean; pattern: string; fighter: Fighter;
    intent: { kind: 'attack' | 'defend' | 'buff' | 'debuff'; base: number; hits: number; damageBeforeBlock: number } }>;
  incomingDamageBeforeBlock: number; drawPile: Pile; discardPile: Pile; exhaustPile: Pile;
  powers: { metallicize: number; demonForm: number; barricade: boolean; feelNoPain: number;
    flexLoss: number; rampageBonus: number; corruption: boolean; regen: number };
  recentEvents: string[];
}
export interface Observation {
  schemaVersion: 2; revision: number; phase: Phase; terminal: boolean; choices: Choice[];
  run: null | {
    character: 'Ironclad' | 'Warden'; stage: 'Ascent' | 'ActTwo' | 'GuardianTrial';
    floor: number; act: number; hp: number; maxHp: number; gold: number; deck: Pile;
    room: RoomKind | null; map: RouteMap | null; event: EventRoom | null; shop: ShopRoom | null;
    treasure: Relic[]; removalDeck: Card[];
    relics: Array<{ id: string; name: string; description: string }>;
    potions: Array<{ potionIndex: number; id: string; name: string; description: string }>;
    rewards: Card[]; battle: Battle | null;
  };
}
export interface SessionOptions { seed?: number; character?: Character; stage?: Stage }
export interface HeadlessSession {
  observe(): Observation;
  step(command: { revision: number; choiceId: string }): Observation;
}
export interface Decision {
  choiceId: string; confidence: number; probabilities: Record<string, number>; model: string;
  usage: { inputTokens: number; outputTokens: number }; elapsedMs: number; attempts: number;
}
export interface Summary {
  type: 'run_end'; schemaVersion: 2; status: 'victory' | 'defeat' | 'limit' | 'error';
  decisions: number; observation: Observation;
  usage: { inputTokens: number; outputTokens: number; requests: number }; elapsedMs: number;
  error?: { code: string };
}
export interface JevRequest {
  model: string; state: Omit<Observation, 'choices'>;
  questions: { next_action: { type: 'choice'; instructions: string;
    criteria: Record<string, { description: string; action: Action }> } };
}
export interface RunStartRecord {
  type: 'run_start'; schemaVersion: 2; seed: number; character: Character | null;
  stage: Stage | null; model: string; startedAt: string; observation: Observation;
}
export interface DecisionRecord {
  type: 'decision'; schemaVersion: 2; index: number; revision: number; choiceId: string;
  decision: Decision; before: Observation; after: Observation;
}
export type AgentRecord = RunStartRecord | DecisionRecord | Summary;

export type RoomKind = 'BATTLE' | 'ELITE' | 'UNIQUE' | 'BOSS' | 'REST' | 'EVENT' | 'SHOP' | 'TREASURE';
export interface Relic { id: string; name: string; description: string }
export interface RouteMap {
  act: number; current: number | null;
  nodes: Array<{ id: number; floor: number; lane: number; kind: RoomKind; next: number[]; visited: boolean; available: boolean }>;
}
export interface EventRoom { id: string; title: string; story: string;
  options: Array<{ index: number; label: string; description: string; enabled: boolean }> }
export interface ShopRoom {
  offers: Array<{ index: number; kind: 'card' | 'relic' | 'potion'; name: string; description: string;
    price: number; sold: boolean; enabled: boolean }>;
  removalPrice: number; removalEnabled: boolean; discountPercent: number;
}
