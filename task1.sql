   -- Запрос выводит связанные данные из 4-х таблиц - candidates, vacancies, early_statuses и access.
   -- Сначала результаты запроса фильтруем по условиям соответствия типу события (es.type_id = 1) и по датам (1 условие).
   -- Затем исключаем ситуации, когда для одного и того же поля (es2.creation_date) существует несколько значений, которые могут быть больше первоначального (es.creation_date) (2 условие).
   -- Потом исключаем ситуации, когда уже были отправлены резюме (not null - т.е. есть дата отправки) (3 условие).
   -- Фильтруем по доступу, т.е. должен быть режим "Read" и соответствовать индексы (4 условие).

SELECT c.id AS candidate_id, c.full_name, c.linkedin_url, es.vacancy_id, v.title AS vacancy_title,
    es.creation_date, es.comment_text, c.is_friend, c.is_pro
FROM early_statuses es
JOIN candidates c ON c.id = es.user_uid
JOIN vacancies v ON v.id = es.vacancy_id
    
    -- 4 условие: доступ HR Alice одновременно и к кандидатам, и к вакансиям (тип доступа - "Read")
    -- Доступ кандидата HR Alice (id = 1)
JOIN access ac_cand ON ac_cand.entity_type = 'candidate' 
	AND ac_cand.entity_id = c.id 
    AND ac_cand.hr_id = 1 
    AND ac_cand.right_code = 'Read'
    
    -- Доступ вакансии HR Alice (id = 1)
JOIN access ac_vac ON ac_vac.entity_type = 'vacancy' 
	AND ac_vac.entity_id = v.id 
    AND ac_vac.hr_id = 1 
    AND ac_vac.right_code = 'Read'
    
   -- 1 условие: Тип события 1 - "Lead" и в пределах установленных дат
   -- если нужно в пределах месяца, то - es.creation_date BETWEEN '2025-03-01' AND '2025-03-21'
WHERE es.type_id = 1 
	AND es.creation_date BETWEEN '2025-03-01' AND '2025-03-21'		
   
   -- 2 условие: Нет более поздних статусов по тому же кандидату и вакансии
    AND NOT EXISTS(
    SELECT 1
    FROM early_statuses es2
    WHERE es2.user_uid = es.user_uid 
        AND es2.vacancy_id = es.vacancy_id 
        AND es2.creation_date > es.creation_date
	)
	
    -- 3 условие: Нет резюме с отправкой по той же самой паре кандидат–вакансия
    AND NOT EXISTS(
        SELECT 1
        FROM resumes r
        WHERE r.candidate_id = es.user_uid 
            AND r.vacancy_id = es.vacancy_id 
            AND r.sent_at IS NOT NULL
    )
ORDER BY es.creation_date ASC;
