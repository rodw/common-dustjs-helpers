path                        = require('path')
fs                          = require('fs')
HOMEDIR                     = path.join(__dirname,'..')
IS_INSTRUMENTED             = fs.existsSync(path.join(HOMEDIR,'lib-cov'))
LIB_DIR                     = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
exports                     = exports ? this
exports.CommonDustjsHelpers = require(path.join(LIB_DIR,'common-dustjs-helpers')).CommonDustjsHelpers
