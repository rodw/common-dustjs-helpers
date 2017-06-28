path                = require 'path'
fs                  = require 'fs'
HOMEDIR             = path.join __dirname, '..'
DOCROOT             = path.join HOMEDIR, 'test', 'test-data'
IS_INSTRUMENTED     = fs.existsSync(path.join(HOMEDIR,'lib-cov'))
LIB_DIR             = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')

#---------------------------------------------------------------------
should     = require 'should'


describe "index file", ()->

  it "exports various attributes", ()->
    index = require(path.join(LIB_DIR,'index'))
    expected = [
      "exportTo","export_to",
      "exportHelpersTo","export_helpers_to",
      "exportFiltersTo","export_filters_to",
      "renderTemplate","render_template"
    ]
    for v in expected
      should.exist index[v]

  it "can render templates", (done)->
    index = require(path.join(LIB_DIR,'index'))
    template = "Hello {name}."
    context = {name:"World"}
    expected = "Hello World."
    index.render_template template, context, (err, output)->
      should.not.exist err
      expected.should.equal output
      done()
