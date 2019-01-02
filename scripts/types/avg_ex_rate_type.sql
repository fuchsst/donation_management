create or replace type AVG_EX_RATE_TYPE as object (
    TOTAL        number,
    CUM_EX_RATE  number,

    static function ODCIAggregateInitialize(SCTX in out AVG_EX_RATE_TYPE) return number,
    member function ODCIAggregateIterate(SELF in out AVG_EX_RATE_TYPE, VALUE in AVG_EX_RATE_PARAMS) return number,
    member function ODCIAggregateTerminate(SELF in AVG_EX_RATE_TYPE, RETURN_VALUE out number, FLAGS in number) return number,
    member function ODCIAggregateMerge(SELF in out AVG_EX_RATE_TYPE, CTX2 in AVG_EX_RATE_TYPE) return number
);
