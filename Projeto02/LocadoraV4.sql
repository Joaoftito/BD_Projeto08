CREATE DATABASE Locadora

GO
USE Locadora

CREATE TABLE Filme(
id INT,
titulo VARCHAR(40),
ano INT NULL CHECK(ano < 2021)
PRIMARY KEY(id)
)

CREATE TABLE Estrela(
id INT,
nome VARCHAR(50)
PRIMARY KEY(id)
)

CREATE TABLE FilmeEstrela(
filmeId INT,
estrelaId INT
PRIMARY KEY(filmeId, estrelaId)
FOREIGN KEY(filmeId) REFERENCES Filme(id),
FOREIGN KEY(estrelaId) REFERENCES Estrela(id)
)

CREATE TABLE Dvd(
num INT,
dataFabricacao DATE CHECK(dataFabricacao < GETDATE()),
filmeId INT
PRIMARY KEY(num)
FOREIGN KEY(filmeId) REFERENCES Filme(id)
)

CREATE TABLE Cliente(
numCadastro INT,
nome VARCHAR(70),
logradouro VARCHAR(150),
num INT CHECK(num >= 0),
cep CHAR(8) NULL CHECK(LEN(cep) = 8)
PRIMARY KEY(numCadastro)
)

CREATE TABLE Locacao(
dvdNum INT,
clienteNumCadastro INT,
dataLocacao DATE DEFAULT GETDATE(),
dataDevolucao DATE,
valor DECIMAL(7, 2) CHECK(valor > 0.0)
PRIMARY KEY(dvdNum, clienteNumCadastro, dataLocacao)
FOREIGN KEY(dvdNum) REFERENCES Dvd(num),
FOREIGN KEY(clienteNumCadastro) REFERENCES Cliente(numCadastro),
CONSTRAINT chk_dt_devolucao
CHECK (dataDevolucao > dataLocacao)
)

ALTER TABLE Estrela
ADD nomeReal VARCHAR(50) NULL

ALTER TABLE Filme
ALTER COLUMN Titulo VARCHAR(80)

INSERT INTO Filme VALUES
(1001, 'Whiplash', 2015),
(1002, 'Birdman', 2015),
(1003, 'Interestelar', 2014),
(1004, 'A Culpa   das estrelas', 2014),
(1005, 'Alexandre e o Dia Terr vel, Horr vel, Espantoso e Horroroso', 2014),
(1006, 'Sing', 2016)

INSERT INTO Estrela VALUES
(9901, 'Michael Keaton', 'Michael John Douglas'),
(9902, 'Emma Stone', 'Emily Jean Stone'),
(9903, 'Miles Teller', NULL),
(9904, 'Steve Carell', 'Steven John Carell'),
(9905, 'Jennifer Garner', 'Jennifer Anne Garner')

INSERT INTO FilmeEstrela VALUES
(1002, 9901),
(1002, 9902),
(1001, 9903),
(1005, 9904),
(1005, 9905)

INSERT INTO Dvd VALUES
(10001, '2020-12-02', 1001),
(10002, '2019-10-18', 1002),
(10003, '2020-04-03', 1003),
(10004, '2020-12-02', 1001),
(10005, '2019-10-18', 1004),
(10006, '2020-04-03', 1002),
(10007, '2020-12-02', 1005),
(10008, '2019-10-18', 1002),
(10009, '2020-04-03', 1003)

INSERT INTO Cliente VALUES
(5501, 'Matilde Luz', 'Rua S ria', 150, '03086040'),
(5502, 'Carlos Carreiro', 'Rua Bartolomeu Aires', 1250, '04419110'),
(5503, 'Daniel Ramalho', 'Rua Itajutiba', 169, NULL),
(5504, 'Roberta Bento', 'Rua Jayme Von Rosenburg', 36, NULL),
(5505, 'Rosa Cerqueira', 'Rua Arnaldo Sim es Pinto', 235, '02917110')

INSERT INTO Locacao VALUES
(10001, 5502, '2021-02-18', '2021-02-21', 3.50),
(10009, 5502, '2021-02-18', '2021-02-21', 3.50),
(10002, 5503, '2021-02-18', '2021-02-19', 3.50),
(10002, 5505, '2021-02-20', '2021-02-23', 3.00),
(10004, 5505, '2021-02-20', '2021-02-23', 3.00),
(10005, 5505, '2021-02-20', '2021-02-23', 3.00),
(10001, 5501, '2021-02-24', '2021-02-26', 3.50),
(10008, 5501, '2021-02-24', '2021-02-26', 3.50)

UPDATE Cliente
SET cep = '08411150'
WHERE numCadastro = 5503

UPDATE Cliente
SET cep = '02918190'
WHERE numCadastro = 5504

UPDATE Locacao
SET valor = 3.25
WHERE dataLocacao = '2021-02-18' AND clienteNumCadastro = 5502

UPDATE Locacao
SET valor = 3.10
WHERE dataLocacao = '2021-02-24' AND clienteNumCadastro = 5501

UPDATE Dvd
SET dataFabricacao = '2019-07-14'
WHERE num = 10005

