CREATE SEQUENCE currency_seq;

CREATE TABLE currency (
  currency_id  NUMBER DEFAULT ON NULL currency_seq.NEXTVAL,
  name         VARCHAR2(100) NOT NULL,
  symbol       VARCHAR2(3),
  code         CHAR(3) NOT NULL,
  CONSTRAINT currency_pk PRIMARY KEY (currency_id),
  CONSTRAINT currency_u1 UNIQUE (name),
  CONSTRAINT currency_u2 UNIQUE (code)
);
COMMENT ON TABLE currency IS 'List of currencies';

CREATE SEQUENCE project_seq;

CREATE TABLE project (
  project_id        NUMBER DEFAULT ON NULL project_seq.NEXTVAL,
  name              VARCHAR2(100) NOT NULL,
  description       VARCHAR2(4000),
  base_currency_id  NUMBER,
  created_on        TIMESTAMP DEFAULT SYSDATE,
  created_by        VARCHAR2(30),
  updated_on        TIMESTAMP DEFAULT SYSDATE,
  updated_by        VARCHAR2(30),
  CONSTRAINT project_pk PRIMARY KEY (project_id),
  CONSTRAINT project_u1 UNIQUE (project_id, name),
  CONSTRAINT project_f1 FOREIGN KEY (base_currency_id) REFERENCES currency(base_currency_id)
);
COMMENT ON TABLE project IS 'Project is the top level entity to separate data already on login. A project might be the social organisation itself.';


CREATE SEQUENCE payment_method_seq;

