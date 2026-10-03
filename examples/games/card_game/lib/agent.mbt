///|
pub fn AgentSession::new(seed? : Int = 42) -> AgentSession {
  { scene: Title, character: Ironclad, seed, run: None, revision: 0, }
}

///|
pub fn AgentSession::start(
  character : CharacterId,
  stage : StageId,
  seed? : Int = 42,
) -> AgentSession {
  {
    scene: Playing,
    character,
    seed,
    run: Some(RunState::adventure(character, stage, seed~)),
    revision: 0,
  }
}

///|
pub fn AgentSession::is_terminal(self : AgentSession) -> Bool {
  self.run is Some({ phase: RunVictory | RunDefeat, .. })
}

///|
fn agent_play_choice(
  index : Int,
  target : Int,
  card : CardId,
  name : String,
) -> AgentChoice {
  {
    id: "play:\{index}:\{target}",
    label: "Play \{card_def(card).name} (hand \{index}) on \{name}",
    action: PlayCard(index, target),
  }
}

///|
/// Enumerate complete execution units, including the target. No target guessing
/// or client-side parsing is needed to apply an opaque choice ID.
pub fn AgentSession::choices(self : AgentSession) -> Array[AgentChoice] {
  match self.scene {
    Title =>
      return [{ id: "begin", label: "Begin an adventure", action: Begin, }]
    CharacterSelect =>
      return [
        {
          id: "character:ironclad",
          label: "Ironclad: 80 HP, Burning Blood heals 6 after battle, Bash applies Vulnerable",
          action: ChooseCharacter(Ironclad),
        },
        {
          id: "character:warden",
          label: "Warden: 96 HP, Anchor gives 10 starting Block, Body Slam deals damage equal to Block",
          action: ChooseCharacter(Warden),
        },
      ]
    StageSelect =>
      return [
        {
          id: "stage:ascent",
          label: "Ember Ascent: start at floor 1, build a deck over 30 floors and two acts",
          action: ChooseStage(Ascent),
        },
        {
          id: "stage:act_two",
          label: "Act Two: start at floor 16 with a starter deck against stronger enemies",
          action: ChooseStage(ActTwo),
        },
        {
          id: "stage:guardian_trial",
          label: "Guardian Trial: defeat the Guardian boss with a starter deck",
          action: ChooseStage(GuardianTrial),
        },
      ]
    Playing => ()
    Settings => return []
  }
  guard self.run is Some(run) else { return [] }
  let choices : Array[AgentChoice] = []
  match run.phase {
    RouteMap | EventRoom | ShopRoom | CardRemoval | TreasureRoom =>
      for choice in run_choices(run) {
        choices.push({
          id: choice.id,
          label: choice.label,
          action: Explore(choice.action),
        })
      }
    Battle => {
      guard run.battle is Some(b) else { return [] }
      if b.phase == Victory || b.phase == Defeat {
        return [
          {
            id: "continue",
            label: if b.phase == Victory {
              "Claim battle rewards and continue"
            } else {
              "Finish the defeated run"
            },
            action: ContinueBattle,
          },
        ]
      }
      if b.phase != PlayerTurn {
        return []
      }
      for index, card in b.hand {
        if can_play_card(b, index) {
          if card_needs_target(card) {
            for target, enemy in b.enemies {
              if !enemy.fighter.is_dead() {
                choices.push(
                  agent_play_choice(
                    index,
                    target,
                    card,
                    "\{enemy.fighter.name} (enemy \{target})",
                  ),
                )
              }
            }
          } else {
            choices.push(
              agent_play_choice(
                index,
                -1,
                card,
                if is_aoe_card(card) {
                  "all living enemies"
                } else {
                  "the player"
                },
              ),
            )
          }
        }
      }
      for index, potion in run.potions {
        let def = potion_def(potion)
        if def.usable_in_combat {
          if def.needs_target {
            for target, enemy in b.enemies {
              if !enemy.fighter.is_dead() {
                choices.push({
                  id: "potion:\{index}:\{target}",
                  label: "Use \{def.name} on \{enemy.fighter.name} (enemy \{target}): \{def.description}",
                  action: UsePotion(index, target),
                })
              }
            }
          } else {
            choices.push({
              id: "potion:\{index}:-1",
              label: "Use \{def.name}: \{def.description}",
              action: UsePotion(index, -1),
            })
          }
        }
      }
      choices.push({
        id: "end_turn",
        label: "End the player turn; resolve living enemy intents, discard the hand, restore energy and draw the next hand",
        action: EndTurn,
      })
    }
    CardReward => {
      for index, card in run.card_rewards {
        choices.push({
          id: "reward:\{index}",
          label: "Add \{card_def(card).name} to the permanent deck: \{card_def(card).description}",
          action: ChooseReward(index),
        })
      }
      choices.push({
        id: "skip_reward",
        label: "Skip the card reward and keep the deck small",
        action: SkipReward,
      })
    }
    RestSite =>
      choices.push({
        id: "rest",
        label: "Heal 25% of maximum HP and continue",
        action: Rest,
      })
    RunVictory | RunDefeat => ()
  }
  choices
}

///|
/// Compare revision and re-enumerate before mutation: a delayed response cannot
/// silently play the card that slid into an old hand index.
pub fn AgentSession::step(
  self : AgentSession,
  revision : Int,
  choice_id : String,
) -> AgentStepResult {
  if revision != self.revision {
    return StaleRevision
  }
  if self.is_terminal() {
    return Terminal
  }
  let mut found : AgentChoice? = None
  for choice in self.choices() {
    if choice.id == choice_id {
      found = Some(choice)
      break
    }
  }
  guard found is Some(choice) else { return IllegalChoice }
  match choice.action {
    Begin => self.scene = CharacterSelect
    ChooseCharacter(character) => {
      self.character = character
      self.scene = StageSelect
    }
    ChooseStage(stage) => {
      self.run = Some(
        RunState::adventure(self.character, stage, seed=self.seed),
      )
      self.scene = Playing
    }
    _ => {
      guard self.run is Some(run) else { return IllegalChoice }
      match choice.action {
        PlayCard(index, target) => {
          guard run.battle is Some(b) else { return IllegalChoice }
          if play_card(b, index, target) != Ok {
            return IllegalChoice
          }
        }
        UsePotion(index, target) => {
          guard run.battle is Some(b) else { return IllegalChoice }
          if !use_potion_in_combat(b, run.potions[index], target) {
            return IllegalChoice
          }
          run.potions.remove(index) |> ignore
        }
        EndTurn => {
          guard run.battle is Some(b) else { return IllegalChoice }
          end_player_turn(b)
        }
        ContinueBattle => {
          guard run.battle is Some(b) else { return IllegalChoice }
          if b.phase == Victory {
            on_battle_victory(run)
          } else {
            on_battle_defeat(run)
          }
        }
        ChooseReward(index) => pick_card_reward(run, index)
        SkipReward => pick_card_reward(run, -1)
        Rest => rest_heal(run)
        Explore(_) =>
          if !apply_run_choice(run, choice.id) {
            return IllegalChoice
          }
        _ => return IllegalChoice
      }
    }
  }
  self.revision += 1
  Applied
}
