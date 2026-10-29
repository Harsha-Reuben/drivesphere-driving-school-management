CREATE OR REPLACE PACKAGE pkg_scheduling AS
  e_slot_clash EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_slot_clash,-20051);
  PROCEDURE book_slot(p_learner_id IN NUMBER,p_instructor_id IN NUMBER,p_vehicle_id IN NUMBER,p_start IN TIMESTAMP,p_end IN TIMESTAMP);
  FUNCTION sessions_remaining(p_learner_id IN NUMBER) RETURN NUMBER;
END pkg_scheduling;
/
CREATE OR REPLACE PACKAGE BODY pkg_scheduling AS
  FUNCTION sessions_remaining(p_learner_id IN NUMBER) RETURN NUMBER IS
    v_required NUMBER; v_done NUMBER;
  BEGIN
    SELECT c.required_sessions INTO v_required FROM learners l JOIN courses c ON c.course_id=l.course_id WHERE l.learner_id=p_learner_id;
    SELECT COUNT(*) INTO v_done FROM sessions s JOIN attendance a ON a.session_id=s.session_id WHERE s.learner_id=p_learner_id AND s.status='COMPLETED' AND a.present='Y';
    RETURN GREATEST(v_required-v_done,0);
  END;
  PROCEDURE book_slot(p_learner_id IN NUMBER,p_instructor_id IN NUMBER,p_vehicle_id IN NUMBER,p_start IN TIMESTAMP,p_end IN TIMESTAMP) IS
    v_branch NUMBER; v_ib NUMBER; v_vb NUMBER; v_status VARCHAR2(20); v_active CHAR(1); v_count NUMBER; v_slot NUMBER;
  BEGIN
    IF p_start IS NULL OR p_end IS NULL OR p_end<=p_start THEN RAISE_APPLICATION_ERROR(-20052,'Invalid slot interval'); END IF;
    SELECT branch_id INTO v_branch FROM learners WHERE learner_id=p_learner_id FOR UPDATE;
    SELECT branch_id,active INTO v_ib,v_active FROM instructors WHERE instructor_id=p_instructor_id FOR UPDATE;
    SELECT branch_id,status INTO v_vb,v_status FROM vehicles WHERE vehicle_id=p_vehicle_id FOR UPDATE;
    IF v_branch<>v_ib OR v_branch<>v_vb OR v_active<>'Y' OR v_status<>'READY' THEN RAISE_APPLICATION_ERROR(-20053,'Resource not available at learner branch'); END IF;
    SELECT COUNT(*) INTO v_count FROM slots sl JOIN sessions se ON se.slot_id=sl.slot_id
      WHERE se.status<>'CANCELLED' AND sl.starts_at<p_end AND sl.ends_at>p_start
      AND (sl.instructor_id=p_instructor_id OR sl.vehicle_id=p_vehicle_id OR se.learner_id=p_learner_id);
    IF v_count>0 THEN RAISE_APPLICATION_ERROR(-20051,'Slot clash: instructor, vehicle or learner already booked'); END IF;
    INSERT INTO slots(branch_id,instructor_id,vehicle_id,starts_at,ends_at) VALUES(v_branch,p_instructor_id,p_vehicle_id,p_start,p_end) RETURNING slot_id INTO v_slot;
    INSERT INTO sessions(slot_id,learner_id) VALUES(v_slot,p_learner_id);
    -- Caller controls COMMIT / ROLLBACK.
  END;
END pkg_scheduling;
/
CREATE OR REPLACE TRIGGER trg_test_eligibility
BEFORE INSERT ON test_bookings
FOR EACH ROW
DECLARE
  v_remaining NUMBER; v_valid NUMBER;
BEGIN
  v_remaining:=pkg_scheduling.sessions_remaining(:NEW.learner_id);
  IF v_remaining>0 THEN RAISE_APPLICATION_ERROR(-20061,'Insufficient completed training sessions'); END IF;
  SELECT COUNT(*) INTO v_valid FROM llr_applications WHERE learner_id=:NEW.learner_id AND status='APPROVED' AND issued_on<=TRUNC(:NEW.test_date) AND expires_on>=TRUNC(:NEW.test_date);
  IF v_valid=0 THEN RAISE_APPLICATION_ERROR(-20062,'Valid learner licence required on test date'); END IF;
END;
/
