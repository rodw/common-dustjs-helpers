path                        = require('path')
fs                          = require('fs')
HOMEDIR                     = path.join(__dirname,'..')
IS_INSTRUMENTED             = fs.existsSync(path.join(HOMEDIR,'lib-cov'))
LIB_DIR                     = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
exports                     = exports ? this
exports.CommonDustjsHelpers = require(path.join(LIB_DIR,'common-dustjs-helpers')).CommonDustjsHelpers
exports.INSTANCE            = new exports.CommonDustjsHelpers()
exports.exportTo            = exports.export_to         = exports.INSTANCE.export_to
exports.exportHelpersTo     = exports.export_helpers_to = exports.INSTANCE.export_helpers_to
exports.exportFiltersTo     = exports.export_filters_to = exports.INSTANCE.export_filters_to
exports.renderTemplate      = exports.render_template   = exports.INSTANCE.render_template
