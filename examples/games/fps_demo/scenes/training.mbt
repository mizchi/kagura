// Edit scene literals here or in Kagura Studio. Keep behavior outside the managed region.
// kagura-scene:begin
pub fn training() -> @scene_document.Document {
  {
    version: 1,
    name: "FPS Demo training",
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
        color: 6649958,
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
        position: [0, 1.7, 5],
        rotation: [0, 0, 0],
        scale: [1, 1, 1],
        color: 4508774,
      }, {
        id: "target",
        name: "target",
        asset: "primitive.sphere",
        parent: "",
        position: [2, 1, 1],
        rotation: [0, 0, 0],
        scale: [1, 1, 1],
        color: 16763955,
      }, {
        id: "box",
        name: "box",
        asset: "primitive.box",
        parent: "",
        position: [-4, 0.5, 0],
        rotation: [0, 0, 0],
        scale: [2, 1, 2],
        color: 11176021,
      }],
    resources: [{
        id: "kagura.example",
        kind: "kagura.example",
        version: 1,
        data: {
          "example": "fps_demo",
          "query": Json::empty_object(),
        },
      }, {
        id: "kagura.scene",
        kind: "kagura.scene",
        version: 1,
        data: {
          "game": "fps_demo",
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
              "node": "target",
              "component": "target",
              "properties": Json::empty_object(),
            }, {
              "node": "box",
              "component": "box",
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
