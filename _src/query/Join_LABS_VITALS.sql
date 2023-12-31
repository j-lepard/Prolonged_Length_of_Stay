DROP TABLE if EXISTS operations_fulldata;
CREATE TABLE operations_fulldata AS (
            SELECT o.op_id,
                   o.subject_id,
                   hadm_id,
                   opdate,
                   age,
                   sex,
                   weight,
                   height,
                   race,
                   asa,
                   emop,
                   department,
                   antype,
                   icd10_pcs,
                   category_desc,
                   desc_short,
                   category_id,
                   orin_time,
                   o.orout_time as or_out_time,
                   opstart_time,
                   opend_time,
                   admission_time,
                   discharge_time,
                   anstart_time,
                   anend_time,
                   cpbon_time,
                   cpboff_time,
                   icuin_time,
                   icuout_time,
                   inhosp_death_time,
                   v.op_id as vital_opid,
                   v.subject_id as vital_subject,
                   v.chart_time as vital_chart_time,
                   v.item_name as vital_name,
                   v.value as vital_value,
                   l.subject_id as lab_subject,
                   l.chart_time as lab_chart_time,
                   l.item_name as lab_test,
                   l.value as lab_value,
                   l.nearest_orout
            FROM operation_pcd o
            left JOIN vitals_in_hospital_filter v ON o.op_id=v.op_id
            left Join labs_in_hospital_filter l ON o.subject_id=l.subject_id
            )

select count (*) from operations_fulldata