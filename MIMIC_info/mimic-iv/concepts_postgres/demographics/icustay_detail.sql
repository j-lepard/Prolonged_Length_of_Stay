-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS icustay_detail;
CREATE TABLE icustay_detail AS
SELECT ie.subject_id, ie.hadm_id, ie.stay_id

    -- patient level factors
    , pat.gender, pat.dod

    -- hospital level factors
    , adm.admittime::timestamp, adm.dischtime::timestamp
    , EXTRACT(DAY FROM (adm.dischtime::timestamp - adm.admittime::timestamp)) AS los_hospital
    -- calculate the age as anchor_age (60) plus difference between
    -- admit year and the anchor year.
    , pat.anchor_age + EXTRACT(YEAR FROM (adm.admittime::timestamp - make_timestamp(pat.anchor_year, 1, 1, 0, 0, 0))) AS admission_age
    , adm.race
    , adm.hospital_expire_flag
    , DENSE_RANK() OVER (
        PARTITION BY adm.subject_id ORDER BY adm.admittime::timestamp
    ) AS hospstay_seq
    , CASE
        WHEN
            DENSE_RANK() OVER (
                PARTITION BY adm.subject_id ORDER BY adm.admittime::timestamp
            ) = 1 THEN True
        ELSE False END AS first_hosp_stay

    -- icu level factors
    , ie.intime::timestamp AS icu_intime, ie.outtime::timestamp AS icu_outtime
    , ROUND(
        CAST(EXTRACT(EPOCH FROM (ie.outtime::timestamp - ie.intime::timestamp)) / 3600 / 24.0 AS NUMERIC), 2
    ) AS los_icu
    , DENSE_RANK() OVER (
        PARTITION BY ie.hadm_id ORDER BY ie.intime::timestamp
    ) AS icustay_seq

    -- first ICU stay *for the current hospitalization*
    , CASE
        WHEN
            DENSE_RANK() OVER (
                PARTITION BY ie.hadm_id ORDER BY ie.intime::timestamp
            ) = 1 THEN True
        ELSE False END AS first_icu_stay

FROM mimiciv_icu.icustays ie
INNER JOIN mimiciv_hosp.admissions adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN mimiciv_hosp.patients pat
    ON ie.subject_id = pat.subject_id;
