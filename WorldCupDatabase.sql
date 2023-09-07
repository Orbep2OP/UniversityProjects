-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 18-Dez-2022 às 22:12
-- Versão do servidor: 10.4.27-MariaDB
-- versão do PHP: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `BDmundial`
--

DELIMITER $$

create database Mundial$$
use Mundial$$

--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_Golos` (IN `Ano_Edi` INT)   BEGIN
IF (EXISTS(SELECT Ano FROM edicao WHERE ano = Ano_Edi)) THEN
    SELECT p.Nome AS Selecao, j.Nome AS Jogador, COUNT(g.Jogo_Numero) AS Num_Golos
    FROM pais p, selecao s, jogadorselecao js, jogador j, golo g
    WHERE s.ano = Ano_Edi AND js.Selecao_Sigla_Pais = s.Sigla_Pais AND js.Selecao_Ano = s.Ano AND s.Sigla_Pais = p.Sigla AND js.NumCamisola = g.Marcador_JogadorEmCampo_NumCamisola
    GROUP BY p.Nome, j.Nome;
ELSE
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existem edições com esse ano registado';
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_Melhor_Marcador` (IN `Ano_Edi` INT)   BEGIN

IF (EXISTS(SELECT Ano FROM edicao WHERE ano = Ano_Edi)) THEN
    SELECT j.Nome AS Jogador, MAX(NumGolos) as Num_Golos
	FROM jogadorselecao js
    WHERE js.Selecao_Ano = Ano_Edi;
ELSE
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existem edições com esse ano registado';
END IF;
End$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Nome_das_Selecoes_Com_Menos_De_26_Jogadores` (IN `Ano` SMALLINT(6))   BEGIN

    SELECT Nome FROM 
( Select Sigla_Pais, (Select count(*) from jogadorselecao js where js.Selecao_Ano = Ano AND js.Selecao_Sigla_Pais = selecao.Sigla_Pais  ) AS Total_Jogadores
    FROM selecao Having Total_Jogadores > '0' ) AS SiglaPais, pais where pais.Sigla = SiglaPais.Sigla_Pais;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Verificar_Cumprimento_das_Regras_do_Mundial` (IN `Ano` SMALLINT(6))   BEGIN
	Declare total_comitivas integer;
    Declare total_grupos_em_incumprimento integer;
    Declare total_selecoes_em_incumprimento integer;
    
    Select count(*) into total_comitivas FROM
    comitiva where comitiva.Ano = Ano;
    
    
   Select count(*) into total_selecoes_em_incumprimento from 
    (SELECT Nome FROM 
    (Select Sigla_Pais, (Select count(*) from jogadorselecao js where js.Selecao_Ano = Ano 
                      AND js.Selecao_Sigla_Pais = selecao.Sigla_Pais ) AS Total_Jogadores
    FROM selecao Having Total_Jogadores < '26' ) AS SiglaPais, pais where pais.Sigla = SiglaPais.Sigla_Pais ) 
    AS Nome_Paises_Em_Incumprimento;
    
    
    Select count(*) into total_grupos_em_incumprimento FROM 
    (SELECT Letra, (Select count(*) from selecao s where s.Ano = Ano
                    AND s.Letra_Grupo = grupo.Letra ) AS num_selecoes_no_grupo FROM grupo HAVING num_selecoes_no_grupo < '4' ) 
     AS tabela_com_grupos_errados;
     
   
   IF total_comitivas < '24' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cada edicao do mundial deve ter no minimo 24 comitivas';
    	
        ELSEIF total_selecoes_em_incumprimento != '0' THEN
        CALL Nome_das_Selecoes_Com_Menos_De_26_Jogadores(Ano);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Os nomes dos paises listados correspondem a selecoes com jogadores insuficientes';
        
            ELSE
            IF total_grupos_em_incumprimento != '0' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existem grupos com um numero de selecoes insuficiente';
            END IF; 
            
    END IF;
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `Golos_Marcados_Por_Selecao_Num_Jogo` (`NumJogo` INT(11), `Sigla_Pais` CHAR(3)) RETURNS INT(11)  BEGIN
	Declare total_golos_marcados integer;
    Declare total_autogolos_a_favor integer;
    Declare total_golos integer;
    
    Select count(*) into total_golos_marcados
    From golo WHERE
    golo.Jogo_Numero = NumJogo AND
    golo.Marcador_JogadorEmCampo_Sigla_Pais = Sigla_Pais AND
    golo.Autogolo = '0';
    
    Select count(*) into total_autogolos_a_favor
    from golo WHERE
    golo.Jogo_Numero = NumJogo AND
    golo.Marcador_JogadorEmCampo_Sigla_Pais != Sigla_Pais AND
    golo.Autogolo != '0';
    
    set total_golos = total_golos_marcados + total_autogolos_a_favor; 
    
    return total_golos;  
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Num_Penalizacoes` (`Ano` SMALLINT, `Sigla_Pais_do_Jogador` CHAR(3), `Numero_de_Camisola` TINYINT) RETURNS TINYINT(4)  BEGIN
	Declare total integer;
    
    SELECT count(*) into total from penalizacao p where p.JogadorEmCampo_Sigla_Pais = Sigla_Pais_do_Jogador
    AND p.JogadorEmCampo_Ano = Ano AND p.JogadorEmCampo_NumCamisola = Numero_de_Camisola;
    return total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Total_Jogos_Sem_Golos_Sofridos` (`Ano_do_Jogador` SMALLINT, `Sigla_Pais_do_Jogador` CHAR(3), `Numero_de_Camisola` TINYINT) RETURNS TINYINT(11)  BEGIN
    Declare total1 integer;
    Declare total2 integer;
    Declare total integer;

    Select count(Jogo_numero) into total1 from ( Select Jogo_numero from jogadoremcampo jec
    WHERE jec.JogadorSelecao_Sigla_Pais = Sigla_Pais_do_Jogador
    AND jec.JogadorSelecao_Ano = Ano_do_Jogador
    AND jec.JogadorSelecao_NumCamisola = Numero_de_Camisola) as tabela_jogos_jogados
    WHERE tabela_jogos_jogados.Jogo_numero not in (SELECT DISTINCT Jogo_Numero from golo g where g.Autogolo = '0' AND
                                  g.Marcador_JogadorEmCampo_Sigla_Pais != Sigla_Pais_do_Jogador);

    Select count(Jogo_numero) into total2 from ( Select Jogo_numero from jogadoremcampo jec
    WHERE jec.JogadorSelecao_Sigla_Pais = Sigla_Pais_do_Jogador
    AND jec.JogadorSelecao_Ano = Ano_do_Jogador
    AND jec.JogadorSelecao_NumCamisola = Numero_de_Camisola) as tabela_jogos_jogados2
    where tabela_jogos_jogados2.Jogo_numero not in 
    (SELECT DISTINCT Jogo_Numero from golo g where g.Autogolo != '0' AND g.Marcador_JogadorEmCampo_Sigla_Pais = Sigla_Pais_do_Jogador);

    SET total = (total1 + total2 );
    
    IF total > '0' THEN
    return total;
    else 
    return '0';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `clubefutebol`
--

