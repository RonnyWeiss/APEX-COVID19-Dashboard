CREATE OR REPLACE FORCE VIEW V_COVID_CASES_GER AS
    SELECT
        HI.PROVINCE,
        HI.LAT,
        HI.LONGI,
        HI.DAY_OCC,
        HI.VALUE_CONFIRMED,
        HI.VALUE_CONFIRMED_BE,
        HI.VALUE_RECOVERED,
        HI.VALUE_RECOVERED_BE,
        HI.VALUE_DEATHS,
        HI.VALUE_DEATHS_BE,
        HI.VALUE_ACTIVE,
        HI.VALUE_ACTIVE_BE,
        HI.UPDATED_ON,
        GE.POPULATION,
        (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/province/flagge-' ||
        LOWER(
            REPLACE(
                REPLACE(
                    HI.PROVINCE,
                    'ü',
                    'ue'
                ),
                ' ',
                '-'
            )
        ) ||
        '.png' AS FLAG
    FROM
        T_COVID_CASES_GER HI LEFT
        JOIN T_POP_GER GE
        ON HI.PROVINCE = GE.PROVINCE;

CREATE OR REPLACE FORCE VIEW V_COVID_CASES_GER_LATEST AS
    SELECT
        GE.PROVINCE,
        GE.LAT,
        GE.LONGI,
        GE.DAY_OCC,
        GE.VALUE_CONFIRMED,
        GE.VALUE_CONFIRMED_BE,
        GE.VALUE_RECOVERED,
        GE.VALUE_RECOVERED_BE,
        GE.VALUE_DEATHS,
        GE.VALUE_DEATHS_BE,
        GE.VALUE_ACTIVE,
        GE.VALUE_ACTIVE_BE,
        GE.UPDATED_ON,
        GE.POPULATION,
        GE.FLAG
    FROM
        V_COVID_CASES_GER GE
    WHERE
        GE.DAY_OCC = (SELECT MAX(MA.DAY_OCC) FROM V_COVID_CASES_GER MA );

CREATE OR REPLACE FORCE VIEW V_COVID_CASES_INT AS
    SELECT
        HI.COUNTRY,
        HI.LAT,
        HI.LONGI,
        HI.DAY_OCC,
        HI.VALUE_CONFIRMED,
        HI.VALUE_CONFIRMED_BE,
        HI.VALUE_RECOVERED,
        HI.VALUE_RECOVERED_BE,
        HI.VALUE_DEATHS,
        HI.VALUE_DEATHS_BE,
        HI.VALUE_ACTIVE,
        HI.VALUE_ACTIVE_BE,
        HI.UPDATED_ON,
        PO.POPULATION,
        (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/' || HI.COUNTRY_SHORT || '.svg' AS FLAG
    FROM
        T_COVID_CASES_INT HI LEFT
        JOIN T_POP_INT PO
        ON HI.COUNTRY = PO.COUNTRY;

CREATE OR REPLACE FORCE VIEW V_COVID_CASES_INT_LATEST AS
    SELECT
        HI.COUNTRY,
        HI.LAT,
        HI.LONGI,
        HI.DAY_OCC,
        HI.VALUE_CONFIRMED,
        HI.VALUE_CONFIRMED_BE,
        HI.VALUE_RECOVERED,
        HI.VALUE_RECOVERED_BE,
        HI.VALUE_DEATHS,
        HI.VALUE_DEATHS_BE,
        HI.VALUE_ACTIVE,
        HI.VALUE_ACTIVE_BE,
        HI.UPDATED_ON,
        HI.POPULATION,
        HI.FLAG
    FROM
        V_COVID_CASES_INT HI
    WHERE
        HI.DAY_OCC = (SELECT MAX(MA.DAY_OCC) FROM V_COVID_CASES_INT MA);
        
CREATE OR REPLACE FORCE VIEW V_COVID_DASHBOARD_WORLD AS
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total active ' || NULLIF('(' || V('P32_COUNTRY_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_COUNTRY_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-ambulance',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_ACTIVE'),
        'value' VALUE TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_ACTIVE) - SUM(VALUE_ACTIVE_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total dead ' || NULLIF('(' || V('P32_COUNTRY_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_COUNTRY_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-minus-circle-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_DEAD'),
        'value' VALUE TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_DEATHS) - SUM(VALUE_DEATHS_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total confirmed ' || NULLIF('(' || V('P32_COUNTRY_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_COUNTRY_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-life-ring',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_CONFIRMED'),
        'value' VALUE TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_CONFIRMED) - SUM(VALUE_CONFIRMED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total recovered ' || NULLIF('(' || V('P32_COUNTRY_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_COUNTRY_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-smile-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_RECOVERED'),
        'value' VALUE TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_RECOVERED) - SUM(VALUE_RECOVERED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'map',
    'title' VALUE NVL(V('P32_COUNTRY_FILTER'), 'Worldwide') || ' - cases of active and dead',
    'colSpan' VALUE 8,
    'height' VALUE 480,
    'isMarked' VALUE DECODE(V('P32_COUNTRY_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG( 
            JSON_OBJECT(
                'radius' VALUE NVL(VAL/1.6,0),
                'latitude' VALUE LAT,
                'longitude' VALUE LONGI,
                'link' VALUE NULL, --'javascript:apex.item(''P32_COUNTRY_FILTER'').setValue('''||COUNTRY||''');$(''#dashboard'').trigger(''apexrefresh'');void(0);',
                'color' VALUE COLOR,
                'tooltip' VALUE '<b>' || COUNTRY || '</b>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_ACTIVE') FROM DUAL)||'">Active: ' || TO_CHAR(VALUE_ACTIVE, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_ACTIVE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_ACTIVE') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_ACTIVE_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_DEAD') FROM DUAL)||'">Dead: ' || TO_CHAR(VALUE_DEATHS, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_DEATHS, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_DEAD') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_DEATHS_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                ||'<br><span style="color:'||(SELECT V('P32_COLOR_CONFIRMED') FROM DUAL)||'">Confirmed: ' || TO_CHAR(VALUE_CONFIRMED, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_CONFIRMED, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_CONFIRMED') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_CONFIRMED_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_RECOVERED') FROM DUAL)||'">Recovered: ' || TO_CHAR(VALUE_RECOVERED, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_RECOVERED, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_RECOVERED') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_RECOVERED_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                || '<br><span style="color:#303030">Population of '||COUNTRY||': ' || TO_CHAR(POPULATION, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</span>'
                RETURNING BLOB)
            RETURNING BLOB)
        FROM (
            SELECT
                1 AS SORT_ORDER,
                LOG(2,NULLIF(VALUE_ACTIVE,0)) AS VAL,
                LAT,
                LONGI,
                (SELECT V('P32_COLOR_ACTIVE') FROM DUAL) AS COLOR,
                COUNTRY,
                VALUE_CONFIRMED,
                VALUE_CONFIRMED - VALUE_CONFIRMED_BE AS CHANGED_CONFIRMED,
                ROUND(VALUE_CONFIRMED/POPULATION*100000,2) AS VALUE_CONFIRMED_PERC,
                VALUE_RECOVERED,
                VALUE_RECOVERED - VALUE_RECOVERED_BE AS CHANGED_RECOVERED,
                ROUND(VALUE_RECOVERED/POPULATION*100000,2) AS VALUE_RECOVERED_PERC,
                VALUE_DEATHS,
                VALUE_DEATHS - VALUE_DEATHS_BE AS CHANGED_DEATHS,
                ROUND(VALUE_DEATHS/POPULATION*100000,2) AS VALUE_DEATHS_PERC,
                VALUE_ACTIVE,
                VALUE_ACTIVE - VALUE_ACTIVE_BE AS CHANGED_ACTIVE,
                ROUND(VALUE_ACTIVE/POPULATION*100000,2) AS VALUE_ACTIVE_PERC,
                POPULATION
            FROM V_COVID_CASES_INT_LATEST
             WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
                2 AS SORT_ORDER,
                LOG(2.5,NULLIF(VALUE_DEATHS,0)) AS VAL,
                LAT,
                LONGI,
                (SELECT V('P32_COLOR_DEAD') FROM DUAL) AS COLOR,
                COUNTRY,
                VALUE_CONFIRMED,
                VALUE_CONFIRMED - VALUE_CONFIRMED_BE AS CHANGED_CONFIRMED,
                ROUND(VALUE_CONFIRMED/POPULATION*100000,2) AS VALUE_CONFIRMED_PERC,
                VALUE_RECOVERED,
                VALUE_RECOVERED - VALUE_RECOVERED_BE AS CHANGED_RECOVERED,
                ROUND(VALUE_RECOVERED/POPULATION*100000,2) AS VALUE_RECOVERED_PERC,
                VALUE_DEATHS,
                VALUE_DEATHS - VALUE_DEATHS_BE AS CHANGED_DEATHS,
                ROUND(VALUE_DEATHS/POPULATION*100000,2) AS VALUE_DEATHS_PERC,
                VALUE_ACTIVE,
                VALUE_ACTIVE - VALUE_ACTIVE_BE AS CHANGED_ACTIVE,
                ROUND(VALUE_ACTIVE/POPULATION*100000,2) AS VALUE_ACTIVE_PERC,
                POPULATION
            FROM V_COVID_CASES_INT_LATEST
             WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
            ORDER BY VALUE_ACTIVE, COUNTRY, SORT_ORDER
        ) HI )
    RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT ( 
    'title' VALUE 'Time course per day ' || NULLIF('(' || V('P32_COUNTRY_FILTER') || ')','()'),
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 240,
    'isMarked' VALUE DECODE((SELECT V('P32_COUNTRY_FILTER') FROM DUAL),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'area',
                'color' VALUE COLOR,
                'x' VALUE DAY_OCC,
                'y' VALUE CNT
                RETURNING BLOB)
            RETURNING BLOB)
            FROM (
                SELECT
                SUM(VALUE_RECOVERED) AS CNT,
                DAY_OCC,
                'Recovered' AS SERIES,
                V('P32_COLOR_RECOVERED') AS COLOR
                FROM V_COVID_CASES_INT
                WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
                UNION ALL
                SELECT
                SUM(VALUE_ACTIVE) AS CNT,
                DAY_OCC,
                'Active' AS SERIES,
                V('P32_COLOR_ACTIVE') AS COLOR
                FROM V_COVID_CASES_INT
                WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
                UNION ALL
                SELECT
                SUM(VALUE_DEATHS) AS CNT,
                DAY_OCC,
                'Dead' AS SERIES,
                V('P32_COLOR_DEAD') AS COLOR
                FROM V_COVID_CASES_INT
                WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
                UNION ALL
                SELECT
                SUM(VALUE_CONFIRMED) AS CNT,
                DAY_OCC,
                'Confirmed' AS SERIES,
                V('P32_COLOR_CONFIRMED') AS COLOR
                FROM V_COVID_CASES_INT
                WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
            )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'list',
    'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_ACTIVE') ||'"></span> Active (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
    'colSpan' VALUE 2,
    'height' VALUE 430,
    'oversize' VALUE 0,
    'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
    'optionsLinkIcon' VALUE 'fa-sort',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'title' VALUE ROWNUM || '. ' || COUNTRY,
                'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                'icon' VALUE FLAG,
                'iconColor' VALUE 'white',
                'iconBackColor' VALUE (SELECT V('P32_COLOR_CONFIRMED') FROM DUAL)
                RETURNING BLOB)
            RETURNING BLOB)
        FROM
        (SELECT
             SUM(VALUE_ACTIVE) AS CNT,
             SUM(VALUE_ACTIVE_BE) AS CNT_BE,
             SUM(VALUE_ACTIVE)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
             COUNTRY,
             FLAG
         FROM V_COVID_CASES_INT_LATEST
         GROUP BY COUNTRY, POPULATION, FLAG
         ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
         WHERE ROWNUM <= 100 AND CNT > 0
   ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
    JSON_OBJECT (
        'itemType' VALUE 'list',
        'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_DEAD') ||'"></span> Dead (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
        'colSpan' VALUE 2,
        'height' VALUE 430,
        'oversize' VALUE 0,
        'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
        'optionsLinkIcon' VALUE 'fa-sort',
        'itemData' VALUE (
            SELECT
            JSON_ARRAYAGG(JSON_OBJECT(
                'title' VALUE ROWNUM || '. ' || COUNTRY,
                'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                'icon' VALUE FLAG,
                'iconColor' VALUE 'white',
                'iconBackColor' VALUE (SELECT V('P32_COLOR_DEAD') FROM DUAL)
            RETURNING BLOB) RETURNING BLOB)
        FROM (
            SELECT
                SUM(VALUE_DEATHS) AS CNT,
                SUM(VALUE_DEATHS_BE) AS CNT_BE,
                SUM(VALUE_DEATHS)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
                COUNTRY,
                FLAG
            FROM V_COVID_CASES_INT_LATEST
            GROUP BY COUNTRY, POPULATION, FLAG
            ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
            WHERE ROWNUM <= 100 AND CNT > 0
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'list',
    'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_CONFIRMED') ||'"></span> Confirmed (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
    'colSpan' VALUE 2,
    'height' VALUE 425,
    'oversize' VALUE 0,
    'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
    'optionsLinkIcon' VALUE 'fa-sort',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'title' VALUE ROWNUM || '. ' || COUNTRY,
                'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                'icon' VALUE FLAG,
                'iconColor' VALUE 'white',
                'iconBackColor' VALUE (SELECT V('P32_COLOR_CONFIRMED') FROM DUAL)
                RETURNING BLOB)
            RETURNING BLOB)
        FROM
        (SELECT
             SUM(VALUE_CONFIRMED) AS CNT,
             SUM(VALUE_CONFIRMED_BE) AS CNT_BE,
             SUM(VALUE_CONFIRMED)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
             COUNTRY,
             FLAG
         FROM V_COVID_CASES_INT_LATEST
         GROUP BY COUNTRY, POPULATION, FLAG
         ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
         WHERE ROWNUM <= 100 AND CNT > 0
   ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'list',
    'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_RECOVERED')||'"></span> Recovered (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
    'colSpan' VALUE 2,
    'height' VALUE 425,
    'oversize' VALUE 0,
    'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
    'optionsLinkIcon' VALUE 'fa-sort',
    'itemData' VALUE (
        SELECT
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'title' VALUE ROWNUM || '. ' || COUNTRY,
                    'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                    || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                    || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                    || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                    'icon' VALUE FLAG,
                    'iconColor' VALUE 'white',
                    'iconBackColor' VALUE (SELECT V('P32_COLOR_RECOVERED') FROM DUAL)
                    RETURNING BLOB) 
                RETURNING BLOB)
        FROM (
            SELECT
                SUM(VALUE_RECOVERED) AS CNT,
                SUM(VALUE_RECOVERED_BE) AS CNT_BE,
                SUM(VALUE_RECOVERED)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
                COUNTRY,
                FLAG
            FROM V_COVID_CASES_INT_LATEST
            GROUP BY COUNTRY, POPULATION, FLAG
            ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
            WHERE ROWNUM <= 100 AND CNT > 0
    ) RETURNING BLOB ) AS JSON_BLOB
FROM
    DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'title' VALUE 'Distribution of latest ' || NULLIF('(' || V('P32_COUNTRY_FILTER') || ')','()'),
    'itemType' VALUE 'chart',
    'colSpan' VALUE 2,
    'height' VALUE 240,
    'isMarked' VALUE DECODE(V('P32_COUNTRY_FILTER'),NULL,NULL,1),
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'itemConfig' VALUE JSON_OBJECT (
        'paddingLeft' VALUE 1,
        'paddingTop' VALUE 1,
        'paddingRight' VALUE 1,
        'paddingBottom' VALUE 1,
        'legendShow' VALUE 1,
        'legendPosition' VALUE 'bottom',
        'gaugeType' VALUE 'multi',
        'gaugeFullCircle' VALUE 1),
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'gauge',
                'color' VALUE COLOR,
                'x' VALUE 1,
                'y' VALUE CNT,
                'tooltipSubText' VALUE TT
                RETURNING BLOB)
            RETURNING BLOB)
        FROM (
            SELECT
            SUM(VALUE_CONFIRMED) AS CNT,
            'Confirmed' AS SERIES,
            V('P32_COLOR_CONFIRMED') AS COLOR,
            'Confirmed: ' || TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_ACTIVE) AS CNT,
            'Active' AS SERIES,
            V('P32_COLOR_ACTIVE') AS COLOR,
            'Active: ' || TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_RECOVERED) AS CNT,
            'Recovered' AS SERIES,
            V('P32_COLOR_RECOVERED') AS COLOR,
            'Recovered: ' || TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_DEATHS) AS CNT,
            'Dead' AS SERIES,
            V('P32_COLOR_DEAD') AS COLOR,
            'Dead: ' || TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) OR (SELECT V('P32_COUNTRY_FILTER') FROM DUAL) IS NULL)
        )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL;

CREATE OR REPLACE FORCE VIEW V_COVID_DASHBOARD_NEWS AS
SELECT JSON_OBJECT(
 'itemType' VALUE 'list',
 'title' VALUE 'News Sites (Click to show)',
 'colSpan' VALUE 2,
 'height' VALUE 100,
 'oversize' VALUE 1,
 'itemData' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT(
  'title' VALUE TITLE,
  'text' VALUE NULL,
  'icon' VALUE ICON,
  'iconColor' VALUE 'white',
  'iconBackColor' VALUE 'rgb(80,95,109)',
  'link' VALUE 'javascript:$(''body'').trigger(''refreshNews'', '''||TITLE||''');void(0);'
  RETURNING BLOB) RETURNING BLOB) FROM 
  (
      SELECT 
      'NBC News' AS TITLE,
      (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/uk.svg' AS ICON
      FROM DUAL
      UNION ALL
      SELECT 
      'WHO Q&A' AS TITLE,
      (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/uk.svg' AS ICON
      FROM DUAL
      UNION ALL
      SELECT 
      'German Intensive Care Register' AS TITLE,
      (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/de.svg' AS ICON
      FROM DUAL
      UNION ALL
      SELECT 
      'ZDF News Ticker' AS TITLE,
      (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/de.svg' AS ICON
      FROM DUAL
      UNION ALL
      SELECT 
      'MDR Aktuell News Ticker' AS TITLE,
      (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/de.svg' AS ICON
      FROM DUAL
      UNION ALL
      SELECT 
      'MDR Sachsen News Ticker' AS TITLE,
      (SELECT V('WORKSPACE_IMAGES') FROM DUAL) || 'flags/country/de.svg' AS ICON
      FROM DUAL)
 ) RETURNING BLOB) AS JSON_BLOB FROM DUAL
UNION ALL
SELECT
 JSON_OBJECT(
  'itemType' VALUE 'html',
  'title' VALUE V('P32_NEWS_ID'),
  'oversize' VALUE 1,
  'itemData' VALUE '<iframe id="news-1" style="width:100%;border:none;height:70vh" src="https://www.nbcnews.com/health/coronavirus"></iframe>'
  RETURNING BLOB) AS JSON_BLOB FROM DUAL WHERE V('P32_NEWS_ID') = 'NBC News'
UNION ALL
SELECT
 JSON_OBJECT(
  'itemType' VALUE 'html',
  'title' VALUE V('P32_NEWS_ID'),
  'oversize' VALUE 1,
  'itemData' VALUE '<iframe id="news-2" style="width:100%;border:none;height:70vh" src="https://www.who.int/"></iframe>'
  RETURNING BLOB) AS JSON_BLOB FROM DUAL WHERE V('P32_NEWS_ID') = 'WHO Q&A'
UNION ALL
SELECT
 JSON_OBJECT(
  'itemType' VALUE 'html',
  'title' VALUE V('P32_NEWS_ID'),
  'oversize' VALUE 1,
  'itemData' VALUE '<iframe id="news-3" style="width:100%;border:none;height:70vh" src="https://www.mdr.de/nachrichten"></iframe>'
  RETURNING BLOB) AS JSON_BLOB FROM DUAL WHERE V('P32_NEWS_ID') = 'MDR Aktuell News Ticker'
UNION ALL
SELECT
 JSON_OBJECT(
  'itemType' VALUE 'html',
  'title' VALUE V('P32_NEWS_ID'),
  'oversize' VALUE 1,
  'itemData' VALUE '<iframe id="news-4" style="width:100%;border:none;height:70vh" src="https://www.mdr.de/sachsen/index.html"></iframe>'
  RETURNING BLOB) AS JSON_BLOB FROM DUAL WHERE V('P32_NEWS_ID') = 'MDR Sachsen News Ticker'
UNION ALL
SELECT
 JSON_OBJECT(
  'itemType' VALUE 'html',
  'title' VALUE V('P32_NEWS_ID'),
  'oversize' VALUE 1,
  'itemData' VALUE '<iframe id="news-4" style="width:100%;border:none;height:70vh" src="https://www.zdf.de/nachrichten/politik/blog-coronavirus-102.html"></iframe>'
  RETURNING BLOB) AS JSON_BLOB FROM DUAL WHERE V('P32_NEWS_ID') = 'ZDF News Ticker'
UNION ALL
SELECT
 JSON_OBJECT(
  'itemType' VALUE 'html',
  'title' VALUE V('P32_NEWS_ID'),
  'oversize' VALUE 1,
  'itemData' VALUE '<iframe id="news-4" style="width:100%;border:none;height:70vh" src="https://www.intensivregister.de/#/intensivregister"></iframe>'
  RETURNING BLOB) AS JSON_BLOB FROM DUAL WHERE V('P32_NEWS_ID') = 'German Intensive Care Register';

CREATE OR REPLACE FORCE VIEW V_COVID_DASHBOARD_GER AS 
  SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total active ' || NULLIF('(' || V('P32_PROVINCE_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-ambulance',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_ACTIVE'),
        'value' VALUE TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_ACTIVE) - SUM(VALUE_ACTIVE_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_GER_LATEST
    WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total dead ' || NULLIF('(' || V('P32_PROVINCE_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-minus-circle-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_DEAD'),
        'value' VALUE TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_DEATHS) - SUM(VALUE_DEATHS_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_GER_LATEST
    WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total confirmed ' || NULLIF('(' || V('P32_PROVINCE_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-life-ring',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_CONFIRMED'),
        'value' VALUE TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_CONFIRMED) - SUM(VALUE_CONFIRMED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_GER_LATEST
    WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total recovered ' || NULLIF('(' || V('P32_PROVINCE_FILTER') || ')','()'),
    'colSpan' VALUE 2,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-smile-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_RECOVERED'),
        'value' VALUE TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_RECOVERED) - SUM(VALUE_RECOVERED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_GER_LATEST
    WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'map',
    'title' VALUE NVL(V('P32_PROVINCE_FILTER'), 'German') || ' - cases of active and dead',
    'colSpan' VALUE 8,
    'height' VALUE 480,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'itemConfig' VALUE JSON_OBJECT (
    'mapCenterLongitude' VALUE 10.4515,
    'mapCenterLatitude' VALUE 51.1657,
    'mapInitialZoom' VALUE 12,
    'mapZoomEnabled' VALUE 0),
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG( 
            JSON_OBJECT(
                'radius' VALUE NVL(VAL*1.6,0),
                'latitude' VALUE LAT,
                'longitude' VALUE LONGI,
                'color' VALUE COLOR,
                'tooltip' VALUE '<b>' || PROVINCE || '</b>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_ACTIVE') FROM DUAL)||'">Active: ' || TO_CHAR(VALUE_ACTIVE, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_ACTIVE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_ACTIVE') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_ACTIVE_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_DEAD') FROM DUAL)||'">Dead: ' || TO_CHAR(VALUE_DEATHS, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_DEATHS, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_DEAD') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_DEATHS_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                ||'<br><span style="color:'||(SELECT V('P32_COLOR_CONFIRMED') FROM DUAL)||'">Confirmed: ' || TO_CHAR(VALUE_CONFIRMED, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_CONFIRMED, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_CONFIRMED') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_CONFIRMED_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_RECOVERED') FROM DUAL)||'">Recovered: ' || TO_CHAR(VALUE_RECOVERED, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' (' 
                || REPLACE(TO_CHAR(CHANGED_RECOVERED, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') || ')</span>'
                || '<br><span style="color:'||(SELECT V('P32_COLOR_RECOVERED') FROM DUAL)||'">Cases/100k: ' 
                || RTRIM(REPLACE(NVL(TO_CHAR(VALUE_RECOVERED_PERC, 'FM999999999999990.99', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-'),' ',''),'.') || '</span>'
                || '<br><span style="color:#303030">Population of '||PROVINCE||': ' || TO_CHAR(POPULATION, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</span>'
                RETURNING BLOB)
            RETURNING BLOB)
        FROM (
            SELECT
                1 AS SORT_ORDER,
                LOG(2,NULLIF(VALUE_ACTIVE,0)) AS VAL,
                LAT,
                LONGI,
                V('P32_COLOR_ACTIVE') AS COLOR,
                PROVINCE,
                VALUE_CONFIRMED,
                VALUE_CONFIRMED - VALUE_CONFIRMED_BE AS CHANGED_CONFIRMED,
                ROUND(VALUE_CONFIRMED/POPULATION*100000,2) AS VALUE_CONFIRMED_PERC,
                VALUE_RECOVERED,
                VALUE_RECOVERED - VALUE_RECOVERED_BE AS CHANGED_RECOVERED,
                ROUND(VALUE_RECOVERED/POPULATION*100000,2) AS VALUE_RECOVERED_PERC,
                VALUE_DEATHS,
                VALUE_DEATHS - VALUE_DEATHS_BE AS CHANGED_DEATHS,
                ROUND(VALUE_DEATHS/POPULATION*100000,2) AS VALUE_DEATHS_PERC,
                VALUE_ACTIVE,
                VALUE_ACTIVE - VALUE_ACTIVE_BE AS CHANGED_ACTIVE,
                ROUND(VALUE_ACTIVE/POPULATION*100000,2) AS VALUE_ACTIVE_PERC,
                POPULATION
            FROM V_COVID_CASES_GER_LATEST
             WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
                2 AS SORT_ORDER,
                LOG(2.5,NULLIF(VALUE_DEATHS,0)) AS VAL,
                LAT,
                LONGI,
                V('P32_COLOR_DEAD') AS COLOR,
                PROVINCE,
                VALUE_CONFIRMED,
                VALUE_CONFIRMED - VALUE_CONFIRMED_BE AS CHANGED_CONFIRMED,
                ROUND(VALUE_CONFIRMED/POPULATION*100000,2) AS VALUE_CONFIRMED_PERC,
                VALUE_RECOVERED,
                VALUE_RECOVERED - VALUE_RECOVERED_BE AS CHANGED_RECOVERED,
                ROUND(VALUE_RECOVERED/POPULATION*100000,2) AS VALUE_RECOVERED_PERC,
                VALUE_DEATHS,
                VALUE_DEATHS - VALUE_DEATHS_BE AS CHANGED_DEATHS,
                ROUND(VALUE_DEATHS/POPULATION*100000,2) AS VALUE_DEATHS_PERC,
                VALUE_ACTIVE,
                VALUE_ACTIVE - VALUE_ACTIVE_BE AS CHANGED_ACTIVE,
                ROUND(VALUE_ACTIVE/POPULATION*100000,2) AS VALUE_ACTIVE_PERC,
                POPULATION
            FROM V_COVID_CASES_GER_LATEST
             WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
            ORDER BY VALUE_ACTIVE, PROVINCE, SORT_ORDER
        ) HI )
    RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT ( 
    'title' VALUE 'Time course per day ' || NULLIF('(' || V('P32_PROVINCE_FILTER') || ')','()'),
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 240,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,0,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'area',
                'color' VALUE COLOR,
                'x' VALUE DAY_OCC,
                'y' VALUE CNT
                RETURNING BLOB)
            RETURNING BLOB)
            FROM (
                SELECT
                SUM(VALUE_RECOVERED) AS CNT,
                DAY_OCC,
                'Recovered' AS SERIES,
                V('P32_COLOR_RECOVERED') AS COLOR
                FROM V_COVID_CASES_GER
                WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
                UNION ALL
                SELECT
                SUM(VALUE_ACTIVE) AS CNT,
                DAY_OCC,
                'Active' AS SERIES,
                V('P32_COLOR_ACTIVE') AS COLOR
                FROM V_COVID_CASES_GER
                WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
                UNION ALL
                SELECT
                SUM(VALUE_DEATHS) AS CNT,
                DAY_OCC,
                'Dead' AS SERIES,
                V('P32_COLOR_DEAD') AS COLOR
                FROM V_COVID_CASES_GER
                WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
                UNION ALL
                SELECT
                SUM(VALUE_CONFIRMED) AS CNT,
                DAY_OCC,
                'Confirmed' AS SERIES,
                V('P32_COLOR_CONFIRMED') AS COLOR
                FROM V_COVID_CASES_GER
                WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
                GROUP BY DAY_OCC
            )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'list',
    'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_ACTIVE') ||'"></span> Active (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
    'colSpan' VALUE 2,
    'height' VALUE 430,
    'oversize' VALUE 0,
    'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
    'optionsLinkIcon' VALUE 'fa-sort',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'title' VALUE ROWNUM || '. ' || PROVINCE,
                'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                'icon' VALUE FLAG,
                'iconColor' VALUE 'white',
                'iconBackColor' VALUE V('P32_COLOR_CONFIRMED')
                RETURNING BLOB)
            RETURNING BLOB)
        FROM
        (SELECT
             SUM(VALUE_ACTIVE) AS CNT,
             SUM(VALUE_ACTIVE_BE) AS CNT_BE,
             SUM(VALUE_ACTIVE)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
             PROVINCE,
             FLAG
         FROM V_COVID_CASES_GER_LATEST
         GROUP BY PROVINCE, POPULATION, FLAG
         ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
         WHERE ROWNUM <= 100 AND CNT > 0
   ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
    JSON_OBJECT (
        'itemType' VALUE 'list',
        'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_DEAD') ||'"></span> Dead (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
        'colSpan' VALUE 2,
        'height' VALUE 430,
        'oversize' VALUE 0,
        'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
        'optionsLinkIcon' VALUE 'fa-sort',
        'itemData' VALUE (
            SELECT
            JSON_ARRAYAGG(JSON_OBJECT(
                'title' VALUE ROWNUM || '. ' || PROVINCE,
                'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                'icon' VALUE FLAG,
                'iconColor' VALUE 'white',
                'iconBackColor' VALUE V('P32_COLOR_DEAD')
            RETURNING BLOB) RETURNING BLOB)
        FROM (
            SELECT
                SUM(VALUE_DEATHS) AS CNT,
                SUM(VALUE_DEATHS_BE) AS CNT_BE,
                SUM(VALUE_DEATHS)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
                PROVINCE,
                FLAG
            FROM V_COVID_CASES_GER_LATEST
            GROUP BY PROVINCE, POPULATION, FLAG
            ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
            WHERE ROWNUM <= 100 AND CNT > 0
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'list',
    'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_CONFIRMED')||'"></span> Confirmed (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
    'colSpan' VALUE 2,
    'height' VALUE 425,
    'oversize' VALUE 0,
    'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
    'optionsLinkIcon' VALUE 'fa-sort',
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'title' VALUE ROWNUM || '. ' || PROVINCE,
                'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                'icon' VALUE FLAG,
                'iconColor' VALUE 'white',
                'iconBackColor' VALUE V('P32_COLOR_CONFIRMED')
                RETURNING BLOB)
            RETURNING BLOB)
        FROM
        (SELECT
             SUM(VALUE_CONFIRMED) AS CNT,
             SUM(VALUE_CONFIRMED_BE) AS CNT_BE,
             SUM(VALUE_CONFIRMED)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
             PROVINCE,
             FLAG
         FROM V_COVID_CASES_GER_LATEST
         GROUP BY PROVINCE, POPULATION, FLAG
         ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
         WHERE ROWNUM <= 100 AND CNT > 0
   ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'list',
    'title' VALUE '<span class="fa fa-circle title-ico" style="color:'||V('P32_COLOR_RECOVERED') ||'"></span> Recovered (<span class="fa fa-sort title-ico"></span> ' || DECODE(V('P32_LIST_ORDER'),1,'Cases/100k','Total') || ')',
    'colSpan' VALUE 2,
    'height' VALUE 425,
    'oversize' VALUE 0,
    'optionsLink' VALUE 'javascript:$(''body'').trigger(''handleList'');void(0);',
    'optionsLinkIcon' VALUE 'fa-sort',
    'itemData' VALUE (
        SELECT
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'title' VALUE ROWNUM || '. ' || PROVINCE,
                    'text' VALUE TO_CHAR(CNT, '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') || ' <span style="color:#858585" title="Change since day before">(' 
                    || REPLACE(TO_CHAR(CNT-CNT_BE, 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),' ','') 
                    || ') </span> <span style="color:#858585;font-size:12px">(Cases/100k: ' 
                    || NVL(TO_CHAR(ROUND(PERC_POP), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),'-') || ')</span>',
                    'icon' VALUE FLAG,
                    'iconColor' VALUE 'white',
                    'iconBackColor' VALUE V('P32_COLOR_RECOVERED')
                    RETURNING BLOB) 
                RETURNING BLOB)
        FROM (
            SELECT
                SUM(VALUE_RECOVERED) AS CNT,
                SUM(VALUE_RECOVERED_BE) AS CNT_BE,
                SUM(VALUE_RECOVERED)/NULLIF(POPULATION,0)*100000 AS PERC_POP,
                PROVINCE,
                FLAG
            FROM V_COVID_CASES_GER_LATEST
            GROUP BY PROVINCE, POPULATION, FLAG
            ORDER BY CASE WHEN (SELECT V('P32_LIST_ORDER') FROM DUAL) = 1 THEN PERC_POP ELSE CNT END DESC NULLS LAST)
            WHERE ROWNUM <= 100 AND CNT > 0
    ) RETURNING BLOB ) AS JSON_BLOB
FROM
    DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'title' VALUE 'Distribution of latest ' || NULLIF('(' || V('P32_PROVINCE_FILTER')||')','()'),
    'itemType' VALUE 'chart',
    'colSpan' VALUE 2,
    'height' VALUE 240,
    'isMarked' VALUE DECODE(V('P32_PROVINCE_FILTER'),NULL,NULL,1),
    'optionsLink' VALUE 'javascript:openModal(''filter_ger'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'itemConfig' VALUE JSON_OBJECT (
        'paddingLeft' VALUE 1,
        'paddingTop' VALUE 1,
        'paddingRight' VALUE 1,
        'paddingBottom' VALUE 1,
        'legendShow' VALUE 1,
        'legendPosition' VALUE 'bottom',
        'gaugeType' VALUE 'multi',
        'gaugeFullCircle' VALUE 1),
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'gauge',
                'color' VALUE COLOR,
                'x' VALUE 1,
                'y' VALUE CNT,
                'tooltipSubText' VALUE TT
                RETURNING BLOB)
            RETURNING BLOB)
        FROM (
            SELECT
            SUM(VALUE_CONFIRMED) AS CNT,
            'Confirmed' AS SERIES,
            V('P32_COLOR_CONFIRMED') AS COLOR,
            'Confirmed: ' || TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_GER_LATEST
            WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_ACTIVE) AS CNT,
            'Active' AS SERIES,
            V('P32_COLOR_ACTIVE') AS COLOR,
            'Active: ' || TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_GER_LATEST
            WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_RECOVERED) AS CNT,
            'Recovered' AS SERIES,
            V('P32_COLOR_RECOVERED') AS COLOR,
            'Recovered: ' || TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_GER_LATEST
            WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_DEATHS) AS CNT,
            'Dead' AS SERIES,
            V('P32_COLOR_DEAD') AS COLOR,
            'Dead: ' || TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_GER_LATEST
            WHERE (PROVINCE = (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) OR (SELECT V('P32_PROVINCE_FILTER') FROM DUAL) IS NULL)
        )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL;

CREATE OR REPLACE FORCE VIEW V_COVID_DASHBOARD_COMPARE AS 
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total active ' || NULLIF('(' || V('P32_COMPARE_1') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-ambulance',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_ACTIVE'),
        'value' VALUE TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_ACTIVE) - SUM(VALUE_ACTIVE_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total dead ' || NULLIF('(' || V('P32_COMPARE_1') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-minus-circle-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_DEAD'),
        'value' VALUE TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_DEATHS) - SUM(VALUE_DEATHS_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total active ' || NULLIF('(' || V('P32_COMPARE_2') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-ambulance',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_ACTIVE'),
        'value' VALUE TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_ACTIVE) - SUM(VALUE_ACTIVE_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total dead ' || NULLIF('(' || V('P32_COMPARE_2') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-minus-circle-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_DEAD'),
        'value' VALUE TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_DEATHS) - SUM(VALUE_DEATHS_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total confirmed ' || NULLIF('(' || V('P32_COMPARE_1') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-life-ring',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_CONFIRMED'),
        'value' VALUE TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_CONFIRMED) - SUM(VALUE_CONFIRMED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total recovered ' || NULLIF('(' || V('P32_COMPARE_1') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-smile-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_RECOVERED'),
        'value' VALUE TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_RECOVERED) - SUM(VALUE_RECOVERED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total confirmed ' || NULLIF('(' || V('P32_COMPARE_2') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-life-ring',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_CONFIRMED'),
        'value' VALUE TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_CONFIRMED) - SUM(VALUE_CONFIRMED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB )
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'itemType' VALUE 'card',
    'title' VALUE 'Total recovered ' || NULLIF('(' || V('P32_COMPARE_2') || ')','()'),
    'colSpan' VALUE 3,
    'optionsLink' VALUE 'javascript:openModal(''filter'');void(0);',
    'optionsLinkIcon' VALUE 'fa-filter',
    'height' VALUE 130,
    'itemData' VALUE JSON_OBJECT (
        'icon' VALUE 'fa-smile-o',
        'iconColor' VALUE 'white',
        'iconBackColor' VALUE V('P32_COLOR_RECOVERED'),
        'value' VALUE TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
        'valueSmall' VALUE TO_CHAR(SUM(VALUE_RECOVERED) - SUM(VALUE_RECOVERED_BE), 'S9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        RETURNING BLOB ) 
    RETURNING BLOB ) AS JSON_BLOB
    FROM V_COVID_CASES_INT_LATEST
    WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
UNION ALL
SELECT
JSON_OBJECT (
    'title' VALUE 'Distribution of latest ' || NULLIF('(' || V('P32_COMPARE_1') || ')','()'),
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 320,
    'itemConfig' VALUE JSON_OBJECT (
        'paddingLeft' VALUE 1,
        'paddingTop' VALUE 1,
        'paddingRight' VALUE 1,
        'paddingBottom' VALUE 1,
        'legendShow' VALUE 1,
        'legendPosition' VALUE 'bottom',
        'gaugeType' VALUE 'multi',
        'gaugeFullCircle' VALUE 1),
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'gauge',
                'color' VALUE COLOR,
                'x' VALUE 1,
                'y' VALUE CNT,
                'tooltipSubText' VALUE TT
                RETURNING BLOB)
            RETURNING BLOB)
        FROM (
            SELECT
            SUM(VALUE_CONFIRMED) AS CNT,
            'Confirmed' AS SERIES,
            V('P32_COLOR_CONFIRMED') AS COLOR,
            'Confirmed: ' || TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_ACTIVE) AS CNT,
            'Active' AS SERIES,
            V('P32_COLOR_ACTIVE') AS COLOR,
            'Active: ' || TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_RECOVERED) AS CNT,
            'Recovered' AS SERIES,
            V('P32_COLOR_RECOVERED') AS COLOR,
            'Recovered: ' || TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_DEATHS) AS CNT,
            'Dead' AS SERIES,
            V('P32_COLOR_DEAD') AS COLOR,
            'Dead: ' || TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_1') FROM DUAL) OR (SELECT V('P32_COMPARE_1') FROM DUAL) IS NULL)
        )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT (
    'title' VALUE 'Distribution of latest ' || NULLIF('(' || V('P32_COMPARE_2') || ')','()'),
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 320,
    'itemConfig' VALUE JSON_OBJECT (
        'paddingLeft' VALUE 1,
        'paddingTop' VALUE 1,
        'paddingRight' VALUE 1,
        'paddingBottom' VALUE 1,
        'legendShow' VALUE 1,
        'legendPosition' VALUE 'bottom',
        'gaugeType' VALUE 'multi',
        'gaugeFullCircle' VALUE 1),
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'gauge',
                'color' VALUE COLOR,
                'x' VALUE 1,
                'y' VALUE CNT,
                'tooltipSubText' VALUE TT
                RETURNING BLOB)
            RETURNING BLOB)
        FROM (
            SELECT
            SUM(VALUE_CONFIRMED) AS CNT,
            'Confirmed' AS SERIES,
            V('P32_COLOR_CONFIRMED') AS COLOR,
            'Confirmed: ' || TO_CHAR(SUM(VALUE_CONFIRMED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_ACTIVE) AS CNT,
            'Active' AS SERIES,
            V('P32_COLOR_ACTIVE') AS COLOR,
            'Active: ' || TO_CHAR(SUM(VALUE_ACTIVE), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_RECOVERED) AS CNT,
            'Recovered' AS SERIES,
            V('P32_COLOR_RECOVERED') AS COLOR,
            'Recovered: ' || TO_CHAR(SUM(VALUE_RECOVERED), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
            UNION ALL
            SELECT
            SUM(VALUE_DEATHS) AS CNT,
            'Dead' AS SERIES,
            V('P32_COLOR_DEAD') AS COLOR,
            'Dead: ' || TO_CHAR(SUM(VALUE_DEATHS), '9999G999G999', 'NLS_NUMERIC_CHARACTERS = '',.''') AS TT
            FROM V_COVID_CASES_INT_LATEST
            WHERE (COUNTRY = (SELECT V('P32_COMPARE_2') FROM DUAL) OR (SELECT V('P32_COMPARE_2') FROM DUAL) IS NULL)
        )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT ( 
    'title' VALUE 'Active - time course per day',
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 300,
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'area',
                'color' VALUE COLOR,
                'x' VALUE DAY_OCC,
                'y' VALUE CNT
                RETURNING BLOB)
            RETURNING BLOB)
            FROM (
                SELECT
                SUM(VALUE_Active) AS CNT,
                DAY_OCC,
                DECODE(COUNTRY,V('P32_COMPARE_1'), '#469cc7', '#707070') AS COLOR,
                COUNTRY || ' - Active' AS SERIES
                FROM V_COVID_CASES_INT
                WHERE COUNTRY IN ((SELECT V('P32_COMPARE_1') FROM DUAL), (SELECT V('P32_COMPARE_2') FROM DUAL))
                GROUP BY DAY_OCC, COUNTRY
            )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT ( 
    'title' VALUE 'Dead - time course per day',
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 300,
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'area',
                'color' VALUE COLOR,
                'x' VALUE DAY_OCC,
                'y' VALUE CNT
                RETURNING BLOB)
            RETURNING BLOB)
            FROM (
                SELECT
                SUM(VALUE_DEATHS) AS CNT,
                DAY_OCC,
                DECODE(COUNTRY,V('P32_COMPARE_1'), '#469cc7', '#707070') AS COLOR,
                COUNTRY || ' - Dead' AS SERIES
                FROM V_COVID_CASES_INT
                WHERE COUNTRY IN ((SELECT V('P32_COMPARE_1') FROM DUAL), (SELECT V('P32_COMPARE_2') FROM DUAL))
                GROUP BY DAY_OCC, COUNTRY
            )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT ( 
    'title' VALUE 'Confirmed - time course per day',
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 300,
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'area',
                'color' VALUE COLOR,
                'x' VALUE DAY_OCC,
                'y' VALUE CNT
                RETURNING BLOB)
            RETURNING BLOB)
            FROM (
                SELECT
                SUM(VALUE_Confirmed) AS CNT,
                DAY_OCC,
                DECODE(COUNTRY,V('P32_COMPARE_1'), '#469cc7', '#707070') AS COLOR,
                COUNTRY || ' - Confirmed' AS SERIES
                FROM V_COVID_CASES_INT
                WHERE COUNTRY IN ((SELECT V('P32_COMPARE_1') FROM DUAL), (SELECT V('P32_COMPARE_2') FROM DUAL))
                GROUP BY DAY_OCC, COUNTRY
            )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL
UNION ALL
SELECT
JSON_OBJECT ( 
    'title' VALUE 'Recovered - time course per day',
    'itemType' VALUE 'chart',
    'colSpan' VALUE 6,
    'height' VALUE 300,
    'itemData' VALUE (
        SELECT
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'seriesID' VALUE SERIES,
                'groupID' VALUE SERIES,
                'label' VALUE SERIES,
                'yAxis' VALUE 'y',
                'type' VALUE 'area',
                'color' VALUE COLOR,
                'x' VALUE DAY_OCC,
                'y' VALUE CNT
                RETURNING BLOB)
            RETURNING BLOB)
            FROM (
                SELECT
                SUM(VALUE_RECOVERED) AS CNT,
                DAY_OCC,
                DECODE(COUNTRY,V('P32_COMPARE_1'), '#469cc7', '#707070') AS COLOR,
                COUNTRY || ' - Recovered' AS SERIES
                FROM V_COVID_CASES_INT
                WHERE COUNTRY IN ((SELECT V('P32_COMPARE_1') FROM DUAL), (SELECT V('P32_COMPARE_2') FROM DUAL))
                GROUP BY DAY_OCC, COUNTRY
            )
    ) RETURNING BLOB ) AS JSON_BLOB
FROM DUAL;