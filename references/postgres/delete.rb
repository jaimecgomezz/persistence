engine.delete
  .where(conditions)  # sym || Hash[sym, *] || Conditions
    .or(conditions)   # sym || Hash[sym, *] || Conditions
    .and(conditions)  # sym || Hash[sym, *] || Conditions
      .is(value)
      .is_not(value)
      .gt(value)
      .lt(value)
      .gte(value)
      .lte(value)
      .in(values)
      .between(a, b)
      .like(value)
      .is_null
      .is_empty
      .is_present
  ,return(fields)     # sym || [sym] || Hash[sym, nil || sym || string]
# .using TODO
