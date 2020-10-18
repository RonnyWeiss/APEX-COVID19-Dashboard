BEGIN
--DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'JOB_REFRESH_COVID_DATA');
DBMS_SCHEDULER.CREATE_JOB(
                JOB_NAME              => 'JOB_REFRESH_COVID_DATA',
                JOB_TYPE              => 'PLSQL_BLOCK',
                JOB_ACTION            => 'DECLARE
                                             VR_RET NUMBER;
                                          BEGIN
                                            VR_RET := REFRESH_COVID_DATA;
                                          EXCEPTION
                                            WHEN OTHERS THEN
                                                ROLLBACK;
                                                RAISE;
                                          END;',
                NUMBER_OF_ARGUMENTS   => 0,
                START_DATE            => NULL,
                REPEAT_INTERVAL       => 'FREQ=HOURLY;INTERVAL=1',
                END_DATE              => NULL,
                ENABLED               => TRUE,
                AUTO_DROP             => FALSE,
                COMMENTS              => ''
            );
END;

 