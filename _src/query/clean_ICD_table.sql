-- Clean up icd-10 Table.
DROP TABLE  if exists icd_10_clean
CREATE TABLE icd_10_clean as
    (SELECT id, trim(icd_10) as icd10, icd_tier, condition
FROM icd_10)