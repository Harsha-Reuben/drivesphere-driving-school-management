# Architecture and business rules

## Entities
Branches own learners, instructors and vehicles. Learners enrol in courses with a required session count. Slots assign a vehicle and instructor; sessions associate a learner with each slot. Attendance records whether completed sessions count toward test eligibility. Learner licence applications record LLR status and validity; driving tests record attempts and outcomes. Payments record fee receipts.

## Scheduling
A booking checks branch consistency, instructor activation, vehicle readiness, and overlap for the learner, instructor or vehicle. Two intervals overlap when existing.start < requested.end AND existing.end > requested.start. The package locks resource rows before conflict checks. All booking writes must use the package; direct INSERT access would bypass the rule. Further concurrency tests and lock-order review are required before production use.

## Test eligibility
An INSERT trigger rejects bookings unless the learner has completed enough attended sessions and has an approved LLR valid on the test date. Rules for test rescheduling, retakes and RTO-specific eligibility require further modelling.

## Analytics
Views expose branch first-attempt pass rates, instructor daily booked-hours utilisation (assumed 8-hour day), vehicle schedules and instructor-attributed pass rates. Attribution uses the instructor with the most completed attended sessions.

## Security and compliance
Use synthetic data only. Planned: role-based APEX authorisation, audit logging, least-privilege grants, retention policy, payment reconciliation and operational validation.

## Integration
EBS/Fusion asset management, O2C and OTBI-style dashboards are future demonstrations, not live integrations.
