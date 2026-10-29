SET SERVEROUTPUT ON
DECLARE
  v_learner NUMBER; v_instructor NUMBER; v_vehicle NUMBER;
  v_start TIMESTAMP := CAST(TRUNC(SYSDATE)+2+10/24 AS TIMESTAMP);
BEGIN
  SELECT MIN(learner_id) INTO v_learner FROM learners WHERE branch_id=(SELECT MIN(branch_id) FROM branches);
  SELECT MIN(instructor_id) INTO v_instructor FROM instructors WHERE branch_id=(SELECT MIN(branch_id) FROM branches);
  SELECT MIN(vehicle_id) INTO v_vehicle FROM vehicles WHERE branch_id=(SELECT MIN(branch_id) FROM branches);
  SAVEPOINT demo_test;
  pkg_scheduling.book_slot(v_learner,v_instructor,v_vehicle,v_start,v_start+INTERVAL '1' HOUR);
  BEGIN
    pkg_scheduling.book_slot(v_learner,v_instructor,v_vehicle,v_start+INTERVAL '30' MINUTE,v_start+INTERVAL '90' MINUTE);
    RAISE_APPLICATION_ERROR(-20999,'FAIL: overlapping slot accepted');
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE=-20051 THEN DBMS_OUTPUT.PUT_LINE('PASS: overlapping slot rejected');
    ELSE RAISE; END IF;
  END;
  DBMS_OUTPUT.PUT_LINE('Remaining sessions: '||pkg_scheduling.sessions_remaining(v_learner));
  ROLLBACK TO demo_test;
END;
/
SELECT * FROM vw_branch_first_attempt_pass ORDER BY branch_id;
