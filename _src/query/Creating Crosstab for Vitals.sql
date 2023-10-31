
-- OR v.chart_time IS NULL

WITH MinVitals AS (
    SELECT v.subject_id, v.op_id,MIN(v.chart_time) AS min_vital_time
    FROM vitals v
    JOIN operation_pcd o
        -- Join Tables on OPERATION ID
    ON v.op_id = o.op_id
    WHERE v.chart_time > o.orout_time
    GROUP BY v.subject_id,v.op_id
)
SELECT *
FROM MinVitals
Where op_id=463767982

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
SELECT *
FROM Vital_leaving_OR
Where op_id=461473883
ORDER BY item_name

--CROSS TAB CREATING
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- USE THE CROSS TAB

-- Create a list of the Vitals Names
Select distinct(item_name)
From vitals


SELECT op_id, subject_id, chart_time,
       COALESCE(aft,0),
        COALESCE(air,0),
        COALESCE(alb20,0),
        COALESCE(alb5,0),
        COALESCE(art_dbp,0),
        COALESCE(art_mbp,0),
        COALESCE(art_sbp,0),
        COALESCE(bis,0),
        COALESCE(bt,0),
        COALESCE(cbro2,0),
        COALESCE(ci,0),
        COALESCE(cpat,0),
        COALESCE(cryo,0),
        COALESCE(cvp,0),
        COALESCE(d10w,0),
        COALESCE(d50w,0),
        COALESCE(d5w,0),
        COALESCE(dobui,0),
        COALESCE(dopai,0),
        COALESCE(ds,0),
        COALESCE(ebl,0),
        COALESCE(eph,0),
        COALESCE(epi,0),
        COALESCE(epii,0),
        COALESCE(etco2,0),
        COALESCE(etdes,0),
        COALESCE(etgas,0),
        COALESCE(etiso,0),
        COALESCE(etsevo,0),
        COALESCE(ffp,0),
        COALESCE(fio2,0),
        COALESCE(ftn,0),
        COALESCE(hes,0),
        COALESCE(hns,0),
        COALESCE(hr,0),
        COALESCE(hs,0),
        COALESCE(mdz,0),
        COALESCE(minvol,0),
        COALESCE(mlni,0),
        COALESCE(n2o,0),
        COALESCE(nepi,0),
        COALESCE(nibp_dbp,0),
        COALESCE(nibp_mbp,0),
        COALESCE(nibp_sbp,0),
        COALESCE(ns,0),
        COALESCE(ntgi,0),
        COALESCE(o2,0),
        COALESCE(pap_dbp,0),
        COALESCE(pap_mbp,0),
        COALESCE(pap_sbp,0),
        COALESCE(pc,0),
        COALESCE(peep,0),
        COALESCE(pepi,0),
        COALESCE(phe,0),
        COALESCE(pheresis,0),
        COALESCE(pip,0),
        COALESCE(pmean,0),
        COALESCE(ppf,0),
        COALESCE(ppfi,0),
        COALESCE(pplat,0),
        COALESCE(psa,0),
        COALESCE(rbc,0),
        COALESCE(rfti,0),
        COALESCE(rr,0),
        COALESCE(sft,0),
        COALESCE(spo2,0),
        COALESCE(sti,0),
        COALESCE(stii,0),
        COALESCE(stiii,0),
        COALESCE(stv5,0),
        COALESCE(svi,0),
        COALESCE(uo,0),
        COALESCE(vaso,0),
        COALESCE(vt,0)
FROM
    crosstab(
      'SELECT op_id, subject_id, chart_time, item_name, value
       FROM Vital_leaving_OR
       WHERE op_id=461473883
       ORDER BY 1,2,3',
      $$VALUES ('AFT'::text),
            ('AIR'::text),
            ('ALB20'::text),
            ('ALB5'::text),
            ('ART_DBP'::text),
            ('ART_MBP'::text),
            ('ART_SBP'::text),
            ('BIS'::text),
            ('BT'::text),
            ('CBRO2'::text),
            ('CI'::text),
            ('CPAT'::text),
            ('CRYO'::text),
            ('CVP'::text),
            ('D10W'::text),
            ('D50W'::text),
            ('D5W'::text),
            ('DOBUI'::text),
            ('DOPAI'::text),
            ('DS'::text),
            ('EBL'::text),
            ('EPH'::text),
            ('EPI'::text),
            ('EPII'::text),
            ('ETCO2'::text),
            ('ETDES'::text),
            ('ETGAS'::text),
            ('ETISO'::text),
            ('ETSEVO'::text),
            ('FFP'::text),
            ('FIO2'::text),
            ('FTN'::text),
            ('HES'::text),
            ('HNS'::text),
            ('HR'::text),
            ('HS'::text),
            ('MDZ'::text),
            ('MINVOL'::text),
            ('MLNI'::text),
            ('N2O'::text),
            ('NEPI'::text),
            ('NIBP_DBP'::text),
            ('NIBP_MBP'::text),
            ('NIBP_SBP'::text),
            ('NS'::text),
            ('NTGI'::text),
            ('O2'::text),
            ('PAP_DBP'::text),
            ('PAP_MBP'::text),
            ('PAP_SBP'::text),
            ('PC'::text),
            ('PEEP'::text),
            ('PEPI'::text),
            ('PHE'::text),
            ('PHERESIS'::text),
            ('PIP'::text),
            ('PMEAN'::text),
            ('PPF'::text),
            ('PPFI'::text),
            ('PPLAT'::text),
            ('PSA'::text),
            ('RBC'::text),
            ('RFTI'::text),
            ('RR'::text),
            ('SFT'::text),
            ('SPO2'::text),
            ('STI'::text),
            ('STII'::text),
            ('STIII'::text),
            ('STV5'::text),
            ('SVI'::text),
            ('UO'::text),
            ('VASO'::text),
            ('VT'::text)$$
    )
    AS ct(
        op_id integer, subject_id integer, chart_time timestamp,
        aft float8,
        air float8,
        alb20 float8,
        alb5 float8,
        art_dbp float8,
        art_mbp float8,
        art_sbp float8,
        bis float8,
        bt float8,
        cbro2 float8,
        ci float8,
        cpat float8,
        cryo float8,
        cvp float8,
        d10w float8,
        d50w float8,
        d5w float8,
        dobui float8,
        dopai float8,
        ds float8,
        ebl float8,
        eph float8,
        epi float8,
        epii float8,
        etco2 float8,
        etdes float8,
        etgas float8,
        etiso float8,
        etsevo float8,
        ffp float8,
        fio2 float8,
        ftn float8,
        hes float8,
        hns float8,
        hr float8,
        hs float8,
        mdz float8,
        minvol float8,
        mlni float8,
        n2o float8,
        nepi float8,
        nibp_dbp float8,
        nibp_mbp float8,
        nibp_sbp float8,
        ns float8,
        ntgi float8,
        o2 float8,
        pap_dbp float8,
        pap_mbp float8,
        pap_sbp float8,
        pc float8,
        peep float8,
        pepi float8,
        phe float8,
        pheresis float8,
        pip float8,
        pmean float8,
        ppf float8,
        ppfi float8,
        pplat float8,
        psa float8,
        rbc float8,
        rfti float8,
        rr float8,
        sft float8,
        spo2 float8,
        sti float8,
        stii float8,
        stiii float8,
        stv5 float8,
        svi float8,
        uo float8,
        vaso float8,
        vt float8
);


