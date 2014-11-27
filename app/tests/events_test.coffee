expect = chai.expect

describe "Event System", ->

  totalCalls = 0
  beforeEach ->
    tweak.Events.on window, "one/two/three", -> expect(true).to.equal true

  it "should be able to find event object", ->
    res = tweak.Events.find "one/two/three"
    found = typeof res is 'object'
    expect(found).to.equal true

  it "should be able to attempt finding event object that doesnt exist", ->
    res = tweak.Events.find "one/two/three/four"
    expect(res).to.equal null

  it "should be able to remove listener", ->
    res = tweak.Events.off window, "one/two/three"
    expect(res).to.equal true

  it "should be able to attempt removing of listener that doesnt exist without breaking", ->
    res = tweak.Events.off window, "one/two/three/four"
    expect(res).to.equal false
  
  it "should be able to trigger listener", ->
    tweak.Events.trigger "one/two/three"

  it "should be able attempt tigger of listener that doesnt exist without breaking", ->
    tweak.Events.trigger "one/two/four"

  it "should be able to add and remove nested events", ->
    empty = ->
    res = tweak.Events.on window, "one/two", empty
    expect(res).to.equal true
    res = tweak.Events.on window, "one/two/three/four", empty
    expect(res).to.equal true
    res = tweak.Events.off window, "one/two", empty
    expect(res).to.equal true
    res = tweak.Events.off window, "one/two/three/four", empty
    expect(res).to.equal true

  it "should be able to tigger up to maximum allowed calls", ->
    maxCalls = 2
    tweak.Events.on window, "one/two/three/four", -> totalCalls++
    ,
    maxCalls
    tweak.Events.trigger "one/two/three/four"
    tweak.Events.trigger "one/two/three/four"
    tweak.Events.trigger "one/two/three/four"
    expect(totalCalls).to.equal maxCalls

  it "should be able to tigger only events matching context", ->
    obj = {}
    tweak.Events.on obj, "one/two/three", -> expect(false).to.equal true
    tweak.Events.trigger {name:"one/two/three", context:window}

  afterEach ->
    tweak.Events.off window, "one/two/three"
    totalCalls = 0