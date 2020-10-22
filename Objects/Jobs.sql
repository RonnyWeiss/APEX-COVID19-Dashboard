BEGIN
--DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'JOB_REFRESH_COVID_DATA');
DBMS_SCHEDULER.CREATE_JOB(
                JOB_NAME              => 'JOB_REFRESH_COVID_DATA',
                JOB_TYPE              => 'PLSQL_BLOCK',
                JOB_ACTION            => 'DECLARE
                                          BEGIN
                                            REFRESH_COVID_DATA;
                                          EXCEPTION
                                            WHEN OTHERS THEN
                                                ROLLBACK;
                                                RAISE;
                                          END;',
                NUMBER_OF_ARGUMENTS   => 0,
                START_DATE            => TRUNC(SYSDATE),
                REPEAT_INTERVAL       => 'FREQ=HOURLY;INTERVAL=3',
                END_DATE              => NULL,
                ENABLED               => TRUE,
                AUTO_DROP             => FALSE,
                COMMENTS              => ''
            );
END;
/
