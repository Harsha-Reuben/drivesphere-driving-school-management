CREATE OR REPLACE VIEW vw_branch_first_attempt_pass AS
SELECT b.branch_id,b.name branch_name,
COUNT(CASE WHEN tb.attempt_no=1 AND tr.outcome IN ('PASS','FAIL') THEN 1 END) first_attempts,
COUNT(CASE WHEN tb.attempt_no=1 AND tr.outcome='PASS' THEN 1 END) passes,
ROUND(100*COUNT(CASE WHEN tb.attempt_no=1 AND tr.outcome='PASS' THEN 1 END)/NULLIF(COUNT(CASE WHEN tb.attempt_no=1 AND tr.outcome IN ('PASS','FAIL') THEN 1 END),0),2) pass_pct
FROM branches b LEFT JOIN learners l ON l.branch_id=b.branch_id LEFT JOIN test_bookings tb ON tb.learner_id=l.learner_id LEFT JOIN test_results tr ON tr.test_booking_id=tb.test_booking_id GROUP BY b.branch_id,b.name;
CREATE OR REPLACE VIEW vw_instructor_daily_utilisation AS
SELECT i.instructor_id,i.full_name,TRUNC(CAST(sl.starts_at AS DATE)) work_day,
ROUND(SUM((CAST(sl.ends_at AS DATE)-CAST(sl.starts_at AS DATE))*24),2) booked_hours,
ROUND(100*SUM((CAST(sl.ends_at AS DATE)-CAST(sl.starts_at AS DATE))*24)/8,2) utilisation_pct
FROM instructors i JOIN slots sl ON sl.instructor_id=i.instructor_id JOIN sessions se ON se.slot_id=sl.slot_id
WHERE se.status<>'CANCELLED' GROUP BY i.instructor_id,i.full_name,TRUNC(CAST(sl.starts_at AS DATE));
CREATE OR REPLACE VIEW vw_vehicle_daily_schedule AS
SELECT TRUNC(CAST(sl.starts_at AS DATE)) schedule_day,v.registration_no,i.full_name instructor_name,l.full_name learner_name,sl.starts_at,sl.ends_at,se.status
FROM sessions se JOIN slots sl ON sl.slot_id=se.slot_id JOIN vehicles v ON v.vehicle_id=sl.vehicle_id JOIN instructors i ON i.instructor_id=sl.instructor_id JOIN learners l ON l.learner_id=se.learner_id;
CREATE OR REPLACE VIEW vw_instructor_pass_rate AS
WITH session_counts AS (SELECT se.learner_id,sl.instructor_id,COUNT(*) n FROM sessions se JOIN slots sl ON sl.slot_id=se.slot_id JOIN attendance a ON a.session_id=se.session_id WHERE se.status='COMPLETED' AND a.present='Y' GROUP BY se.learner_id,sl.instructor_id), primary_instructor AS (SELECT learner_id,instructor_id,ROW_NUMBER() OVER(PARTITION BY learner_id ORDER BY n DESC,instructor_id) rn FROM session_counts)
SELECT i.instructor_id,i.full_name,COUNT(tr.test_booking_id) tests,COUNT(CASE WHEN tr.outcome='PASS' THEN 1 END) passes,ROUND(100*COUNT(CASE WHEN tr.outcome='PASS' THEN 1 END)/NULLIF(COUNT(tr.test_booking_id),0),2) pass_pct
FROM instructors i LEFT JOIN primary_instructor pi ON pi.instructor_id=i.instructor_id AND pi.rn=1 LEFT JOIN test_bookings tb ON tb.learner_id=pi.learner_id LEFT JOIN test_results tr ON tr.test_booking_id=tb.test_booking_id GROUP BY i.instructor_id,i.full_name;
