
-- Copy Data from CSV file to History table
COPY patientDetails_history(patientID, age, gender, bmi, glucoseLevel, outcome, readmission, visitDate)
FROM 'input_path\diabetes_data.csv'
delimiter ','
csv header ;


-- Insert data to Refined table from Raw table
insert into patientDetails_ref(patientID, age,gender,bmi,glucoseLevel,
outcome,readmission,visitDate)
select
    patientID,
    age,
    gender,
    CAST(bmi as DOUBLE PRECISION),
    CAST(glucoseLevel AS INTEGER),
    CAST(outcome as INTEGER),
    CAST(readmission as INTEGER),
    CAST(visitDate as DATE)
from patientDetails_rw;

-- If you want your seqID in Refined table to start from a specific value like 100 (Optional)
UPDATE patientDetails_ref
set seqId = seqId + 100;