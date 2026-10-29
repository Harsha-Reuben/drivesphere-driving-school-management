# DriveSphere — Driving School Training & Licence Test Management System

Oracle SQL / PL/SQL portfolio project for a six-branch driving-school chain handling 400 learners per month and 50 vehicles.

## Scope
Learners, branches, courses, vehicles, instructors, slots, sessions, attendance, learner licence applications, driving test bookings/results, and payments.

## Key capabilities
- Collision-safe scheduling design with learner, instructor, and vehicle conflict checks
- Session eligibility and learner licence validation before driving tests
- Instructor utilisation, vehicle daily schedules, and first-attempt pass-rate reporting
- Planned Oracle APEX forms, calendar, LOV, master/detail and dashboards

## Getting started
Use an Oracle 19c+ database (or Oracle APEX with a supported Oracle database). Execute scripts in this order:
1. `database/01_schema.sql`
2. `database/02_logic.sql`
3. `database/03_analytics.sql`

Run the examples in `tests/manual_acceptance.sql` after adding test data.

**Status:** Initial SQL/PLSQL foundation. Not yet executed or verified on Oracle. APEX application, realistic seed data, automated tests and ERP integrations are planned. Do not use this prototype for real learner personal data.

## Architecture
Oracle APEX (planned) → PL/SQL packages and validation → Oracle relational database → SQL reporting views.

ERP integration is a proposed mock/demo; no live Oracle EBS/Fusion integration is claimed.

## Roadmap
1. Oracle setup and reproducible seed data
2. Concurrency and transactional booking tests
3. APEX role-based interfaces and master-detail forms
4. Dashboards, printable reports and payment reconciliation
5. ERP simulation, CI, screenshots and demo video
