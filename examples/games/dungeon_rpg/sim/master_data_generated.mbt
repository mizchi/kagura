// Generated from assets/master-data.json; run just dungeon-rpg-master-build.
///|
let default_master_source : String =
  #| {
  #|   "format": "kagura.master-data",
  #|   "version": 1,
  #|   "game": "dungeon_rpg",
  #|   "tables": {
  #|     "rules": [
  #|       {
  #|         "id": "expedition",
  #|         "enemy_hp_scale": 1,
  #|         "enemy_damage_scale": 1,
  #|         "encounter_steps": 8,
  #|         "sweep_damage": 4
  #|       }
  #|     ],
  #|     "enemies": [
  #|       {
  #|         "id": "rat",
  #|         "kind": 0,
  #|         "name": "大ねずみ",
  #|         "hp": 8,
  #|         "attack": 2,
  #|         "armor": 0,
  #|         "speed": 8,
  #|         "sweeps": false
  #|       },
  #|       {
  #|         "id": "skeleton",
  #|         "kind": 1,
  #|         "name": "骨の兵",
  #|         "hp": 16,
  #|         "attack": 4,
  #|         "armor": 1,
  #|         "speed": 3,
  #|         "sweeps": false
  #|       },
  #|       {
  #|         "id": "slime",
  #|         "kind": 2,
  #|         "name": "泥の塊",
  #|         "hp": 12,
  #|         "attack": 3,
  #|         "armor": 2,
  #|         "speed": 2,
  #|         "sweeps": false
  #|       },
  #|       {
  #|         "id": "lamp",
  #|         "kind": 3,
  #|         "name": "灯喰い",
  #|         "hp": 14,
  #|         "attack": 4,
  #|         "armor": 0,
  #|         "speed": 5,
  #|         "sweeps": false
  #|       },
  #|       {
  #|         "id": "guardian",
  #|         "kind": 4,
  #|         "name": "深淵の守護者",
  #|         "hp": 54,
  #|         "attack": 8,
  #|         "armor": 2,
  #|         "speed": 3,
  #|         "sweeps": true
  #|       },
  #|       {
  #|         "id": "spirit",
  #|         "kind": 5,
  #|         "name": "迷い火",
  #|         "hp": 10,
  #|         "attack": 3,
  #|         "armor": 0,
  #|         "speed": 6,
  #|         "sweeps": false
  #|       }
  #|     ],
  #|     "encounters": [
  #|       {
  #|         "id": "b1_a",
  #|         "context": "b1_a",
  #|         "enemy1": "rat",
  #|         "enemy2": "rat",
  #|         "enemy3": null
  #|       },
  #|       {
  #|         "id": "b1_b",
  #|         "context": "b1_b",
  #|         "enemy1": "skeleton",
  #|         "enemy2": "rat",
  #|         "enemy3": null
  #|       },
  #|       {
  #|         "id": "b2",
  #|         "context": "b2",
  #|         "enemy1": "skeleton",
  #|         "enemy2": "lamp",
  #|         "enemy3": "slime"
  #|       },
  #|       {
  #|         "id": "guardian",
  #|         "context": "guardian",
  #|         "enemy1": "guardian",
  #|         "enemy2": "spirit",
  #|         "enemy3": null
  #|       }
  #|     ]
  #|   }
  #| }
