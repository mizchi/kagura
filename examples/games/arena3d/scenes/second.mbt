// Edit scene literals here or in Kagura Studio. Keep behavior outside the managed region.
// kagura-scene:begin
pub fn second() -> @scene_document.Document {
  {
    version: 1,
    name: "Arena 3D second",
    units: "meters",
    up: "Y",
    forward: "+Z",
    nodes: [{
        id: "floor",
        name: "floor",
        asset: "primitive.box",
        parent: "",
        position: [0, -0.125, 0],
        rotation: [0, 0, 0],
        scale: [18, 0.25, 18],
        color: 8415056,
      }, {
        id: "wall",
        name: "wall",
        asset: "primitive.box",
        parent: "",
        position: [4, 1, 0],
        rotation: [0, 0, 0],
        scale: [1, 2, 5],
        color: 5464690,
      }, {
        id: "spawn",
        name: "spawn",
        asset: "primitive.sphere",
        parent: "",
        position: [0, 0.5, 5],
        rotation: [0, 0, 0],
        scale: [1, 1, 1],
        color: 4508774,
      }, {
        id: "item",
        name: "item",
        asset: "primitive.sphere",
        parent: "",
        position: [2, 0.3, 1],
        rotation: [0, 0, 0],
        scale: [1, 1, 1],
        color: 16763955,
      }, {
        id: "enemy",
        name: "enemy",
        asset: "primitive.box",
        parent: "",
        position: [-5, 0.5, -5],
        rotation: [0, 0, 0],
        scale: [1, 1, 1],
        color: 15615027,
      }],
    resources: [{
        id: "kagura.example",
        kind: "kagura.example",
        version: 1,
        data: {
          "example": "arena3d",
          "query": Json::empty_object(),
        },
      }, {
        id: "kagura.scene",
        kind: "kagura.scene",
        version: 1,
        data: {
          "game": "arena3d",
          "bindings": [{
              "node": "floor",
              "component": "floor",
              "properties": Json::empty_object(),
            }, {
              "node": "wall",
              "component": "wall",
              "properties": Json::empty_object(),
            }, {
              "node": "spawn",
              "component": "spawn",
              "properties": Json::empty_object(),
            }, {
              "node": "item",
              "component": "item",
              "properties": Json::empty_object(),
            }, {
              "node": "enemy",
              "component": "enemy",
              "properties": Json::empty_object(),
            }],
        },
      }],
    action: {
      target: "",
      duration: 1,
      flashDuration: 0.08,
      recoilDuration: 0.3,
      recoilStrength: 0.4,
    },
  }
}
// kagura-scene:end
