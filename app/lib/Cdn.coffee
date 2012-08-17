
throwError = (msg) ->
  throw new Error("CDN: " + msg)

renderAttributes = (attributes) ->
  str = []
  for name of attributes
    str.push escape(name) + "=\"" + escape(attributes[name]) + "\""
  str.sort().join " "

renderTag = (options, assets, attributes) ->
  
  # Set attributes
  attributes = attributes or {}
  
  # In production mode
  src = ""
  position = undefined
  if options.production
    src = "//" + options.domain
    
  buf = []
  if typeof assets is "object"
    i = 0

    while i < assets.length
      buf.push createTag(src, assets[i], attributes)
      return buf.join("\n") + "\n"  if (i + 1) is assets.length
      i += 1
  else if typeof assets is "string"
    createTag(src, assets, attributes) + "\n"
  else
    throwError "asset was not a string or an array"


createTag = (src, asset, attributes) ->
  urlItems = asset.split("/")
  urlItems.shift()
  
  # based on folder type
  switch urlItems[0]
    when "js"
      attributes.type = attributes.type or "text/javascript"
      attributes.src = src + asset
      "<script " + renderAttributes(attributes) + "></script>"
    when "css"
      attributes.rel = attributes.rel or "stylesheet"
      attributes.href = src + asset
      "<link " + renderAttributes(attributes) + " />"
    when "img"
      attributes.src = src + asset
      "<img " + renderAttributes(attributes) + " />"
    else
      throwError "unknown asset type"

CDN = (app, options) ->
  
  # Validate express
  throwError "requires express"  if typeof app isnt "object"
  
  # Validate options
  required = ["domain", "hostname", "port",  "production"]
  required.forEach (index) ->
    throwError "missing option \"" + options[index] + "\""  if typeof options[index] is "undefined"
  
  # Return the dynamic view helper
  (req, res) ->
    (assets, attributes) ->
      throwError "assets undefined"  if typeof assets is "undefined"
      renderTag options, assets, attributes

module.exports = CDN