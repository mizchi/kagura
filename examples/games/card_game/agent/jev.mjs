import {JevClient as SharedClient,makeJevRequest as request} from '../../../../scripts/agents/jev.mjs';
export {loadApiKey} from '../../../../scripts/agents/jev.mjs';
const instructions = 'Choose one offered action to maximize the probability of completing the adventure alive. ' +
          'In menus prefer a viable character and adventure; the ascent allows building a stronger deck before bosses. ' +
          'On the map plan along connected nodes: balance battles, healing, treasure and shops using HP, gold and deck quality. ' +
          'Unique enemies have signature patterns and guaranteed relic rewards, but are dangerous. In shops buy useful upgrades or remove weak cards; keep gold for later if offers do not help. ' +
          'Events show exact HP and gold costs; avoid sacrificing health when vulnerable. Select relics that strengthen the current deck. ' +
          'During combat consider enemy intents, incoming damage, current Block, energy, card effects and powers. ' +
          'Block absorbs damage and normally resets next turn. Strength increases each attack hit; Weak reduces outgoing damage, Vulnerable increases incoming damage. ' +
          'Focus lethal attacks on enemies to prevent their actions. Use useful affordable cards before ending the turn, but avoid wasting Block beyond incoming damage. ' +
          'Use potions when they improve survival. Choose rewards that improve the deck and its synergies; skip weak additions. ' +
          'Hand and enemy indices refer to this exact revision. Choose only a supplied choice ID.';
export function makeJevRequest(observation,model='jev-latest'){return request(observation,model,instructions);}
export class JevClient extends SharedClient {constructor(options={}){super({...options,instructions});}}
