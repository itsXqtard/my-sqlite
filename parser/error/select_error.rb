module ERROR
  COLUMN_FORMAT = "Select statement needs to be followed by * or column_name(s)"
  BODY = "Body of select statement missing"
  MISSING_FROM_CLAUSE = "Missing FROM clause"
  WRONG_CONSTRAINTS = "Wrong constraints for select statement"
  TABLE_MISSING = "table name missing"
  MISSING_JOIN_TABLE = "Missing table to join on"
  INCORRECT_JOIN = "Must be a file to join"
  MISSING_ON_CLAUSE = "Missing ON clause for JOIN"
  MISSING_ON_CONDITIONS = "No conditions were set to join"
  IMPROPER_ORDERING_CONDITION = "The ordering of the conditions are not correct"
  MISSING_LHS_OR_RHS_CONDITION = "Left hand side or right hand side is missing for ON condition"
  INCORRECT_RHS_ON_CONDITION = "Right hand side of assignment operator is incorrect"
  MISSING_WHERE_CONDITION = "Missing condition after WHERE clause"
  INCORRECT_WHERE_CONDITION = " Left hand side or right hand side is missing for WHERE condition"
  INCORRECT_RHS_WHERE_CONDITION = "Right hand side of assignment operator is incorrect"
  INCORRECT_ORDER_BY_KEY_WORD = "Wrong order by key word"
  INCORRECT_LENGTH_ORDER_BY = "Wrong length for condition to order by"
end