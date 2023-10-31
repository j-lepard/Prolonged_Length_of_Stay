-- TODO: investigate why there are still many vitals that are not captured by the cross tab query.
-- TODO: USE THIS FORMAT FOR THE OTHER VITALS AND LABS

------------ PART 1: CREATE FILTEREDE VITALS TABLE

-- Create a  filtered Vitals table :: REMOVE ANY vitals BEFORE OR_OUT
-- result: reduces record count from 8M to 1.6M.
CREATE TABLE Vitals_postop AS
SELECT V.*
FROM Vitals V
JOIN operation_pcd O ON V.op_id = O.op_id
WHERE V.chart_time >= O.orout_time;
select count (*) from vitals_postop;

---------------------------------- PART 2 - use python. Run away from below!!!







--  IMPLEMENTATION
    --------------------------------
DROP TABLE IF EXISTS tmp_equal_time;
Create table tmp_equal_time as (
    SELECT v.subject_id, v.op_id, v.chart_time, item_name, value
    FROM vitals v
    LEFT JOIN operation_pcd o ON v.op_id = o.op_id
    WHERE v.chart_time = o.orout_time
);
-- CHECK
Select count ( distinct op_id) from tmp_equal_time;
-- Result = 68552

-- >> REMOVED THE MIN TIME AND UNION PORTION

-- DROP TABLE if EXISTS  tmp_min_chart_time
-- Create table tmp_min_chart_time AS (
--     SELECT v.subject_id, v.op_id, MIN(v.chart_time) as chart_time
--     FROM vitals v
--     LEFT JOIN operation_pcd o ON v.op_id = o.op_id
--     WHERE v.chart_time > o.orout_time
--     GROUP BY v.subject_id, v.op_id
-- );
-- Select count ( distinct op_id) from tmp_min_chart_time;
-- -- Result = 35994
--
-- DROP TABLE if EXISTS tmp_combined_charts
-- create table tmp_combined_charts AS (
--     SELECT * FROM tmp_equal_time
--     UNION ALL
--     SELECT * FROM tmp_min_chart_time mat
-- --     WHERE NOT EXISTS (SELECT 1 FROM tmp_equal_time et WHERE et.op_id = mat.op_id)
-- );
-- -- CHECK
-- select count (distinct op_id) from tmp_combined_charts;

-- -- PART 3 - Perform the Crosstab on results.
-- -- CROSSTAB VERsION 3

