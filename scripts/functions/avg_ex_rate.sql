create or replace function AVG_EX_RATE(input AVG_EX_RATE_PARAMS) return number parallel_enable aggregate using AVG_EX_RATE_TYPE;

