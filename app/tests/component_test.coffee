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
describe("Component", ->
  
  beforeEach ->
    component = new tweak.Component(window, "test")

  describe("Models", ->
    it("should have data built from config", ->

    )
  )

  afterEach ->
    expect(component).to.have.property("name", "test")
    expect(component).to.have.property("view")
    expect(component).to.have.property("model")
    expect(component).to.have.property("components")
    expect(component).to.have.property("parent")
    expect(component).to.have.property("controller")
    expect(component).to.have.property("config")
)