CREATE TABLE payment_method (
  payment_method_id  NUMBER DEFAULT ON NULL payment_method_seq.NEXTVAL,
  name               VARCHAR2(100) NOT NULL,
  description        VARCHAR2(4000),
  project_id         NUMBER NOT NULL,
  CONSTRAINT payment_method_pk PRIMARY KEY (payment_method_id),
  CONSTRAINT payment_method_u1 UNIQUE (project_id, name),
  CONSTRAINT payment_method_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE payment_method IS 'List of ways that money can be received';


CREATE SEQUENCE conversion_provider_seq;

CREATE TABLE conversion_provider (
  conversion_provider_id  NUMBER DEFAULT ON NULL conversion_provider_seq.NEXTVAL,
  name                    VARCHAR2(100) NOT NULL,
  description             VARCHAR2(4000),
  project_id              NUMBER NOT NULL,
  CONSTRAINT conversion_provider_pk PRIMARY KEY (conversion_provider_id),
  CONSTRAINT conversion_provider_u1 UNIQUE (project_id, name),
  CONSTRAINT conversion_provider_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE conversion_provider IS 'List of providers that convert/transfer money';


CREATE SEQUENCE gender_seq;

CREATE TABLE gender (
  gender_id    NUMBER DEFAULT ON NULL gender_seq.NEXTVAL,
  name         VARCHAR2(100) NOT NULL,
  code         CHAR(1) NOT NULL,
  CONSTRAINT gender_pk PRIMARY KEY (gender_id),
  CONSTRAINT gender_u1 UNIQUE (name)
);
COMMENT ON TABLE gender IS 'List of genders';


CREATE SEQUENCE region_seq;

CREATE TABLE region (
  region_id    NUMBER DEFAULT ON NULL region_seq.NEXTVAL,
  name         VARCHAR2(100) NOT NULL,
  description  VARCHAR2(4000),
  project_id   NUMBER NOT NULL,
  CONSTRAINT region_pk PRIMARY KEY (region_id),
  CONSTRAINT region_u1 UNIQUE (project_id, name),
  CONSTRAINT region_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE region IS 'List of regions where kids are assigned to';

CREATE INDEX region_ix1 ON school(project_id);


CREATE SEQUENCE term_seq;

CREATE TABLE term (
  term_id      NUMBER DEFAULT ON NULL term_seq.NEXTVAL,
  name         VARCHAR2(100) NOT NULL,
  description  VARCHAR2(4000),
  school_year  NUMBER(4) NOT NULL,
  project_id   NUMBER NOT NULL,
  created_on   TIMESTAMP DEFAULT SYSDATE,
  created_by   VARCHAR2(30),
  updated_on   TIMESTAMP DEFAULT SYSDATE,
  updated_by   VARCHAR2(30),  
  CONSTRAINT term_pk PRIMARY KEY (term_id),
  CONSTRAINT term_u1 UNIQUE (project_id, name),
  CONSTRAINT term_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE term IS 'List of school terms (e.g. "Term 1 /2018")';


CREATE SEQUENCE grade_seq;

CREATE TABLE grade (
  grade_id     NUMBER DEFAULT ON NULL grade_seq.NEXTVAL,
  name         VARCHAR2(100) NOT NULL,
  is_boarding  CHAR(1) DEFAULT 'N' NOT NULL,
  grade_order  NUMBER NOT NULL,
  project_id   NUMBER NOT NULL,
  CONSTRAINT grade_pk PRIMARY KEY (grade_id),
  CONSTRAINT grade_u1 UNIQUE (project_id, name),
  CONSTRAINT grade_c1 CHECK (is_boarding IN ('Y', 'N')),
  CONSTRAINT grade_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE grade IS 'List of school grades (e.g. "Primary 1"), incl. separate entries for boarding school classes';


CREATE SEQUENCE school_seq;

CREATE TABLE school (
  school_id     NUMBER DEFAULT ON NULL school_seq.NEXTVAL,
  school_name   VARCHAR2(100) NOT NULL,
  address       VARCHAR2(200),
  head_teacher  VARCHAR2(100),
  contact       VARCHAR2(100),
  annotation    VARCHAR2(4000),
  region_id     NUMBER NOT NULL,
  created_on    TIMESTAMP DEFAULT SYSDATE,
  created_by    VARCHAR2(30),
  updated_on    TIMESTAMP DEFAULT SYSDATE,
  updated_by    VARCHAR2(30),
  CONSTRAINT school_pk PRIMARY KEY (school_id),
  CONSTRAINT school_u1 UNIQUE (region_id, school_name),
  CONSTRAINT school_f1 FOREIGN KEY (region_id) REFERENCES region(region_id)
);
COMMENT ON TABLE school IS 'List of schools';



CREATE SEQUENCE school_grade_ref_seq;

CREATE TABLE school_grade_ref(
  school_grade_ref_id  NUMBER DEFAULT ON NULL school_grade_ref_seq.NEXTVAL,
  school_id            NUMBER NOT NULL,
  grade_id             NUMBER NOT NULL,
  created_on           TIMESTAMP DEFAULT SYSDATE,
  created_by           VARCHAR2(30),
  updated_on           TIMESTAMP DEFAULT SYSDATE,
  updated_by           VARCHAR2(30),
  CONSTRAINT school_grade_ref_pk PRIMARY KEY (school_grade_ref_id),
  CONSTRAINT school_grade_ref_u1 UNIQUE (school_id, grade_id)
);

COMMENT ON TABLE school_grade_ref IS 'Link of Grades that are offered by a school';


CREATE SEQUENCE school_grade_term_seq;

CREATE TABLE school_grade_term (
  school_grade_term_id  NUMBER DEFAULT ON NULL school_grade_term_seq.NEXTVAL,
  school_grade_ref_id   NUMBER NOT NULL,
  term_id               NUMBER NOT NULL,
  fee_per_term          NUMBER(*, 4) NOT NULL,
  term_begin            DATE NOT NULL,
  term_end              DATE NOT NULL,
  created_on            TIMESTAMP DEFAULT SYSDATE,
  created_by            VARCHAR2(30),
  updated_on            TIMESTAMP DEFAULT SYSDATE,
  updated_by            VARCHAR2(30),
  CONSTRAINT school_grade_term_pk PRIMARY KEY (school_grade_term_id),
  CONSTRAINT school_grade_term_u1 UNIQUE (school_grade_ref_id, term_id),
  CONSTRAINT school_grade_term_f1 FOREIGN KEY (school_grade_ref_id) REFERENCES school_grade_ref(school_grade_ref_id),
  CONSTRAINT school_grade_term_f2 FOREIGN KEY (term_id) REFERENCES term(term_id),
  CONSTRAINT school_grade_term_c1 CHECK (term_begin<term_end)
);
COMMENT ON TABLE school_grade_term IS 'Definition of schools with the offered grades and the definition of their term period/fees';

CREATE INDEX school_grade_term_ix1 ON school_grade_term(term_id);


CREATE SEQUENCE kid_seq;

CREATE TABLE kid (
  kid_id            NUMBER DEFAULT ON NULL kid_seq.NEXTVAL,
  kid_number        NUMBER NOT NULL,
  forename          VARCHAR2(100) NOT NULL,
  surname           VARCHAR2(100),
  gender_id         NUMBER NOT NULL,
  birthday          DATE,
  annotation        CLOB,
  picture           BLOB, 
  picture_mime      VARCHAR2(100),
  picture_filename  VARCHAR2(255),
  project_id        NUMBER NOT NULL,
  created_on        TIMESTAMP DEFAULT SYSDATE,
  created_by        VARCHAR2(30),
  updated_on        TIMESTAMP DEFAULT SYSDATE,
  updated_by        VARCHAR2(30),
  CONSTRAINT kid_pk PRIMARY KEY (kid_id),
  CONSTRAINT kid_f1 FOREIGN KEY (gender_id) REFERENCES gender(gender_id)
  CONSTRAINT kid_u1 UNIQUE (project_id, kid_number)
);
COMMENT ON TABLE kid IS 'List of kids that might be part of the program';


CREATE SEQUENCE donator_seq;

CREATE TABLE donator (
  donator_id    NUMBER DEFAULT ON NULL donator_seq.NEXTVAL,
  donator_name  VARCHAR2(200) NOT NULL,
  email         VARCHAR2(100),
  annotation    VARCHAR2(4000), 
  project_id    NUMBER NOT NULL,
  created_on    TIMESTAMP DEFAULT SYSDATE,
  created_by    VARCHAR2(30),
  updated_on    TIMESTAMP DEFAULT SYSDATE,
  updated_by    VARCHAR2(30),
  CONSTRAINT donator_pk PRIMARY KEY (donator_id),
  CONSTRAINT donator_c1 UNIQUE (donator_name)
);
COMMENT ON TABLE donator IS 'List of donators';


CREATE SEQUENCE kid_in_program_seq;

CREATE TABLE kid_in_program (
  kid_in_program_id  NUMBER DEFAULT ON NULL kid_in_program_seq.NEXTVAL,
  kid_id             NUMBER NOT NULL,
  region_id          NUMBER NOT NULL,
  in_program_from    DATE NOT NULL,
  in_program_to      DATE,
  created_on         TIMESTAMP DEFAULT SYSDATE,
  created_by         VARCHAR2(30),
  updated_on         TIMESTAMP DEFAULT SYSDATE,
  updated_by         VARCHAR2(30),
  CONSTRAINT kid_in_program_pk PRIMARY KEY (kid_in_program_id),
  CONSTRAINT kid_in_program_u1 UNIQUE (kid_id, in_program_from),
  CONSTRAINT kid_in_program_f1 FOREIGN KEY (kid_id) REFERENCES kid(kid_id),
  CONSTRAINT kid_in_program_f2 FOREIGN KEY (region_id) REFERENCES region(region_id),
  CONSTRAINT kid_in_program_c1 CHECK (in_program_from<in_program_to OR in_program_to IS NULL)
);
COMMENT ON TABLE kid_in_program IS 'Historical references of the kids that are part of the program.';

CREATE INDEX kid_in_program_ix1 ON kid_in_program(region_id);


CREATE SEQUENCE kid_donator_ref_seq;

CREATE TABLE kid_donator_ref (
  kid_donator_ref_id  NUMBER DEFAULT ON NULL kid_donator_ref_seq.NEXTVAL,
  kid_in_program_id   NUMBER NOT NULL,
  donator_id          NUMBER NOT NULL,
  sponsored_from      DATE NOT NULL,
  sponsored_to        DATE,
  created_on          TIMESTAMP DEFAULT SYSDATE,
  created_by          VARCHAR2(30),
  updated_on          TIMESTAMP DEFAULT SYSDATE,
  updated_by          VARCHAR2(30),
  CONSTRAINT kid_donator_ref_pk PRIMARY KEY (kid_donator_ref_id),
  CONSTRAINT kid_donator_ref_u1 UNIQUE (kid_in_program_id, sponsored_from),
  CONSTRAINT kid_donator_ref_f1 FOREIGN KEY (kid_in_program_id) REFERENCES kid_in_program(kid_in_program_id),
  CONSTRAINT kid_donator_ref_f2 FOREIGN KEY (donator_id) REFERENCES donator(donator_id),
  CONSTRAINT kid_donator_ref_c1 CHECK (sponsored_from<sponsored_to OR sponsored_to IS NULL)
);
COMMENT ON TABLE kid_donator_ref IS 'Historical references between kids in the program and their sponsors.';

CREATE INDEX kid_donator_ref_ix1 ON kid_donator_ref(kid_in_program_id);
CREATE INDEX kid_donator_ref_ix2 ON kid_donator_ref(donator_id);


CREATE SEQUENCE kid_school_term_ref_seq;

CREATE TABLE kid_school_term_ref (
  kid_school_term_ref_id  NUMBER DEFAULT ON NULL kid_school_term_ref_seq.NEXTVAL,
  kid_in_program_id       NUMBER NOT NULL,
  school_grade_term_id    NUMBER NOT NULL,
  created_on              TIMESTAMP DEFAULT SYSDATE,
  created_by              VARCHAR2(30),
  updated_on              TIMESTAMP DEFAULT SYSDATE,
  updated_by              VARCHAR2(30),
  CONSTRAINT kid_school_term_ref_pk PRIMARY KEY (kid_school_term_ref_id),
  CONSTRAINT kid_school_term_ref_u1 UNIQUE (kid_in_program_id, school_grade_term_id),
  CONSTRAINT kid_school_term_ref_f1 FOREIGN KEY (kid_in_program_id) REFERENCES kid_in_program(kid_in_program_id),
  CONSTRAINT kid_school_term_ref_f2 FOREIGN KEY (school_grade_term_id) REFERENCES school_grade_term(school_grade_term_id)
);
COMMENT ON TABLE kid_school_term_ref IS 'Historical references of the kids that are part of the program.';

CREATE INDEX kid_school_term_ref_ix1 ON kid_school_term_ref(school_grade_term_id);


CREATE SEQUENCE campaign_seq;

CREATE TABLE campaign (
  campaign_id    NUMBER DEFAULT ON NULL campaign_seq.NEXTVAL,
  name           VARCHAR2(100) NOT NULL,
  project_id     NUMBER NOT NULL,
  created_on     TIMESTAMP DEFAULT SYSDATE,
  created_by     VARCHAR2(30),
  updated_on     TIMESTAMP DEFAULT SYSDATE,
  updated_by     VARCHAR2(30),
  CONSTRAINT campaign_pk PRIMARY KEY (campaign_id),
  CONSTRAINT campaign_u1 UNIQUE (project_id, name),
  CONSTRAINT campaign_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE campaign IS 'A subdivision of a project. Each donation within a campaign can only be spend for a purpose within that campaign.';


CREATE SEQUENCE purpose_seq;

CREATE TABLE purpose (
  purpose_id    NUMBER DEFAULT ON NULL purpose_seq.NEXTVAL,
  name          VARCHAR2(100) NOT NULL,
  description   VARCHAR2(4000),
  project_id    NUMBER NOT NULL,
  color_code    VARCHAR2(10),
  created_on    TIMESTAMP DEFAULT SYSDATE,
  created_by    VARCHAR2(30),
  updated_on    TIMESTAMP DEFAULT SYSDATE,
  updated_by    VARCHAR2(30),
  CONSTRAINT purpose_pk PRIMARY KEY (purpose_id),
  CONSTRAINT purpose_u1 UNIQUE (project_id, name),
  CONSTRAINT purpose_f1 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE purpose IS 'A general grouping of the donations/expenidtures to define their usage.';


CREATE SEQUENCE purpose_campaign_ref_seq;

CREATE TABLE purpose_campaign_ref (
  purpose_campaign_ref_id  NUMBER DEFAULT ON NULL purpose_exp_type_ref_seq.NEXTVAL,
  purpose_id               NUMBER NOT NULL,
  campaign_id              NUMBER NOT NULL,
  created_on               TIMESTAMP DEFAULT SYSDATE,
  created_by               VARCHAR2(30),
  updated_on               TIMESTAMP DEFAULT SYSDATE,
  updated_by               VARCHAR2(30),
  CONSTRAINT purpose_campaign_ref_pk PRIMARY KEY (purpose_campaign_ref_id),
  CONSTRAINT purpose_campaign_ref_u1 UNIQUE (campaign_id, purpose_id),
  CONSTRAINT purpose_campaign_ref_f1 FOREIGN KEY (purpose_id) REFERENCES purpose(purpose_id),
  CONSTRAINT purpose_campaign_ref_f2 FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id)
);
COMMENT ON TABLE purpose_campaign_ref IS 'Link of purposes to the campaigns where they can be used';

CREATE INDEX purpose_campaign_ref_ix1 on purpose_campaign_ref(purpose_campaign_ref_id);


CREATE SEQUENCE expenditure_type_seq;

CREATE TABLE expenditure_type (
  expenditure_type_id    NUMBER DEFAULT ON NULL expenditure_type_seq.NEXTVAL,
  name                   VARCHAR2(100) NOT NULL,
  description            VARCHAR2(4000),
  purpose_id             NUMBER NOT NULL,
  created_on             TIMESTAMP DEFAULT SYSDATE,
  created_by             VARCHAR2(30),
  updated_on             TIMESTAMP DEFAULT SYSDATE,
  updated_by             VARCHAR2(30),
  CONSTRAINT expenditure_type_pk PRIMARY KEY (expenditure_type_id),
  CONSTRAINT expenditure_type_u1 UNIQUE (purpose_id, name),
  CONSTRAINT expenditure_type_f1 FOREIGN KEY (purpose_id) REFERENCES purpose(purpose_id)
);
COMMENT ON TABLE expenditure_type IS 'A specific kind of expenditure (e.g. "School fees for School A, Primary 1 Term 2").';




CREATE SEQUENCE school_fee_donation_budget_seq;

CREATE TABLE school_fee_donation_budget (
  school_fee_donation_budget_id  NUMBER DEFAULT ON NULL school_fee_donation_budget_seq.NEXTVAL,
  term_id                        NUMBER,
  grade_id                       NUMBER,
  amount                         NUMBER(*, 4),
  currency_id                    NUMBER,
  linked_expenditure_type_id     NUMBER,
  created_on             TIMESTAMP DEFAULT SYSDATE,
  created_by             VARCHAR2(30),
  updated_on             TIMESTAMP DEFAULT SYSDATE,
  updated_by             VARCHAR2(30),
  CONSTRAINT school_fee_donation_budget_pk PRIMARY KEY (school_fee_donation_budget_id),
  CONSTRAINT school_fee_donation_budget_u1 UNIQUE (term_id, grade_id),
  CONSTRAINT school_fee_donation_budget_f1 FOREIGN KEY (term_id) REFERENCES term(term_id),
  CONSTRAINT school_fee_donation_budget_f2 FOREIGN KEY (grade_id) REFERENCES grade(grade_id),
  CONSTRAINT school_fee_donation_budget_f3 FOREIGN KEY (currency_id) REFERENCES currency(currency_id)
);

CREATE INDEX school_fee_donation_budget_ix1 on school_fee_donation_budget(grade_id);
CREATE INDEX school_fee_donation_budget_ix2 on school_fee_donation_budget(currency_id);
CREATE INDEX school_fee_donation_budget_ix3 on school_fee_donation_budget(linked_expenditure_type_id);

COMMENT ON TABLE school_fee_donation_budget IS 'Budget for each school-term (per grade) to be donated';

CREATE SEQUENCE account_seq;

CREATE TABLE account (
  account_id    NUMBER DEFAULT ON NULL account_seq.NEXTVAL,
  name          VARCHAR2(100) NOT NULL,
  code          VARCHAR2(30) NOT NULL,
  currency_id   NUMBER NOT NULL,
  description   VARCHAR2(4000),
  project_id    NUMBER NOT NULL,
  created_on    TIMESTAMP DEFAULT SYSDATE,
  created_by    VARCHAR2(30),
  updated_on    TIMESTAMP DEFAULT SYSDATE,
  updated_by    VARCHAR2(30),
  CONSTRAINT account_pk PRIMARY KEY (account_id),
  CONSTRAINT account_u1 UNIQUE (project_id, name),
  CONSTRAINT account_u2 UNIQUE (project_id, code),
  CONSTRAINT account_f1 FOREIGN KEY (currency_id) REFERENCES currency(currency_id),
  CONSTRAINT account_f2 FOREIGN KEY (project_id) REFERENCES project(project_id)
);
COMMENT ON TABLE account IS 'Account in the currency donations are received in (e.g. Euro, or US$), normally a bank account.';

CREATE INDEX account_ix1 on account(currency_id);


CREATE SEQUENCE account_booking_type_seq;

CREATE TABLE account_booking_type (
  account_booking_type_id  NUMBER DEFAULT ON NULL account_booking_type_seq.NEXTVAL,
  name                     VARCHAR2(100) NOT NULL,
  code                     VARCHAR2(30) NOT NULL,
  in_out_factor            NUMBER NOT NULL,
  CONSTRAINT account_booking_type_pk PRIMARY KEY (account_booking_type_id),
  CONSTRAINT account_booking_type_u1 UNIQUE (name),
  CONSTRAINT account_booking_type_u2 UNIQUE (code),
  CONSTRAINT account_booking_type_c1 CHECK (in_out_factor in (-1,0,1))
);
COMMENT ON TABLE account_booking_type IS 'Bookings (transactions) on the accounts (referenced by the income/convert/spend tables).';


CREATE SEQUENCE account_booking_seq;

CREATE TABLE account_booking (
  account_booking_id       NUMBER DEFAULT ON NULL account_booking_seq.NEXTVAL,
  account_id               NUMBER NOT NULL,
  account_booking_type_id  NUMBER NOT NULL,
  booking_entered_date     TIMESTAMP NOT NULL,
  amount                   NUMBER(*, 4) NOT NULL,
  created_on               TIMESTAMP DEFAULT SYSDATE,
  created_by               VARCHAR2(30),
  updated_on               TIMESTAMP DEFAULT SYSDATE,
  updated_by               VARCHAR2(30),
  CONSTRAINT account_booking_pk PRIMARY KEY (account_booking_id),
  CONSTRAINT account_booking_f1 FOREIGN KEY (account_id) REFERENCES account(account_id),
  CONSTRAINT account_booking_f2 FOREIGN KEY (account_booking_type_id) REFERENCES account_booking_type(account_booking_type_id)
);
COMMENT ON TABLE account_booking IS 'Bookings (transactions) on the accounts (referenced by the income/convert/spend tables).';

CREATE INDEX account_booking_ix1 on account_booking(account_id);
CREATE INDEX account_booking_ix2 on account_booking(account_booking_type_id);


CREATE SEQUENCE expense_seq;

CREATE TABLE expense (
  expense_id              NUMBER DEFAULT ON NULL expense_seq.NEXTVAL,
  campaign_id             NUMBER NOT NULL,
  expenditure_type_id     NUMBER NOT NULL,
  expense_date            DATE NOT NULL,
  account_booking_id      NUMBER NOT NULL,
  annotation              VARCHAR2(4000),
  units                   NUMBER,
  invoice_image           BLOB,
  invoice_image_mime      VARCHAR2(100),
  invoice_image_filename  VARCHAR2(255),
  created_on              TIMESTAMP DEFAULT SYSDATE,
  created_by              VARCHAR2(30),
  updated_on              TIMESTAMP DEFAULT SYSDATE,
  updated_by              VARCHAR2(30),
  CONSTRAINT expense_pk PRIMARY KEY (expense_id),
  CONSTRAINT expense_f1 FOREIGN KEY (expenditure_type_id) REFERENCES expenditure_type(expenditure_type_id),
  CONSTRAINT expense_f2 FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
  CONSTRAINT expense_f3 FOREIGN KEY (account_booking_id) REFERENCES account_booking(account_booking_id)
);
COMMENT ON TABLE expense IS 'Transactions of all expenses from local accounts. Optionally the number of units (e.g. kilogram when buying beans) can be stated';

CREATE INDEX expense_ix1 on expense(expenditure_type_id);
CREATE INDEX expense_ix2 on campaign(campaign_id);
CREATE INDEX expense_ix3 on expense(account_booking_id);

CREATE SEQUENCE expense_kid_distr_seq;

CREATE TABLE expense_kid_distr (
  expense_kid_distr_id  NUMBER DEFAULT ON NULL expense_kid_distr_seq.NEXTVAL,
  expense_id            NUMBER NOT NULL,
  kid_in_program_id     NUMBER NOT NULL,
  school_grade_term_id  NUMBER,
  amount                NUMBER(*, 4) NOT NULL,
  created_on            TIMESTAMP DEFAULT SYSDATE,
  created_by            VARCHAR2(30),
  updated_on            TIMESTAMP DEFAULT SYSDATE,
  updated_by            VARCHAR2(30),
  CONSTRAINT expense_kid_distr_pk PRIMARY KEY (expense_kid_distr_id),
  CONSTRAINT expense_kid_distr_u1 UNIQUE (expense_id, kid_in_program_id),
  CONSTRAINT expense_kid_distr_f1 FOREIGN KEY (expense_id) REFERENCES expense(expense_id) ON DELETE CASCADE,
  CONSTRAINT expense_kid_distr_f2 FOREIGN KEY (kid_in_program_id) REFERENCES kid_in_program(kid_in_program_id),
  CONSTRAINT expense_kid_distr_f3 FOREIGN KEY (school_grade_term_id) REFERENCES school_grade_term(school_grade_term_id)
);
COMMENT ON TABLE expense_kid_distr IS 'Distribution of an expense among kids. Optionally the school term can be mentioned.';

CREATE INDEX expense_kid_distr_ix1 on expense_kid_distr(kid_in_program_id);
CREATE INDEX expense_kid_distr_ix2 on expense_kid_distr(school_grade_term_id);


CREATE SEQUENCE received_money_seq;

CREATE TABLE received_money (
  received_money_id            NUMBER DEFAULT ON NULL received_money_seq.NEXTVAL,
  donator_id                   NUMBER NOT NULL,
  donation_date                DATE NOT NULL,
  received_date                DATE,
  transaction_code             VARCHAR2(100),
  payment_method_id            NUMBER NOT NULL,
  campaign_id                  NUMBER NOT NULL,
  purpose_id                   NUMBER NOT NULL,
  fee_expense_id               NUMBER,
  received_account_booking_id  NUMBER NOT NULL,
  created_on                   TIMESTAMP DEFAULT SYSDATE,
  created_by                   VARCHAR2(30),
  updated_on                   TIMESTAMP DEFAULT SYSDATE,
  updated_by                   VARCHAR2(30),
  CONSTRAINT received_money_pk PRIMARY KEY (received_money_id),
  CONSTRAINT received_money_u1 UNIQUE (payment_method_id, transaction_code),
  CONSTRAINT received_money_f1 FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id),
  CONSTRAINT received_money_f2 FOREIGN KEY (purpose_id) REFERENCES purpose(purpose_id),
  CONSTRAINT received_money_f3 FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id),
  CONSTRAINT received_money_f4 FOREIGN KEY (fee_expense_id) REFERENCES expense(expense_id) ON DELETE SET NULL,
  CONSTRAINT received_money_f5 FOREIGN KEY (received_account_booking_id) REFERENCES account_booking(account_booking_id)
);
COMMENT ON TABLE received_money IS 'Transactions of donations. The currency of the of the donated amount must be the same as the currency of the account that receives the donation!';

CREATE INDEX received_money_ix1 on received_money(donator_id);
CREATE INDEX received_money_ix2 on received_money(campaign_id);
CREATE INDEX received_money_ix3 on received_money(purpose_id);
CREATE INDEX received_money_ix4 on received_money(received_account_booking_id);


CREATE SEQUENCE received_money_kid_distr_seq;

CREATE TABLE received_money_kid_distr (
  received_money_kid_distr_id  NUMBER DEFAULT ON NULL received_money_kid_distr_seq.NEXTVAL,
  received_money_id            NUMBER NOT NULL,
  kid_in_program_id            NUMBER NOT NULL,
  term_id                      NUMBER,
  amount                       NUMBER(*, 4) NOT NULL,
  created_on                   TIMESTAMP DEFAULT SYSDATE,
  created_by                   VARCHAR2(30),
  updated_on                   TIMESTAMP DEFAULT SYSDATE,
  updated_by                   VARCHAR2(30),
  CONSTRAINT received_money_kid_distr_pk PRIMARY KEY (received_money_kid_distr_id),
  CONSTRAINT received_money_kid_distr_u1 UNIQUE (received_money_id, kid_in_program_id, term_id),
  CONSTRAINT received_money_kid_distr_f1 FOREIGN KEY (received_money_id) REFERENCES received_money(received_money_id) ON DELETE CASCADE,
  CONSTRAINT received_money_kid_distr_f2 FOREIGN KEY (kid_in_program_id) REFERENCES kid_in_program(kid_in_program_id),
  CONSTRAINT received_money_kid_distr_f3 FOREIGN KEY (term_id) REFERENCES term(term_id)
);
COMMENT ON TABLE received_money IS 'Transactions of donations. The currency of the of the donated amount must be the same as the currency of the account that receives the donation! Optionally it can also be stated which school term this payment relates to.';

CREATE INDEX received_money_kid_distr_ix1 on received_money_kid_distr(kid_in_program_id);


CREATE SEQUENCE conversion_seq;

CREATE TABLE conversion (
  conversion_id                  NUMBER DEFAULT ON NULL conversion_seq.NEXTVAL,
  transaction_code               VARCHAR2(30) NOT NULL,
  conversion_provider_id         NUMBER NOT NULL,
  conversion_initiated_date      DATE,
  conversion_date                DATE NOT NULL,
  from_account_booking_id        NUMBER NOT NULL,
  to_account_booking_id          NUMBER NOT NULL,
  from_fee_expense_id            NUMBER,
  to_fee_expense_id              NUMBER,
  conversion_receipt_image       BLOB,
  conversion_receipt_image_mime  VARCHAR2(100),
  conversion_receipt_image_fname VARCHAR2(255),
  created_on                     TIMESTAMP DEFAULT SYSDATE,
  created_by                     VARCHAR2(30),
  updated_on                     TIMESTAMP DEFAULT SYSDATE,
  updated_by                     VARCHAR2(30),
  CONSTRAINT conversion_pk PRIMARY KEY (conversion_id),
  CONSTRAINT conversion_u1 UNIQUE (conversion_provider_id, transaction_code),
  CONSTRAINT conversion_f1 FOREIGN KEY (conversion_provider_id) REFERENCES conversion_provider(conversion_provider_id),
  CONSTRAINT conversion_f2 FOREIGN KEY (from_account_booking_id) REFERENCES account_booking(account_booking_id),
  CONSTRAINT conversion_f3 FOREIGN KEY (to_account_booking_id) REFERENCES account_booking(account_booking_id),
  CONSTRAINT conversion_f4 FOREIGN KEY (from_fee_expense_id) REFERENCES expense(expense_id) ON DELETE SET NULL,
  CONSTRAINT conversion_f5 FOREIGN KEY (to_fee_expense_id) REFERENCES expense(expense_id) ON DELETE SET NULL
);
COMMENT ON TABLE conversion IS 'Transactions of conversions from donation to local accounts.';

CREATE INDEX conversion_ix1 on conversion(from_account__booking_id);
CREATE INDEX conversion_ix2 on conversion(to_account_booking_id);
CREATE INDEX conversion_ix3 on conversion(fee_account_booking_id);


CREATE TABLE config_fee_expense_type (
  fee_code             VARCHAR2(30),
  expenditure_type_id  NUMBER,
  campaign_id          NUMBER,
  CONSTRAINT config_fee_expense_type_pk PRIMARY KEY (fee_code),
  CONSTRAINT config_fee_expense_type_f1 FOREIGN KEY (expenditure_type_id) REFERENCES expenditure_type(expenditure_type_id),
  CONSTRAINT config_fee_expense_type_f2 FOREIGN KEY (campaign_id) REFERENCES campaign(campaign_id)
);
