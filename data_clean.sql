--select diagnoses from original table and delete disease that can not be predicted.

SELECT 
person_id,visit_occurrence_id,condition_source_value   
INTO [DeepRepresentation].[dbo].diagnoses_raw  
FROM [ohdsi].[west].[condition_occurrence]
where condition_source_value not like '9%' and condition_source_value not like '8%' and condition_source_value not like 'E%' and condition_source_value not like 'V%' and condition_source_value not like '042%' 
and condition_source_value != '***';


--delete visit id and person_id 
--Note that as for the patient who have final visit admission with unpredictable disease, their final admission should be deleted to make sure complete patient in final classification table.
--we only concern visit id that appear in diagnose final table to make sure we also delete person whose final visit admission is unpredictable diease
SELECT  visit_occurrence_id
into  [DeepRepresentation].[dbo].[visitid]
FROM [DeepRepresentation].[dbo].[visit_raw_yuqi]
where visit_occurrence_id in (
select visit_occurrence_id 
from [DeepRepresentation].[dbo].diagnoses_raw);

--extract information from admission

SELECT  PERSON_id,visit_occurrence_id,visit_start_date,visit_end_date
into [DeepRepresentation].[dbo].admission
from [DeepRepresentation].[dbo].[visit_raw_yuqi]
where visit_occurrence_id in (
select visit_occurrence_id
from [DeepRepresentation].[dbo].[visitid]);


--only focus on patient that have 5-100 admissions 

select  person_id,count(VISIT_OCCURRENCE_ID)as freq_admission
into [DeepRepresentation].[DBO].[PERSON_ADMIT_FREQ_YUQI]
from [DeepRepresentation].[dbo].admission
group by person_id
ORDER BY PERSON_ID;

select  *
into [DeepRepresentation].[dbo].visit_final
from [DeepRepresentation].[dbo].admission
where person_id in(
select  PERSON_ID 
FROM  [DeepRepresentation].[DBO].[PERSON_ADMIT_FREQ_YUQI]
WHERE freq_admission >4 AND freq_admission<101
);

---select unique visit id

select  distinct(visit_occurrence_id)
into [DeepRepresentation].[dbo].[unique_visitid]
from [DeepRepresentation].[dbo].[visit_final]
ORDER BY visit_occurrence_id;

---select unique person id

select distinct(person_id)
into [DeepRepresentation].[dbo].[unique_personid]
from [DeepRepresentation].[dbo].[visit_final]
ORDER BY PERSON_ID;

---select last time admit

SELECT  PERSON_ID, max(visit_occurrence_id) as LASTID
into  [DeepRepresentation].[dbo].[visit_last]
from  [DeepRepresentation].[dbo].[visit_final]
group by person_id
ORDER BY PERSON_ID;

---select except last time visit id
select  visit_occurrence_id 
into [DeepRepresentation].[dbo].[visit_exceptlast]
from [DeepRepresentation].[dbo].[unique_visitid]
where visit_occurrence_id 
not in (
select LASTID
from  [DeepRepresentation].[dbo].[visit_last] )
order by visit_occurrence_id ;



---extract diagnoses,procedure,drug and make sure the visit id are those we want

select  *
into [DeepRepresentation].[dbo].diagnoses_original
from [DeepRepresentation].[dbo].diagnoses_raw
where visit_occurrence_id in (
select visit_occurrence_id from [DeepRepresentation].[dbo].[unique_visitid])
ORDER BY PERSON_ID;

select *
into  [DeepRepresentation].[dbo].procedures_original 
from [DeepRepresentation].[dbo].procedures_raw_yuqi   
where visit_occurrence_id in (
select visit_occurrence_id from [DeepRepresentation].[dbo].[unique_visitid])
ORDER BY PERSON_ID;

select person_id,visit_occurrence_id,drug_concept_id,drug_exposure_start_date
into  [DeepRepresentation].[dbo].drug_original
from [DeepRepresentation].[dbo].drug_raw_yuqi   
where visit_occurrence_id in (
select visit_occurrence_id from [DeepRepresentation].[dbo].[unique_visitid]);



----------------------------------DIAGNOSE---------------------------------------------------------------------
---delete too much and too little diagnoses 80%*patients - 5

