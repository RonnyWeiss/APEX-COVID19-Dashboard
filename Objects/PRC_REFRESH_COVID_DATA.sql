CREATE OR REPLACE PROCEDURE REFRESH_COVID_DATA IS

    VR_LAST_DATE   DATE := NULL;
    VR_BLOB        BLOB := EMPTY_BLOB();
    C_GERMAN_STR   CONSTANT VARCHAR(50) := 'Deutschland';
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

    VR_BLOB := APEX_WEB_SERVICE.MAKE_REST_REQUEST_B(
        P_URL           => 'https://raw.githubusercontent.com/RonnyWeiss/APEX-COVID19-Dashboard/master/data/covid-data.json',
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
                    'Mali'
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
                    COUNTRY,
                    COUNTRY_SHORT,
                    LAT,
                    LONGI,
                    DAY_OCC,
                    VALUE_CONFIRMED,
                    VALUE_RECOVERED,
                    VALUE_DEATHS,
                    GREATEST(
                        VALUE_CONFIRMED - NVL(
                            VALUE_RECOVERED,
                            0
                        ) - NVL(
                            VALUE_DEATHS,
                            0
                        ),
                        0
                    ) AS VALUE_ACTIVE,
                    SYSDATE AS UPDATED_ON
                FROM
                    JSON_TABLE ( VR_BLOB, '$[*]' ERROR ON ERROR
                        COLUMNS (
                            COUNTRY VARCHAR2 PATH '$.label',
                            LABEL_PARENT VARCHAR2 PATH '$.label_parent',
                            COUNTRY_SHORT VARCHAR2 PATH '$.id',
                            LAT NUMBER PATH '$.lat',
                            LONGI NUMBER PATH '$.lon',
                            DAY_OCC DATE PATH '$.date',
                            VALUE_CONFIRMED DATE PATH '$.confirmed',
                            VALUE_RECOVERED DATE PATH '$.recovered',
                            VALUE_DEATHS DATE PATH '$.deaths'
                        )
                    )
                WHERE
                    LABEL_PARENT IS NULL
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
                    PROVINCE,
                    LAT,
                    LONGI,
                    DAY_OCC,
                    VALUE_CONFIRMED,
                    VALUE_RECOVERED,
                    VALUE_DEATHS,
                    GREATEST(
                        VALUE_CONFIRMED - NVL(
                            VALUE_RECOVERED,
                            0
                        ) - NVL(
                            VALUE_DEATHS,
                            0
                        ),
                        0
                    ) AS VALUE_ACTIVE,
                    SYSDATE AS UPDATED_ON
                FROM
                    JSON_TABLE ( VR_BLOB, '$[*]' ERROR ON ERROR
                        COLUMNS (
                            PROVINCE VARCHAR2 PATH '$.label',
                            LAT NUMBER PATH '$.lat',
                            LONGI NUMBER PATH '$.lon',
                            DAY_OCC DATE PATH '$.date',
                            VALUE_CONFIRMED DATE PATH '$.confirmed',
                            VALUE_RECOVERED DATE PATH '$.recovered',
                            VALUE_DEATHS DATE PATH '$.deaths'
                        )
                    )
                WHERE
                    LABEL_PARENT = C_GERMAN_STR
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
        AND COUNTRY = C_GERMAN_STR;

    END LOOP;

END;