engine.select
  .preload(association) # Hash[sym, SelectOperation]
  .distinct(fields)     # sym || [sym]
  .aggregate(field)     # sym || [sym] || Hash[sym, sym || Hash[sym, sym]]
    .average
    .count
    .max
    .mix
    .sum
        .as(name)
  .alias(map)           # Hash[symbol, sym || string]
  .where(conditions)    # sym || Hash[sym, *] || Conditions
    .not(conditions)    # sym || Hash[sym, *] || Conditions
    .or(conditions)     # sym || Hash[sym, *] || Conditions
    .and(conditions)    # sym || Hash[sym, *] || Conditions
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
  .group(fields)        # sym || [sym]
  .join(table)
    .inner              # default
      .on(a, b)
    .router
      .exclusive
        .on(a, b)
    .louter
      .exclusive
        .on(a, b)
    .outer
      .on(a, b)
    .on(a, b)
  .order(fields)
    .asc                # default
      .nulls(order)
    .desc
      .nulls(order)
  .limit(size)
  .offset(size)
  ,return(fields)       # sym || [sym] || Hash[sym, nil || sym || Hash[sym, sym]]
# .from(source)         # TODO