select  condition_source_value, count(person_id) as patient_num
into [DeepRepresentation].[dbo].diagnoses_freq
from [DeepRepresentation].[dbo].diagnoses_original
group by condition_source_value;

select *
into [DeepRepresentation].[dbo].diagnoses_1
from [DeepRepresentation].[dbo].diagnoses_original
where condition_source_value in (
select condition_source_value 
from [DeepRepresentation].[dbo].diagnoses_freq
where patient_num < 486271 and patient_num >5 );

--add index for diagnoses and except last visit id

CREATE INDEX idx_Name ON [DeepRepresentation].[dbo].diagnoses_1
(person_id,visit_occurrence_id,condition_source_value);  
CREATE INDEX idx_Name ON [DeepRepresentation].[dbo].[visitid_exceptlast]
(visitid_exceptlast);  


--select for last time
select * 
into [DeepRepresentation].[dbo].diagnoses_lasttime
from [DeepRepresentation].[dbo].diagnoses_1
where visit_occurrence_id in(
select lastid 
from [DeepRepresentation].[dbo].[visit_last]
);

--create table for classification
--to see which disease is more
select top 100 condition_source_value,count(person_id)as patient_num
from [DeepRepresentation].[dbo].diagnoses_lasttime
group by condition_source_value
order by patient_num desc;

alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add A_49390 int;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add U_5990 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add D_25000 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add A_78900 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add A_4659 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add H_7840 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add C_78650 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add H_2724 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add C_4280 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add O_3829 int;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add C_41401 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add P_2720 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add A_462 int ;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add A_2859 int;
alter TABLE [DeepRepresentation].dbo.[diagnoses_lasttime] add L_7242 int ;
update [DeepRepresentation].dbo.[diagnoses_lasttime]
set L_7242 = 0
where L_7242 is null;


update [DeepRepresentation].dbo.[diagnoses_lasttime]
set C_4280 = 1
where condition_source_value = '428.0';
update [DeepRepresentation].dbo.[diagnoses_lasttime]
set O_3829 = 1
where condition_source_value = '382.9';
update [DeepRepresentation].dbo.[diagnoses_lasttime]
set C_41401 = 1
where condition_source_value = '414.01';
update [DeepRepresentation].dbo.[diagnoses_lasttime]
set  P_2720 = 1
where condition_source_value ='272.0';

update [DeepRepresentation].dbo.[diagnoses_lasttime]
set A_462 = 1
where condition_source_value = '462';
update [DeepRepresentation].dbo.[diagnoses_lasttime]
set A_2859 = 1
where condition_source_value ='285.9';
update [DeepRepresentation].dbo.[diagnoses_lasttime]
set L_7242 = 1
where condition_source_value = '724.2';


update [DeepRepresentation].dbo.[diagnoses_lasttime]
set A_462 = '0'
where A_462 is null;

select person_id, 
sum(A_49390)as A_49390,
sum(U_5990)as U_5990,
sum(D_25000)as D_25000,
sum(A_78900)as A_78900,
sum(A_4659)as A_4659,
sum(H_7840)as H_7840,
sum(C_78650)as C_78650,
sum(H_2724)as H_2724,
sum(C_4280)as C_4280,
sum(O_3829)as O_3829,
sum(C_41401)as C_41401,
sum(P_2720)as P_2720,
sum(A_462)as A_462,
sum(A_2859)as A_2859,
sum(L_7242)as L_7242
into  [DeepRepresentation].[dbo].[diagnoses_classification]
from  [DeepRepresentation].dbo.[diagnoses_lasttime]
group by person_id
order by person_id;


---left join unique person_id and classification table

select  U.person_id, A_49390,U_5990,D_25000,A_78900,A_4659,H_7840,C_78650,H_2724,C_4280,O_3829,C_41401,P_2720,A_462,A_2859,L_7242
into [DeepRepresentation].[dbo].[classification_final] 
from [DeepRepresentation].[dbo].[unique_personid] U
left join [DeepRepresentation].[dbo].[diagnoses_classification] D
on U.person_id = D.person_id;

update [DeepRepresentation].[dbo].[classification_final] 
set L_7242 = 0
where L_7242 IS NULL;



----------------------------------PROCEDURE---------------------------------------------------------------------

---delete too much and too little procedures 80%*patients - 5

