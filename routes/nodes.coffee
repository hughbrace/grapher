#
#	GET all nodes.		
#
request = require("superagent")
exports.list = (req, res) ->
  dbURL = process.env.GRAPHENEDB_URL or "http://localhost:7474"
  request.post(dbURL + "/db/data/cypher").send(query: "MATCH (n) RETURN n;").end (neo4jRes) ->
    res.send neo4jRes.text
    return

  return
