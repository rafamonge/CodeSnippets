-- Disable all table constraints
ALTER TABLE TableTheHasAFkToAnotherTable NOCHECK CONSTRAINT ALL

set identity_insert AnotherTable on

Delete from AnotherTable
Insert into AnotherTable


set identity_insert AnotherTable off

ALTER TABLE TableTheHasAFkToAnotherTable CHECK CONSTRAINT ALL