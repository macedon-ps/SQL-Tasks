   -- Запрос выводит связанные данные из 3-х таблиц - vacancies, early_statuses и resumes.
   -- Постепенно формируем данные с использованием метода Count() и конструкции Case When (условие) THEN (результат) ELSE (другой результат) END. 
   -- Проходимся построчно и считаем уникальных кандидатов с нужными статусами (total_candidates), количество отправленных резюме (resumes_sent),
   -- составленные контракты (contracts), отказы (rejections), звонки (calls), интервью (interviews).
   -- Затем вводим ограничения по датам создания события и отправки резюме
   -- Группируем данные и упорядочиваем их по v.id. 
      
SELECT v.id AS vacancy_id, v.title AS vacancy_title, 'March' AS month,			
    
    -- Уникальные кандидаты с нужными типами статусов
    COUNT(DISTINCT CASE 
          WHEN es.type_id IN(1, 3, 4, 10, 11, 12, 14, 19) THEN es.user_uid 
          ELSE NULL
    END) AS total_candidates,
    
	-- Количество резюме с отправкой
    COUNT(DISTINCT CASE 
          WHEN r.sent_at IS NOT NULL THEN r.id 
          ELSE NULL
    END) AS resumes_sent,
    
    -- Контракты
    COUNT(CASE 
          WHEN es.type_id = 10 THEN 1 
          ELSE NULL
    END) AS contracts,
    
    -- Отказы
    COUNT(CASE 
          WHEN es.type_id = 11 THEN 1 
          ELSE NULL
    END) AS rejections,
    
    -- Звонки
    COUNT(CASE 
          WHEN es.type_id = 2 THEN 1 
          ELSE NULL
    END) AS calls,
    
    -- Інтервью
    COUNT(CASE 
          WHEN es.type_id IN(12, 14) THEN 1 
          ELSE NULL
    END) AS interviews
FROM vacancies v

    -- Статусы за месяц
LEFT JOIN early_statuses es ON es.vacancy_id = v.id 
	AND es.creation_date >= '2025-03-01 00:00:00' 
    AND es.creation_date < '2025-04-01 00:00:00'
    
    -- Резюме за месяц
LEFT JOIN resumes r ON r.vacancy_id = v.id 
	AND r.sent_at >= '2025-03-01 00:00:00' 
    AND r.sent_at < '2025-04-01 00:00:00'
GROUP BY v.id, v.title
ORDER BY v.id;