DROP TABLE IF EXISTS operation_first_vitals;
CREATE TABLE operation_first_vitals AS
WITH crosstabresults_vital AS (
        SELECT
        op_id, subject_id, chart_time,
        aft,
        air,
        alb20,
        alb5,
        art_dbp,
        art_mbp,
        art_sbp,
        bis,
        bt,
        cbro2,
        ci,
        cpat,
        cryo,
        cvp,
        d10w,
        d50w,
        d5w,
        dobui,
        dopai,
        ds,
        ebl,
        eph,
        epi,
        epii,
        etco2,
        etdes,
        etgas,
        etiso,
        etsevo,
        ffp,
        fio2,
        ftn,
        hes,
        hns,
        hr,
        hs,
        mdz,
        minvol,
        mlni,
        n2o,
        nepi,
        nibp_dbp,
        nibp_mbp,
        nibp_sbp,
        ns,
        ntgi,
        o2,
        pap_dbp,
        pap_mbp,
        pap_sbp,
        pc,
        peep,
        pepi,
        phe,
        pheresis,
        pip,
        pmean,
        ppf,
        ppfi,
        pplat,
        psa,
        rbc,
        rfti,
        rr,
        sft,
        spo2,
        sti,
        stii,
        stiii,
        stv5,
        svi,
        uo,
        vaso,
        vt

        FROM
        crosstab(
          'SELECT op_id, subject_id, chart_time, item_name, value
           FROM tmp_equal_time
            ORDER BY 1,2,3',
            $$VALUES
            ('aft'::text),
            ('air'::text),
            ('alb20'::text),
            ('alb5'::text),
            ('art_dbp'::text),
            ('art_mbp'::text),
            ('art_sbp'::text),
            ('bis'::text),
            ('bt'::text),
            ('cbro2'::text),
            ('ci'::text),
            ('cpat'::text),
            ('cryo'::text),
            ('cvp'::text),
            ('d10w'::text),
            ('d50w'::text),
            ('d5w'::text),
            ('dobui'::text),
            ('dopai'::text),
            ('ds'::text),
            ('ebl'::text),
            ('eph'::text),
            ('epi'::text),
            ('epii'::text),
            ('etco2'::text),
            ('etdes'::text),
            ('etgas'::text),
            ('etiso'::text),
            ('etsevo'::text),
            ('ffp'::text),
            ('fio2'::text),
            ('ftn'::text),
            ('hes'::text),
            ('hns'::text),
            ('hr'::text),
            ('hs'::text),
            ('mdz'::text),
            ('minvol'::text),
            ('mlni'::text),
            ('n2o'::text),
            ('nepi'::text),
            ('nibp_dbp'::text),
            ('nibp_mbp'::text),
            ('nibp_sbp'::text),
            ('ns'::text),
            ('ntgi'::text),
            ('o2'::text),
            ('pap_dbp'::text),
            ('pap_mbp'::text),
            ('pap_sbp'::text),
            ('pc'::text),
            ('peep'::text),
            ('pepi'::text),
            ('phe'::text),
            ('pheresis'::text),
            ('pip'::text),
            ('pmean'::text),
            ('ppf'::text),
            ('ppfi'::text),
            ('pplat'::text),
            ('psa'::text),
            ('rbc'::text),
            ('rfti'::text),
            ('rr'::text),
            ('sft'::text),
            ('spo2'::text),
            ('sti'::text),
            ('stii'::text),
            ('stiii'::text),
            ('stv5'::text),
            ('svi'::text),
            ('uo'::text),
            ('vaso'::text),
            ('vt'::text)
            $$
        )
        AS ct_vital(
            op_id integer, subject_id integer, chart_time integer,
            aft numeric,
            air numeric,
            alb20 numeric,
            alb5 numeric,
            art_dbp numeric,
            art_mbp numeric,
            art_sbp numeric,
            bis numeric,
            bt numeric,
            cbro2 numeric,
            ci numeric,
            cpat numeric,
            cryo numeric,
            cvp numeric,
            d10w numeric,
            d50w numeric,
            d5w numeric,
            dobui numeric,
            dopai numeric,
            ds numeric,
            ebl numeric,
            eph numeric,
            epi numeric,
            epii numeric,
            etco2 numeric,
            etdes numeric,
            etgas numeric,
            etiso numeric,
            etsevo numeric,
            ffp numeric,
            fio2 numeric,
            ftn numeric,
            hes numeric,
            hns numeric,
            hr numeric,
            hs numeric,
            mdz numeric,
            minvol numeric,
            mlni numeric,
            n2o numeric,
            nepi numeric,
            nibp_dbp numeric,
            nibp_mbp numeric,
            nibp_sbp numeric,
            ns numeric,
            ntgi numeric,
            o2 numeric,
            pap_dbp numeric,
            pap_mbp numeric,
            pap_sbp numeric,
            pc numeric,
            peep numeric,
            pepi numeric,
            phe numeric,
            pheresis numeric,
            pip numeric,
            pmean numeric,
            ppf numeric,
            ppfi numeric,
            pplat numeric,
            psa numeric,
            rbc numeric,
            rfti numeric,
            rr numeric,
            sft numeric,
            spo2 numeric,
            sti numeric,
            stii numeric,
            stiii numeric,
            stv5 numeric,
            svi numeric,
            uo numeric,
            vaso numeric,
            vt numeric
        )
)
SELECT op.op_id, c.subject_id, c.chart_time,
        COALESCE(c.aft,0) as aft,
        COALESCE(c.air,0) as air,
        COALESCE(c.alb20,0) as alb20,
        COALESCE(c.alb5,0) as alb5,
        COALESCE(c.art_dbp,0) as art_dbp,
        COALESCE(c.art_mbp,0) as art_mbp,
        COALESCE(c.art_sbp,0) as art_sbp,
        COALESCE(c.bis,0) as bis,
        COALESCE(c.bt,0) as bt,
        COALESCE(c.cbro2,0) as cbro2,
        COALESCE(c.ci,0) as ci,
        COALESCE(c.cpat,0) as cpat,
        COALESCE(c.cryo,0) as cryo,
        COALESCE(c.cvp,0) as cvp,
        COALESCE(c.d10w,0) as d10w,
        COALESCE(c.d50w,0) as d50w,
        COALESCE(c.d5w,0) as d5w,
        COALESCE(c.dobui,0) as dobui,
        COALESCE(c.dopai,0) as dopai,
        COALESCE(c.ds,0) as ds,
        COALESCE(c.ebl,0) as ebl,
        COALESCE(c.eph,0) as eph,
        COALESCE(c.epi,0) as epi,
        COALESCE(c.epii,0) as epii,
        COALESCE(c.etco2,0) as etco2,
        COALESCE(c.etdes,0) as etdes,
        COALESCE(c.etgas,0) as etgas,
        COALESCE(c.etiso,0) as etiso,
        COALESCE(c.etsevo,0) as etsevo,
        COALESCE(c.ffp,0) as ffp,
        COALESCE(c.fio2,0) as fio2,
        COALESCE(c.ftn,0) as ftn,
        COALESCE(c.hes,0) as hes,
        COALESCE(c.hns,0) as hns,
        COALESCE(c.hr,0) as hr,
        COALESCE(c.hs,0) as hs,
        COALESCE(c.mdz,0) as mdz,
        COALESCE(c.minvol,0) as minvol,
        COALESCE(c.mlni,0) as mlni,
        COALESCE(c.n2o,0) as n2o,
        COALESCE(c.nepi,0) as nepi,
        COALESCE(c.nibp_dbp,0) as nibp_dbp,
        COALESCE(c.nibp_mbp,0) as nibp_mbp,
        COALESCE(c.nibp_sbp,0) as nibp_sbp,
        COALESCE(c.ns,0) as ns,
        COALESCE(c.ntgi,0) as ntgi,
        COALESCE(c.o2,0) as o2,
        COALESCE(c.pap_dbp,0) as pap_dbp,
        COALESCE(c.pap_mbp,0) as pap_mbp,
        COALESCE(c.pap_sbp,0) as pap_sbp,
        COALESCE(c.pc,0) as pc,
        COALESCE(c.peep,0) as peep,
        COALESCE(c.pepi,0) as pepi,
        COALESCE(c.phe,0) as phe,
        COALESCE(c.pheresis,0) as pheresis,
        COALESCE(c.pip,0) as pip,
        COALESCE(c.pmean,0) as pmean,
        COALESCE(c.ppf,0) as ppf,
        COALESCE(c.ppfi,0) as ppfi,
        COALESCE(c.pplat,0) as pplat,
        COALESCE(c.psa,0) as psa,
        COALESCE(c.rbc,0) as rbc,
        COALESCE(c.rfti,0) as rfti,
        COALESCE(c.rr,0) as rr,
        COALESCE(c.sft,0) as sft,
        COALESCE(c.spo2,0) as spo2,
        COALESCE(c.sti,0) as sti,
        COALESCE(c.stii,0) as stii,
        COALESCE(c.stiii,0) as stiii,
        COALESCE(c.stv5,0) as stv5,
        COALESCE(c.svi,0) as svi,
        COALESCE(c.uo,0) as uo,
        COALESCE(c.vaso,0) as vaso,
        COALESCE(c.vt,0) as vt

