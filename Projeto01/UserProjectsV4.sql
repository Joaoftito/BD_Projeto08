CREATE DATABASE UserProjects

GO
USE UserProjects

CREATE TABLE Users (
id int IDENTITY(1, 1),
name_ varchar(45),
username varchar(45) UNIQUE,
password_ varchar(45) DEFAULT('123mudar'),
email varchar(45)
PRIMARY KEY(id)
)

CREATE TABLE Projects (
id int IDENTITY(10001, 1),
name_ varchar(45),
description_ varchar(45) NULL,
date_ date CHECK(date_ > '2014-09-01')
PRIMARY KEY(id)
)

CREATE TABLE Users_Has_Projects (
usersId int,
projectsId int
PRIMARY KEY(usersId, projectsId)
FOREIGN KEY(usersId) REFERENCES Users(id),
FOREIGN KEY(projectsId) REFERENCES Projects(id)
)

ALTER TABLE Users
ALTER COLUMN username varchar(10)

ALTER TABLE Users
ALTER COLUMN password_ varchar(8)

INSERT INTO Users (name_, username, email) VALUES
('Maria', 'Rh_maria', 'maria@empresa.com')

INSERT INTO Users (name_, username, password_, email) VALUES
('Paulo', 'Ti_paulo', '123@456', 'paulo@empresa.com')

INSERT INTO Users (name_, username, email) VALUES
('Ana', 'Rh_ana', 'ana@empresa.com'),
('Clara', 'Ti_clara', 'clara@empresa.com')

INSERT INTO Users (name_, username, password_, email) VALUES
('Aparecido', 'Rh_apareci', '55@!cido', 'aparecido@empresa.com')

INSERT INTO Projects (name_, description_, date_) VALUES
('Re-folha', 'Refatora  o das Folhas', '2014-09-05'),
('Manuten  o', 'Manutencao PC', '2014-09-06')

INSERT INTO Projects (name_, date_) VALUES
('Auditoria', '2014-09-07')

INSERT INTO Users_has_projects VALUES
(1, 10001),
(5, 10001),
(3, 10003),
(4, 10002),
(2, 10002)

UPDATE Projects
SET date_ = '2014-09-12'
WHERE id = 10002

UPDATE Users
SET username = 'Rh_cido'
WHERE id = 5

UPDATE Users
SET password_ = '888@*'
WHERE username = 'Rh_maria' AND password_ = '123mudar'

DELETE Users_has_projects
WHERE usersId = 2

--PARTE 2--

SELECT id, name_, email, username,
		CASE WHEN password_ <> '123mudar' THEN '********' 
		ELSE password_
		END AS senha
FROM Users

SELECT name_, description_, date_, DATEADD(DAY, 15, date_) AS data_final
FROM Projects
WHERE id = 10001 AND id IN (SELECT projectsId FROM Users_Has_Projects
		                    WHERE usersId = 
						   (SELECT id FROM Users
		                    WHERE email = 'aparecido@empresa.com'))

SELECT name_, email
FROM Users
WHERE id IN (SELECT usersId FROM Users_Has_Projects
             WHERE projectsId =
			(SELECT id FROM Projects
			 WHERE name_ = 'Auditoria'))

SELECT name_, description_, date_, DATEADD(DAY, 4, date_) AS data_final,
       DATEDIFF(DAY, date_, '2014-09-16') * 79.85 AS custo_total
FROM Projects
WHERE name_ = 'Manutenção'

--PARTE 3--

INSERT INTO Users VALUES
('Joao', 'Ti_joao', '123mudar', 'joao@empresa.com')

INSERT INTO Projects VALUES
('Atualização de Sistemas', 'Modificação de Sistemas Operacionais nos PCs', '2014-09-12')

SELECT us.id, us.name_, us.email, pr.id, pr.name_, pr.description_, pr.date_
FROM Users us INNER JOIN Users_Has_Projects uspr
ON us.id = uspr.usersId
INNER JOIN Projects pr
ON pr.id = uspr.projectsId
WHERE pr.name_ = 'Re-folha'

SELECT pr.name_
FROM Projects pr LEFT OUTER JOIN Users_Has_Projects uspr
ON pr.id = uspr.projectsId
LEFT OUTER JOIN Users us
ON us.id = uspr.usersId
WHERE uspr.usersId IS NULL

SELECT us.id
FROM Users us LEFT OUTER JOIN Users_Has_Projects uspr
ON us.id = uspr.usersId
LEFT OUTER JOIN Projects pr
ON pr.id = uspr.projectsId
WHERE uspr.usersId IS NULL

--PARTE 4--

SELECT COUNT(uspr.projectsId) AS qty_projects_no_users
FROM Projects pr LEFT OUTER JOIN Users_Has_Projects uspr
ON pr.id = uspr.projectsId
LEFT OUTER JOIN Users us
ON us.id = uspr.usersId
WHERE uspr.usersId IS NULL

SELECT pr.id, pr.name_, COUNT(uspr.usersId) AS qty_users_project
FROM Projects pr INNER JOIN Users_Has_Projects uspr
ON pr.id = uspr.projectsId
GROUP BY pr.id, pr.name_
ORDER BY pr.name_ ASC