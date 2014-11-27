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

describe "Models", ->
  beforeEach ->
    component = new tweak.Component window, {name:"test", model:{test2:"works"}}
    component.init()

  it "should be able to get data from model built from config", ->
    modelProperty = component.model.get "test2"
    expect(modelProperty).to.equal "works"

  it "should be able to get data from model built passed in config to component", ->
    modelProperty = component.model.get "test"
    expect(modelProperty).to.equal 100

  it "should be able to get data from model built independently of component", ->
    model = new tweak.Model @, {test:500}
    expect(model.get "test").to.equal 500

  it "should be able to set and get data from model", ->
    model = new tweak.Model @, {test:500}
    expect(model.get "test").to.equal 500
    model.set "test2", 5000
    expect(model.get "test2").to.equal 5000
      

  afterEach ->
    expect(component).to.have.property "name", "test"
    expect(component).to.have.property "view"
    expect(component).to.have.property "model"
    expect(component).to.have.property "components"
    expect(component).to.have.property "parent"
    expect(component).to.have.property "controller"
    expect(component).to.have.property "config"
