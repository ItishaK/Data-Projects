-- Count of Diabetic vs. Non-Diabetic Patients by Gender
SELECT
    Gender,
    COUNT(CASE WHEN Outcome = 1 THEN 1 END) AS DiabeticCount,
    COUNT(CASE WHEN Outcome = 0 THEN 1 END) AS NonDiabeticCount
FROM patientDetails_ref
GROUP BY Gender
ORDER BY Gender;

-- Percentage of Diabetic Patients by Gender
SELECT
    Gender, age,
    ROUND(
        (COUNT(CASE WHEN Outcome = 1 THEN 1 END) * 100.0) / COUNT(*), 2
    ) AS DiabeticPercentage,
    ROUND(
        (COUNT(CASE WHEN Outcome = 0 THEN 1 END) * 100.0) / COUNT(*), 2
    ) AS NonDiabeticPercentage
FROM patientDetails_ref
WHERE Gender IS NOT NULL
GROUP BY Gender, age
ORDER BY Gender;