FROM operation_pcd op
LEFT JOIN crosstabresults_vital c ON op.op_id = c.op_id;

select count (*) from operation_first_vitals;









-------- Below is a bit janky ignore
SELECT icd_description,
       count (distinct icd10_pcs)
FROM operations_proc
GROUP BY icd_description
ORDER by count DESC



-- Create an abbreviate PCS table
-- Create an abbreviated PCS table
DROP TABLE IF EXISTS pcs_abbr;

CREATE TABLE icd_pcs_abbr AS
WITH NumberedRows AS (
    SELECT
        pcs_trunc,
        desc_short,
        category_id,
        category_desc,
        ROW_NUMBER() OVER(PARTITION BY pcs_trunc ORDER BY pcs_trunc) AS rn
    FROM
        icd_pcs
)
SELECT
    pcs_trunc,
    desc_short,
    category_id,
    category_desc
FROM
    NumberedRows
WHERE
    rn = 1; ;

-- Join the Operations with the PCS description
Select o.op_id,
       o.subject_id,
       o.hadm_id,
       o.case_id,
       o.opdate,
       o.age,
       o.sex,
       o.weight,
       o.height,
       o.race,
       o.asa,
       o.emop,
       o.department,
       o.antype,
       o.icd10_pcs,
       p.category_desc,p.desc_short,p.category_id,
       o.orin_time,
       o.orout_time,
       o.opstart_time,
       o.opend_time,
       o.admission_time,
       o.discharge_time,
       o.anstart_time,
       o.anend_time,
       o.cpbon_time,
       o.cpboff_time,
       o.icuin_time,
       o.icuout_time,
       o.inhosp_death_time
