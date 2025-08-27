   -- Обновляем таблицу skill_variants, при этом объединяем ее с данными выборки cs.
   -- В выборке cs подсчитываем количество кандидатов на определенный скилл.
   -- Затем полученные данные присваиваем колонке sv.cnt.

UPDATE skill_variants sv
JOIN (
    SELECT variant_id, COUNT(DISTINCT candidate_id) AS candidate_count
    FROM candidate_skills
    GROUP BY variant_id
) AS cs ON sv.id = cs.variant_id
SET sv.cnt = cs.candidate_count;