/*
I, Marcello De Filippis, student number 000823174, certify that this material is my original work. 
No other person's work has been used without due acknowledgment and I have not made my work available to anyone else.

db name: lab5
Name: Marcello De Filippis
Date: October 24th 2022
*/
USE chdb



PRINT 'GROUP 1 SELECT B '


SELECT COUNT (*)
FROM patients
where gender = 'M' AND patient_weight <
	(SELECT AVG(patient_weight)
	FROM patients
	WHERE gender = 'F'
	)
	

PRINT 'GROUP 1 SELECT C '


SELECT first_name, last_name, patient_height
from patients
WHERE patient_height = 
	(SELECT MAX(patient_height)
	FROM patients
	WHERE gender = 'F')



PRINT 'GROUP 2 SELECT C '

SELECT COUNT(*), province_id
from patients
GROUP BY province_id
HAVING province_id != 'ON'


PRINT 'GROUP 2 SELECT D '

SELECT COUNT(*), gender
from patients
WHERE patient_height > 175 
GROUP BY gender


PRINT 'GROUP 3 SELECT A'

SELECT patients.patient_id, patients.first_name, patients.last_name, admissions.room, admissions.bed
from patients
JOIN admissions
ON patients.patient_id = admissions.patient_id
WHERE nursing_unit_id = '2SOUTH' AND discharge_date is null 
ORDER BY last_name


PRINT 'GROUP 3 SELECT B'

SELECT unit_dose_orders.pharmacist_initials, unit_dose_orders.entered_date, unit_dose_orders.dosage, medications.medication_description
FROM unit_dose_orders
JOIN medications
ON unit_dose_orders.medication_id = medications.medication_id
Where medication_description= 'Morphine' 
order by pharmacist_initials


PRINT 'GROUP 4 SELECT A'

SELECT 
physicians.physician_id, 
physicians.first_name, 
physicians.last_name,
physicians.specialty, 
encounters.patient_id,
patients.first_name
FROM ((physicians
JOIN encounters ON physicians.physician_id = encounters.physician_id)
JOIN patients ON encounters.patient_id = patients.patient_id)
where patients.first_name = 'Walter'


PRINT 'GROUP 4 SELECT B'

SELECT
patients.first_name,
patients.last_name,
admissions.nursing_unit_id,
admissions.primary_diagnosis,
admissions.discharge_date,
physicians.specialty
FROM ((patients
JOIN admissions ON patients.patient_id  = admissions.patient_id)
JOIN  physicians ON admissions.attending_physician_id = admissions.attending_physician_id)
WHERE admissions.discharge_date IS null 
AND physicians.specialty = 'internist'
ORDER BY first_name



PRINT 'GROUP 5 SELECT B'


SELECT
CONCAT(patients.first_name, ' ' ,patients.last_name) AS patient,
admissions.nursing_unit_id,
admissions.room, 
medications.medication_description
FROM (((patients
JOIN admissions ON patients.patient_id = admissions.patient_id)
JOIN unit_dose_orders on patients.patient_id = unit_dose_orders.patient_id)
JOIN medications on unit_dose_orders.medication_id = medications.medication_id)
WHERE allergies = 'Penicillin' and discharge_date is null


PRINT 'GROUP 6 SELECT B'

SELECT 
purchase_order_id,
order_date,
department_id
FROM purchase_orders
	WHERE NOT EXISTS ( SELECT purchase_order_line_id
	FROM purchase_order_lines 
	WHERE purchase_orders.purchase_order_id = purchase_order_lines.purchase_order_id)

