CREATE OR REPLACE FUNCTION REFRESH_COVID_DATA (
    P_IN_FORCE NUMBER := NULL
) RETURN NUMBER IS
    VR_LAST_DATE   DATE := NULL;
    VR_BLOB        BLOB := EMPTY_BLOB();
BEGIN
    BEGIN
        SELECT
            UPDATED_ON
        INTO VR_LAST_DATE
        FROM
            T_COVID_CASES_INT
        WHERE
            ROWNUM = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            VR_LAST_DATE := SYSDATE - 100;
    END;

    IF ( SYSDATE - 1 / 24 ) > VR_LAST_DATE OR P_IN_FORCE = 1 THEN
        VR_BLOB := APEX_WEB_SERVICE.MAKE_REST_REQUEST_B(
            P_URL           => 'https://funkeinteraktiv.b-cdn.net/history.v4.csv',
            P_HTTP_METHOD   => 'GET'
        );
        DELETE FROM T_COVID_CASES_INT;

        INSERT INTO T_COVID_CASES_INT (
            COUNTRY,
            COUNTRY_SHORT,
            LAT,
            LONGI,
            DAY_OCC,
            VALUE_CONFIRMED,
            VALUE_CONFIRMED_BE,
            VALUE_RECOVERED,
            VALUE_RECOVERED_BE,
            VALUE_DEATHS,
            VALUE_DEATHS_BE,
            VALUE_ACTIVE,
            VALUE_ACTIVE_BE,
            UPDATED_ON
        )
            ( SELECT
                CASE
                    WHEN COUNTRY = 'Austia' THEN
                        'Austria'
                    WHEN COUNTRY = 'Libya'
                         AND LONGI = - 4
                         AND LAT = 17 THEN
                        'Libya (17,-4)'
                    ELSE
                        COUNTRY
                END,
                COUNTRY_SHORT,
                LAT,
                LONGI,
                DAY_OCC,
                VALUE_CONFIRMED,
                NVL(
                    LAG(VALUE_CONFIRMED) OVER(
                        PARTITION BY COUNTRY
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_CONFIRMED_BE,
                VALUE_RECOVERED,
                NVL(
                    LAG(VALUE_RECOVERED) OVER(
                        PARTITION BY COUNTRY
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_RECOVERED_BE,
                VALUE_DEATHS,
                NVL(
                    LAG(VALUE_DEATHS) OVER(
                        PARTITION BY COUNTRY
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_DEATHS_BE,
                VALUE_ACTIVE,
                NVL(
                    LAG(VALUE_ACTIVE) OVER(
                        PARTITION BY COUNTRY
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_ACTIVE_BE,
                UPDATED_ON
            FROM
                (
                    SELECT
                        COL005    AS COUNTRY,
                        COL001    AS COUNTRY_SHORT,
                        TO_NUMBER(
                            DECODE(
                                COL008,
                                'null',
                                0,
                                COL008
                            )
                        ) AS LAT,
                        TO_NUMBER(
                            DECODE(
                                COL007,
                                'null',
                                0,
                                COL007
                            )
                        ) AS LONGI,
                        TO_DATE(
                            COL010,
                            'YYYYMMDD'
                        ) AS DAY_OCC,
                        TO_NUMBER(COL014) AS VALUE_CONFIRMED,
                        TO_NUMBER(COL015) AS VALUE_RECOVERED,
                        TO_NUMBER(COL016) AS VALUE_DEATHS,
                        GREATEST(
                            TO_NUMBER(COL014) - NVL(
                                TO_NUMBER(COL015),
                                0
                            ) - NVL(
                                TO_NUMBER(COL016),
                                0
                            ),
                            0
                        ) AS VALUE_ACTIVE,
                        SYSDATE   AS UPDATED_ON
                    FROM
                        TABLE ( APEX_DATA_PARSER.PARSE(
                            P_CONTENT     => VR_BLOB,
                            P_FILE_NAME   => 'data.csv',
                            P_SKIP_ROWS   => 1
                        ) )
                    WHERE
                        SUBSTR(
                            COL011,
                            1,
                            1
                        ) = '0'
                )
            );

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20111,
                'No data is loaded for int.'
            );
        END IF;
        INSERT INTO T_COVID_CASES_INT (
            COUNTRY,
            LAT,
            LONGI,
            DAY_OCC,
            VALUE_CONFIRMED,
            VALUE_CONFIRMED_BE,
            VALUE_RECOVERED,
            VALUE_RECOVERED_BE,
            VALUE_DEATHS,
            VALUE_DEATHS_BE,
            VALUE_ACTIVE,
            VALUE_ACTIVE_BE,
            UPDATED_ON
        )
            ( SELECT
                COUNTRY,
                LAT,
                LONGI,
                DAY_OCC + 1,
                VALUE_CONFIRMED,
                VALUE_CONFIRMED,
                VALUE_RECOVERED,
                VALUE_RECOVERED,
                VALUE_DEATHS,
                VALUE_DEATHS,
                VALUE_ACTIVE,
                VALUE_ACTIVE,
                UPDATED_ON
            FROM
                T_COVID_CASES_INT BE
            WHERE
                BE.DAY_OCC = TRUNC(SYSDATE - 1)
                AND NOT EXISTS (
                    SELECT
                        1
                    FROM
                        T_COVID_CASES_INT TOD
                    WHERE
                        BE.COUNTRY = TOD.COUNTRY
                        AND TOD.DAY_OCC = TRUNC(SYSDATE)
                )
            );

        DELETE FROM T_COVID_CASES_GER;

        INSERT INTO T_COVID_CASES_GER (
            PROVINCE,
            LAT,
            LONGI,
            DAY_OCC,
            VALUE_CONFIRMED,
            VALUE_CONFIRMED_BE,
            VALUE_RECOVERED,
            VALUE_RECOVERED_BE,
            VALUE_DEATHS,
            VALUE_DEATHS_BE,
            VALUE_ACTIVE,
            VALUE_ACTIVE_BE,
            UPDATED_ON
        )
            ( SELECT
                PROVINCE,
                LAT,
                LONGI,
                DAY_OCC,
                VALUE_CONFIRMED,
                NVL(
                    LAG(VALUE_CONFIRMED) OVER(
                        PARTITION BY PROVINCE
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_CONFIRMED_BE,
                VALUE_RECOVERED,
                NVL(
                    LAG(VALUE_RECOVERED) OVER(
                        PARTITION BY PROVINCE
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_RECOVERED_BE,
                VALUE_DEATHS,
                NVL(
                    LAG(VALUE_DEATHS) OVER(
                        PARTITION BY PROVINCE
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_DEATHS_BE,
                VALUE_ACTIVE,
                NVL(
                    LAG(VALUE_ACTIVE) OVER(
                        PARTITION BY PROVINCE
                        ORDER BY
                            DAY_OCC
                    ),
                    0
                ) AS VALUE_ACTIVE_BE,
                UPDATED_ON
            FROM
                (
                    SELECT
                        COL003    AS PROVINCE,
                        TO_NUMBER(
                            DECODE(
                                COL008,
                                'null',
                                51.1642292,
                                COL008
                            )
                        ) AS LAT,
                        TO_NUMBER(
                            DECODE(
                                COL007,
                                'null',
                                10.4541194,
                                COL007
                            )
                        ) AS LONGI,
                        TO_DATE(
                            COL010,
                            'YYYYMMDD'
                        ) AS DAY_OCC,
                        TO_NUMBER(COL014) AS VALUE_CONFIRMED,
                        TO_NUMBER(COL015) AS VALUE_RECOVERED,
                        TO_NUMBER(COL016) AS VALUE_DEATHS,
                        GREATEST(
                            TO_NUMBER(COL014) - NVL(
                                TO_NUMBER(COL015),
                                0
                            ) - NVL(
                                TO_NUMBER(COL016),
                                0
                            ),
                            0
                        ) AS VALUE_ACTIVE,
                        SYSDATE   AS UPDATED_ON
                    FROM
                        TABLE ( APEX_DATA_PARSER.PARSE(
                            P_CONTENT     => VR_BLOB,
                            P_FILE_NAME   => 'data.csv',
                            P_SKIP_ROWS   => 1
                        ) )
                    WHERE
                        COL002 = 'de'
                        AND COL003 != 'weitere Fälle bundesweit'
                )
            );

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20111,
                'No data is loaded for ger.'
            );
        END IF;
        FOR REC IN (
            SELECT
                SUM(VALUE_CONFIRMED) AS VALUE_CONFIRMED,
                SUM(VALUE_CONFIRMED_BE) AS VALUE_CONFIRMED_BE,
                SUM(VALUE_RECOVERED) AS VALUE_RECOVERED,
                SUM(VALUE_RECOVERED_BE) AS VALUE_RECOVERED_BE,
                SUM(VALUE_DEATHS) AS VALUE_DEATHS,
                SUM(VALUE_DEATHS_BE) AS VALUE_DEATHS_BE,
                SUM(VALUE_ACTIVE) AS VALUE_ACTIVE,
                SUM(VALUE_ACTIVE_BE) AS VALUE_ACTIVE_BE,
                DAY_OCC
            FROM
                T_COVID_CASES_GER
            GROUP BY
                DAY_OCC
        ) LOOP UPDATE T_COVID_CASES_INT
        SET
            VALUE_CONFIRMED = REC.VALUE_CONFIRMED,
            VALUE_CONFIRMED_BE = REC.VALUE_CONFIRMED_BE,
            VALUE_RECOVERED = REC.VALUE_RECOVERED,
            VALUE_RECOVERED_BE = REC.VALUE_RECOVERED_BE,
            VALUE_DEATHS = REC.VALUE_DEATHS,
            VALUE_DEATHS_BE = REC.VALUE_DEATHS_BE,
            VALUE_ACTIVE = REC.VALUE_ACTIVE,
            VALUE_ACTIVE_BE = REC.VALUE_ACTIVE_BE
        WHERE
            DAY_OCC = REC.DAY_OCC
            AND COUNTRY = 'Germany';

        END LOOP;

        RETURN 1;
    END IF;

    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        APEX_DEBUG.ERROR(DBMS_UTILITY.FORMAT_ERROR_STACK);
        APEX_DEBUG.ERROR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        RAISE_APPLICATION_ERROR(
            -20111,
            'Error in PL/SQL Block occured.'
        );
END;