FROM operations o
JOIN icd_pcs_abbr p
on o.icd10_pcs=p.pcs_trunc
Where subject_id = 187733661;

-- create table operation_pcd. It includes information about the oepration performed.
Drop TABLE  if exists operation_pcd
CREATE TABLE operation_pcd AS (
    Select o.op_id,
       o.subject_id,
       o.hadm_id,
       o.case_id,
       o.opdate,
       o.age,
       o.sex,
       o.weight,
       o.height,
       o.race,
       o.asa,
       o.emop,
       o.department,
       o.antype,
       o.icd10_pcs,
       p.category_desc,p.desc_short,p.category_id,
       o.orin_time,
       o.orout_time,
       o.opstart_time,
       o.opend_time,
       o.admission_time,
       o.discharge_time,
       o.anstart_time,
       o.anend_time,
       o.cpbon_time,
       o.cpboff_time,
       o.icuin_time,
       o.icuout_time,
       o.inhosp_death_time
FROM operations o
JOIN icd_pcs_abbr p
on o.icd10_pcs=p.pcs_trunc);

-- OR v.chart_time IS NULL

WITH MinVitals AS (
    SELECT v.hv.subject_id, MIN(v.chart_time) AS min_vital_time
    FROM vitals v
    JOIN operations_proc o
    ON v.subject_id = o.subject_id
    WHERE v.chart_time > o.orout_time and o.subject_id = 155688823
    GROUP BY v.had
)
SELECT *
FROM MinVitals

----- CONTINUED


-- OR v.chart_time IS NULL

WITH MinVitals AS (
    SELECT v.subject_id, v.op_id,MIN(v.chart_time) AS min_vital_time
    FROM vitals v
    JOIN operation_pcd o
        -- Join Tables on OPERATION ID
    ON v.op_id = o.op_id
    WHERE v.chart_time >= o.orout_time
    GROUP BY v.subject_id,v.op_id
)
SELECT *
FROM MinVitals



/*
 WHERE v.chart_time > o.orout_time get 35,994 results
 WHERE  v.chart_time = o.orout_time get 68,552 result
 WHERE v.chart_time >= o.orout_time get 72,261 result
 Decision - use >= for the chart times as gives larger data set.
 */


--- Change to Vitals Taken at DX from OR. So OR-out == Vital chart time.
--  This looks more promising. Now need to transponse it and then attach it to the Operations_vitals table(to crate)
WITH Vital_leaving_OR AS (
    SELECT v.op_id, v.subject_id, v.chart_time, v.item_name, v.value
    FROM vitals v
    JOIN operation_pcd o
        -- Join Tables on OPERATION ID
    ON v.op_id = o.op_id
    WHERE v.chart_time = o.orout_time
--     GROUP BY v.subject_id,v.op_id
)
SELECT count(op_id)
FROM Vital_leaving_OR


--CROSS TAB CREATING
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- USE THE CROSS TAB

-- Create a list of the Vitals Names
Select distinct(item_name)
From vitals;

-- QUESTIONS:
    -- There are 128,031 distinct op_id in OPERATIONS
    -- There are 131,000 distinct op_id in VITALS
    -- Therefore we should see roughly equal counts in the MinVitals Table... but we dont. Fuck.


---- PART 1 - Filter the Vitals Times to either the time at OR discharge or the MIN (earliest) in the Ward)
DROP TABLE  IF EXISTS tmp_MinVitals;
CREATE TEMP TABLE tmp_MinVitals AS (
    SELECT v.subject_id, v.op_id,MIN(v.chart_time) AS min_vital_time
    FROM vitals v
    JOIN operation_pcd o
    ON v.op_id = o.op_id
    WHERE v.chart_time >= o.orout_time
    GROUP BY v.subject_id,v.op_id
);
-- TEST: Confirm count of Op_id records in tmp_MinVitals = 72,261
Select count(op_id)
From tmp_MinVitals

