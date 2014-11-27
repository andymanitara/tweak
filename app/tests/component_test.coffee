expect = chai.expect
###require.register "test/config", (exports, require, module) ->
  module.exports = {
    model:{
      test:100
    }
  }

describe "Component", ->
  
  beforeEach ->
    component = new tweak.Component window, {name:"test"}
    component.init()

  afterEach ->
    expect(component).to.have.property "name", "test"
    expect(component).to.have.property "view"
    expect(component).to.have.property "model"
    expect(component).to.have.property "components"
    expect(component).to.have.property "parent"
    expect(component).to.have.property "controller"
    expect(component).to.have.property "config"
###