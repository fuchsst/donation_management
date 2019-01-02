create or replace type body AVG_EX_RATE_TYPE is
    static function ODCIAggregateInitialize(SCTX in out AVG_EX_RATE_TYPE) return number
    is
    begin
        SCTX := AVG_EX_RATE_TYPE( 0, null );
        return ODCIConst.Success;
    end;


   member function ODCIAggregateIterate(SELF in out AVG_EX_RATE_TYPE, VALUE in AVG_EX_RATE_PARAMS) return number
   is
   begin
      if (VALUE.EX_RATE is not null and (nvl(VALUE.VALUE,0) + nvl(SELF.TOTAL,0))>0) then
        SELF.CUM_EX_RATE := ((nvl(VALUE.VALUE,0) * nvl(VALUE.EX_RATE,0)) + (nvl(SELF.TOTAL,0) * nvl(SELF.CUM_EX_RATE,0))) / (nvl(VALUE.VALUE,0) + nvl(SELF.TOTAL,0));
      end if; 
      SELF.TOTAL := nvl(VALUE.VALUE,0) + nvl(SELF.TOTAL,0);
      return ODCIConst.Success;
   end;
 
   member function ODCIAggregateTerminate(SELF in AVG_EX_RATE_TYPE, RETURN_VALUE out number, FLAGS in number) return number
   is
   begin
       if (nvl(SELF.CUM_EX_RATE,0)>0) then
           RETURN_VALUE := SELF.CUM_EX_RATE;
       else
           RETURN_VALUE := null;
       end if;
       return ODCIConst.Success;
   end;
 
   member function ODCIAggregateMerge(SELF in out AVG_EX_RATE_TYPE, CTX2 in AVG_EX_RATE_TYPE) return number
   is
   begin
       if (SELF.CUM_EX_RATE is not null and CTX2.CUM_EX_RATE is not null and (nvl(SELF.TOTAL,0) + nvl(CTX2.TOTAL,0)) > 0) then
           SELF.CUM_EX_RATE := ((nvl(SELF.TOTAL,0) * nvl(SELF.CUM_EX_RATE,0)) + (nvl(CTX2.TOTAL,0) * nvl(CTX2.CUM_EX_RATE,0))) / (nvl(SELF.TOTAL,0) + nvl(CTX2.TOTAL,0));
       elsif (CTX2.CUM_EX_RATE is not null and nvl(CTX2.TOTAL,0) > 0) then
           SELF.CUM_EX_RATE := CTX2.CUM_EX_RATE;
       end if;
       SELF.TOTAL := nvl(SELF.TOTAL,0) + nvl(CTX2.TOTAL,0);
       return ODCIConst.Success;
   end;
 
end;
