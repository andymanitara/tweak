expect = chai.expect
require.register "test/config", (exports, require, module) ->
  module.exports = {
    model:{
      test:100  
    }
  }

require.register "test2/config", (exports, require, module) ->
  module.exports = {}

require.register "extender/config", (exports, require, module) ->
  module.exports = 
    extends: "test2"

component = null
describe "Component", ->
  
  beforeEach ->
    component = new tweak.Component window, {name:"test", model:{test:"works"}}
    component.init()

  describe "Models", ->
    it "should be able to get data from model built from config", ->
      modelProperty = component.model.get "test"
      expect(modelProperty).to.equal "works"

  afterEach ->
    expect(component).to.have.property "name", "test"
    expect(component).to.have.property "view"
    expect(component).to.have.property "model"
    expect(component).to.have.property "components"
    expect(component).to.have.property "parent"
    expect(component).to.have.property "controller"
    expect(component).to.have.property "config"
