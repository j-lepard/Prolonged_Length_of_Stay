select *

FROM operation_pcd o
left JOIN operation_first_vitals v ON o.op_id=v.op_id
left join operation_first_labs l ON o.subject_id=l.subject_id