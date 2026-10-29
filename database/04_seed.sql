-- Demo data; run once on a clean schema.
INSERT INTO branches(name) VALUES ('RS Puram');
INSERT INTO branches(name) VALUES ('Peelamedu');
INSERT INTO branches(name) VALUES ('Gandhipuram');
INSERT INTO branches(name) VALUES ('Saibaba Colony');
INSERT INTO branches(name) VALUES ('Singanallur');
INSERT INTO branches(name) VALUES ('Saravanampatti');
INSERT INTO courses(name,required_sessions,fee) VALUES ('LMV Beginner',10,8500);
INSERT INTO courses(name,required_sessions,fee) VALUES ('LMV Refresher',5,4500);
INSERT INTO courses(name,required_sessions,fee) VALUES ('LMV Intensive',15,12000);
INSERT INTO instructors(branch_id,full_name) SELECT branch_id,'Instructor '||branch_id||'-A' FROM branches;
INSERT INTO instructors(branch_id,full_name) SELECT branch_id,'Instructor '||branch_id||'-B' FROM branches;
INSERT INTO vehicles(branch_id,registration_no) SELECT MOD(LEVEL-1,6)+1, 'TN-38-DS-'||LPAD(LEVEL,4,'0') FROM dual CONNECT BY LEVEL<=50;
INSERT INTO learners(branch_id,course_id,full_name,email,enrolled_on)
SELECT MOD(LEVEL-1,6)+1, MOD(LEVEL-1,3)+1, 'Demo Learner '||LEVEL, 'demo'||LEVEL||'@example.invalid', TRUNC(SYSDATE)-MOD(LEVEL,90)
FROM dual CONNECT BY LEVEL<=400;
COMMIT;
