#
# * GET home page.
# 
exports.index = (req, res) ->
  res.render "index",
    title: "Grapher"
  console.log "GET /"    
