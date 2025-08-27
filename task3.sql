   -- Запрос 1 формирует временную таблицу kpi_table.   
   -- Запрос 2 наполняет временную таблицу таблицу kpi_table связанными данными из 3-х таблиц - aspnetusers, early_statuses и resumes.
   -- Постепенно формируем данные с использованием метода Count() и конструкции Case When (условие) THEN (результат) ELSE (другой результат) END. 
   -- Проходимся построчно и считаем количество лидов (es.type_id = 1), количество других событий, кроме лидов (es.type_id != 1), 
   -- количество подготовленных резюме (es.type_id = 3), количество отправленных резюме (r.sent_at или es.type_id = 4),
   -- количество звонков (es.type_id = 2), количество составленных контрактов (es.type_id = 10).
   -- Затем вводим ограничения по датам создания события и отправки резюме. При этом учитывается вчерашний день, т.е. от (UTC_DATE() - INTERVAL 1 DAY) (вчера) 
   -- до UTC_DATE() (сегодня).
   -- Группируем данные и упорядочиваем их по u.id.  
   -- Запрос 3 выводит данные временной таблицы kpi_table.

  -- 1. Создаем временную таблицу kpi_table по указанной схеме.
CREATE TEMPORARY TABLE kpi_table (
  day_date DATE,
  hr_id INT,
  leads_created INT,
  statuses_added INT,
  resumes_prepared INT,
  resumes_sent INT,
  calls_made INT,
  contracts_signed INT
);

   -- 2. Заполняем таблицу kpi_table данными.
INSERT INTO kpi_table (
  day_date, hr_id, leads_created, statuses_added, resumes_prepared,
  resumes_sent, calls_made, contracts_signed
)
SELECT 
  CURDATE() - INTERVAL 1 DAY AS day_date,
  u.id AS hr_id,

  -- leads_created: type_id = 1
  COUNT(CASE WHEN es.type_id = 1 THEN 1 END) AS leads_created,

  -- statuses_added: все типы кроме 1
  COUNT(CASE WHEN es.type_id != 1 THEN 1 END) AS statuses_added,

  -- resumes_prepared: type_id = 3
  COUNT(CASE WHEN es.type_id = 3 THEN 1 END) AS resumes_prepared,

  -- resumes_sent: sent_at IS NOT NULL
  COUNT(DISTINCT CASE 
    WHEN r.sent_at IS NOT NULL THEN r.id 
    ELSE NULL 
  END) AS resumes_sent,

  -- calls_made: type_id = 2
  COUNT(CASE WHEN es.type_id = 2 THEN 1 END) AS calls_made,

  -- contracts_signed: type_id = 10
  COUNT(CASE WHEN es.type_id = 10 THEN 1 END) AS contracts_signed

FROM aspnetusers u

-- LEFT JOIN early_statuses по created_by
LEFT JOIN early_statuses es ON es.created_by = u.id
  AND es.creation_date >= UTC_DATE() - INTERVAL 1 DAY
  AND es.creation_date < UTC_DATE()

-- LEFT JOIN resumes по created_by
LEFT JOIN resumes r ON r.created_by = u.id
  AND r.created_at >= UTC_DATE() - INTERVAL 1 DAY
  AND r.created_at < UTC_DATE()

GROUP BY u.id;

   -- 3. Выводим данные временной таблицы.
SELECT * FROM kpi_table;