-- TEST : Which operations.op_id records DO NOT appear in the Vitals table
SELECT o.op_id
FROM operation_pcd o
LEFT JOIN Vitals v ON o.op_id = v.op_id
WHERE v.op_id IS NULL;

-- TEST: Confirm count of op_id in Operations table (regardless of min Vitals) = 128,031
-- QUESTION - where did all the vitals go? Are there that many people who didnt get vitals in the ward.
-- How to find them?
select count (distinct op_id)
from vitals;


----------------------------------------

SELECT COUNT(DISTINCT o.op_id)
FROM operation_pcd o
LEFT JOIN vitals v ON o.op_id = v.op_id
WHERE v.chart_time IS NULL OR (v.chart_time <> o.orout_time AND v.chart_time < o.orout_time);
--- RESULT : 128,000

-- Next - Confirm how many results have charting == to OR OUT
-- REsult 68,552
    SELECT COUNT(DISTINCT o.op_id)
FROM operation_pcd o
JOIN vitals v ON o.op_id = v.op_id
WHERE v.chart_time = o.orout_time;

-- And for the MIN portion if there is no exact match
-- Result 35994
WITH MinAfterTimes AS (
    SELECT v.subject_id, v.op_id, MIN(v.chart_time) AS vital_time
    FROM vitals v
    JOIN operation_pcd o ON v.op_id = o.op_id
    WHERE v.chart_time > o.orout_time
    GROUP BY v.subject_id, v.op_id
)
SELECT COUNT(DISTINCT op_id) FROM MinAfterTimes;

-- Given that these two conditions are mutually exclusive by design,
-- the total number of unique op_id values that match either condition should be:
-- 68,552 (from EqualTimes) + 35,994 (from MinAfterTimes) = 104,546
-- Try fixing using UNION ALL


-- -- PART 2 - Temp Table of all the VITALs Joined with the MinVitals to filter.
CREATE TEMP TABLE tmp_vital_leaving_or AS
SELECT v.op_id, v.subject_id, v.chart_time, v.item_name, v.value
FROM vitals v
JOIN operation_pcd o ON v.op_id = o.op_id
JOIN tmp_MinVitals mv ON v.subject_id = mv.subject_id AND v.op_id = mv.op_id
WHERE v.chart_time = o.orout_time;

-- TEST: Confirm count records
-- -- Result count op_id= 641,229 total records (>1 per subject-expected)
-- -- Result count distinct op_id= 68,552 total records (>1 per subject-expected)
Select count (distinct op_id)
FROM tmp_vital_leaving_or;

-- ALTERNATIVE IMPLEMENTATION
    --------------------------------
DROP TABLE IF EXISTS tmp_equal_time;
Create temp table tmp_equal_time as (
    SELECT v.subject_id, v.op_id, v.chart_time, item_name, value
    FROM vitals v
    LEFT JOIN operation_pcd o ON v.op_id = o.op_id
    WHERE v.chart_time = o.orout_time
);
-- CHECK
Select * from tmp_equal_time;

DROP TABLE if EXISTS  tmp_min_chart_time
Create temp table tmp_min_chart_time AS (
    SELECT v.subject_id, v.op_id, MIN(v.chart_time) as chart_time, item_name, value
    FROM vitals v
    LEFT JOIN operation_pcd o ON v.op_id = o.op_id
    WHERE v.chart_time > o.orout_time
    GROUP BY v.subject_id, v.op_id, item_name, value
);
Select * from tmp_min_chart_time;

DROP TABLE if EXISTS tmp_combined_charts
create temp table tmp_combined_charts AS (
    SELECT * FROM tmp_equal_time
    UNION ALL
    SELECT * FROM tmp_min_chart_time mat
    WHERE NOT EXISTS (SELECT 1 FROM tmp_equal_time et WHERE et.op_id = mat.op_id)
);
-- CHECK
select count (distinct op_id) from tmp_combined_charts;

-- -- PART 3 - Perform the Crosstab on results. VERSION 1 was an INNER join. No good.

