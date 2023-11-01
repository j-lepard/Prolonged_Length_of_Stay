-- STEP 1: Create Fitltered LABS:: REMOVE any LABS before admit and after Dx
DROP TABLE IF EXISTS labs_in_hospital;
CREATE TABLE labs_in_hospital AS
WITH Deduplicated AS (
    SELECT l.*,
           ROW_NUMBER() OVER(PARTITION BY l.subject_id, l.chart_time, l.item_name, l.value ORDER BY l.subject_id) as rn
    FROM labs l
    JOIN operation_pcd O ON l.subject_id = O.subject_id
    WHERE l.chart_time >= O.admission_time AND l.chart_time < O.discharge_time
)
SELECT subject_id, chart_time, item_name, value -- and other columns you have in 'labs'
FROM Deduplicated
WHERE rn = 1 AND item_name IN ('alp','alt','ast','chloride','creatinine','crp','glucose','hb','hba1c','hco3','lymphocyte','platelet','potassium','sodium','total_bilirubin','wbc');

select count (*) from labs_in_hospital;
------------------------------------------------------
-- labs table has 21,367,131
-- labs_in_hopsital has 13,714,214
-- labs in hosptial with select tests has 7,759,999
-- labs in hospital filter = 629,055

--- STEP 2: Filter the results (as there are multiple charting events, I only want 1 as close to OR OUT time)
-------VERSION 2 :: Use a JOIN it to the OR table.
DROP TABLE IF EXISTS labs_in_hospital_filter;
CREATE TABLE labs_in_hospital_filter as
WITH ClosestChartTime AS (
    SELECT
        labs.subject_id,
        labs.chart_time,
        ops.orout_time,
        ROW_NUMBER() OVER (PARTITION BY ops.subject_id, ops.orout_time ORDER BY ABS(labs.chart_time - ops.orout_time)) AS time_rank
    FROM
        labs_in_hospital AS labs
    JOIN
        operation_pcd AS ops
    ON
        labs.subject_id = ops.subject_id
    ),
    RankedItems AS (
        SELECT
            labs.subject_id,
            labs.chart_time,
            labs.item_name,
            labs.value,
            cct.orout_time,
            ROW_NUMBER() OVER (PARTITION BY labs.subject_id, labs.chart_time ORDER BY item_name) AS item_rank -- Replace <some_criteria_for_top_items> with your own criteria.
        FROM
            labs_in_hospital AS labs
        INNER JOIN
            ClosestChartTime AS cct
        ON
            labs.subject_id = cct.subject_id AND
            labs.chart_time = cct.chart_time
        WHERE
            cct.time_rank = 1
    )
SELECT
    subject_id,
    chart_time,
    item_name,
    value,
    orout_time as nearest_orout
FROM
    RankedItems
WHERE
    item_rank <= 16;
---------------------------------
select count (*) from labs_in_hospital_filter


--------------------------------------------------------------------------

--- VERSION 1 (manual target time as 3390)
WITH input_time AS (
SELECT 3390 AS desired_time
)

SELECT
    subject_id,
    chart_time,
    item_name,
    value,
    ABS(chart_time - (SELECT desired_time FROM input_time)) AS time_difference
FROM
    labs_in_hospital, input_time where subject_id=100002094
ORDER BY
    time_difference ASC
LIMIT 2;  -- how many lab results do you want to bring back? (probably should be the legnth of the filtered list above)




--------------------------------------------------------------------------



-- MOCK up and OLD WORK:


--- FILTER THE LABS TABLE
-- Create Fitlered LABS:: REMOVE any LABS before admit and after Dx
DROP TABLE IF EXISTS labs_in_hospital
CREATE TABLE labs_in_hospital AS
WITH Deduplicated AS (
    SELECT l.*,
           ROW_NUMBER() OVER(PARTITION BY l.subject_id, l.chart_time, l.item_name, l.value ORDER BY l.subject_id) as rn
    FROM labs l
    JOIN operation_pcd O ON l.subject_id = O.subject_id
    WHERE l.chart_time >= O.admission_time AND l.chart_time < O.discharge_time
)
SELECT subject_id, chart_time, item_name, value -- and other columns you have in 'labs'
FROM Deduplicated
WHERE rn = 1;



--------------------------------------------------------------------------
-- ORIGINAL TABLE THAT HAD DUPLICATES
CREATE TABLE labs_in_hospital AS
SELECT l.*
FROM labs l
JOIN operation_pcd O ON l.subject_id = O.subject_id
WHERE l.chart_time >= O.admission_time AND l.chart_time < o.discharge_time;


--------------------------------------------------------------------------



