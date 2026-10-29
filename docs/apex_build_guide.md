# Oracle APEX build guide (planned)

1. Obtain access to a supported Oracle APEX workspace and database.
2. Run the SQL files in order in SQL Workshop > SQL Scripts, checking compilation errors after each script.
3. Use App Builder to create a new application named DriveSphere.
4. Create master-detail pages: Learners master, Sessions detail; add LOVs for Branch and Course.
5. Create a Calendar page using slots STARTS_AT and ENDS_AT.
6. Use a form process that invokes PKG_SCHEDULING.BOOK_SLOT instead of direct DML.
7. Add interactive reports for VW_VEHICLE_DAILY_SCHEDULE and VW_INSTRUCTOR_DAILY_UTILISATION.
8. Add charts based on VW_BRANCH_FIRST_ATTEMPT_PASS and VW_INSTRUCTOR_PASS_RATE.
9. Implement role-specific authorisation for admin, manager and instructor before entering real data.
10. Export the application into an apex/ directory, document the APEX version, and add screenshots.

This is a build guide; an importable APEX application export has not yet been produced.
