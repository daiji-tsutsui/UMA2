-- 出走取消でオッズ情報に不整合が生じたレコードの検出

-- race_results
SELECT race_id, cnt, horse_cnt
FROM (
    SELECT rr.race_id
        , (
            SELECT (length(odds_json) - length(replace(odds_json,',','')) / length(','))
        ) + 1 AS cnt
        , horse_cnt
    FROM race_results rr
    INNER JOIN (
        SELECT race_id, COUNT(*) AS horse_cnt FROM race_horses GROUP BY race_id
    ) AS chorses
    ON rr.race_id = chorses.race_id
) AS sub
WHERE cnt <> horse_cnt
ORDER BY race_id
;

-- odds_histories
SELECT id, race_id, cnt, horse_cnt
FROM (
    SELECT oh.id
        , oh.race_id
        , (
            SELECT (length(data_json) - length(replace(data_json,',','')) / length(','))
        ) + 1 AS cnt
        , horse_cnt
    FROM odds_histories oh
    INNER JOIN (
        SELECT race_id, COUNT(*) AS horse_cnt FROM race_horses GROUP BY race_id
    ) AS chorses
    ON oh.race_id = chorses.race_id
) AS sub
WHERE cnt <> horse_cnt
ORDER BY id
;