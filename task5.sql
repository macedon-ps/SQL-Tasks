   -- Запрос выводит связанные данные из 3-х таблиц - reminders, candidates и access.
   -- Проверяем доступ HR 'Alice Recruiter' к напоминаниям (a.hr_id = 1, a.entity_type = 'reminder'), 
   -- режим доступа (a.right_code = 'Read').
   -- Затем вводим ограничения по дате напоминания. При этом учитывается сегодняшний день, т.е. 
   -- от UTC_DATE() (сегодня) до CURDATE() + INTERVAL 1 DAY (завтра).
   -- Группируем данные и упорядочиваем их по r.remdate.  


  SELECT 
  r.id AS reminder_id,
  r.remdate,
  r.candidate_id,
  c.full_name,
  r.note
FROM reminders r
JOIN candidates c ON c.id = r.candidate_id

-- Перевірка доступу до нагадування
JOIN access a ON a.entity_type = 'reminder' 
  AND a.entity_id = r.id 
  AND a.hr_id = 1 
  AND a.right_code = 'Read'

WHERE r.hr_id = 1
  AND r.remdate >= CURDATE()
  AND r.remdate < CURDATE() + INTERVAL 1 DAY

ORDER BY r.remdate;