select procedure_source_value, count(person_id) as patient_num
into [DeepRepresentation].[dbo].procedures_freq
from [DeepRepresentation].[dbo].procedures_original
group by procedure_source_value;

select *
into [DeepRepresentation].[dbo].procedures_1
from [DeepRepresentation].[dbo].procedures_original
where procedure_source_value in (
select procedure_source_value 
from [DeepRepresentation].[dbo].procedures_freq
where patient_num < 486271 and patient_num >5 );



----------------------------------DRUG---------------------------------------------------------------------



  ----------assign visit id according to startdate and enddate for drug

--give row num

SELECT  row_number() over(order by person_id) as rownum, *
into [DeepRepresentation].dbo.[drug_2]
from [DeepRepresentation].[dbo].[drug_raw_yuqi]

--extract null

SELECT *
into [DeepRepresentation].dbo.[drug_null]
from [DeepRepresentation].dbo.[drug_2]
where visit_occurrence_id is null;

--count duration to each admit and each disch


SELECT  L.rownum, L.person_id, A.visit_occurrence_id,
abs(DATEDIFF (day, A.visit_start_date , L.drug_exposure_start_date ) ) as to_admit,
abs(DATEDIFF (day, A.visit_end_date , L.drug_exposure_start_date ) ) as to_disch
INTO [DeepRepresentation].dbo.[drug_null_2]
FROM [DeepRepresentation].dbo.[drug_null] L, [DeepRepresentation].dbo.[visit_final] A
where L.person_id = A.person_id;


select count(*)
from [DeepRepresentation].dbo.[drug_null_2]
--calculate min of to_admit and to_disch


SELECT rownum,visit_occurrence_id,
case
  when to_admit <= to_disch then to_admit
  when to_disch > to_admit then to_disch

end
 as min_time
--INTO [DeepRepresentation].dbo.[drug_null_3]
FROM [DeepRepresentation].dbo.[drug_null_2];

---SELECT THE REAL MIN TIME FOR EACH ROW

SELECT  L.rownum,min(L.visit_occurrence_id)as visit_occurrence_id, min(L.min_time) as real_mintime
into [DeepRepresentation].dbo.[drug_null_4]
FROM [DeepRepresentation].dbo.[drug_null_3] L,
(
SELECT rownum, min(min_time) as real_min_time
from [DeepRepresentation].dbo.[drug_null_3]
group by rownum
) MINL
WHERE
L.rownum = MINL.rownum and L.min_time = MINL.real_min_time
GROUP BY L.rownum;

  -- create new table with null hadm_id
SELECT   L.rownum, L.person_id, L2.visit_occurrence_id, L.drug_concept_id
INTO [DeepRepresentation].dbo.[drug_null_5]
FROM [DeepRepresentation].dbo.[drug_2] L, [DeepRepresentation].dbo.[drug_null_4] L2
WHERE L.rownum = L2.rownum;



---extract not null

SELECT rownum, person_id,visit_occurrence_id,drug_concept_id
into [DeepRepresentation].dbo.[drug_notnull]
from [DeepRepresentation].dbo.[drug_2]
where visit_occurrence_id is not null;

select count(*)
from [DeepRepresentation].dbo.[drug_notnull]

---stack two table

SELECT  *
INTO [DeepRepresentation].dbo.[drug_3]
FROM [DeepRepresentation].dbo.[drug_null_5]
UNION
SELECT *
FROM [DeepRepresentation].dbo.[drug_notnull]
ORDER BY person_id;

--select drug that in unique visit id 
select person_id,visit_occurrence_id,drug_concept_id
into  [DeepRepresentation].[dbo].drug_original
from [DeepRepresentation].[dbo].drug_3  
where visit_occurrence_id in (
select visit_occurrence_id from [DeepRepresentation].[dbo].[unique_visitid]);

--delete too much and too little

select drug_concept_id, count(person_id) as patient_num
into [DeepRepresentation].[dbo].drug_freq
from [DeepRepresentation].[dbo].drug_original
group by drug_concept_id;

select *
into [DeepRepresentation].[dbo].drug_4
from [DeepRepresentation].[dbo].drug_original
where drug_concept_id in (
select drug_concept_id
from [DeepRepresentation].[dbo].drug_freq
where patient_num < 486271 and patient_num >5 );