CREATE TABLE `clubefutebol` (
  `NomeClube` varchar(60) NOT NULL,
  `Sigla` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `comitiva`
--

CREATE TABLE `comitiva` (
  `Sigla_Pais` char(3) NOT NULL,
  `Ano` smallint(6) NOT NULL,
  `Mascote` varchar(60) DEFAULT NULL,
  `Patrocinador_Oficial_sigla` char(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `comitiva`
--

INSERT INTO `comitiva` (`Sigla_Pais`, `Ano`, `Mascote`, `Patrocinador_Oficial_sigla`) VALUES
('AGR', 2022, NULL, 'ADID'),
('ALE', 2022, NULL, 'ADID'),
('AUS', 2022, NULL, 'BUD_'),
('BEL', 2022, NULL, 'KIA_'),
('BRA', 2022, NULL, 'VISA'),
('CAN', 2022, NULL, 'NIKE'),
('CMR', 2022, NULL, 'XERO'),
('CRC', 2022, NULL, 'XERO'),
('CRO', 2022, NULL, 'PUMA'),
('DEN', 2022, NULL, 'KIA_'),
('EQU', 2022, NULL, 'BUD_'),
('ESP', 2022, NULL, 'VISA'),
('EUA', 2022, NULL, 'COLA'),
('FRA', 2022, NULL, 'HISE'),
('GHA', 2022, NULL, 'NIKE'),
('HOL', 2022, NULL, 'KIA_'),
('ING', 2022, NULL, 'BUD_'),
('IRN', 2022, NULL, 'HISE'),
('JAP', 2022, NULL, 'PUMA'),
('KOR', 2022, NULL, 'KIA_'),
('KSA', 2022, NULL, 'QATA'),
('MAR', 2022, NULL, 'QATA'),
('MEX', 2022, NULL, 'PUMA'),
('POL', 2022, NULL, 'XERO'),
('POR', 2022, NULL, 'COLA'),
('QAT', 2022, NULL, 'QATA'),
('SEN', 2022, NULL, 'NIKE'),
('SUI', 2022, NULL, 'HISE'),
('TUN', 2022, NULL, 'VISA'),
('WAL', 2022, NULL, 'BUD_');

--
-- Acionadores `comitiva`
--
DELIMITER $$
CREATE TRIGGER `PatrocinadoOficial_Tem_De_Pertence_Aos_Patrocinios` BEFORE INSERT ON `comitiva` FOR EACH ROW BEGIN
	Declare total integer;
    
    SELECT count(*) into total from patrocinio
    where patrocinio.Patrocinador_Sigla = new.Patrocinador_Oficial_sigla AND
   patrocinio.Comitiva_Sigla_Pais = new.Sigla_Pais AND
   patrocinio.Comitiva_Ano = new.Ano;
   
   IF total = '0' THEN 
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O patrocinador oficial tem de patrocionar a comitiva';
   END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `edicao`
--

CREATE TABLE `edicao` (
  `Ano` smallint(6) NOT NULL,
  `Designacao` varchar(60) DEFAULT NULL,
  `Orcamento` int(11) DEFAULT 0,
  `NumSelecoesParticipantes` int(11) NOT NULL DEFAULT 0,
  `Organizador_1` char(3) NOT NULL,
  `Organizador_2` char(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `edicao`
--

INSERT INTO `edicao` (`Ano`, `Designacao`, `Orcamento`, `NumSelecoesParticipantes`, `Organizador_1`, `Organizador_2`) VALUES
(2014, 'mundial brazil', 0, 0, 'BRA', NULL),
(2022, 'Mundial do Qatar', NULL, 24, 'QAT', NULL);

--
-- Acionadores `edicao`
--
DELIMITER $$
CREATE TRIGGER `Federacoes_Diferentes_Na_Mesma_Edicao` BEFORE INSERT ON `edicao` FOR EACH ROW BEGIN
	IF new.Organizador_1 = new.Organizador_2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='AS federacoes têm de ser diferentes';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `estadio`
--

CREATE TABLE `estadio` (
  `Estadio_ID` int(11) NOT NULL,
  `Nome` varchar(60) NOT NULL,
  `Sigla_Pais` char(3) NOT NULL,
  `Localidade` varchar(60) DEFAULT NULL,
  `Lotacao` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `federacao`
--

CREATE TABLE `federacao` (
  `Federacao_ID` char(3) NOT NULL,
  `Nome` varchar(60) NOT NULL,
  `Sigla_Pais` char(3) DEFAULT NULL,
  `NumFederados` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `federacao`
--

INSERT INTO `federacao` (`Federacao_ID`, `Nome`, `Sigla_Pais`, `NumFederados`) VALUES
('001', 'Associação de Futebol do Qatar', 'QAT', 0),
('003', 'federação brasileira', 'BRA', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `funcaotecnico`
--

CREATE TABLE `funcaotecnico` (
  `FuncaoTecnica_ID` char(3) NOT NULL,
  `Funcao` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `funcaotecnico`
--

INSERT INTO `funcaotecnico` (`FuncaoTecnica_ID`, `Funcao`) VALUES
('1', 'fisioterapeuta');

-- --------------------------------------------------------

--
-- Estrutura da tabela `golo`
--

CREATE TABLE `golo` (
  `Jogo_Numero` int(11) NOT NULL,
  `Golo_Numero` tinyint(4) NOT NULL,
  `Marcador_JogadorEmCampo_Jogo_numero` int(11) NOT NULL,
  `Marcador_JogadorEmCampo_Sigla_Pais` char(3) NOT NULL,
  `Marcador_JogadorEmCampo_Ano` smallint(6) NOT NULL,
  `Marcador_JogadorEmCampo_NumCamisola` tinyint(4) NOT NULL,
  `Assistencia_JogadorEmCampo_Jogo_numero` int(11) DEFAULT NULL,
  `Assistencia_JogadorEmCampo_Sigla_Pais` char(3) DEFAULT NULL,
  `Assistencia_JogadorEmCampo_Ano` smallint(6) DEFAULT NULL,
  `Assistencia_JogadorEmCampo_NumCamisola` tinyint(4) DEFAULT NULL,
  `Momento` time DEFAULT NULL,
  `Autogolo` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `golo`
--

INSERT INTO `golo` (`Jogo_Numero`, `Golo_Numero`, `Marcador_JogadorEmCampo_Jogo_numero`, `Marcador_JogadorEmCampo_Sigla_Pais`, `Marcador_JogadorEmCampo_Ano`, `Marcador_JogadorEmCampo_NumCamisola`, `Assistencia_JogadorEmCampo_Jogo_numero`, `Assistencia_JogadorEmCampo_Sigla_Pais`, `Assistencia_JogadorEmCampo_Ano`, `Assistencia_JogadorEmCampo_NumCamisola`, `Momento`, `Autogolo`) VALUES
(1, 1, 1, 'EQU', 2022, 13, NULL, NULL, NULL, NULL, '19:21:19', 0);

--
-- Acionadores `golo`
--
DELIMITER $$
CREATE TRIGGER `Atualizar_Total_Golos_No_Jogo` AFTER INSERT ON `golo` FOR EACH ROW BEGIN
    DECLARE total integer;

    SELECT COUNT(Golo_Numero) INTO total
    FROM golo
    WHERE golo.Jogo_Numero = new.Jogo_Numero;

    UPDATE jogo SET jogo.total_Golos = total
    WHERE jogo.Numero = new.Jogo_Numero;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Atualizar_golos_ e_assitencias_dos_jogadores` AFTER INSERT ON `golo` FOR EACH ROW BEGIN
	Declare total_golos integer;
    Declare total_assistencias integer;
    Declare total_golos2 integer;
    Declare total_assistencias2 integer;
    
    Select count(*) into total_golos
    from golo where 
    golo.Marcador_JogadorEmCampo_Sigla_Pais = new.Marcador_JogadorEmCampo_Sigla_Pais AND
    golo.Marcador_JogadorEmCampo_Ano = new.Marcador_JogadorEmCampo_Ano AND
    golo.Marcador_JogadorEmCampo_NumCamisola = new.Marcador_JogadorEmCampo_NumCamisola AND
    golo.Autogolo = '0';
     
    Select count(*) into total_assistencias
    from golo where 
  golo.Assistencia_JogadorEmCampo_Sigla_Pais = new.Assistencia_JogadorEmCampo_Sigla_Pais AND
    golo.Assistencia_JogadorEmCampo_Ano = new.Assistencia_JogadorEmCampo_Ano AND
    golo.Assistencia_JogadorEmCampo_NumCamisola = golo.Assistencia_JogadorEmCampo_NumCamisola AND
    golo.Autogolo = '0';        
      
   update jogadorselecao set NumGolos = total_golos where 
   jogadorselecao.Selecao_Sigla_Pais = new.Marcador_JogadorEmCampo_Sigla_Pais AND
   jogadorselecao.Selecao_Ano = new.Marcador_JogadorEmCampo_Ano AND
   jogadorselecao.NumCamisola = new.Marcador_JogadorEmCampo_NumCamisola; 
   
   update jogadorselecao set NumAssistencias = total_assistencias where 
   jogadorselecao.Selecao_Sigla_Pais = new.Assistencia_JogadorEmCampo_Sigla_Pais AND
   jogadorselecao.Selecao_Ano = new.Assistencia_JogadorEmCampo_Ano AND
   jogadorselecao.NumCamisola = new.Assistencia_JogadorEmCampo_NumCamisola; 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Atualizar_resultado_no_jogo` AFTER INSERT ON `golo` FOR EACH ROW BEGIN
	Declare selecao1 char(3);
    Declare selecao2 char(3);
    
    Declare total_golos_selecao1 integer(11);
    Declare total_golos_selecao2 integer(11);
   
    Declare nome_selecao1 varchar(60);
    Declare nome_selecao2 varchar(60);
    
    Select jogo.SelecaoParticipante_Sigla_Pais into selecao1
    from jogo
    where jogo.Numero = new.Jogo_Numero ;
    
    Select jogo.SelecaoParticipante2_Sigla_Pais into selecao2
    from jogo
    where jogo.Numero = new.Jogo_Numero;
    
    Select pais.Nome into nome_selecao1 
    from pais
    WHERE pais.Sigla = selecao1;
    
    Select pais.Nome into nome_selecao2 
   from pais
   WHERE pais.Sigla = selecao2;
    
    set total_golos_selecao1 = Golos_Marcados_Por_Selecao_Num_Jogo(new.Jogo_Numero, selecao1);
    
     set total_golos_selecao2 = Golos_Marcados_Por_Selecao_Num_Jogo(new.Jogo_Numero, selecao2);
     
     IF total_golos_selecao1 > total_golos_selecao2 THEN
     UPDATE jogo set resultado = nome_selecao1 
     where jogo.Numero = new.Jogo_Numero;
     
     	ELSEIF total_golos_selecao2 > total_golos_selecao1 THEN
        UPDATE jogo set resultado = nome_selecao2 
        where jogo.Numero = new.Jogo_Numero;
        
        ELSE
        UPDATE jogo set resultado = 'Empate';
     END IF;    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Autogolos_Nao_Possuem_Assistencia` BEFORE INSERT ON `golo` FOR EACH ROW BEGIN
    IF new.Autogolo != '0' THEN
    	IF new.Assistencia_JogadorEmCampo_Jogo_numero != NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Autogolos nao possuem assistencia';
        	ELSEIF new.Assistencia_JogadorEmCampo_Sigla_Pais != NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Autogolos nao possuem assistencia'; 
            	ELSE
                	IF new.Assistencia_JogadorEmCampo_Ano != NULL THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Autogolos nao possuem assistencia';
                    	ELSEIF new.Assistencia_JogadorEmCampo_NumCamisola THEN
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Autogolos nao possuem assistencia';
                     END IF;   
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Marcador_E_Assistencia_Estao_Sempre_No_Mesmo_Jogo` BEFORE INSERT ON `golo` FOR EACH ROW BEGIN
 IF new.Assistencia_JogadorEmCampo_Jogo_numero != NULL THEN
 	IF new.Marcador_JogadorEmCampo_Jogo_numero != new.Assistencia_JogadorEmCampo_Jogo_numero THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Os jogadores em questao estao a ser registados com jogos diferentes';
    	
        ELSEIF new.Marcador_JogadorEmCampo_Sigla_Pais != new.Assistencia_JogadorEmCampo_Sigla_Pais THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Os jogadores estao a ser registados com selecoes diferentes';
            ELSE 
            IF new.Marcador_JogadorEmCampo_Ano != new.Assistencia_JogadorEmCampo_Ano THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Os jogadores estao a ser registados com anos diferentes';
            	ELSEIF new.Marcador_JogadorEmCampo_NumCamisola = new.Assistencia_JogadorEmCampo_NumCamisola THEN
               SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Um jogador nao pode fazer uma assistencia a si mesmo';
               
            END IF;    
     END IF;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `grupo`
--

CREATE TABLE `grupo` (
  `Edicao_Ano` smallint(6) NOT NULL,
  `Letra` enum('A','B','C','D','E','F','G','H') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `grupo`
--

INSERT INTO `grupo` (`Edicao_Ano`, `Letra`) VALUES
(2022, 'A'),
(2022, 'B'),
(2022, 'C'),
(2022, 'D'),
(2022, 'E'),
(2022, 'F'),
(2022, 'G'),
(2022, 'H');

-- --------------------------------------------------------

--
-- Estrutura da tabela `jogadoremcampo`
--

CREATE TABLE `jogadoremcampo` (
  `Jogo_numero` int(11) NOT NULL,
  `JogadorSelecao_Sigla_Pais` char(3) NOT NULL,
  `JogadorSelecao_Ano` smallint(6) NOT NULL,
  `JogadorSelecao_NumCamisola` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `jogadoremcampo`
--

INSERT INTO `jogadoremcampo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) VALUES
(1, 'EQU', 2022, 13);

--
-- Acionadores `jogadoremcampo`
--
DELIMITER $$
CREATE TRIGGER `Atualizar_NumInternacionalizacoes` AFTER INSERT ON `jogadoremcampo` FOR EACH ROW BEGIN
	Declare total integer;
    Declare total1 integer;
                   
     Select NumInternacionalizacoes into total from jogadorselecao js where 
                   js.Selecao_Sigla_Pais = new.JogadorSelecao_Sigla_Pais AND js.Selecao_Ano = new.JogadorSelecao_Ano
                   AND
                   js.NumCamisola = new.JogadorSelecao_NumCamisola;
                   
     set total1 = total + '1';
    
    update jogadorselecao set NumInternacionalizacoes = total1 WHERE 
    jogadorselecao.Selecao_Sigla_Pais = new.JogadorSelecao_Sigla_Pais AND
    jogadorselecao.Selecao_Ano = new.JogadorSelecao_Ano AND
    jogadorselecao.NumCamisola = new.JogadorSelecao_NumCamisola;
    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Atualizar_Num_Jogos_Sem_Golos_Sofridos` AFTER INSERT ON `jogadoremcampo` FOR EACH ROW BEGIN
	Declare total integer;
    Declare total2 integer;
    
    set total = Total_Jogos_Sem_Golos_Sofridos(new.JogadorSelecao_Ano, new.JogadorSelecao_Sigla_Pais, new.JogadorSelecao_NumCamisola);
    
    set total2 = total - '1';
    
    update jogadorselecao set jogadorselecao.JogosSemGolosSofridos = total2 
    where jogadorselecao.Selecao_Sigla_Pais = new.JogadorSelecao_Sigla_Pais AND 
    jogadorselecao.Selecao_Ano = new.JogadorSelecao_Ano AND
    jogadorselecao.NumCamisola = new.JogadorSelecao_NumCamisola;
    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `JogadorEmCampo_Apenas_Pode_Ter_Estado_Convocado` BEFORE INSERT ON `jogadoremcampo` FOR EACH ROW BEGIN
	Declare estado varchar(60);
    
    Select EstadoJogador into estado from jogadorjogo where 
    jogadorjogo.Jogo_numero = new.Jogo_numero AND
    jogadorjogo.JogadorSelecao_Sigla_Pais = new.JogadorSelecao_Sigla_Pais AND jogadorjogo.JogadorSelecao_Ano = new.JogadorSelecao_Ano AND jogadorjogo.JogadorSelecao_NumCamisola = new.JogadorSelecao_NumCamisola;
    
    IF estado != 'convocado' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jogador nao pode entrar em campo pois nao foi convocado';
    END IF;
     
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `jogadorjogo`
--

CREATE TABLE `jogadorjogo` (
  `JogadorSelecao_Sigla_Pais` char(3) NOT NULL,
  `JogadorSelecao_Ano` smallint(6) NOT NULL,
  `JogadorSelecao_NumCamisola` tinyint(4) NOT NULL,
  `Jogo_numero` int(11) NOT NULL,
  `EstadoJogador` enum('convocado','dispensado','lesionado','castigado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `jogadorjogo`
--

INSERT INTO `jogadorjogo` (`JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`, `Jogo_numero`, `EstadoJogador`) VALUES
('EQU', 2022, 13, 1, 'convocado');

-- --------------------------------------------------------

--
-- Estrutura da tabela `jogadorselecao`
--

CREATE TABLE `jogadorselecao` (
  `NumeroSerie` smallint(6) NOT NULL,
  `Selecao_Sigla_Pais` char(3) NOT NULL,
  `Selecao_Ano` smallint(6) NOT NULL,
  `NumCamisola` tinyint(4) NOT NULL,
  `EstadoJogador` enum('Convocado','Dispensado','Lesionado','Castigado') NOT NULL,
  `PosicaoJogo` enum('guarda-redes','defesa','medio','avancado') NOT NULL,
  `NumGolos` tinyint(4) DEFAULT 0,
  `NumAssistencias` tinyint(4) DEFAULT 0,
  `JogosSemGolosSofridos` tinyint(4) DEFAULT 0,
  `NumPenalizacoes` tinyint(4) DEFAULT 0,
  `Comitiva_Sigla_Pais` char(3) NOT NULL,
  `Comitiva_Ano` smallint(6) NOT NULL,
  `NumInternacionalizacoes` smallint(6) DEFAULT 0,
  `Nome` varchar(60) NOT NULL,
  `DtNasc` date NOT NULL,
  `Sigla_Pais` char(3) NOT NULL,
  `Clube_Sigla` char(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `jogadorselecao`
--

INSERT INTO `jogadorselecao` (`NumeroSerie`, `Selecao_Sigla_Pais`, `Selecao_Ano`, `NumCamisola`, `EstadoJogador`, `PosicaoJogo`, `NumGolos`, `NumAssistencias`, `JogosSemGolosSofridos`, `NumPenalizacoes`, `Comitiva_Sigla_Pais`, `Comitiva_Ano`, `NumInternacionalizacoes`, `Nome`, `DtNasc`, `Sigla_Pais`, `Clube_Sigla`) VALUES
(1, 'EQU', 2022, 13, 'Convocado', 'avancado', 1, 0, 1, 1, 'EQU', 2022, 1, 'Enner Valencia', '1989-11-04', 'EQU', NULL);

--
-- Acionadores `jogadorselecao`
--
DELIMITER $$
CREATE TRIGGER `Ano_e_SiglaPais_Comitiva_Igual_na_Selecao` BEFORE INSERT ON `jogadorselecao` FOR EACH ROW BEGIN

	IF new.Selecao_Sigla_Pais != new.Comitiva_Sigla_Pais THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pais da comitiva deve ser o mesmo que o pais da selecao';
        
        ELSEIF new.Selecao_Ano != new.Comitiva_Ano THEN
            	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ano na comitiva deve ser o mesmo que o ano na selecao';
                
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Apenas_Pode_Representar_Uma_Selecao` BEFORE INSERT ON `jogadorselecao` FOR EACH ROW BEGIN
	Declare total integer;
    
    SELECT COUNT(*) INTO total FROM
    jogadorselecao where jogadorselecao.NumeroSerie = new.NumeroSerie AND
    jogadorselecao.Selecao_Sigla_Pais != new.Selecao_Sigla_Pais;
    
    IF total != '0'  THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O jogador ja representou uma selecao diferente logo nao pode mudar de selecao';
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `jogo`
--

CREATE TABLE `jogo` (
  `Grupo_Edicao_Ano` smallint(6) DEFAULT NULL,
  `Grupo_Letra` enum('A','B','C','D','E','F','G','H') DEFAULT NULL,
  `Estadio_Jogo_ID` int(11) DEFAULT NULL,
  `Numero` int(11) NOT NULL,
  `Fase` enum('Grupos','Oitavos','Quartos','Meias','Final') NOT NULL,
  `Data` date DEFAULT NULL,
  `Resultado` varchar(60) DEFAULT NULL,
  `SelecaoParticipante_Sigla_Pais` char(3) NOT NULL,
  `SelecaoParticipante_Ano` smallint(6) NOT NULL,
  `SelecaoParticipante2_Sigla_Pais` char(3) NOT NULL,
  `SelecaoParticipante2_Ano` smallint(6) NOT NULL,
  `total_Golos` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `jogo`
--

INSERT INTO `jogo` (`Grupo_Edicao_Ano`, `Grupo_Letra`, `Estadio_Jogo_ID`, `Numero`, `Fase`, `Data`, `Resultado`, `SelecaoParticipante_Sigla_Pais`, `SelecaoParticipante_Ano`, `SelecaoParticipante2_Sigla_Pais`, `SelecaoParticipante2_Ano`, `total_Golos`) VALUES
(2022, 'A', NULL, 1, 'Grupos', NULL, 'Equador', 'CAR', 2022, 'EQU', 2022, 0),
(2022, 'B', NULL, 2, 'Grupos', NULL, 'Empate', 'ING', 2022, 'IRN', 2022, 0);

--
-- Acionadores `jogo`
--
DELIMITER $$
CREATE TRIGGER `Grupo_Atribuido_Apenas_A_Jogos_Na_Fase_de_Grupos` BEFORE INSERT ON `jogo` FOR EACH ROW BEGIN
	Declare fase_nome varchar(60);
    
    SELECT Fase into fase_nome from jogo j where j.Numero = new.Numero;
    
	IF new.Fase != fase_nome AND new.Grupo_Letra != NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jogos fora da fase de grupo nao possuem um grupo atribuido';
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Grupo_No_Jogo_Igual_Grupo_Das_SelecoesParticipantes` BEFORE INSERT ON `jogo` FOR EACH ROW BEGIN
	Declare letra_grupo1  varchar(60);
    Declare letra_grupo2  varchar(60);

    SELECT Letra_Grupo into letra_grupo1 from selecao s where 
    s.Sigla_Pais = new.SelecaoParticipante_Sigla_Pais AND
    s.Ano = new.SelecaoParticipante_Ano;
    
    SELECT Letra_Grupo into letra_grupo2 from selecao s where 
    s.Sigla_Pais = new.SelecaoParticipante2_Sigla_Pais AND
    s.Ano = new.SelecaoParticipante2_Ano;

	IF new.Grupo_Letra != letra_grupo1 OR new.Grupo_Letra != letra_grupo2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Grupo atribuido ao jogo deve ser o mesmo que o grupo das selecoes que participam nesse jogo';
    
    ELSEIF new.Fase != 'Grupos' AND new.Grupo_Letra != NULL THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='O grupo deve ser atrbuido para jogos na fase de grupos';
    END IF;
    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Max_6_Jogos_Por_Grupo` BEFORE INSERT ON `jogo` FOR EACH ROW BEGIN
	Declare total integer;
    
    SELECT COUNT(*) into total FROM jogo
    where jogo.Grupo_Letra = new.Grupo_Letra AND
    jogo.Grupo_Edicao_Ano = new.Grupo_Edicao_Ano;
    
    IF total >= '6' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Apenas 6 jogos realizados por grupo';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Selecoes_Nao_Jogar_Contra_Si_Mesmas` BEFORE INSERT ON `jogo` FOR EACH ROW BEGIN
	IF new.SelecaoParticipante_Sigla_Pais = new.SelecaoParticipante2_Sigla_Pais THEN
	 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uma selecao nao pode jogar contra si mesma';
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Validacoes_relacionadas_com_repeticoes` BEFORE INSERT ON `jogo` FOR EACH ROW BEGIN
	Declare total integer;
    Declare total_jogos integer;
    Declare total_jogos2 integer;
    
    Select count(DISTINCT Numero) into total_jogos from jogo WHERE
    jogo.SelecaoParticipante_Sigla_Pais = new.SelecaoParticipante_Sigla_Pais AND 
    jogo.SelecaoParticipante_Ano = new.SelecaoParticipante_Ano OR  jogo.SelecaoParticipante2_Sigla_Pais = new.SelecaoParticipante_Sigla_Pais AND 
    jogo.SelecaoParticipante2_Ano = new.SelecaoParticipante_Ano ;
    
     Select count(DISTINCT Numero) into total_jogos2 from jogo WHERE
    jogo.SelecaoParticipante_Sigla_Pais = new.SelecaoParticipante2_Sigla_Pais AND 
    jogo.SelecaoParticipante_Ano = new.SelecaoParticipante2_Ano OR  jogo.SelecaoParticipante2_Sigla_Pais = new.SelecaoParticipante2_Sigla_Pais AND 
    jogo.SelecaoParticipante2_Ano = new.SelecaoParticipante2_Ano ;
    
    Select count(DISTINCT Numero) into total from jogo where jogo.SelecaoParticipante_Sigla_Pais =     new.SelecaoParticipante_Sigla_Pais AND 
    jogo.SelecaoParticipante_Ano = new.SelecaoParticipante_Ano AND
    jogo.SelecaoParticipante2_Sigla_Pais = new.SelecaoParticipante2_Sigla_Pais AND
    jogo.SelecaoParticipante2_Ano = new.SelecaoParticipante2_Ano;
    
    
    IF new.Grupo_Edicao_Ano != new.SelecaoParticipante_Ano 
    OR new.Grupo_Edicao_Ano != new.SelecaoParticipante2_Ano THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='O ano em que o jogo ocorre deve ser o mesmo que o das selecoes participantes nesse mesmo jogo';
       
       ELSEIF total_jogos >= '3' OR total_jogos2 >= '3' THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Cada selecao joga apenas 3 jogos por grupo';
        
    			ELSEIF new.Fase != 'Final' AND total != '0' THEN
          			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Este jogo ja ocorreu';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `outrafuncao`
--

CREATE TABLE `outrafuncao` (
  `OutraFuncao_ID` char(3) NOT NULL,
  `Funcao` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `outro`
--

CREATE TABLE `outro` (
  `NumeroSerie` smallint(6) NOT NULL,
  `Funcao` varchar(30) NOT NULL,
  `Comitiva_Sigla_Pais` char(3) NOT NULL,
  `Comitiva_Ano` smallint(6) NOT NULL,
  `DtNasc` date NOT NULL,
  `Nome` varchar(60) NOT NULL,
  `Sigla_Pais` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `pais`
--

CREATE TABLE `pais` (
  `Nome` varchar(60) NOT NULL,
  `Sigla` char(3) NOT NULL,
  `NumHabitantes` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `pais`
--

INSERT INTO `pais` (`Nome`, `Sigla`, `NumHabitantes`) VALUES
('Argentina', 'AGR', 45),
('Alemanha', 'ALE', 83),
('Austrália', 'AUS', 24),
('Bélgica', 'BEL', 11),
('Brasil', 'BRA', 215),
('Canadá', 'CAN', 37),
('Catar', 'CAR', 1),
('Camarões', 'CMR', 26),
('Costa Rica', 'CRC', 4),
('Croácia', 'CRO', 4),
('Dinamarca', 'DEN', 5),
('Equador', 'EQU', 17),
('Espanha', 'ESP', 46),
('Estados Unidos', 'EUA', 331),
('França', 'FRA', 65),
('Gana', 'GHA', 31),
('Holanda', 'HOL', 17),
('Inglaterra', 'ING', 55),
('irão', 'IRN', 83),
('Japão', 'JAP', 126),
('Repúblic da Coreia', 'KOR', 51),
('Arabia Saudita', 'KSA', 34),
('Marrocos', 'MAR', 36),
('México', 'MEX', 128),
('Polónia', 'POL', 37),
('Portugal', 'POR', 11),
('Qatar', 'QAT', 2),
('Senegal', 'SEN', 16),
('Suíça', 'SUI', 8),
('Tunísia', 'TUN', 11),
('Pais de Gales', 'WAL', 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `patrocinador`
--

CREATE TABLE `patrocinador` (
  `Sigla` char(4) NOT NULL,
  `Patrocinador_Nome` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `patrocinador`
--

INSERT INTO `patrocinador` (`Sigla`, `Patrocinador_Nome`) VALUES
('ADID', 'Adidas'),
('BUD_', 'Budweiser'),
('COLA', 'Coca-cola'),
('HISE', 'Hisense'),
('KIA_', 'Hyundai Motors'),
('NIKE', 'Nike'),
('PUMA', 'Puma'),
('QATA', 'Qatar Airways'),
('VISA', 'Visa'),
('XERO', 'Xero');

-- --------------------------------------------------------

--
-- Estrutura da tabela `patrocinio`
--

CREATE TABLE `patrocinio` (
  `Comitiva_Sigla_Pais` char(3) NOT NULL,
  `Comitiva_Ano` smallint(6) NOT NULL,
  `Patrocinador_Sigla` char(4) NOT NULL,
  `Montante` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `patrocinio`
--

INSERT INTO `patrocinio` (`Comitiva_Sigla_Pais`, `Comitiva_Ano`, `Patrocinador_Sigla`, `Montante`) VALUES
('AGR', 2022, 'ADID', 1000000),
('HOL', 2022, 'VISA', 2222);

-- --------------------------------------------------------

--
-- Estrutura da tabela `penalizacao`
--

CREATE TABLE `penalizacao` (
  `Jogo_Numero` int(11) NOT NULL,
  `NumeroCartao` tinyint(4) NOT NULL,
  `Momento` time DEFAULT NULL,
  `Amarelo` tinyint(1) DEFAULT 0,
  `Vermelho` tinyint(1) DEFAULT 0,
  `JogadorEmCampo_Jogo_numero` int(11) NOT NULL,
  `JogadorEmCampo_Sigla_Pais` char(3) NOT NULL,
  `JogadorEmCampo_Ano` smallint(6) NOT NULL,
  `JogadorEmCampo_NumCamisola` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `penalizacao`
--

INSERT INTO `penalizacao` (`Jogo_Numero`, `NumeroCartao`, `Momento`, `Amarelo`, `Vermelho`, `JogadorEmCampo_Jogo_numero`, `JogadorEmCampo_Sigla_Pais`, `JogadorEmCampo_Ano`, `JogadorEmCampo_NumCamisola`) VALUES
(1, 1, '18:43:35', 1, 0, 1, 'EQU', 2022, 13);

--
-- Acionadores `penalizacao`
--
DELIMITER $$
CREATE TRIGGER `2_Amarelos_Equivale_A_UM_Cartao_Vermelho` AFTER INSERT ON `penalizacao` FOR EACH ROW BEGIN
	Declare total_amarelos integer;
    Declare numero_cartao integer;
    
    set numero_cartao = new.NumeroCartao + '1';
    
    Select count(*) into total_amarelos
    from penalizacao WHERE
    penalizacao.Jogo_Numero = new.Jogo_Numero AND
    penalizacao.JogadorEmCampo_Sigla_Pais = new.JogadorEmCampo_Sigla_Pais AND
    penalizacao.JogadorEmCampo_Ano = new.JogadorEmCampo_Ano AND
    penalizacao.JogadorEmCampo_NumCamisola = new.JogadorEmCampo_NumCamisola;
    
    if total_amarelos = '2' THEN
    INSERT into penalizacao values (new.Jogo_Numero, numero_cartao, NULL, '0', '1', new.JogadorEmCampo_Jogo_numero, new.JogadorEmCampo_Sigla_Pais, new.JogadorEmCampo_Ano, new.JogadorEmCampo_NumCamisola);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Atualizar_Estado_JogadorJogo_Caso_Receber_Vermelho` AFTER INSERT ON `penalizacao` FOR EACH ROW BEGIN
 	If new.Vermelho != '0' THEN
     update jogadorjogo set EstadoJogador = 'castigado' where jogadorjogo.JogadorSelecao_Sigla_Pais = new.JogadorEmCampo_Sigla_Pais AND
        jogadorjogo.JogadorSelecao_Ano = new.JogadorEmCampo_Ano AND
        jogadorjogo.JogadorSelecao_NumCamisola = new.JogadorEmCampo_NumCamisola;
    END IF;
 END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Atualizar_Num_Penalizacoes` AFTER INSERT ON `penalizacao` FOR EACH ROW BEGIN
	Declare total integer;
    
    set total = Num_Penalizacoes(new.JogadorEmCampo_Ano, new.JogadorEmCampo_Sigla_Pais, new.JogadorEmCampo_NumCamisola);
    
    update jogadorselecao set NumPenalizacoes = total WHERE
    jogadorselecao.Selecao_Ano = new.JogadorEmCampo_Ano AND
    jogadorselecao.Selecao_Sigla_Pais = new.JogadorEmCampo_Sigla_Pais AND 
    jogadorselecao.NumCamisola = new.JogadorEmCampo_NumCamisola;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Penalizacao_Apenas_Vermelho_Ou_Amarelo_E_Max_2_Amarelos_Jogador` BEFORE INSERT ON `penalizacao` FOR EACH ROW BEGIN
	Declare total_cartoesvermelhos integer;
    Declare total_amarelos integer;
    
    SELECT count(*) into total_cartoesvermelhos
    from penalizacao WHERE
    penalizacao.Jogo_Numero = new.Jogo_Numero AND
    penalizacao.JogadorEmCampo_Sigla_Pais = new.JogadorEmCampo_Sigla_Pais AND
    penalizacao.JogadorEmCampo_Ano = new.JogadorEmCampo_Ano AND
    penalizacao.JogadorEmCampo_NumCamisola = new.JogadorEmCampo_NumCamisola AND
    new.Vermelho != '0';
    
    Select count(*) into total_amarelos
    from penalizacao WHERE
    penalizacao.Jogo_Numero = new.Jogo_Numero AND
    penalizacao.JogadorEmCampo_Sigla_Pais = new.JogadorEmCampo_Sigla_Pais AND
    penalizacao.JogadorEmCampo_Ano = new.JogadorEmCampo_Ano AND
    penalizacao.JogadorEmCampo_NumCamisola = new.JogadorEmCampo_NumCamisola;
    
    IF total_amarelos = '2' then
    	IF new.Amarelo != '0' then
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este jogador ja tem 2 amarelos e foi expulso';
        END IF;
    END IF;
    
    IF new.Vermelho != '0' THEN
    	IF total_cartoesvermelhos > '0' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uma jogador apenas pode receber 1 cartao vermelho';
    	END IF;
    END IF;
    
	IF new.Amarelo != '0' THEN
        IF new.Vermelho != '0' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uma penalizacao apenas pode corresponder a um cartao vermelho ou a um cartao amarelo';
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `presidentefederacao`
--

CREATE TABLE `presidentefederacao` (
  `AnoNomeacao` smallint(6) NOT NULL,
  `NumeroSerie` smallint(6) NOT NULL,
  `Comitiva_Sigla_Pais` char(3) NOT NULL,
  `Comitiva_Ano` smallint(6) NOT NULL,
  `DtNasc` date NOT NULL,
  `Nome` varchar(60) NOT NULL,
  `Sigla_Pais` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `selecao`
--

CREATE TABLE `selecao` (
  `Sigla_Pais` char(3) NOT NULL,
  `Ano` smallint(6) NOT NULL,
  `Letra_Grupo` enum('A','B','C','D','E','F','G','H') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `selecao`
--

INSERT INTO `selecao` (`Sigla_Pais`, `Ano`, `Letra_Grupo`) VALUES
('CAR', 2022, 'A'),
('EQU', 2022, 'A'),
('HOL', 2022, 'A'),
('SEN', 2022, 'A'),
('EUA', 2022, 'B'),
('ING', 2022, 'B'),
('IRN', 2022, 'B'),
('WAL', 2022, 'B'),
('AGR', 2022, 'C'),
('KSA', 2022, 'C'),
('MEX', 2022, 'C'),
('POL', 2022, 'C'),
('AUS', 2022, 'D'),
('DEN', 2022, 'D'),
('FRA', 2022, 'D'),
('TUN', 2022, 'D'),
('ALE', 2022, 'E'),
('CRC', 2022, 'E'),
('ESP', 2022, 'E'),
('JAP', 2022, 'E'),
('BEL', 2022, 'F'),
('CAN', 2022, 'F'),
('CRO', 2022, 'F'),
('MAR', 2022, 'F');

--
-- Acionadores `selecao`
--
DELIMITER $$
CREATE TRIGGER `Atualizar_NumSelecoesParticipantes_Na_Respetiva_Edicao` AFTER INSERT ON `selecao` FOR EACH ROW BEGIN
	Declare total_selecoes integer;
    
    set total_selecoes = ( (Select count(*) from selecao where selecao.Ano = new.Ano));
    
	UPDATE edicao set NumSelecoesParticipantes = total_selecoes where edicao.Ano = new.Ano;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Max_4_Selecoes_Por_Grupo` BEFORE INSERT ON `selecao` FOR EACH ROW BEGIN
 	Declare total integer;
 
 	SELECT count(*) into total from selecao WHERE
    selecao.Ano = new.Ano AND selecao.Letra_Grupo = new.Letra_Grupo;
    
    IF total >= '4' THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximo de 4 selecoes por grupo';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Maximo_32_Selecoes_Por_Edicao_de_Mundial` BEFORE INSERT ON `selecao` FOR EACH ROW BEGIN
Declare total_selecoes integer;
          
select NumSelecoesParticipantes into total_selecoes from edicao
where edicao.Ano = new.Ano;

	 IF total_selecoes >= '32' THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Maximo de 32 selecoes por edicao de mundial';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `substituicao`
--

CREATE TABLE `substituicao` (
  `Substituido_Jogo_numero` int(11) NOT NULL,
  `Substituido_JogadorSelecao_Sigla_Pais` char(3) NOT NULL,
  `Substituido_JogadorSelecao_Ano` smallint(6) NOT NULL,
  `Substituido_JogadorSelecao_NumCamisola` tinyint(4) NOT NULL,
  `Substituto_Jogo_numero` int(11) NOT NULL,
  `Substituto_JogadorSelecao_Sigla_Pais` char(3) NOT NULL,
  `Substituto_JogadorSelecao_Ano` smallint(6) NOT NULL,
  `Substituto_JogadorSelecao_NumCamisola` tinyint(4) NOT NULL,
  `Momento` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Acionadores `substituicao`
--
DELIMITER $$
CREATE TRIGGER `Validacoes_Importantes` BEFORE INSERT ON `substituicao` FOR EACH ROW BEGIN
	IF new.Substituido_JogadorSelecao_Sigla_Pais != new.Substituto_JogadorSelecao_Sigla_Pais THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Os jogadores devem pertencer à mesma selecao';
     	ELSEIF new.Substituido_JogadorSelecao_Ano != new.Substituto_JogadorSelecao_Ano THEN
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Os jogadores devem pertencer à mesma selecao no mesmo ano';
         	ELSEIF new.Substituido_JogadorSelecao_NumCamisola = new.Substituto_JogadorSelecao_NumCamisola THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Um jogador nao pode substituir-se a si mesmo';
      END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tecnico`
--

CREATE TABLE `tecnico` (
  `NumeroSerie` smallint(6) NOT NULL,
  `Comitiva_Sigla_Pais` char(3) NOT NULL,
  `Comitiva_Ano` smallint(6) NOT NULL,
  `Funcao` varchar(60) NOT NULL,
  `AnosExperiencia` tinyint(4) DEFAULT 0,
  `DtNasc` date NOT NULL,
  `Nome` varchar(60) NOT NULL,
  `Sigla_Pais_Tecnico` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `tecnico`
--

INSERT INTO `tecnico` (`NumeroSerie`, `Comitiva_Sigla_Pais`, `Comitiva_Ano`, `Funcao`, `AnosExperiencia`, `DtNasc`, `Nome`, `Sigla_Pais_Tecnico`) VALUES
(1, 'AGR', 2022, 'fisioterapeuta', 0, '1885-02-05', 'neur', 'ARG');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `clubefutebol`
--
ALTER TABLE `clubefutebol`
  ADD PRIMARY KEY (`Sigla`),
  ADD UNIQUE KEY `UQ_NOMECLUBE` (`NomeClube`);

--
-- Índices para tabela `comitiva`
--
ALTER TABLE `comitiva`
  ADD PRIMARY KEY (`Sigla_Pais`,`Ano`),
  ADD KEY `FK_Comitiva___Edicao` (`Ano`),
  ADD KEY `FK_Comitiva__PatrocinadorOficial___Patrocinador` (`Patrocinador_Oficial_sigla`);

--
-- Índices para tabela `edicao`
--
ALTER TABLE `edicao`
  ADD PRIMARY KEY (`Ano`),
  ADD KEY `FK_Edicao_Organizador_1_Pais` (`Organizador_1`),
  ADD KEY `FK_Edicao_Organizador_2_Pais` (`Organizador_2`);

--
-- Índices para tabela `estadio`
--
ALTER TABLE `estadio`
  ADD PRIMARY KEY (`Estadio_ID`),
  ADD UNIQUE KEY `UW_NomeEstadio` (`Nome`),
  ADD KEY `FK_Estadio__Sigla_Pais` (`Sigla_Pais`);

--
-- Índices para tabela `federacao`
--
ALTER TABLE `federacao`
  ADD PRIMARY KEY (`Federacao_ID`),
  ADD UNIQUE KEY `UQ_Nome` (`Nome`),
  ADD KEY `FK_Federecao_Sigla_Pais` (`Sigla_Pais`);

--
-- Índices para tabela `funcaotecnico`
--
ALTER TABLE `funcaotecnico`
  ADD PRIMARY KEY (`FuncaoTecnica_ID`),
  ADD UNIQUE KEY `UQ_Funcao` (`Funcao`);

--
-- Índices para tabela `golo`
--
ALTER TABLE `golo`
  ADD PRIMARY KEY (`Jogo_Numero`,`Golo_Numero`),
  ADD KEY `FK_Golo___Marcador_JogadorEmCampo` (`Marcador_JogadorEmCampo_Jogo_numero`,`Marcador_JogadorEmCampo_Sigla_Pais`,`Marcador_JogadorEmCampo_Ano`,`Marcador_JogadorEmCampo_NumCamisola`),
  ADD KEY `FK_Golo_Assitencia_JogadorEmCampo` (`Assistencia_JogadorEmCampo_Jogo_numero`,`Assistencia_JogadorEmCampo_Sigla_Pais`,`Assistencia_JogadorEmCampo_Ano`,`Assistencia_JogadorEmCampo_NumCamisola`);

--
-- Índices para tabela `grupo`
--
ALTER TABLE `grupo`
  ADD PRIMARY KEY (`Edicao_Ano`,`Letra`),
  ADD UNIQUE KEY `UQ_GrupoLetra` (`Letra`);

--
-- Índices para tabela `jogadoremcampo`
--
ALTER TABLE `jogadoremcampo`
  ADD PRIMARY KEY (`Jogo_numero`,`JogadorSelecao_Sigla_Pais`,`JogadorSelecao_Ano`,`JogadorSelecao_NumCamisola`);

--
-- Índices para tabela `jogadorjogo`
--
ALTER TABLE `jogadorjogo`
  ADD PRIMARY KEY (`JogadorSelecao_Sigla_Pais`,`JogadorSelecao_Ano`,`JogadorSelecao_NumCamisola`,`Jogo_numero`),
  ADD KEY `FK_JogadorJogo___Jogo` (`Jogo_numero`);

--
-- Índices para tabela `jogadorselecao`
--
ALTER TABLE `jogadorselecao`
  ADD PRIMARY KEY (`Selecao_Sigla_Pais`,`Selecao_Ano`,`NumCamisola`,`NumeroSerie`),
  ADD KEY `FK_JogadorSelecao_Comitiva` (`Comitiva_Ano`,`Comitiva_Sigla_Pais`),
  ADD KEY `FK_Naturalidade` (`Sigla_Pais`),
  ADD KEY `FK_Jogador__ClubFutebol` (`Clube_Sigla`);

--
-- Índices para tabela `jogo`
--
ALTER TABLE `jogo`
  ADD PRIMARY KEY (`Numero`),
  ADD KEY `FK_Jogo___Grupo` (`Grupo_Edicao_Ano`,`Grupo_Letra`),
  ADD KEY `FK_Jogo___Estadio` (`Estadio_Jogo_ID`),
  ADD KEY `FK_SelecaoParticipante_Selecao` (`SelecaoParticipante2_Ano`,`SelecaoParticipante2_Sigla_Pais`),
  ADD KEY `FK_SelecaoParticipante2_Selecao` (`SelecaoParticipante_Ano`,`SelecaoParticipante_Sigla_Pais`);

--
-- Índices para tabela `outrafuncao`
--
ALTER TABLE `outrafuncao`
  ADD PRIMARY KEY (`OutraFuncao_ID`),
  ADD UNIQUE KEY `UQ_Funcao` (`Funcao`);

--
-- Índices para tabela `outro`
--
ALTER TABLE `outro`
  ADD PRIMARY KEY (`NumeroSerie`),
  ADD UNIQUE KEY `UQ_Nome` (`Nome`),
  ADD UNIQUE KEY `UQ_DtNasc` (`DtNasc`),
  ADD KEY `FK_Outro___Comitiva` (`Comitiva_Ano`,`Comitiva_Sigla_Pais`),
  ADD KEY `FK_Outro_OutraFuncao` (`Funcao`),
  ADD KEY `FK_Pais__Nascimento` (`Sigla_Pais`);

--
-- Índices para tabela `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`Sigla`),
  ADD UNIQUE KEY `UQ_NOME` (`Nome`);

--
-- Índices para tabela `patrocinador`
--
ALTER TABLE `patrocinador`
  ADD PRIMARY KEY (`Sigla`),
  ADD UNIQUE KEY `UQ_Nome` (`Patrocinador_Nome`);

--
-- Índices para tabela `patrocinio`
--
ALTER TABLE `patrocinio`
  ADD PRIMARY KEY (`Comitiva_Sigla_Pais`,`Comitiva_Ano`,`Patrocinador_Sigla`),
  ADD KEY `FK_Patrocinador_Patrocinio_Comitiva_` (`Patrocinador_Sigla`);

--
-- Índices para tabela `penalizacao`
--
ALTER TABLE `penalizacao`
  ADD PRIMARY KEY (`Jogo_Numero`,`NumeroCartao`),
  ADD KEY `FK_Penalizacao_JogadorEmCampo` (`JogadorEmCampo_Jogo_numero`,`JogadorEmCampo_Sigla_Pais`,`JogadorEmCampo_Ano`,`JogadorEmCampo_NumCamisola`);

--
-- Índices para tabela `presidentefederacao`
--
ALTER TABLE `presidentefederacao`
  ADD PRIMARY KEY (`NumeroSerie`),
  ADD UNIQUE KEY `UQ_Nome` (`Nome`),
  ADD KEY `FK_PresidenteFederacao_Comitiva` (`Comitiva_Ano`,`Comitiva_Sigla_Pais`),
  ADD KEY `FK_Pais__Nascença` (`Sigla_Pais`);

--
-- Índices para tabela `selecao`
--
ALTER TABLE `selecao`
  ADD PRIMARY KEY (`Sigla_Pais`,`Ano`),
  ADD KEY `FK_Selecao_Ano` (`Ano`),
  ADD KEY `FK_Selecao_Grupo` (`Letra_Grupo`);

--
-- Índices para tabela `substituicao`
--
ALTER TABLE `substituicao`
  ADD PRIMARY KEY (`Substituido_Jogo_numero`,`Substituido_JogadorSelecao_Sigla_Pais`,`Substituido_JogadorSelecao_Ano`,`Substituido_JogadorSelecao_NumCamisola`,`Substituto_Jogo_numero`,`Substituto_JogadorSelecao_Sigla_Pais`,`Substituto_JogadorSelecao_Ano`,`Substituto_JogadorSelecao_NumCamisola`),
  ADD KEY `FK_Substituicao___substituto_JogadorEmCampo` (`Substituto_Jogo_numero`,`Substituto_JogadorSelecao_Sigla_Pais`,`Substituto_JogadorSelecao_Ano`,`Substituto_JogadorSelecao_NumCamisola`);

--
-- Índices para tabela `tecnico`
--
ALTER TABLE `tecnico`
  ADD PRIMARY KEY (`NumeroSerie`),
  ADD UNIQUE KEY `UQ_Nome` (`Nome`),
  ADD KEY `FK_Tecnico_Comitiva` (`Comitiva_Ano`,`Comitiva_Sigla_Pais`),
  ADD KEY `FK_Tecnico_FuncaoTecnico` (`Funcao`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `estadio`
--
ALTER TABLE `estadio`
  MODIFY `Estadio_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `jogo`
--
ALTER TABLE `jogo`
  MODIFY `Numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `outro`
--
ALTER TABLE `outro`
  MODIFY `NumeroSerie` smallint(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `presidentefederacao`
--
ALTER TABLE `presidentefederacao`
  MODIFY `NumeroSerie` smallint(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tecnico`
--
ALTER TABLE `tecnico`
  MODIFY `NumeroSerie` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `comitiva`
--
ALTER TABLE `comitiva`
  ADD CONSTRAINT `FK_Comitiva__PatrocinadorOficial___Patrocinador` FOREIGN KEY (`Patrocinador_Oficial_sigla`) REFERENCES `patrocinador` (`Sigla`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Comitiva___Edicao` FOREIGN KEY (`Ano`) REFERENCES `edicao` (`Ano`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Comitiva___Pais` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `edicao`
--
ALTER TABLE `edicao`
  ADD CONSTRAINT `FK_Edicao_Organizador_1_Pais` FOREIGN KEY (`Organizador_1`) REFERENCES `federacao` (`Sigla_Pais`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Edicao_Organizador_2_Pais` FOREIGN KEY (`Organizador_2`) REFERENCES `federacao` (`Sigla_Pais`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estadio`
--
ALTER TABLE `estadio`
  ADD CONSTRAINT `FK_Estadio__Sigla_Pais` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `federacao`
--
ALTER TABLE `federacao`
  ADD CONSTRAINT `FK_Federecao_Sigla_Pais` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `golo`
--
ALTER TABLE `golo`
  ADD CONSTRAINT `FK_Golo_Assitencia_JogadorEmCampo` FOREIGN KEY (`Assistencia_JogadorEmCampo_Jogo_numero`,`Assistencia_JogadorEmCampo_Sigla_Pais`,`Assistencia_JogadorEmCampo_Ano`,`Assistencia_JogadorEmCampo_NumCamisola`) REFERENCES `jogadoremcampo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Golo__Jogo` FOREIGN KEY (`Jogo_Numero`) REFERENCES `jogo` (`Numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Golo___Marcador_JogadorEmCampo` FOREIGN KEY (`Marcador_JogadorEmCampo_Jogo_numero`,`Marcador_JogadorEmCampo_Sigla_Pais`,`Marcador_JogadorEmCampo_Ano`,`Marcador_JogadorEmCampo_NumCamisola`) REFERENCES `jogadoremcampo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `grupo`
--
ALTER TABLE `grupo`
  ADD CONSTRAINT `FK_EdicaoAno_Edicao` FOREIGN KEY (`Edicao_Ano`) REFERENCES `edicao` (`Ano`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `jogadoremcampo`
--
ALTER TABLE `jogadoremcampo`
  ADD CONSTRAINT `FK_JogadorEmCampo___JogadorJogo` FOREIGN KEY (`Jogo_numero`,`JogadorSelecao_Sigla_Pais`,`JogadorSelecao_Ano`,`JogadorSelecao_NumCamisola`) REFERENCES `jogadorjogo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `jogadorjogo`
--
ALTER TABLE `jogadorjogo`
  ADD CONSTRAINT `FK_JogadorJogo___Jogador` FOREIGN KEY (`JogadorSelecao_Sigla_Pais`,`JogadorSelecao_Ano`,`JogadorSelecao_NumCamisola`) REFERENCES `jogadorselecao` (`Selecao_Sigla_Pais`, `Selecao_Ano`, `NumCamisola`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_JogadorJogo___Jogo` FOREIGN KEY (`Jogo_numero`) REFERENCES `jogo` (`Numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `jogadorselecao`
--
ALTER TABLE `jogadorselecao`
  ADD CONSTRAINT `FK_JogadorSelecao_Comitiva` FOREIGN KEY (`Comitiva_Ano`,`Comitiva_Sigla_Pais`) REFERENCES `comitiva` (`Ano`, `Sigla_Pais`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_JogadorSelecao___Selecao` FOREIGN KEY (`Selecao_Sigla_Pais`,`Selecao_Ano`) REFERENCES `selecao` (`Sigla_Pais`, `Ano`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jogador__ClubFutebol` FOREIGN KEY (`Clube_Sigla`) REFERENCES `clubefutebol` (`Sigla`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Naturalidade` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `jogo`
--
ALTER TABLE `jogo`
  ADD CONSTRAINT `FK_Jogo___Estadio` FOREIGN KEY (`Estadio_Jogo_ID`) REFERENCES `estadio` (`Estadio_ID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jogo___Grupo` FOREIGN KEY (`Grupo_Edicao_Ano`,`Grupo_Letra`) REFERENCES `grupo` (`Edicao_Ano`, `Letra`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_SelecaoParticipante2_Selecao` FOREIGN KEY (`SelecaoParticipante_Ano`,`SelecaoParticipante_Sigla_Pais`) REFERENCES `selecao` (`Ano`, `Sigla_Pais`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_SelecaoParticipante_Selecao` FOREIGN KEY (`SelecaoParticipante2_Ano`,`SelecaoParticipante2_Sigla_Pais`) REFERENCES `selecao` (`Ano`, `Sigla_Pais`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `outro`
--
ALTER TABLE `outro`
  ADD CONSTRAINT `FK_Outro_OutraFuncao` FOREIGN KEY (`Funcao`) REFERENCES `outrafuncao` (`Funcao`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Outro___Comitiva` FOREIGN KEY (`Comitiva_Ano`,`Comitiva_Sigla_Pais`) REFERENCES `comitiva` (`Ano`, `Sigla_Pais`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Pais__Nascimento` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `patrocinio`
--
ALTER TABLE `patrocinio`
  ADD CONSTRAINT `FK_Comitiva_Patrocinio_Patrocinador_` FOREIGN KEY (`Comitiva_Sigla_Pais`,`Comitiva_Ano`) REFERENCES `comitiva` (`Sigla_Pais`, `Ano`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Patrocinador_Patrocinio_Comitiva_` FOREIGN KEY (`Patrocinador_Sigla`) REFERENCES `patrocinador` (`Sigla`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `penalizacao`
--
ALTER TABLE `penalizacao`
  ADD CONSTRAINT `FK_Penalizacao_JogadorEmCampo` FOREIGN KEY (`JogadorEmCampo_Jogo_numero`,`JogadorEmCampo_Sigla_Pais`,`JogadorEmCampo_Ano`,`JogadorEmCampo_NumCamisola`) REFERENCES `jogadoremcampo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Penalizacao_Jogo` FOREIGN KEY (`Jogo_Numero`) REFERENCES `jogo` (`Numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `presidentefederacao`
--
ALTER TABLE `presidentefederacao`
  ADD CONSTRAINT `FK_Pais__Nascença` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`),
  ADD CONSTRAINT `FK_PresidenteFederacao_Comitiva` FOREIGN KEY (`Comitiva_Ano`,`Comitiva_Sigla_Pais`) REFERENCES `comitiva` (`Ano`, `Sigla_Pais`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `selecao`
--
ALTER TABLE `selecao`
  ADD CONSTRAINT `FK_Selecao_Ano` FOREIGN KEY (`Ano`) REFERENCES `edicao` (`Ano`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Selecao_Grupo` FOREIGN KEY (`Letra_Grupo`) REFERENCES `grupo` (`Letra`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Selecao_Sigla_Pais` FOREIGN KEY (`Sigla_Pais`) REFERENCES `pais` (`Sigla`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `substituicao`
--
ALTER TABLE `substituicao`
  ADD CONSTRAINT `FK_Substituicao___substituido_JogadorEmCampo` FOREIGN KEY (`Substituido_Jogo_numero`,`Substituido_JogadorSelecao_Sigla_Pais`,`Substituido_JogadorSelecao_Ano`,`Substituido_JogadorSelecao_NumCamisola`) REFERENCES `jogadoremcampo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Substituicao___substituto_JogadorEmCampo` FOREIGN KEY (`Substituto_Jogo_numero`,`Substituto_JogadorSelecao_Sigla_Pais`,`Substituto_JogadorSelecao_Ano`,`Substituto_JogadorSelecao_NumCamisola`) REFERENCES `jogadoremcampo` (`Jogo_numero`, `JogadorSelecao_Sigla_Pais`, `JogadorSelecao_Ano`, `JogadorSelecao_NumCamisola`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tecnico`
--
ALTER TABLE `tecnico`
  ADD CONSTRAINT `FK_Tecnico_Comitiva` FOREIGN KEY (`Comitiva_Ano`,`Comitiva_Sigla_Pais`) REFERENCES `comitiva` (`Ano`, `Sigla_Pais`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Tecnico_FuncaoTecnico` FOREIGN KEY (`Funcao`) REFERENCES `funcaotecnico` (`Funcao`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