UPDATE Estrela
SET nomeReal = 'Miles Alexander Teller'
WHERE nome = 'Miles Teller'

DELETE Filme
WHERE id = 1006

--PARTE 2--

SELECT id, ano, 
		CASE WHEN LEN(titulo) > 10 THEN SUBSTRING(titulo, 1, 10) + '...'
		ELSE titulo
		END AS nome_filme
FROM Filme
WHERE id IN (SELECT filmeId FROM Dvd
             WHERE dataFabricacao > '2020-01-01')

SELECT num, dataFabricacao, DATEDIFF(MONTH, dataFabricacao, GETDATE()) AS qtd_meses_desde_fabricacao
FROM Dvd
WHERE filmeId IN (SELECT id FROM Filme
                  WHERE titulo = 'Interestelar')

SELECT dvdNum, dataLocacao, dataDevolucao, DATEDIFF(DAY, dataLocacao, dataDevolucao) AS dias_alugado,
       valor
FROM Locacao
WHERE clienteNumCadastro IN (SELECT numCadastro FROM Cliente
                             WHERE nome LIKE '%Rosa%')

SELECT nome, logradouro + ' ' + CAST(num AS VARCHAR(5)) AS endereço_completo, 
       SUBSTRING(cep, 1, 5) + '-' + SUBSTRING(cep, 6, 3) AS cep
FROM Cliente
WHERE numCadastro IN (SELECT clienteNumCadastro FROM Locacao
                      WHERE dvdNum = 10002)

--PARTE 3--

SELECT cli.numCadastro, cli.nome, FORMAT(loc.dataLocacao, 'dd/MM/yyyy'), 
       DATEDIFF(DAY, loc.dataLocacao, loc.dataDevolucao) AS Qtd_dias_alugado,
	   fil.titulo, fil.ano
FROM Cliente cli INNER JOIN Locacao loc
ON cli.numCadastro = loc.clienteNumCadastro
INNER JOIN Dvd dvd
ON dvd.num = loc.dvdNum
INNER JOIN Filme fil
ON fil.id = dvd.filmeId
WHERE cli.nome LIKE 'Matilde%'

SELECT est.nome, est.nomeReal, fil.titulo
FROM Estrela est INNER JOIN FilmeEstrela filEst
ON est.id = filEst.estrelaId
INNER JOIN Filme fil
ON fil.id = filEst.filmeId
WHERE fil.ano = 2015

SELECT fil.titulo, FORMAT(dvd.dataFabricacao, 'dd/MM/yyyy'),
       CASE WHEN DATEDIFF(YEAR, dvd.dataFabricacao, GETDATE()) > 6 THEN 
	   CAST(DATEDIFF(YEAR, dvd.dataFabricacao, GETDATE()) AS VARCHAR) + ' anos' ELSE
	   CAST(DATEDIFF(YEAR, dvd.dataFabricacao, GETDATE()) AS VARCHAR)
	   END AS diferenca_anos
FROM Filme fil INNER JOIN Dvd dvd
ON fil.id = dvd.filmeId

--PARTE 4--

SELECT cli.numCadastro, cli.nome, fil.titulo, dvd.dataFabricacao, loc.valor
FROM Cliente cli INNER JOIN Locacao loc
ON cli.numCadastro = loc.clienteNumCadastro
INNER JOIN Dvd dvd
ON dvd.num = loc.dvdNum
INNER JOIN Filme fil
ON fil.id = dvd.filmeId
WHERE dvd.dataFabricacao = (SELECT MAX(dataFabricacao) FROM DVD)

SELECT cli.numCadastro, cli.nome, FORMAT(loc.dataLocacao, 'dd/MM/yyyy'), COUNT(dvd.num) AS qtd
FROM Cliente cli INNER JOIN Locacao loc
ON cli.numCadastro = loc.clienteNumCadastro
INNER JOIN Dvd dvd
ON dvd.num = loc.dvdNum
GROUP BY cli.numCadastro, cli.nome, loc.dataLocacao

SELECT cli.numCadastro, cli.nome, FORMAT(loc.dataLocacao, 'dd/MM/yyyy'), 
       SUM(loc.valor) AS valor_total 
FROM Cliente cli INNER JOIN Locacao loc
ON cli.numCadastro = loc.clienteNumCadastro
INNER JOIN Dvd dvd
ON dvd.num = loc.dvdNum
GROUP BY cli.numCadastro, cli.nome, loc.dataLocacao

SELECT cli.numCadastro, cli.nome, cli.logradouro + ' ' + CAST(cli.num AS VARCHAR(5)) AS endereco,
       FORMAT(loc.dataLocacao, 'dd/MM/yyyy')
FROM Cliente cli INNER JOIN Locacao loc
ON cli.numCadastro = loc.clienteNumCadastro
INNER JOIN Dvd dvd
ON dvd.num = loc.dvdNum
GROUP BY cli.NumCadastro, cli.nome, cli.logradouro, cli.num, loc.dataLocacao
HAVING COUNT(dvd.num) > 2;