-- DONT NOT MESS WITH THE BELOW (old old version)
DROP TABLE if EXISTS  tmp_min_chart_time_lab
Create table tmp_min_chart_time_lab AS (
    SELECT l.subject_id, MIN(l.chart_time) as chart_time, item_name, value
    FROM labs l
    LEFT JOIN operation_pcd o ON l.subject_id = o.subject_id
    WHERE l.chart_time > o.orout_time
    GROUP BY l.subject_id, item_name, value
);
Select * from tmp_min_chart_time_lab;
-------
DROP TABLE IF EXISTS operation_first_labs;
CREATE TABLE operation_first_labs AS
WITH crosstabresults_lab AS (
        SELECT
        subject_id, chart_time,
        albumin,
alp,
alt,
aptt,
ast,
be,
bun,
calcium,
chloride,
ck,
ckmb,
creatinine,
crp,
d_dimer,
fibrinogen,
glucose,
hb,
hba1c,
hco3,
hct,
lacate,
lymphocyte,
paco2,
pao2,
ph,
phosphorus,
platelet,
potassium,
ptinr,
sao2,
sodium,
total_bilirubin,
total_protein,
troponin_i,
troponin_t,
wbc

        FROM
        crosstab(
          'SELECT subject_id, chart_time, item_name, value
           FROM tmp_min_chart_time_lab
            ORDER BY 1,2,3',
            $$VALUES
            ('albumin'::text),
('alp'::text),
('alt'::text),
('aptt'::text),
('ast'::text),
('be'::text),
('bun'::text),
('calcium'::text),
('chloride'::text),
('ck'::text),
('ckmb'::text),
('creatinine'::text),
('crp'::text),
('d_dimer'::text),
('fibrinogen'::text),
('glucose'::text),
('hb'::text),
('hba1c'::text),
('hco3'::text),
('hct'::text),
('lacate'::text),
('lymphocyte'::text),
('paco2'::text),
('pao2'::text),
('ph'::text),
('phosphorus'::text),
('platelet'::text),
('potassium'::text),
('ptinr'::text),
('sao2'::text),
('sodium'::text),
('total_bilirubin'::text),
('total_protein'::text),
('troponin_i'::text),
('troponin_t'::text),
('wbc'::text)

            $$
        )
        AS ct_lab(
            subject_id integer, chart_time integer,
            albumin numeric,
alp numeric,
alt numeric,
aptt numeric,
ast numeric,
be numeric,
bun numeric,
calcium numeric,
chloride numeric,
ck numeric,
ckmb numeric,
creatinine numeric,
crp numeric,
d_dimer numeric,
fibrinogen numeric,
glucose numeric,
hb numeric,
hba1c numeric,
hco3 numeric,
hct numeric,
lacate numeric,
lymphocyte numeric,
paco2 numeric,
pao2 numeric,
ph numeric,
phosphorus numeric,
platelet numeric,
potassium numeric,
ptinr numeric,
sao2 numeric,
sodium numeric,
total_bilirubin numeric,
total_protein numeric,
troponin_i numeric,
troponin_t numeric,
wbc numeric

            )
)
SELECT op.op_id, lab.subject_id, lab.chart_time,
        COALESCE(lab.albumin,0) as albumin,
COALESCE(lab.alp,0) as alp,
COALESCE(lab.alt,0) as alt,
COALESCE(lab.aptt,0) as aptt,
COALESCE(lab.ast,0) as ast,
COALESCE(lab.be,0) as be,
COALESCE(lab.bun,0) as bun,
COALESCE(lab.calcium,0) as calcium,
COALESCE(lab.chloride,0) as chloride,
COALESCE(lab.ck,0) as ck,
COALESCE(lab.ckmb,0) as ckmb,
COALESCE(lab.creatinine,0) as creatinine,
COALESCE(lab.crp,0) as crp,
COALESCE(lab.d_dimer,0) as d_dimer,
COALESCE(lab.fibrinogen,0) as fibrinogen,
COALESCE(lab.glucose,0) as glucose,
COALESCE(lab.hb,0) as hb,
COALESCE(lab.hba1c,0) as hba1c,
COALESCE(lab.hco3,0) as hco3,
COALESCE(lab.hct,0) as hct,
COALESCE(lab.lacate,0) as lacate,
COALESCE(lab.lymphocyte,0) as lymphocyte,
COALESCE(lab.paco2,0) as paco2,
COALESCE(lab.pao2,0) as pao2,
COALESCE(lab.ph,0) as ph,
COALESCE(lab.phosphorus,0) as phosphorus,
COALESCE(lab.platelet,0) as platelet,
COALESCE(lab.potassium,0) as potassium,
COALESCE(lab.ptinr,0) as ptinr,
COALESCE(lab.sao2,0) as sao2,
COALESCE(lab.sodium,0) as sodium,
COALESCE(lab.total_bilirubin,0) as total_bilirubin,
COALESCE(lab.total_protein,0) as total_protein,
COALESCE(lab.troponin_i,0) as troponin_i,
COALESCE(lab.troponin_t,0) as troponin_t,
COALESCE(lab.wbc,0) as wbc

FROM operation_pcd op
LEFT JOIN crosstabresults_lab lab ON op.subject_id = lab.subject_id;

select count (distinct subject_id) from operation_first_labs