select * 
into [DeepRepresentation].[dbo].drug_exceptlast
from [DeepRepresentation].[dbo].drug_4
where visit_occurrence_id not in(
select lastid 
from [DeepRepresentation].[dbo].[visit_last]
);





---delete too much and too little procedures 80%*patients - 5

select  procedure_source_value, count(person_id) as patient_num
into [DeepRepresentation].[dbo].procedures_freq
from [DeepRepresentation].[dbo].procedures_original
group by procedure_source_value
ORDER BY patient_num ;

select *
into [DeepRepresentation].[dbo].procedures_1
from [DeepRepresentation].[dbo].procedures_original
where procedure_source_value in (
select procedure_source_value 
from [DeepRepresentation].[dbo].procedures_freq
where patient_num < 486271 and patient_num >5 );

--select except last time for diagnoses procedures and drugs

select * 
into [DeepRepresentation].[dbo].diagnoses_exceptlast
from [DeepRepresentation].[dbo].diagnoses_1
where visit_occurrence_id  in(
select visitid_exceptlast
from  [DeepRepresentation].[dbo].visitid_exceptlast
)
and person_id in (
select person_id
FROM [DeepRepresentation].[dbo].[unique_personid]);


select * 
into [DeepRepresentation].[dbo].procedures_exceptlast
from [DeepRepresentation].[dbo].procedures_1
where visit_occurrence_id  in(
select visitid_exceptlast
from  [DeepRepresentation].[dbo].visitid_exceptlast
)
and person_id in (
select person_id
FROM [DeepRepresentation].[dbo].[unique_personid]);


select * 
into [DeepRepresentation].[dbo].drug_exceptlast
from [DeepRepresentation].[dbo].drug_4
where visit_occurrence_id  in(
select visitid_exceptlast
from  [DeepRepresentation].[dbo].visitid_exceptlast
)
and person_id in (
select person_id
FROM [DeepRepresentation].[dbo].[unique_personid]);


--count the freq for drug except last time for patients

SELECT  person_id,visit_occurrence_id,drug_concept_id, count(*) as frequency
into [DeepRepresentation].dbo.[drug_exceptlast_freq]
FROM [DeepRepresentation].dbo.[drug_exceptlast]
GROUP BY person_id,visit_occurrence_id,drug_concept_id
ORDER BY  person_id,visit_occurrence_id;

SELECT person_id,drug_concept_id,AVG(cast(frequency as decimal(10,2))) as freq
into [DeepRepresentation].dbo.[drug_exceptlast_freq_patient_AVG] 
FROM [DeepRepresentation].dbo.[drug_exceptlast_freq]
GROUP BY person_id,drug_concept_id
ORDER BY  person_id,drug_concept_id;


SELECT  person_id,visit_occurrence_id,procedure_source_value, count(*) as frequency
into [DeepRepresentation].dbo.[procedures_exceptlast_freq]
FROM [DeepRepresentation].dbo.[procedures_exceptlast]
GROUP BY person_id,visit_occurrence_id, procedure_source_value
ORDER BY  person_id,visit_occurrence_id;


SELECT  person_id,procedure_source_value,AVG(cast(frequency as decimal(10,2))) as freq
into [DeepRepresentation].dbo.[procedures_exceptlast_freq_patient_AVG] 
FROM [DeepRepresentation].dbo.[procedures_exceptlast_freq]

GROUP BY person_id,procedure_source_value
ORDER BY  person_id,procedure_source_value
;


SELECT  person_id,visit_occurrence_id,condition_source_value, count(*) as frequency
into [DeepRepresentation].dbo.[diagnoses_exceptlast_freq]
FROM [DeepRepresentation].dbo.[diagnoses_exceptlast]
GROUP BY person_id,visit_occurrence_id, condition_source_value
ORDER BY  person_id,visit_occurrence_id;


SELECT person_id,condition_source_value,AVG(cast(frequency as decimal(10,2))) as freq
into [DeepRepresentation].dbo.[diagnoses_exceptlast_freq_patient_AVG] 
FROM [DeepRepresentation].dbo.[diagnoses_exceptlast_freq]
GROUP BY person_id,condition_source_value
ORDER BY  person_id,condition_source_value;