-- CROSSTAB VERsION 2 - WORKED
DROP Table if EXISTS operation_first_vitals
CREATE TABLE operation_first_vitals AS
WITH crosstabresults AS (
        SELECT
        op_id, subject_id, chart_time,
        aft ,
        air ,
        alb20 ,
        alb5 ,
        art_dbp ,
        art_mbp ,
        art_sbp ,
        bis ,
        bt ,
        cbro2 ,
        ci ,
        cpat ,
        cryo ,
        cvp ,
        d10w ,
        d50w ,
        d5w ,
        dobui ,
        dopai ,
        ds ,
        ebl ,
        eph ,
        epi ,
        epii ,
        etco2 ,
        etdes ,
        etgas ,
        etiso ,
        etsevo ,
        ffp ,
        fio2 ,
        ftn ,
        hes ,
        hns ,
        hr ,
        hs ,
        mdz ,
        minvol ,
        mlni ,
        n2o ,
        nepi ,
        nibp_dbp ,
        nibp_mbp ,
        nibp_sbp ,
        ns ,
        ntgi ,
        o2 ,
        pap_dbp ,
        pap_mbp ,
        pap_sbp ,
        pc ,
        peep ,
        pepi ,
        phe ,
        pheresis ,
        pip ,
        pmean ,
        ppf ,
        ppfi ,
        pplat ,
        psa ,
        rbc ,
        rfti ,
        rr ,
        sft ,
        spo2 ,
        sti ,
        stii ,
        stiii ,
        stv5 ,
        svi ,
        uo ,
        vaso ,
        vt

FROM
    crosstab(
      'SELECT op_id, subject_id, chart_time, item_name, value
       FROM tmp_combined_charts
        ORDER BY 1,2,3',
        $$VALUES ('aft'::text),
        ('air'::text),
        ('alb20'::text),
        ('alb5'::text),
        ('art_dbp'::text),
        ('art_mbp'::text),
        ('art_sbp'::text),
        ('bis'::text),
        ('bt'::text),
        ('cbro2'::text),
        ('ci'::text),
        ('cpat'::text),
        ('cryo'::text),
        ('cvp'::text),
        ('d10w'::text),
        ('d50w'::text),
        ('d5w'::text),
        ('dobui'::text),
        ('dopai'::text),
        ('ds'::text),
        ('ebl'::text),
        ('eph'::text),
        ('epi'::text),
        ('epii'::text),
        ('etco2'::text),
        ('etdes'::text),
        ('etgas'::text),
        ('etiso'::text),
        ('etsevo'::text),
        ('ffp'::text),
        ('fio2'::text),
        ('ftn'::text),
        ('hes'::text),
        ('hns'::text),
        ('hr'::text),
        ('hs'::text),
        ('mdz'::text),
        ('minvol'::text),
        ('mlni'::text),
        ('n2o'::text),
        ('nepi'::text),
        ('nibp_dbp'::text),
        ('nibp_mbp'::text),
        ('nibp_sbp'::text),
        ('ns'::text),
        ('ntgi'::text),
        ('o2'::text),
        ('pap_dbp'::text),
        ('pap_mbp'::text),
        ('pap_sbp'::text),
        ('pc'::text),
        ('peep'::text),
        ('pepi'::text),
        ('phe'::text),
        ('pheresis'::text),
        ('pip'::text),
        ('pmean'::text),
        ('ppf'::text),
        ('ppfi'::text),
        ('pplat'::text),
        ('psa'::text),
        ('rbc'::text),
        ('rfti'::text),
        ('rr'::text),
        ('sft'::text),
        ('spo2'::text),
        ('sti'::text),
        ('stii'::text),
        ('stiii'::text),
        ('stv5'::text),
        ('svi'::text),
        ('uo'::text),
        ('vaso'::text),
        ('vt'::text)$$
    )
    AS ct(
        op_id integer, subject_id integer, chart_time integer,
        aft numeric,
        air numeric,
        alb20 numeric,
        alb5 numeric,
        art_dbp numeric,
        art_mbp numeric,
        art_sbp numeric,
        bis numeric,
        bt numeric,
        cbro2 numeric,
        ci numeric,
        cpat numeric,
        cryo numeric,
        cvp numeric,
        d10w numeric,
        d50w numeric,
        d5w numeric,
        dobui numeric,
        dopai numeric,
        ds numeric,
        ebl numeric,
        eph numeric,
        epi numeric,
        epii numeric,
        etco2 numeric,
        etdes numeric,
        etgas numeric,
        etiso numeric,
        etsevo numeric,
        ffp numeric,
        fio2 numeric,
        ftn numeric,
        hes numeric,
        hns numeric,
        hr numeric,
        hs numeric,
        mdz numeric,
        minvol numeric,
        mlni numeric,
        n2o numeric,
        nepi numeric,
        nibp_dbp numeric,
        nibp_mbp numeric,
        nibp_sbp numeric,
        ns numeric,
        ntgi numeric,
        o2 numeric,
        pap_dbp numeric,
        pap_mbp numeric,
        pap_sbp numeric,
        pc numeric,
        peep numeric,
        pepi numeric,
        phe numeric,
        pheresis numeric,
        pip numeric,
        pmean numeric,
        ppf numeric,
        ppfi numeric,
        pplat numeric,
        psa numeric,
        rbc numeric,
        rfti numeric,
        rr numeric,
        sft numeric,
        spo2 numeric,
        sti numeric,
        stii numeric,
        stiii numeric,
        stv5 numeric,
        svi numeric,
        uo numeric,
        vaso numeric,
        vt numeric
    )
)
SELECT ctr.op_id, ctr.subject_id, chart_time,
       COALESCE(aft) as aft,
        COALESCE(air) as air,
        COALESCE(alb20) as alb20,
        COALESCE(alb5) as alb5,
        COALESCE(art_dbp) as art_dbp,
        COALESCE(art_mbp) as art_mbp,
        COALESCE(art_sbp) as art_sbp,
        COALESCE(bis) as bis,
        COALESCE(bt) as bt,
        COALESCE(cbro2) as cbro2,
        COALESCE(ci) as ci,
        COALESCE(cpat) as cpat,
        COALESCE(cryo) as cryo,
        COALESCE(cvp) as cvp,
        COALESCE(d10w) as d10w,
        COALESCE(d50w) as d50w,
        COALESCE(d5w) as d5w,
        COALESCE(dobui) as dobui,
        COALESCE(dopai) as dopai,
        COALESCE(ds) as ds,
        COALESCE(ebl) as ebl,
        COALESCE(eph) as eph,
        COALESCE(epi) as epi,
        COALESCE(epii) as epii,
        COALESCE(etco2) as etco2,
        COALESCE(etdes) as etdes,
        COALESCE(etgas) as etgas,
        COALESCE(etiso) as etiso,
        COALESCE(etsevo) as etsevo,
        COALESCE(ffp) as ffp,
        COALESCE(fio2) as fio2,
        COALESCE(ftn) as ftn,
        COALESCE(hes) as hes,
        COALESCE(hns) as hns,
        COALESCE(hr) as hr,
        COALESCE(hs) as hs,
        COALESCE(mdz) as mdz,
        COALESCE(minvol) as minvol,
        COALESCE(mlni) as mlni,
        COALESCE(n2o) as n2o,
        COALESCE(nepi) as nepi,
        COALESCE(nibp_dbp) as nibp_dbp,
        COALESCE(nibp_mbp) as nibp_mbp,
        COALESCE(nibp_sbp) as nibp_sbp,
        COALESCE(ns) as ns,
        COALESCE(ntgi) as ntgi,
        COALESCE(o2) as o2,
        COALESCE(pap_dbp) as pap_dbp,
        COALESCE(pap_mbp) as pap_mbp,
        COALESCE(pap_sbp) as pap_sbp,
        COALESCE(pc) as pc,
        COALESCE(peep) as peep,
        COALESCE(pepi) as pepi,
        COALESCE(phe) as phe,
        COALESCE(pheresis) as pheresis,
        COALESCE(pip) as pip,
        COALESCE(pmean) as pmean,
        COALESCE(ppf) as ppf,
        COALESCE(ppfi) as ppfi,
        COALESCE(pplat) as pplat,
        COALESCE(psa) as psa,
        COALESCE(rbc) as rbc,
        COALESCE(rfti) as rfti,
        COALESCE(rr) as rr,
        COALESCE(sft) as sft,
        COALESCE(spo2) as spo2,
        COALESCE(sti) as sti,
        COALESCE(stii) as stii,
        COALESCE(stiii) as stiii,
        COALESCE(stv5) as stv5,
        COALESCE(svi) as svi,
        COALESCE(uo) as uo,
        COALESCE(vaso) as vaso,
        COALESCE(vt) as vt
FROM operation_pcd op
LEFT JOIN crosstabresults ctr ON op.op_id = ctr.op_id;

select count (*) from operation_first_vitals
