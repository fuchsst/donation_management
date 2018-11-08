insert into GENDER (name, code) values ('boy', 'M');
insert into GENDER (name, code) values ('girl', 'F');
commit;

insert into ACCOUNT_BOOKING_TYPE(name, code) values ('Expenditure', 'EXPENDITURE');
insert into ACCOUNT_BOOKING_TYPE(name, code) values ('Money Received', 'MONEY_RECEIVED');
insert into ACCOUNT_BOOKING_TYPE(name, code) values ('Conversion (payment)', 'CONVERSION_PAYMENT');
insert into ACCOUNT_BOOKING_TYPE(name, code) values ('Conversion (fee)', 'CONVERSION_FEE');
insert into ACCOUNT_BOOKING_TYPE(name, code) values ('Conversion (deposit)', 'CONVERSION_DEPOSIT');
commit;

insert into CONFIG_FEE_EXPENSE_TYPE(fee_code) values ('DONATION_FEE');
insert into CONFIG_FEE_EXPENSE_TYPE(fee_code) values ('CONVERSION_SEND_FEE');
insert into CONFIG_FEE_EXPENSE_TYPE(fee_code) values ('CONVERSION_RECEIVE_FEE');
commit;
