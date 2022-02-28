engine.insert
  .fields(fields) # sym || [sym]
  .with(map)      # Hash[sym, *]
    .defaults
  ,return(fields) # sym || [sym] || Hash[sym, nil || sym || Hash[sym, sym]]
